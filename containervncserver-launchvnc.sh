#!/bin/bash
export username=$1

ls /tmp/.X*
rm -rf /tmp/.X*

rm /home/$username/.vnc/*.log
rm /home/$username/.vnc/*.pid

su -c 'vncserver -PasswordFile /home/$username/.vnc/passwd' $username


