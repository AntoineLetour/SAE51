RAM=4096
DISK=64000
ACTION=$1
VMNAME=$2
VMDISK="$HOME/VirtualBox VMs/$VMNAME/$VMNAME.vdi"
USER_INFO="$USER"
DATE_INFO=$(date --iso-8601)
TFTP_ISO="$HOME/TFTP/debian-13.1.0-amd64-netinst.iso"


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
            VM=$(echo "$line" | cut -d'"' -f2)
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
        
        if ! VBoxManage createvm --name "$VMNAME" --ostype "Debian_64" --register &> /dev/null; then
           echo "Erreur : impossible de créer la VM"
           exit 1
        fi
	

        if ! VBoxManage modifyvm "$VMNAME" --memory $RAM --nic1 nat --boot1 net &> /dev/null; then
           echo "Erreur : impossible de créer les caractéristiques de la VM"
           exit 1
        fi

        if ! VBoxManage createhd --filename "$VMDISK" --size $DISK &> /dev/null || \
           ! VBoxManage storagectl "$VMNAME" --name "SATA Controller" --add sata --controller IntelAhci &> /dev/null || \
           ! VBoxManage storageattach "$VMNAME" --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium "$VMDISK" &> /dev/null; then
           echo "Erreur : impossible de créer le disque de la VM"
           exit 1
        fi

        mkdir -p "$HOME/TFTP"

        if [ ! -f "$TFTP_ISO" ]; then
            echo "Téléchargement de l'ISO Debian..."
            wget -O "$TFTP_ISO" "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-13.1.0-amd64-netinst.iso" &> /dev/null
        fi

        VBoxManage modifyvm "$VMNAME" --natpf1 "tftp,tcp,,69,,69"        

        if ! VBoxManage storagectl "$VMNAME" --name "IDE Controller" --add ide &> /dev/null || \
           ! VBoxManage storageattach "$VMNAME" --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium "$TFTP_ISO" &> /dev/null || \
           ! VBoxManage modifyvm "$VMNAME" --boot1 dvd &> /dev/null; then
           echo "Erreur : impossible de créer le PXE de la VM"
           exit 1
        fi

        VBoxManage setextradata "$VMNAME" "date_info" "$DATE_INFO"
        VBoxManage setextradata "$VMNAME" "user_info" "$USER_INFO" 

        echo "VM $VMNAME créée"
        ;;
    S)
        if VBoxManage list vms | grep -q "\"$VMNAME\"" &> /dev/null; then 
            VBoxManage unregistervm "$VMNAME" --delete &> /dev/null
        else
            echo "VM $VMNAME supprimée"
        fi
        ;;
    D)
        if VBoxManage startvm "$VMNAME" --type gui &> /dev/null; then
            echo "La VM est démarrée"
        else
            echo "Erreur : impossible de démarrer la VM"
        fi
        ;;
    A)
        if  VBoxManage controlvm "$VMNAME" poweroff &> /dev/null; then
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

