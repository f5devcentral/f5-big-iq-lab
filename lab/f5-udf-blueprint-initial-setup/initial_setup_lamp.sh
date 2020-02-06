#!/bin/bash

# Ubuntu 19.10 Lamp Server
# Use Ubuntu 18.04 LTS as a baseline in UDF

# Initial script install:
# sudo su -
# curl -O https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/f5-udf-blueprint-initial-setup/initial_setup_lamp.sh
# chmod +x /root/initial_setup_lamp.sh
# ./initial_setup_lamp.sh

# Run as root in /root

function pause(){
   read -p "$*"
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd /root

read -p "Perform Ubuntu Upgrade 18.04 to 19.10? (Y/N) (Default=N): " answer
if [[  $answer == "Y" ]]; then
    lsb_release -a
    apt update
    export DEBIAN_FRONTEND=noninteractive; apt dist-upgrade -y
    apt install update-manager-core -y
    sed -i 's/lts/normal/g' /etc/update-manager/release-upgrades
    sed -i 's/bionic/eoan/g' /etc/apt/sources.list
    apt update
    apt upgrade -y
    apt update
    export DEBIAN_FRONTEND=noninteractive; apt dist-upgrade -y
    apt autoremove -y
    apt clean

    lsb_release -a
    read -p "Reboot? (Y/N) (Default=N): " answer
    if [[  $answer == "Y" ]]; then
        shutdown -r now
    fi

fi

lsb_release -a

echo -e "Cleanup unnessary packages"
apt --purge remove apache2 chromium-browser -y
apt update
apt upgrade -y
apt autoremove -y

read -p "Install Netplan? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    apt install netplan.io -y
fi

read -p "Configure Network with Netplan? (Y/N) (Default=N): " answer
if [[  $answer == "Y" ]]; then
    # Configure Network
    echo 'network:
  version: 2
  ethernets:
    ens4:
        addresses:
            - 10.1.10.5/24
    ens5:
        addresses:
            - 10.1.20.5/24
            - 10.1.20.110/24
            - 10.1.20.111/24
            - 10.1.20.112/24
            - 10.1.20.113/24
            - 10.1.20.114/24
            - 10.1.20.115/24
            - 10.1.20.116/24
            - 10.1.20.117/24
            - 10.1.20.118/24
            - 10.1.20.119/24
            - 10.1.20.120/24
            - 10.1.20.121/24
            - 10.1.20.122/24
            - 10.1.20.123/24
            - 10.1.20.124/24
            - 10.1.20.125/24
            - 10.1.20.126/24
            - 10.1.20.127/24
            - 10.1.20.128/24
            - 10.1.20.129/24
            - 10.1.20.130/24
            - 10.1.20.131/24
            - 10.1.20.132/24
            - 10.1.20.133/24
            - 10.1.20.134/24
            - 10.1.20.135/24
            - 10.1.20.136/24
            - 10.1.20.137/24
            - 10.1.20.138/24' > /etc/netplan/01-netcfg.yaml

    netplan generate
    netplan try
fi

echo -e "\nIP config check"
ip addr
ifconfig

echo -e "\nInstall Docker"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install apt-transport-https ca-certificates curl software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
apt-key fingerprint 0EBFCD88
# add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu disco stable"
apt update
apt install docker-compose -y
systemctl unmask docker.service
systemctl unmask docker.socket
systemctl start docker.service
docker version
docker info
docker network ls
/etc/init.d/docker status

read -p "Add user f5student? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    adduser f5student --disabled-password --gecos ""
    echo "f5student:purple123" | chpasswd

    echo -e "\nCustomisation Users"
    pause "Press [Enter] key to continue... CTRL+C to Cancel"
    ln -snf /home/f5student /home/f5
    chown -R f5student:f5student /home/f5
    echo 'f5student ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

    usermod -aG docker f5student

    # bashrc config
    echo 'cd /home/f5student
    echo
    sudo docker images
    echo
    sudo docker ps
    echo
    echo "To connect to a docker instance: sudo docker exec -i -t <Container ID> /bin/bash"
    echo
    echo -e "\nIn order to force the lab scripts updates and re-build ALL docker containers, run ./update_git.sh as root user.\n"
    echo
    sudo su - f5student' >> /home/ubuntu/.bashrc

    # customize vim
    echo 'let &t_SI .= "\<Esc>[?2004h"
    let &t_EI .= "\<Esc>[?2004l"
    inoremap <special> <expr> <Esc>[200~ XTermPasteBegin()

    function! XTermPasteBegin()
    set pastetoggle=<Esc>[201~
    set paste
    return ""
    endfunction' > /root/.vimrc
    cp /root/.vimrc /home/ubuntu/.vimrc
    cp /root/.vimrc /home/f5student/.vimrc
    chown ubuntu:ubuntu /home/ubuntu/.vimrc
    chown f5student:f5student /home/f5student/.vimrc
    chown -R f5student:f5student /home/f5student
fi

echo -e "\nInstall DHCP service"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install isc-dhcp-server -y
echo 'INTERFACES="ens3"' > /etc/default/isc-dhcp-server
echo 'default-lease-time 600;
max-lease-time 7200;

subnet 10.1.1.0 netmask 255.255.255.0 {
option routers                  10.1.1.1;
option subnet-mask              255.255.255.0;
option domain-search            "example.com";
option domain-name-servers      8.8.8.8;
range   10.1.1.220   10.1.1.250;
}' > /etc/dhcp/dhcpd.conf
/etc/init.d/isc-dhcp-server restart
/etc/init.d/isc-dhcp-server status
dhcp-lease-list --lease /var/lib/dhcp/dhcpd.leases

echo -e "\nInstall Radius service"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install freeradius -y
freeradius –v
echo 'paula   Cleartext-Password := "paula"
paul    Cleartext-Password := "paul"
marco   Cleartext-Password := "marco"
larry   Cleartext-Password := "larry"
david   Cleartext-Password := "david"' >> /etc/freeradius/3.0/users

echo 'client 0.0.0.0/0 {
secret = default
shortname = bigiq
}' >> /etc/freeradius/3.0/radiusd.conf
/etc/init.d/freeradius restart
/etc/init.d/freeradius status

echo -e "\nInstall Apache Benchmark, Git, SNMPD, jq"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install apache2-utils -y
apt install git git-lfs -y
apt install snmpd snmptrapd -y
apt install jq -y

echo -e "\nInstall Ansible and sshpass"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install software-properties-common -y
apt-add-repository --yes --update ppa:ansible/ansible
apt update
apt install ansible -y
apt install sshpass -y
ansible-playbook --version

echo -e "\nInstall Postman"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install cdcat libqt5core5a libqt5network5 libqt5widgets5 -y 
#wget https://dl.pstmn.io/download/latest/linux64 -O postman.tar.gz
#tar -xzf postman.tar.gz -C /opt
#rm postman.tar.gz
#ln -s /opt/Postman/Postman /usr/bin/postman
snap install postman

echo -e "\nInstall Java (used for Access traffic generator)"
add-apt-repository --yes --update ppa:linuxuprising/java
apt update
apt install openjdk-12-jdk -y

echo -e "\nInstall nmap and hping3 (used for AFM and DDOS traffic generators)"
apt install nmap -y
apt install hping3 -y

echo -e "\nInstall DNS perf"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install libbind-dev libkrb5-dev libssl-dev libcap-dev libxml2-dev -y
apt install gzip curl make gcc bind9utils libjson-c-dev libgeoip-dev -y
apt --fix-broken install
wget ftp://ftp.nominum.com/pub/nominum/dnsperf/2.0.0.0/dnsperf-src-2.0.0.0-1.tar.gz
tar xfvz dnsperf-src-2.0.0.0-1.tar.gz
cd dnsperf-src-2.0.0.0-1
./configure
make
make install
rm -f dnsperf-src-2.0.0.0-1.tar.gz

echo -e "\nInstall Samba"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install samba samba-client -y
cp -p /etc/samba/smb.conf /etc/samba/smb.conf.orig
echo "[global]
workgroup = WORKGROUP
server string = Samba Server %v
netbios name = centos
security = user
map to guest = bad user
dns proxy = no
#============================ Share Definitions ==============================
[dcdbackup]
path = /dcdbackup
browsable =yes
writable = yes
guest ok = yes
read only = no" > /etc/samba/smb.conf
mkdir /dcdbackup
chown -R nobody:nogroup /dcdbackup
systemctl restart smbd
smbclient -L localhost -N
echo -e "\nTo test the Samba/CIFS server from BIG-IQ:\nmkdir /tmp/testfolder\nmount.cifs //10.1.1.5/dcdbackup /tmp/testfolder -o user=,password=\n\nworkgroup = WORKGROUP\n"

echo -e "\nInstall Azure CLI"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
AZ_REPO=$(lsb_release -cs)
echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
tee /etc/apt/sources.list.d/azure-cli.list
# Get the Microsoft signing key:
curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
# Install the CLI:
apt update
apt --fix-broken install -y
apt install apt-transport-https azure-cli -y

echo -e "\nInstall AWS CLI"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
apt install python-pip -y
apt --fix-broken install -y
pip --version
cd /home/f5student/f5-aws-vpn-ssg
ansible-playbook 01a-install-pip.yml

echo -e "\nInstall Python librairies (as f5sutdent)"
su - f5student -c "pip install PyVmomi" # VMware ansible playbooks 
su - f5student -c "pip install dnspython" # for DDOS DNS traffic generator
su - f5student -c "pip install jmespath" # for AS3 ansible playbooks 
su - f5student -c "pip install ansible-tower-cli" # for AWX / Ansible Tower

echo -e "\nInstall and Desktop and xRDP"
apt --fix-broken install
apt install -y ubuntu-desktop gnome-shell-extension-desktop-icons gnome xrdp
apt install -y xfce4 xfce4-goodies
echo "polkit.addRule(function(action, subject) {
if ((action.id == “org.freedesktop.color-manager.create-device” ||
action.id == “org.freedesktop.color-manager.create-profile” ||
action.id == “org.freedesktop.color-manager.delete-device” ||
action.id == “org.freedesktop.color-manager.delete-profile” ||
action.id == “org.freedesktop.color-manager.modify-device” ||
action.id == “org.freedesktop.color-manager.modify-profile”) &&
subject.isInGroup(“{users}”)) {
return polkit.Result.YES;
}
});" > /etc/polkit-1/localauthority.conf.d/02-allow-color.d.conf
# ONLY FOR UDF option to have no passwords to JumpHost
sed -i 's/username=ask/username=f5student/g' /etc/xrdp/xrdp.ini
sed -i 's/password=ask/password=purple123/g' /etc/xrdp/xrdp.ini
service xrdp restart

