This is work in progress
========================

0. you can use the 1 Step install script:

```
curl -sL https://raw.githubusercontent.com/thkl/homekit-ccu/master/doc/debmatic.sh | bash -
````

or do the steps by yourself 

1. install nodejs:
```
curl -sL https://deb.nodesource.com/setup_14.x | sudo -E bash -
sudo apt install -y nodejs
```

2. create a folder for hap in your home 

```
mkdir $HOME/homekit-ccu
cd $HOME/homekit-ccu
npm install homekit-ccu
```

3. create a data folder in your home
```
mkdir $HOME/.homekit-ccu
```

4. create a file in your $home/homekit-ccu folder named homekit-ccu.service

```
nano $HOME/homekit-ccu.service
```

paste this content

```
[Unit]
Description=Hap_Homematic
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
```



make the file runable

```
chmod +x $HOME/homekit-ccu/homekit-ccu.service
```

link this to the systemd and enable the service

```
sudo systemctl link $HOME/homekit-ccu/homekit-ccu.service
sudo systemctl enable homekit-ccu.service
```



Note here: you have to adjust path names according to your installation


Run it
```
sudo service homekit-ccu start
```

