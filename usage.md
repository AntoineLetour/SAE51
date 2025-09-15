# Présentation SAE51

Antoine Letourneur & Thomas Dehais

BUT RT-2025/2026

## Résumé du Projet

Le projet consiste à développer un script bash capable d'automatiser la création d'une machine virtuelle Debian 64 et de la supprimer après vérification.
Nous devrons ensuite ajouter plusieurs spécificités au script, comme la vérification de l'inexistence d'une machine virtuelle portant le même nom que celle que l'on souhaite créer, ou encore le démarrage de la machine via PXE pour installer Debian à l'aide d'un serveur TFTP.
Nous ajouterons également une liste d’arguments pour chaque action. Ces actions seront : créer, supprimer, démarrer et arrêter, tout cela en conservant des variables pour la configuration.
Enfin, nous intégrerons dans le script des fonctionnalités permettant d'enregistrer et d'afficher des métadonnées, comme la date de création et l'utilisateur associé.
Nous vous présenterons par la suite chacune des étapes qui nous ont permis de réaliser ce projet.
Nous terminerons par une indication des sources utilisées pour le construire.

### Etape 1

Pour cette étape, nous avons créé un **script qui permet de créer une machine virtuelle**.
Nous avons également renseigné les informations avec lesquelles nous allons configurer la VM.

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%201/Code%20version%201.png)

Nous avons également ajouté, dans cette première partie du script, une **pause qui nous permettra d’effectuer des vérifications**.
Une fois les vérifications terminées, **le programme reprend et supprime la machine que nous venons de créer**.

### Etape 2 

Nous passons ensuite à l’ajout, dans le script, d’une **vérification permettant d’éviter la création d’une machine portant le même nom**.
Si une machine avec ce nom existe déjà, le programme s'arrètera marquant une erreur avant la création de la nouvelle.

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%202/Code%20version%202.png)

### Etape 3

Pour cette partie nous allons rajouter dans le script une gestion d'arguments.
Nous allons avoir comme  **1° argument une lettre qui correspond à une action de la création de la VM** :

-L pour lister l'ensemble des machines enregistrées dans VB.

-N pour ajouter une nouvelle machine.

-S pour supprimer une machine.

-D pour démarrer une machine 

-A pour arreter une machine.

Pour la création on demande à l'utillisateur deux arguments, comme on voit si-dessous **le premier est l'actions qui est identifié par `$1` et le nom de la VM identifié par `$2`**.

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%203/Code%20version%204%20var.png)

Pour ce bout de programme on vérifie que lors du choix d'actions, l'utilisateur **renseigne bien deux arguments**, si ce n'est pas le cas cela renvoie un message d'erreur. 

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%203/Code%20version%204%20lettres.png)

Le deuxième **argument des commandes N, S, D et A correspond au nom de la machine à créer ou manipuler**, avec des caractéristiques (RAM et disque dur) définies en début de script via des variables modifiables.

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%203/Code%20version%204%20case.png)
 
 
![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%203/Code%20version%204%20ex.png)

Ces screens montrent que la variable **`$ACTION`** est redirigé grâce au case.

### Etape 4

On doit vérifier, via l'interface graphique (GUI) de VirtualBox, que la machine virtuelle démarre bien en utilisant le **boot PXE**.

On configure ensuite le **serveur TFTP interne à VirtualBox** afin que la machine puisse démarrer sur le programme d’**installation d’une Debian stable (version netinst)**.  
On veillera à **télécharger au préalable l’image ISO de Debian netinst**, qui servira de source d’installation via le réseau: https://www.debian.org/releases/bookworm/debian-installer/

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%204/Code%20version%204%20var.png)
![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%204/Code%20version%204%20code.png)

Les commandes vont ouvrir l'ISO Debian et copié sont contenu dans `$HOME/TFTP/` pour préparé le boot PXE puis une fois la copie créée elle se ferme.

### Etape 5

Pour finir, cette étape fut la plus compliqué a produire. On eu besoin de modifier le programme de gestion d'arguments en étape 4.

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%205/Code%20version%205%20var.png)

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%205/Code%20version%205%20ajout%20dans%20la%20creation.png)

La commande **`VBoxManage setextradata`** permet d'ajouter ou de modifier des métadonnées pour une machine virtuelle.

![images](https://github.com/AntoineLetour/SAE51/blob/brMD/images/code%20version%205/Code%20version%205%20boucle%20for.png)

Pour cette étape on devait attacher des métadonnés telles que la date de création, obtenue via l’OS, et l’identité de l’utilisateur, obtenue via
la variable d’environnement qui contient cette information. Ces informations seront donc unique à chaque VM créée et pourront être affiché avec l'argument **"L"**.
Pour faire cela on redirige la sortie de la commande `VBoxManage list vms` vers un fichier texte.  
Ce fichier est ensuite **analysé ligne par ligne à l’aide d’une boucle `FOR`**, en séparant les champs par les espaces.  
On récupère le **premier champ (le nom de la machine)** pour l’utiliser avec la commande `VBoxManage getextradata` afin d'obtenir des informations associées à chaque machine virtuelle.