# NoVNC
echo -e "\nInstall noVNC"
apt -y install novnc websockify python-numpy
apt -y install vnc4server
openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/novnc.pem -out /etc/ssl/novnc.pem -days 1825
chmod 644 /etc/ssl/novnc.pem
cp -p /usr/share/novnc/vnc.html /usr/share/novnc/index.html
su - f5student -c "printf 'purple123\npurple123\nn\n\n' | vncpasswd"
su - f5student -c "vncserver :1"
su - f5student -c "websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 6080 localhost:5901"

# Chrome needs to be before Deskop
echo -e "\nInstall Chrome"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
#echo 'deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main' >> /etc/apt/sources.list
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
dpkg -i google-chrome-stable_current_amd64.deb

echo -e "\nSystem customisation (e.g. host file)"
pause "Press [Enter] key to continue... CTRL+C to Cancel"
echo '10.1.10.110 site10.example.com
10.1.10.111 site11.example.com
10.1.10.112 site12.example.com
10.1.10.113 site13.example.com
10.1.10.114 site14.example.com
10.1.10.115 site15.example.com
10.1.10.116 site16.example.com
10.1.10.117 site17.example.com site17auth.example.com
10.1.10.118 site18.example.com
10.1.10.119 site19.example.com site19auth.example.com
10.1.10.120 site20.example.com
10.1.10.121 site21.example.com site21auth.example.com
10.1.10.122 site22.example.com
10.1.10.123 site23.example.com
10.1.10.124 site24.example.com
10.1.10.125 site25.example.com
10.1.10.126 site26.example.com
10.1.10.127 site27.example.com
10.1.10.128 site28.example.com
10.1.10.129 site29.example.com
10.1.10.130 site30.example.com
10.1.10.131 site31.example.com
10.1.10.132 site32.example.com
10.1.10.133 site33.example.com
10.1.10.134 site34.example.com
10.1.10.135 site35.example.com
10.1.10.136 site36.example.com
10.1.10.137 site37.example.com
10.1.10.138 site38.example.com
10.1.10.139 site39.example.com
10.1.10.140 site40.example.com
10.1.10.141 site41.example.com
10.1.10.142 site42.example.com
10.1.10.143 site43.example.com
10.1.10.144 site44.example.com
10.1.10.145 site45.example.com' >> /etc/hosts

