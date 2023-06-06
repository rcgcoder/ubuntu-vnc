#!/bin/bash
echo user passed $withUser - password $withPassword
export ENV_USER=${withUser:-sae}
export ENV_PASSWORD=${withPassword:-$ENV_USER}
export userPath="/home/$ENV_USER"
echo $userPath -- $username
if [ ! -d "$userPath" ]; then
    echo "$userPath not exists";
	/usr/bin/addUserWithPassword $ENV_USER $ENV_PASSWORD
fi
export vncpasswdPath="$userPath/.vnc"
if [ ! -d "$vncpasswdPath" ]; then
    echo "$vncpasswdPath not exists";
	mkdir -p $vncpasswdPath
fi

echo $ENV_PASSWORD | tigervncpasswd -f > $vncpasswdPath/passwd

echo "\$localhost=\"no\";"  >> /etc/vnc.conf

chown $ENV_USER:$ENV_USER $vncpasswdPath -R


