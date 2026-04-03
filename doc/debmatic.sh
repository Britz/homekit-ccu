#!/bin/bash

curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs
mkdir $HOME/homekit-ccu
mkdir $HOME/.homekit-ccu
cd $HOME/homekit-ccu
npm install homekit-ccu
rm $HOME/homekit-ccu/homekit-ccu.service
if test -f "$HOME/homekit-ccu/homekit-ccu.service"; then
    rm $HOME/homekit-ccu/homekit-ccu.service
fi
bash -c 'cat << EOT >> $HOME/homekit-ccu/homekit-ccu.service
[Unit]
Description=HomeKit_CCU
After=debmatic-rega.target
[Service]
Type=simple
User=root
ExecStart=/usr/bin/node $HOME/homekit-ccu/node_modules/homekit-ccu/index -C $HOME/.homekit-ccu/
Restart=on-failure
RestartSec=10
KillMode=process
[Install]
WantedBy=multi-user.target
EOT'

chmod +x $HOME/homekit-ccu/homekit-ccu.service
sudo systemctl link $HOME/homekit-ccu/homekit-ccu.service
sudo systemctl enable homekit-ccu.service
sudo service homekit-ccu start
