RAM=4096
DISK=64000
ACTION=$1
VMNAME=$2
VMDISK="$HOME/VirtualBox VMs/$VMNAME/$VMNAME.vdi"
USER_INFO="$USER"
DATE_INFO=$(date --iso-8601)


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
        VBoxManage list vms | while read line; do
            VM="${line#\"}"
            VM="${VM%%\"*}"
            DATE_VBOX=$(VBoxManage getextradata "$VM" "date_info" 2> /dev/null)
            USER_VBOX=$(VBoxManage getextradata "$VM" "user_info" 2> /dev/null)
            echo "$VM  ${USER_VBOX}, ${DATE_VBOX}"
        done
        ;;

    N)
        if VBoxManage list vms | grep -q "\"$VMNAME\""; then
           echo "Erreur : le nom de VM \"$VMNAME\" est déjà utilisé."
           exit 1
        fi
        
        if ! VBoxManage createvm --name "$VMNAME" --ostype "Debian_64" --register > /dev/null 2>&1; then
           echo "Erreur : impossible de créer la VM"
           exit 1
        fi


        if ! VBoxManage modifyvm "$VMNAME" --memory $RAM --nic1 nat --boot1 net > /dev/null 2>&1; then
           echo "Erreur : impossible de créer les caractéristiques de la VM"
           exit 1
        fi

        if ! VBoxManage createhd --filename "$VMDISK" --size $DISK > /dev/null 2>&1 || \
           ! VBoxManage storagectl "$VMNAME" --name "SATA Controller" --add sata --controller IntelAhci > /dev/null 2>&1 || \
           ! VBoxManage storageattach "$VMNAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VMDISK" > /dev/null 2>&1; then
           echo "Erreur : impossible de créer le disque de la VM"
           exit 1
        fi

        VBoxManage setextradata "$VMNAME" "date_info" "$DATE_INFO"
        VBoxManage setextradata "$VMNAME" "user_info" "$USER_INFO"

        echo "VM $VMNAME créée"
        ;;
    S)
        if VBoxManage list vms | grep -q "\"$VMNAME\""; then 
            VBoxManage unregistervm "$VMNAME" --delete > /dev/null
        else
            echo "VM $VMNAME supprimée"
        fi
        ;;
    D)
        if VBoxManage startvm "$VMNAME" --type gui > /dev/null 2>&1; then
            echo "La VM est démarrée"
        else
            echo "Erreur : impossible de démarrer la VM"
        fi
        ;;
    A)
        if  VBoxManage controlvm "$VMNAME" poweroff > /dev/null 2>&1; then
            echo "La VM est éteinte"
        else
            echo "Erreur : impossible de d'éteindre la VM"
        fi
        ;;
    *)
        echo "Erreur : action invalide"
        exit 1
        ;;
esac

