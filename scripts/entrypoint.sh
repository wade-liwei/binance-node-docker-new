#!/bin/sh

# exit script on any error
set -e
echo "setting up initial configurations"

if [ ! -f "$BNBD_HOME/config/config.toml" ];
then
  cp -r /tmp/config $BNBD_HOME/config
fi


echo "configuration complete  ---- starting..."

#exec  /usr/local/bin/bnbchaind start  --home $BNBD_HOME
exec supervisord --nodaemon --configuration /etc/supervisor/supervisord.conf
