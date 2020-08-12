#!/bin/sh

echo "Adjusting SAP profile - increasing workers number..."
PROFILE_PATH=/sapmnt/NPL/profile/NPL_D00_vhcalnplci
sudo cp $PROFILE_PATH $PROFILE_PATH.bak
sudo sed -i -e 's/wp_no_dia = 2/wp_no_dia = 6/' $PROFILE_PATH

#ssl/ciphersuites         =  135:PFS:HIGH::EC_P256:EC_HIGH
#ssl/client_ciphersuites  =  150:PFS:HIGH::EC_P256:EC_HIGH
echo "ssl/client_sni_enabled = TRUE" >> $PROFILE_PATH

echo "SAP HARDWARE KEY"
sudo -i -u npladm saplicense -get || true