echo -e "\nInstall and execution of update_git.sh"
pause "Press [Enter] key to continue... CTRL+C to Cancel"

echo '#!/bin/sh -e

curl -o /home/f5student/update_git.sh https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/update_git.sh
/home/f5student/update_git.sh > /home/f5student/update_git.log
chown -R f5student:f5student /home/f5student

exit 0' > /etc/rc.local
chmod +x /etc/rc.local

curl -o /home/f5student/update_git.sh https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/update_git.sh
chown f5student:f5student /home/f5student/update_git.sh
chmod +x /home/f5student/update_git.sh

# remove GIT_LFS_SKIP_SMUDGE=1 to get the qkviews
sed -i 's/GIT_LFS_SKIP_SMUDGE=1//g' /home/f5student/update_git.sh
/home/f5student/update_git.sh
chown -R f5student:f5student /home/f5student
killall sleep

echo -e "\nSSH keys exchanges between Lamp server and BIG-IP and BIG-IQ CM/DCD"
su - f5student -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'

## Add there things to do manually
echo -e "\nPost-Checks:
- Disable auto-lock screen for f5student user
- Disable keying (https://www.fosslinux.com/2561/how-to-disable-keyring-in-ubuntu-elementary-os-and-linux-mint.htm)
- Test Reboot (shutdown -r now) and stop/start from UDF
- Test Connection to RDP
- Test Connection to noVNC
- Re-arrange Favorites in the task bar (have Chrome, Firefox, Terminal, Postman)
- Test Launch Chrome & Firefox
- Add bookmark of the BIG-IQ CE lab guide and Splunk, check all bookmarks works
- Add postman collection from f5-ansible-bigiq-as3-demo-7.0.0, disable SSL in postman\n\n"

exit 0