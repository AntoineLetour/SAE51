VBoxManage createvm --name "DebianSAE51" --ostype "Debian_64" --register > /dev/null
VBoxManage modifyvm DebianSAE51 --memory 4096 > /dev/null
VBoxManage modifyvm DebianSAE51 --nic1 nat --boot1 net > /dev/null
VBoxManage createhd --filename "$HOME/VirtualBox VMs/DebianSAE51/DebianSAE51.vdi" > /dev/null
VBoxManage storagectl "DebianSAE51" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/DebianSAE51/DebianSAE51.vdi" > /dev/null

read -p "test"

VBoxManage unregistervm "DebianSAE51" --delete > /dev/null
