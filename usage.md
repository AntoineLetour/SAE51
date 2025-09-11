# Présentation SAE51

Antoine Letourneur & Thomas Dehais

BUT RT-2025/2026

## Résumé du Projet

Ce projet consiste en la création d'un script bash pour créer une machine virtuelle uniquemet en ligne de commande.

Le projet consiste à développer un script capable d'automatiser la création d'une machine virtuelle Debian 64 et de la supprimer après vérification.
Nous devrons ensuite ajouter plusieurs spécificités au script, comme la vérification de l'inexistence d'une machine virtuelle portant le même nom que celle que l'on souhaite créer, ou encore le démarrage de la machine via PXE pour installer Debian à l'aide d'un serveur TFTP.
Nous ajouterons également une liste d’arguments pour chaque action. Ces actions seront : créer, supprimer, démarrer et arrêter, tout cela en conservant des variables pour la configuration.
Enfin, nous intégrerons dans le script des fonctionnalités permettant d'enregistrer et d'afficher des métadonnées, comme la date de création et l'utilisateur associé.
Nous vous présenterons par la suite chacune des étapes qui nous ont permis de réaliser ce projet.
Nous terminerons par une indication des sources utilisées pour le construire.

### Etape 1

Pour cette étape, nous avons créé un script qui permet de créer une machine virtuelle.
Nous avons également renseigné les informations avec lesquelles nous allons configurer la VM.
![]
Nous avons également ajouté, dans cette première partie du script, une pause qui nous permettra d’effectuer des vérifications.
Une fois les vérifications terminées, le programme reprend et supprime la machine que nous venons de créer.

#### Etape 2 