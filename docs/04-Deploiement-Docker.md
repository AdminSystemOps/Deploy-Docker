# 04 - Déploiement de Docker

## Introduction

Une fois le Control Node préparé, la machine cible configurée et l'inventaire renseigné, il est possible de lancer le déploiement de Docker.

Cette étape consiste à exécuter le playbook Ansible fourni par le projet.

Le playbook va se connecter à la machine cible, vérifier plusieurs prérequis, puis installer Docker à partir du dépôt officiel Docker.

L'objectif est d'obtenir une installation propre, reproductible et conforme aux recommandations de l'éditeur.

---

# Vue d'ensemble du processus

Le déploiement se déroule selon les étapes suivantes :

```text
1. Connexion à la machine cible
2. Vérification du système d'exploitation
3. Suppression des anciens paquets Docker
4. Installation des dépendances nécessaires
5. Ajout du dépôt officiel Docker
6. Installation de Docker Engine
7. Installation de Docker Compose
8. Activation du service Docker
9. Ajout de l'utilisateur au groupe docker
10. Vérifications finales
```

Une fois ces opérations terminées, la machine est prête à héberger des conteneurs Docker.

---

# Activer l'environnement virtuel Python (RAPPEL)

Avant d'exécuter le playbook, activer l'environnement virtuel créé lors de la préparation du Control Node.

Depuis le répertoire du projet :

```bash
source .venv/bin/activate
```

L'invite de commande doit alors afficher :

```text
(.venv) utilisateur@machine:~/Deploy-Docker$
```

Cette indication confirme que les commandes Python et Ansible utiliseront les dépendances du projet.

---

# Vérifier la connectivité Ansible (RAPPEL)

Avant de lancer le déploiement complet, il est recommandé de tester la communication avec la machine cible.

Commande :

```bash
ansible docker_hosts -i inventory.yml -m ping
```

Résultat attendu :

```text
srv-docker | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.13"
    },
    "changed": false,
    "ping": "pong"
}
```

Cette étape permet de vérifier :

* la connectivité réseau
* le fonctionnement du protocole SSH
* la validité des identifiants
* le bon fonctionnement d'Ansible

Si cette commande échoue, il est inutile de lancer le playbook complet. Se référer au fichier `05-Depannage.md`

---

# Lancer le déploiement

Le projet fournit un script permettant de simplifier l'exécution du playbook. 

Rendre le script exécutable :

```bash
chmod +x install-docker.sh
```

Puis exécuter le script :

```bash
./install-docker.sh
```

Le script lance simplement le playbook Ansible avec l'inventaire configuré.

Il est également possible de lancer le playbook directement :

```bash
ansible-playbook -i inventory.yml playbook.yml
```

Les deux méthodes produisent exactement le même résultat.

---

# Comprendre ce que fait le playbook

## Étape 1 - Vérification du système d'exploitation

Le playbook commence par vérifier que la machine cible utilise bien Debian.

Cette vérification évite d'exécuter des commandes incompatibles sur une autre distribution Linux.

Exemple :

```text
Debian 11
Debian 12
Debian 13
```

Si la distribution n'est pas supportée, le playbook s'arrête immédiatement.

---

## Étape 2 - Suppression des anciens paquets Docker

Certaines distributions installent Docker à partir de leurs propres dépôts.

Ces versions peuvent entrer en conflit avec celles distribuées officiellement par Docker.

Le playbook supprime notamment :

```text
docker.io
docker-compose
containerd
runc
podman-docker
```

Cette étape garantit une base propre avant installation.

---

## Étape 3 - Installation des dépendances

Docker nécessite plusieurs paquets système pour fonctionner correctement.

Le playbook installe notamment :

```text
ca-certificates
curl
gnupg
```

Ces paquets sont utilisés pour :

* télécharger des fichiers ;
* vérifier leur authenticité ;
* communiquer avec les dépôts logiciels.

---

## Étape 4 - Ajout du dépôt officiel Docker

Par défaut, Debian ne fournit pas toujours la dernière version de Docker.

Le playbook ajoute donc le dépôt officiel Docker.

Cette opération comprend :

* l'ajout de la clé GPG Docker ;
* la création du dépôt APT ;
* la mise à jour du cache des paquets.

Cette approche permet de bénéficier des versions maintenues directement par Docker.

---

## Étape 5 - Installation de Docker Engine

Le playbook installe ensuite :

```text
docker-ce
docker-ce-cli
containerd.io
docker-buildx-plugin
docker-compose-plugin
```

Ces composants constituent l'environnement Docker complet.

---

## Étape 6 - Activation du service Docker

Une fois les paquets installés, le service Docker est démarré.

Le playbook configure également le démarrage automatique au boot.

Vérification :

```bash
systemctl status docker
```

Résultat attendu :

```text
active (running)
```

---

## Étape 7 - Ajout au groupe docker

Par défaut, seuls les administrateurs peuvent utiliser Docker.

Le playbook ajoute l'utilisateur défini dans les variables au groupe :

```text
docker
```

Cette opération permet d'utiliser Docker sans avoir à saisir systématiquement :

```bash
sudo
```

---

# Fin du déploiement

À l'issue de l'installation, une reconnexion SSH est généralement recommandée.

Cette opération permet au système de prendre en compte l'appartenance au groupe Docker.

Déconnexion :

```bash
exit
```

Puis reconnexion :

```bash
ssh utilisateur@serveur
```

---

# Vérifier l'installation de Docker

Afficher la version installée :

```bash
docker --version
```

Exemple :

```text
Docker version XX.XX.X
```

Afficher la version de Docker Compose :

```bash
docker compose version
```

Exemple :

```text
Docker Compose version vX.X.X
```

---

# Vérifier le fonctionnement de Docker

Lancer un conteneur de test :

```bash
docker run hello-world
```

Docker télécharge alors une image de démonstration et exécute un conteneur.

Résultat attendu :

```text
Hello from Docker!
```

Si ce message apparaît, Docker est correctement installé et fonctionnel.

---

# Vérifier le fonctionnement sans sudo

Tester :

```bash
docker ps
```

Si la commande fonctionne sans erreur, cela signifie que l'utilisateur appartient bien au groupe Docker.

Si un message du type apparaît :

```text
permission denied while trying to connect to the Docker daemon socket
```
```text
permission denied while trying to connect to the docker API at unix:///var/run/docker.sock
```


déconnecte-toi puis reconnecte-toi à la machine. Et si ça ne suffit pas (cela peut arriver si un terminal reste ouvert ou dans une session graphique) , alors redemarre la machine. 

---

# Vérification finale

Avant de passer au projet suivant, vérifie les points suivants :
* Docker est installé
* Docker Compose est installé
* Le service Docker est démarré
* Le service Docker est activé au démarrage
* L'utilisateur peut exécuter Docker sans sudo
* Le conteneur `hello-world` fonctionne correctement

