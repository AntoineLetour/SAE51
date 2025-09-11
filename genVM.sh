RAM=4096
DISK=64000
ACTION=$1
VMNAME=$2
VMDISK="$HOME/VirtualBox VMs/$VMNAME/$VMNAME.vdi"


if [ $# -lt 1 ]; then
    echo "  L : Lister l’ensemble des machines enregistrées"
    echo "  N : Ajouter une nouvelle machine"
    echo "  S : Supprimer une machine"
    echo "  D : Démarrer une machine"
    echo "  A : Arreter une machine"
    exit 1
fi



case "$ACTION" in
    L)
        echo "Liste des VMs :" 
        VBoxManage list vms
        ;;
    N)

        if VBoxManage list vms | grep -q "\"$VMNAME\""; then
            VBoxManage unregistervm "$VMNAME" --delete > /dev/null
        fi

        VBoxManage createvm --name "$VMNAME" --ostype "Debian_64" --register > /dev/null
        VBoxManage modifyvm "$VMNAME" --memory $RAM --nic1 nat --boot1 net > /dev/null
        VBoxManage createhd --filename "$VMDISK" --size $DISK > /dev/null
        VBoxManage storagectl "$VMNAME" --name "SATA Controller" --add sata --controller IntelAhci > /dev/null
        VBoxManage storageattach "$VMNAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VMDISK" > /dev/null

        echo "VM $VMNAME créée avec $RAM Mo RAM et disque $DISK Go"
        ;;
    S)
        if VBoxManage list vms | grep -q "\"$VMNAME\""; then 
            VBoxManage unregistervm "$VMNAME" --delete > /dev/null
        fi
        echo "VM $VMNAME supprimée"
        ;;
    D)
        VBoxManage startvm "$VMNAME" --type headless
        ;;
    A)
        VBoxManage controlvm "$VMNAME" poweroff
        ;;
    *)
        echo "Erreur : action invalide"
        exit 1
        ;;
esac

