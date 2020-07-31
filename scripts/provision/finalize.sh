#!/bin/sh

echo "Installation sequence complete"

# Elapsed time calculation
PROVISION_START_TS=`cat /tmp/provision-start.timestamp`
PROVISION_END_TS=`date +%s`
ELAPSED_TIME=$(($PROVISION_END_TS - $PROVISION_START_TS))
echo "Installation took $(($ELAPSED_TIME / 60)) minutes and $(($ELAPSED_TIME % 60)) seconds"
