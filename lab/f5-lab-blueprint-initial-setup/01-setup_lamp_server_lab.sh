#!/bin/bash

# Ubuntu 19.10 Lamp Server
# Use Ubuntu 18.04 LTS as a baseline in UDF

# Initial script install:
# sudo su -
# curl -O https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/f5-lab-blueprint-initial-setup/01-setup_lamp_server_lab.sh
# chmod +x /root/01-setup_lamp_server_lab.sh
# ./01-setup_lamp_server_lab.sh

# Run as root in /root

function pause(){
   read -p "$*"
}

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

cd /root

echo
uname -a
lsb_release -a
echo

read -p "Speedtest? (Y/N) (Default=N): " answer
if [[  $answer == "Y" ]]; then
    curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -
fi

read -p "Change Kernel to boot on old one 4.15 to mitigate speed issue? (Y/N) (Default=N): " answer
if [[  $answer == "Y" ]]; then
    cp -p /etc/default/grub /etc/default/grub.orig
    sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT="Advanced options for Ubuntu>Ubuntu, with Linux 4.15.0-118-generic"/g' /etc/default/grub
    cat /etc/default/grub
    update-grub
    read -p "Reboot? (Y/N) (Default=N): " answer
    if [[  $answer == "Y" ]]; then
        shutdown -r now
    fi
fi

echo
uname -a
lsb_release -a
echo

echo -e "Cleanup & apt update & upgrade unnessary packages"
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
    echo -e "Double check network interface names along with network interface in UDF (e.g. ens6, ens7 look at the MAC address) )."
    pause "Press [Enter] key to continue... CTRL+C to Cancel"
    echo 'network:
  version: 2
  ethernets:
    ens6:
        addresses:
            - 10.1.10.5/24
    ens7:
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

read -p "Install Docker? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
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
fi

read -p "Install Utils, Ansible, sshpass? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall Radius utils"
    apt install freeradius-utils -y

    echo -e "\nInstall LDAP utils"
    apt install ldap-utils -y

    echo -e "\nInstall Samba Client"
    apt install samba-client -y

    echo -e "\nInstall Apache Benchmark, Git, SNMPD, jq, unzip"
    apt install apache2-utils -y
    apt install git git-lfs -y
    apt install snmp snmpd snmptrapd -y
    apt install jq -y
    apt install unzip -y

    echo -e "\nInstall Ansible and sshpass"
    apt install ansible -y
    apt install sshpass -y
    ansible-playbook --version

    echo -e "\nInstall fortune (used to add random quotes on BIG-IQ login)"
    apt install fortune -y
fi

# echo -e "\nInstall nmap and hping3 (used for AFM and DDOS traffic generators)"
# apt install nmap -y
# apt install hping3 -y

read -p "Install python pip3 (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    apt install python3-pip
    pip3 --version
fi

read -p "Install DNS perf? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall DNS perf"
    apt install libbind-dev libkrb5-dev libssl-dev libcap-dev libxml2-dev -y
    apt install gzip curl make gcc bind9utils libjson-c-dev libgeoip-dev -y
    snap install --devmode --beta dnsperf
fi

read -p "Install Postman? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall Postman"
    snap install postman
fi

read -p "Install AWS/Azure CLI? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall Azure CLI"
    pause "Press [Enter] key to continue... CTRL+C to Cancel"
    AZ_REPO=$(lsb_release -cs)
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $AZ_REPO main" | \
    tee /etc/apt/sources.list.d/azure-cli.list
    # Get the Microsoft signing key:
    curl -L https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
    # Install the CLI:
    apt update
    apt install apt-transport-https azure-cli -y
    az --version

    echo -e "\nInstall AWS CLI"
    pause "Press [Enter] key to continue... CTRL+C to Cancel"
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    rm -f awscliv2.zip
    ./aws/install
    aws --version
fi

read -p "Install Java? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall Java (used for Access traffic generator)"
    apt install default-jdk
    java -version
    javac -version
fi

# read -p "Install DHCP server? (Y/N) (Default=N):" answer
# if [[  $answer == "Y" ]]; then
#     echo -e "\nInstall DHCP service"
#     pause "Press [Enter] key to continue... CTRL+C to Cancel"
#     apt -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" install isc-dhcp-server -y
#     echo 'INTERFACES="ens3"' > /etc/default/isc-dhcp-server

#     cp /etc/dhcp/dhcpd.conf /etc/dhcp/dhcpd.conf.orig
#     echo 'default-lease-time 600;
#     max-lease-time 7200;

#     subnet 10.1.1.0 netmask 255.255.255.0 {
#     option routers                  10.1.1.1;
#     option subnet-mask              255.255.255.0;
#     option domain-search            "example.com";
#     option domain-name-servers      8.8.8.8;
#     range   10.1.1.220   10.1.1.250;
#     }' > /etc/dhcp/dhcpd.conf
#     /etc/init.d/isc-dhcp-server restart
#     /etc/init.d/isc-dhcp-server status
#     dhcp-lease-list --lease /var/lib/dhcp/dhcpd.leases
# fi

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

    echo "Reset ubuntu user password"
    echo "ubuntu:purple123" | chpasswd

    # bashrc config
    echo 'cd /home/f5student
echo
sudo docker images
echo
sudo docker ps
echo
echo "To connect to a docker instance: sudo docker exec -i -t <container id or name> /bin/bash"
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

read -p "Install Python librairies? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall Python librairies (as f5sutdent)"
    su - f5student -c "pip3 install PyVmomi" # VMware ansible playbooks 
    su - f5student -c "pip3 install dnspython" # for DDOS DNS traffic generator
    su - f5student -c "pip3 install jmespath" # for AS3 ansible playbooks 
    su - f5student -c "pip3 install ansible-tower-cli" # for AWX / Ansible Tower
