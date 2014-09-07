#!/bin/bash
echo "########### GamersCoin Auto Node Daemon Install Script Deb/Ubuntu"
echo "########### Changing to Home"
cd ~
read -p "Press [Enter] key to start Install GamersCoin with node/Daemon Support ..."

echo "Add a user for Gamerscoin Daemon and move gamerscoind"
adduser gamerscoin && usermod -g users gamerscoin && delgroup gamerscoin && chmod 0701 /home/gamerscoin
mkdir /home/gamerscoin/bin

echo "########### Firewall rules; allow 40002,40001 p2p/rcp"
ufw allow 40002/tcp
ufw allow 40001/tcp
ufw --force enable

echo "########### Updating Deb/Ubuntu"
apt-get update -y
apt-get upgrade -y
apt-get dist-upgrade -y
apt-get install software-properties-common python-software-properties -y

echo "########### Creating Swap"
dd if=/dev/zero of=/swapfile bs=1M count=1024 ; mkswap /swapfile ; swapon /swapfile
echo "/swapfile swap swap defaults 0 0" >> /etc/fstab

echo "########### Update and install dependencies"
apt-get update -y 
apt-get upgrade -y
apt-get install ntp git build-essential libssl-dev libdb-dev libdb++-dev libboost-all-dev libqrencode-dev wget -y

echo "########### Update miniupnpc-1.8"
wget http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.8.tar.gz && tar -zxf download.php\?file\=miniupnpc-1.8.tar.gz && cd miniupnpc-1.8/
make && make install && cd .. && rm -rf miniupnpc-1.8 download.php\?file\=miniupnpc-1.8.tar.gz

echo "########### Get and Compile Gamerscoin Daemon"
git clone https://github.com/gamers-coin/gamers-coinv3.git
cd gamers-coinv3/src/
make -f makefile.unix
strip gamerscoind
cp ~/gamers-coinv3/src/gamerscoind /home/gamerscoin/bin/gamerscoind
chown -R gamerscoin:users /home/gamerscoin/bin
cd && rm -rf gamers-coinv3

echo "########### Setting up autostart (cron)"
crontab -u gamerscoin -l > tempcron
echo "@reboot gamerscoind -daemon" >> tempcron
crontab -u gamerscoin tempcron
rm tempcron

echo "########### Creating Gamerscoin Config"
mkdir /home/gamerscoin/.gamerscoin
config="/home/gamerscoin/.gamerscoin/gamerscoin.conf"
touch $config
echo "server=1" > $config
echo "daemon=1" >> $config
echo "connections=100" >> $config
randUser=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
randPass=`< /dev/urandom tr -dc A-Za-z0-9 | head -c30`
echo "rpcuser=$randUser" >> $config
echo "rpcpassword=$randPass" >> $config

chown -R gamerscoin:users /home/gamerscoin

echo "########### Start Demon"
cd /home/gamerscoin/bin
sudo -u gamerscoin ./gamerscoind
tail -f /home/gamerscoin/.gamerscoin/debug.log