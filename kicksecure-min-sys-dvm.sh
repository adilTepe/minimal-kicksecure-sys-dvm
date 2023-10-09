#!/bin/bash

SOURCE_TEMPLATE=debian-12-minimal
TARGET_TEMPLATE=kicksecure-17-min
TARGET_TEMPLATE_DISP="$TARGET_TEMPLATE"-dvm""

# download the template
qvm-template install $SOURCE_TEMPLATE 
# update repos and upgrade packages
qvm-run --pass-io -u root $SOURCE_TEMPLATE "apt-get update && apt-get full-upgrade -y"
# install basic packages
< pulseaudio-qubes"
# set Xfce4-terminal as default
qvm-run --pass-io -u root $SOURCE_TEMPLATE "update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper"
# shutdown
qvm-shutdown --wait $SOURCE_TEMPLATE
sleep 20
# set memory limits
qvm-prefs $SOURCE_TEMPLATE memory 512
qvm-prefs $SOURCE_TEMPLATE maxmem 5120
# clone the updated template
qvm-clone $SOURCE_TEMPLATE $TARGET_TEMPLATE
qvm-prefs $TARGET_TEMPLATE memory 512
qvm-prefs $TARGET_TEMPLATE maxmem 5120
qvm-run --pass-io --no-gui --user=root $TARGET_TEMPLATE 'apt-get update && apt-get dist-upgrade -y'
# Some packages needed for kicksecure to install
qvm-run --pass-io --no-gui --user=root $TARGET_TEMPLATE 'apt-get install -y dkms zenity qubes-core-agent-networking qubes-mgmt-salt-vm-connector qubes-kernel-vm-support'
# install kicksecure (straight from the kicksecure website but in a bash script)
qvm-run --pass-io --no-gui --user=root $TARGET_TEMPLATE 'apt-get install -y --no-install-recommends sudo adduser'
qvm-run --pass-io --no-gui --user=root $TARGET_TEMPLATE 'addgroup --system console && adduser user console && adduser user sudo'
qvm-shutdown --wait $TARGET_TEMPLATE
sleep 20
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo apt-get install -y --no-install-recommends extrepo'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo http_proxy=http://127.0.0.1:8082 https_proxy=http://127.0.0.1:8082 extrepo enable kicksecure'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo apt-get update'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo apt-get dist-upgrade -y'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo apt-get install -y --no-install-recommends kicksecure-qubes-gui'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo extrepo disable kicksecure'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo mv /etc/apt/sources.list ~/'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo touch /etc/apt/sources.list'
qvm-run --pass-io --no-gui --user=user $TARGET_TEMPLATE 'sudo repository-dist --enable --repository stable-proposed-updates'

qvm-run --pass-io --no-gui --user=root $TARGET_TEMPLATE 'apt-get install -y lkrg-dkms tirdad apparmor-notify apparmor-profile-everything libpam-apparmor notification-daemon python3-notify2'
qvm-prefs -s $TARGET_TEMPLATE kernelopts "apparmor=1 security=apparmor"
qvm-run --pass-io --no-gui --user=root $TARGET_TEMPLATE "apt-get install -y --no-install-recommends qubes-core-agent-networking wpasupplicant qubes-core-agent-network-manager firmware-iwlwifi qubes-usb-proxy qubes-input-proxy-sender zenity policykit-1 libblockdev-crypto2 ntfs-3g qubes-core-agent-dom0-updates"
qvm-shutdown --wait $TARGET_TEMPLATE
sleep 20

qvm-run --pass-io --no-gui --user=root $TARGET_TEMPLATE "modprobe -r iwlwifi ; modprobe iwlwifi"

qvm-shutdown --wait $TARGET_TEMPLATE
sleep 20

qvm-create --template $TARGET_TEMPLATE --label red $TARGET_TEMPLATE_DISP 
qvm-prefs $TARGET_TEMPLATE_DISP template_for_dispvms True
qvm-features $TARGET_TEMPLATE_DISP appmenus-dispvm 1  
qvm-prefs $TARGET_TEMPLATE_DISP memory 512
qvm-prefs $TARGET_TEMPLATE_DISP maxmem 5120