fi

read -p "Install Desktop and RDP? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall and Desktop and xRDP"
    apt --fix-broken install
    apt install -y ubuntu-desktop gnome-shell-extension-desktop-icons gnome xrdp
    # XRDP
    sed -i 's/username=ask/username=f5student/g' /etc/xrdp/xrdp.ini
    sed -i 's/password=ask/password=purple123/g' /etc/xrdp/xrdp.ini
    service xrdp restart

    # NoVNC
    echo -e "\nInstall noVNC"
    apt -y install websockify python-numpy novnc 
    openssl req -x509 -nodes -newkey rsa:2048 -keyout /etc/ssl/novnc.pem -out /etc/ssl/novnc.pem -days 1825
    chmod 644 /etc/ssl/novnc.pem
    cp -p /usr/share/novnc/vnc.html /usr/share/novnc/index.html
    su - f5student -c "/usr/bin/websockify -D --web=/usr/share/novnc/ --cert=/etc/ssl/novnc.pem 6080 localhost:5900"

    echo -e "\nConfigure Gnome Screen Sharing"
    cd /etc/NetworkManager
    sudo cp NetworkManager.conf NetworkManager.orig
    # Change NetworkManager.conf: 'managed=false' to 'managed=true'
    sudo sed -i 's/managed=false/managed=true/g' NetworkManager.conf
    sudo service network-manager restart
    cd /etc/netplan
    # Ensure networks are managed by NetworkManager
    # Whitespace in this command is important!
    sudo sed -i '/^network:/a \    renderer: NetworkManager' 50-cloud-init.yaml
    sudo netplan apply

    echo -e "\nEnable Sharing > Screen Sharing in Ubuntu\n"
    echo -e "\nEnable Automatic Login for f5student in Ubuntu\n"
    echo -e "Execute:\n"
    echo -e "gsettings set org.gnome.Vino require-encryption false"
    echo -e "gsettings set org.gnome.Vino vnc-password $(echo -n 'purple123'|base64)"

    ## This is for in case you want to use xfce4 for VNC desktop
    # apt install -y xfce4 xfce4-goodies
    # echo "polkit.addRule(function(action, subject) {
    # if ((action.id == “org.freedesktop.color-manager.create-device” ||
    # action.id == “org.freedesktop.color-manager.create-profile” ||
    # action.id == “org.freedesktop.color-manager.delete-device” ||
    # action.id == “org.freedesktop.color-manager.delete-profile” ||
    # action.id == “org.freedesktop.color-manager.modify-device” ||
    # action.id == “org.freedesktop.color-manager.modify-profile”) &&
    # subject.isInGroup(“{users}”)) {
    # return polkit.Result.YES;
    # }
    # });" > /etc/polkit-1/localauthority.conf.d/02-allow-color.d.conf
    # ONLY FOR UDF option to have no passwords to JumpHost

    #apt -y install tightvncserver
    #su - f5student -c "printf 'purple123\npurple123\nn\n\n' | vncpasswd"
    #su - f5student -c "/usr/bin/vncserver :1 -geometry 1280x800 -depth 24"

#     echo '#!/bin/sh
# unset SESSION_MANAGER
# unset DBUS_SESSION_BUS_ADDRESS
# exec startxfce4 &' > /home/f5student/.vnc/xstartup

    # chmod 755 /home/f5student/.vnc/xstartup
    # chown f5student:f5student /home/f5student/.vnc/xstartup
fi

read -p "Install Chrome? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then
    echo -e "\nInstall Chrome"
    pause "Press [Enter] key to continue... CTRL+C to Cancel"
    wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
    dpkg -i google-chrome-stable_current_amd64.deb
fi

read -p "System customisation? (Y/N) (Default=N):" answer
if [[  $answer == "Y" ]]; then

    echo "Update timezone"
    rm /etc/localtime
    ln -s /usr/share/zoneinfo/America/Los_Angeles /etc/localtime

    echo -e "\nSystem customisation (e.g. host file)"
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
10.1.10.145 site45.example.com
10.1.1.17 ec2amaz-bq0fcmk.f5demo.com # Venafi' >> /etc/hosts

    echo -e "\nInstall and execution of update_git.sh"

    echo '#!/bin/sh -e

curl -o /home/f5student/update_git.sh https://raw.githubusercontent.com/f5devcentral/f5-big-iq-lab/develop/lab/update_git.sh
chmod +x /home/f5student/update_git.sh
/home/f5student/update_git.sh > /home/f5student/update_git.log 2>&1 &
chown -R f5student:f5student /home/f5student

exit 0' > /etc/rc.local

    chmod +x /etc/rc.local

    pause "Press [Enter] key to continue... CTRL+C to Cancel"
    /etc/rc.local

    killall sleep

    echo -e "\nSSH keys for between Lamp server and BIG-IP and BIG-IQ CM/DCD"
    su - f5student -c 'ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa'


fi

## Add there things to do manually
echo -e "\nPost-Checks:
- Test Connection to RDP
- Test Connection to noVNC
- Disable auto-lock screen for f5student user
- Re-arrange Favorites in the desktop task bar (have Chrome, Firefox, Terminal, Postman)
- Test Launch Chrome & Firefox
- Add bookmark of the BIG-IQ lab guide
- Add postman collection from f5-ansible-bigiq-as3-demo, disable SSL in postman
- Install BIG-IQ MIB from /usr/share/snmp/mibs/
- Test Reboot (shutdown -r now) and stop/start from UDF\n\n"

exit 0