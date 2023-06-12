#!/bin/bash
echo user passed $withUser - password $withPassword
export ENV_USER=${withUser:-sae}
export ENV_PASSWORD=${withPassword:-$ENV_USER}
export ENV_WITHDEBUG=${withDebug:-""}
/usr/bin/containervncserver-setup.sh

export updatedRunNodeServer="/home/$ENV_USER/updatedRunNodeServer"
export runNodeServer="/home/$ENV_USER/runnodeserver"
export runNodeExpect="/home/$ENV_USER/runNode.exp"
export runNodeScript="/home/$ENV_USER/runNode.sh"


if [ ! -f "$updatedRunNodeServer" ]; then
	echo "Adding runnodeserver to supervisord configuration"
	echo "" >> /etc/supervisord.conf
	echo "[program:nodeserver]" >> /etc/supervisord.conf
	echo "command=$runNodeServer" >> /etc/supervisord.conf
	echo "user=$ENV_USER" >> /etc/supervisord.conf
	echo "priority=500" >> /etc/supervisord.conf
	echo "autorestart=true" >> /etc/supervisord.conf
	echo "" >> /etc/supervisord.conf
	echo "updated" > $updatedRunNodeServer
else
	echo "supervisord configured"
fi


echo "Creating file $runNodeServer that executes de expect ($runNodeExpect) to run $runNodeScript to execute node wich can launch vncservers"
echo "#!/bin/bash" > $runNodeServer
echo "echo Lanzando node con usuario $ENV_USER.. $runNodeScript" >> $runNodeServer
echo "#su -s /bin/bash -c 'node $withDebug main.js &> /usr/src/app/main.log' $ENV_USER" >> $runNodeServer
echo "#node $ENV_WITHDEBUG main.js &> /usr/src/app/main.log" >>$runNodeServer
echo "$runNodeExpect" >> $runNodeServer
echo "" >> $runNodeServer 

echo "Creating file $runNodeExpect to call $runNodeScript to execute node wich can launch vncservers"
echo "#!/usr/bin/expect -f" > $runNodeExpect
echo "spawn ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $ENV_USER@localhost \"$runNodeScript\"" >> $runNodeExpect
echo "expect \"assword:\"" >> $runNodeExpect
echo "send \"$ENV_PASSWORD\r\"" >> $runNodeExpect
echo "interact" >> $runNodeExpect
echo "" >> $runNodeExpect

echo "Creating $runNodeScript to execute node wich can launch vncservers"
echo "#!/bin/bash" > $runNodeScript
echo "echo Lanzando node con usuario $ENV_USER.. $runNodeScript" >> $runNodeScript
echo "export ENV_USER=$ENV_USER" >> $runNodeScript 
echo "export ENV_PASSWORD=$ENV_PASSWORD" >> $runNodeScript 
echo "export ENV_WITHDEBUG=$ENV_WITHDEBUG" >> $runNodeScript 
echo "export ORACLE_BASE=/usr/lib/instantclient_12_1" >> $runNodeScript 
echo "export LD_LIBRARY_PATH=/usr/lib/instantclient_12_1" >> $runNodeScript 
echo "export TNS_ADMIN=/usr/lib/instantclient_12_1" >> $runNodeScript 
echo "export ORACLE_HOME=/usr/lib/instantclient_12_1" >> $runNodeScript 
echo "Adding all environment variables that starts with 'with'"
for var in "${!with@}"; do
    printf 'export %s=%s\n' "$var" "${!var}" >> $runNodeScript
done
echo "cd /usr/src/app " >> $runNodeScript 
echo "node $ENV_WITHDEBUG main.js &> /usr/src/app/main.log" >> $runNodeScript 
echo "" >> $runNodeScript 

chown $ENV_USER:$ENV_USER /home/$ENV_USER -R
chown $ENV_USER:$ENV_USER /usr/src/app -R
chmod 777 $runNodeServer
chmod 777 $runNodeExpect
chmod 777 $runNodeScript 