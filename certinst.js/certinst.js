const rfc = require('node-rfc');
const fs = require('fs');
const path = require('path');
const { promisify } = require('util');
const readFileAsync = promisify( fs.readFile );
const { spawn } = require('child_process');

const abapSystem = {
    user: 'sap*',
    passwd: 'Down1oad',
    ashost: 'localhost', // vhcalnplci
    sysnr: '00',
    client: '001'
};

// function invokeRfc(fnName, params) {
//   return new Promise((resolve, reject) => {
//     const client = new rfc.Client(abapSystem);
//     // console.log('RFC client lib version: ', client.getVersion());

//     client.connect(function(err) {
//         if (err) reject(err);
//         client.invoke(fnName, params, (err, res) => {
//             if (err) reject(err);
//             resolve(res);
//         });
//     });
//   });
// }

// async function testConnectionOld() {
//     try {
//         const res = await invokeRfc('STFC_CONNECTION', { REQUTEXT: 'Hello SAP!' });
//         console.log('Result STFC_CONNECTION:', res);
//     } catch(err) {
//         console.error('Error invoking STFC_CONNECTION:', err);
//     }
// }

async function callRfc(fmName, params, isVerbose = false) {
    const client = new rfc.Client(abapSystem);
    if (isVerbose) console.log('RFC client lib version: ', client.version);

    await client.open();
    const res = await client.call(fmName, params);
    await client.close();
    return res;
}

async function testConnection(isVerbose = true) {
    try {
        const res = await callRfc('STFC_CONNECTION', { REQUTEXT: 'Hello SAP!' }, isVerbose);
        res.RESPTEXT = res.RESPTEXT.replace(/\s{2,}/g, ' '); // condense
        if (isVerbose) console.log('STFC_CONNECTION response:', res);
        return true;
    } catch (error) {
        if (isVerbose) console.error('Error invoking STFC_CONNECTION:', error);
        return false;
    }
}

function spawnOpenssl(buf) {
    return new Promise((resolve, rejest) => {
        const openssl = spawn('openssl', ['x509', '-inform', 'der', '-noout', '-subject']); //, '-in', 'cert.cer']);

        let output = '';
        openssl.stdout.on('data', (data) => { output += data });
        openssl.stderr.on('data', (data) => { console.log(`openssl error: ${data}`) });
        openssl.on('close', (code) => resolve(output));

        openssl.stdin.write(buf);
        openssl.stdin.end();
    });
}

async function listCertificates(isVerbose = true) {
    try {
        const res = await callRfc('SSFR_GET_CERTIFICATELIST', {
            IS_STRUST_IDENTITY: { PSE_CONTEXT: 'SSLC', PSE_APPLIC: 'ANONYM' }
        });
        if (isVerbose) {
            console.log(`SSFR_GET_CERTIFICATELIST returned ${res.ET_CERTIFICATELIST.length} certificates`);
            let num = 0;
            for (const cert of res.ET_CERTIFICATELIST) {
                const certCN = await spawnOpenssl(cert);
                console.log(`  ${++num}:`, certCN.replace('\n', ''));
            }
        }
        return res.ET_CERTIFICATELIST.length;
    } catch(err) {
        if (isVerbose) console.error('Error invoking SSFR_GET_CERTIFICATELIST:', err);
        return -1;
    }
}

function getCertFiles(dir) {
    const files = fs.readdirSync(dir).filter(f => /\.cer$/.test(f));
    return files.map(f => path.join(dir, f));
}

async function installCertificates(dir) {
    
    const files = getCertFiles(dir);

    try {
        const res = await callRfc('SSFR_PSE_CHECK', { IS_STRUST_IDENTITY: { PSE_CONTEXT: 'SSLC', PSE_APPLIC: 'ANONYM' } });
        console.log('Result SSFR_PSE_CHECK:', res.ET_BAPIRET2[0].TYPE, res.ET_BAPIRET2[0].MESSAGE);
    } catch(err) {
        console.error('Error invoking SSFR_PSE_CHECK:', err);
    }

    const certsBefore = await listCertificates(false);
    console.log('Certificates before installation:', certsBefore);

    for (const file of files) {
        try {
            const certBlob = await readFileAsync(file);
            const res = await callRfc('SSFR_PUT_CERTIFICATE', {
                IS_STRUST_IDENTITY: { PSE_CONTEXT: 'SSLC', PSE_APPLIC: 'ANONYM' },
                IV_CERTIFICATE: certBlob,
            });
            // console.log('Result SSFR_PUT_CERTIFICATE:', res);
            console.log(file, '- OK');
        } catch(err) {
            // console.error('Error invoking SSFR_PUT_CERTIFICATE:', err);
            console.log(file, '- FAILED');
        }
    }

    const certsAfter = await listCertificates(false);
    console.log('Certificates after installation:', certsAfter);
}


async function main() {
    const command = process.argv[2] ? process.argv[2].toLowerCase() : null;
    
    if (!['list', 'test', 'install'].includes(command)) {
        [
            'Usage: node certinst.js <command>',
            '',
            '  test    - test NW connection',
            '  list    - list installed certificates',
            '  install - install certificates from certificates dir',
        ].forEach(h => console.log(h));
        process.exit(1);
    }

    const isSilent = (process.argv[3] === '-s');
    
    if (command === 'test') {
        const success = await testConnection(!isSilent);
        process.exit(success ? 0 : 1);
    } else if (command === 'list') {
        const certCount = await listCertificates(!isSilent);
        if (certCount >= 0) {
            if (isSilent) console.log(certCount);
            process.exit(0);
        } else {
            process.exit(1);
        }
    } else if (command === 'install') {
        await installCertificates('./certificates');
    } else {
        console.log('Unknown command');
    }
}

process.on('unhandledRejection', async (reason, p) => {
    console.error('Unhandled Rejection at: Promise', p , 'reason:', reason);
    process.exit(1);
});
main();
