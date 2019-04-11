const fs = require('fs');
const { promisify } = require('util');
const readFileAsync = promisify(fs.readFile);
const commander = require('commander');
const {
    ADTClient,
    session_types,
} = require('abap-adt-api');

function create() {
    const ip = process.env.AD_IP || 'localhost';
    const user = process.env.AD_USER || 'developer';
    const pass = process.env.AD_PASS || 'Down1oad';

    return new ADTClient(
        `http://${ip}:8000`,
        user,
        pass,
    );
}

async function fetchTmpObj(objName) { // eslint-disable-line no-unused-vars
    const client      = create();
    const nodes       = await client.nodeContents('DEVC/K', '$TMP');
    const node        = nodes.nodes.find(i => i.OBJECT_NAME === objName);
    const structure   = await client.objectStructure(node.OBJECT_URI);
    const mainInclude = ADTClient.mainInclude(structure);
    const code        = await client.getObjectSource(mainInclude);
    // console.log(structure, mainInclude);
    console.log(code);
}

async function installProg(name, source) {
    const client = create();
    const path   = '/sap/bc/adt/programs/programs/' + name;
    const main   = path + '/source/main';

    try {
        await client.createObject({
            description: name,
            name,
            objtype: 'PROG/P',
            parentName: '$TMP',
            parentPath: '/sap/bc/adt/packages/$TMP'
        });

        client.stateful = session_types.stateful;
        const handle = await client.lock(path);
        await client.setObjectSource(main, source, handle.LOCK_HANDLE); // write the program
        console.log(`Program ${name} was successfully created`);
        await client.unLock(path, handle.LOCK_HANDLE);

        // read it for verification
        // const newsource = await c.getObjectSource(main)
        // console.log(newsource);

        const result = await client.activate( name, path );
        console.log(result);
    } finally {
        client.dropSession();
    }
}

async function main(args) {

    // fetchTmpObj('ZCL_Z001_MPC');
    // installProg('zadt_test_temp', `report zadt_test_temp.\nwrite:/ 'Hello World!'.`);

    if (!args.program) {
        console.error('Please specify program name');
        process.exit(1);
    }

    try {
        const src = await readFileAsync(args.from, 'utf8');
        installProg(args.program, src);
    } catch (error) {
        console.error(error);
        process.exit(1);
    }

}

process.on('unhandledRejection', async (reason, p) => {
    console.error('Unhandled Rejection at: Promise', p, 'reason:', reason);
    process.exit(1);
});

commander
    .option('-p,--program <program-name>', 'Program name')
    .option('-f,--from <path>', 'Path to abap source');
commander.parse(process.argv);
main(commander);
