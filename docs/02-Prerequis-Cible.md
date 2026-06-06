# 02 - Prérequis sur la machine cible

## Introduction

Avant d'exécuter le playbook, la machine cible doit respecter un certain nombre de prérequis.

Le rôle d'Ansible n'est pas de rendre une machine accessible pour la première fois. Il suppose qu'une connexion SSH fonctionnelle existe déjà entre le Control Node et la machine distante (appelée Managed Node).

L'objectif de ce document est donc de vérifier que la machine cible est prête à recevoir les actions du playbook.

Dans le cadre de ce projet, la machine cible est généralement :
* Un VPS hébergé chez un fournisseur cloud
* Une machine virtuelle Debian
* Un serveur physique Debian
* Une machine de laboratoire

---

# Système d'exploitation supporté

Le playbook a été conçu pour fonctionner sur Debian.

Versions recommandées :
* Debian 13 (Trixie)
* Debian 12 (Bookworm)
* Debian 11 (Bullseye)

Vérifier la version :

```bash
cat /etc/os-release
```

Exemple :

```text
PRETTY_NAME="Debian GNU/Linux 13 (trixie)"
...
```

---

# Connectivité réseau

La machine cible doit être joignable depuis le Control Node.

Depuis le Control Node :

```bash
ping 192.168.1.10
```

ou

```bash
ping serveur.exemple.local
```

Une réponse doit être obtenue.

Exemple :

```text
64 bytes from 192.168.1.10: icmp_seq=1 ttl=64 time=0.7 ms
```

Si le serveur n'est pas joignable, le playbook ne pourra pas être exécuté.

---

# Service SSH

Ansible utilise SSH pour communiquer avec la machine distante.

Le serveur SSH doit donc être installé et démarré.

Vérification :

```bash
sudo systemctl status ssh
```

ou :

```bash
sudo systemctl status sshd
```

Installation si nécessaire :

```bash
sudo apt update
sudo apt install -y openssh-server
```

Activation automatique au démarrage :

```bash
sudo systemctl enable ssh
sudo systemctl start ssh
```

---

# Vérification du port SSH

Par défaut, SSH écoute sur le port 22.

Vérification depuis la machine distante :

```bash
ss -tlnp | grep :22
```

Exemple :

```text
LISTEN 0      128          0.0.0.0:22        0.0.0.0:*
```

Si un port personnalisé est utilisé, il devra être renseigné dans l'inventaire Ansible, dans la variable `ansible_port: <port>`.

Exemple :

```yaml
ansible_port: 2222
```

---

# Présence de Python

Ansible exécute ses modules grâce à Python présent sur la machine distante.

Vérification :

```bash
python3 --version
```

Exemple :

```text
Python 3.13.5
```

Installation si nécessaire :

```bash
sudo apt update
sudo apt install -y python3
```

Sans Python, Ansible ne pourra pas exécuter ses modules.

---

# Compte utilisateur

Le playbook ne doit généralement pas être exécuté avec le compte root.

Il est recommandé de créer un utilisateur dédié à l'administration sur la machien cible.

Exemple :

```bash
sudo adduser sysadmin
```

---

# Droits sudo

L'utilisateur utilisé par Ansible doit disposer de droits d'administration.

Ajouter l'utilisateur au groupe sudo, depuis le compte root :

```bash
sudo usermod -aG sudo sysadmin
```

Si sudo n'est pas installé, l'installer depuis le compte root :
```bash
apt update
apt install sudo -y
```

Vérifier les droits :

```bash
groups sysadmin
```

Exemple :

```text
sysadmin : sysadmin sudo
```

---

# Test de l'élévation de privilèges

Connecte-toi avec le compte qui sera utilisé par Ansible :

```bash
su - sysadmin
```

Puis :

```bash
sudo whoami
```

Résultat attendu :

```text
root
```

Si cette commande échoue, le playbook ne pourra pas installer Docker.

---

# Authentification SSH par mot de passe

Si le projet utilise une authentification par mot de passe, vérifie que la connexion fonctionne.

Depuis le Control Node :

```bash
ssh sysadmin@192.168.1.10
```

Le mot de passe doit être demandé puis accepté.

---

# Authentification SSH par clé

L'authentification par clé SSH est généralement recommandée pour administrer des serveurs Linux.

Contrairement à une authentification par mot de passe, elle repose sur une paire de clés :

* une **clé privée** conservée sur le poste d'administration ;
* une **clé publique** copiée sur le serveur distant.

Lorsqu'une connexion SSH est établie, le serveur vérifie que le client possède bien la clé privée correspondant à la clé publique enregistrée sur le serveur.

Cette méthode présente plusieurs avantages :

* meilleure sécurité ;
* protection contre les attaques par force brute ;
* possibilité d'automatiser certaines tâches ;
* absence de mot de passe à saisir à chaque connexion (selon la configuration retenue).

Depuis le Control Node, générer une paire de clés si nécessaire :

```bash
ssh-keygen -t ed25519 -b 256 -C "user@server" -f ~/.ssh/id_ed25519_server -N 'mypassphrase'
```

## Comprendre la commande

* `ssh-keygen` : utilitaire permettant de générer une paire de clés SSH.
* `-t ed25519` : type de clé utilisé. Ed25519 est aujourd'hui recommandé pour la plupart des usages.
* `-b 256` : taille de la clé. Pour Ed25519, cette valeur est fixe mais reste souvent indiquée pour plus de lisibilité.
* `-C` : commentaire associé à la clé, généralement un email ou une description.
* `-f` : emplacement et nom des fichiers générés.
* `-N` : phrase secrète (passphrase) utilisée pour protéger la clé privée.

## Pourquoi utiliser une passphrase ?

Une erreur fréquente consiste à générer une clé privée sans protection :

```bash
ssh-keygen -t ed25519 
```

Cette méthode est pratique mais moins sécurisée.

Si un attaquant parvient à récupérer le fichier de clé privée, il pourra potentiellement se connecter à tous les serveurs qui lui font confiance.

L'utilisation d'une passphrase ajoute une couche de protection supplémentaire.

Même si la clé privée est volée, elle ne pourra pas être utilisée sans connaître la phrase secrète associée.

Lorsqu'une passphrase est configurée :

```bash
-N 'MonMotDePasseComplexe'
```

chaque utilisation de la clé demandera cette phrase secrète.

Exemple :

```text
Enter passphrase for key '/home/sysadmin/.ssh/id_ed25519_server':
```

## Copier la clé publique sur le serveur distant

Une fois la paire de clés générée, seule la clé publique doit être copiée sur le serveur distant.

La clé privée doit rester exclusivement sur le Control Node.

Copie de la clé publique :

```bash
ssh-copy-id -i ~/.ssh/id_ed25519_server.pub sysadmin@192.168.1.10
```

Explications :

* `ssh-copy-id` : outil qui copie automatiquement la clé publique sur le serveur distant ;
* `-i ~/.ssh/id_ed25519_server.pub` : indique quelle clé publique envoyer ;
* `sysadmin@192.168.1.10` : utilisateur et adresse IP de la machine cible.

Cette commande ajoute la clé publique dans le fichier suivant sur le serveur distant :

```bash
/home/sysadmin/.ssh/authorized_keys
```
* Lorsqu'on demande le mot de passe `sysadmin@10.10.10.87's password:` il s'agit du mot de passe SSH, pas de la clé privée.

Tester ensuite la connexion :

```bash
ssh -i ~/.ssh/id_ed25519_server sysadmin@192.168.1.10
```

Si une passphrase a été définie avec l’option -N, elle sera demandée au moment d’utiliser la clé privée.

Si la connexion fonctionne, l’inventaire Ansible pourra utiliser cette clé :

```
ansible_ssh_private_key_file: ~/.ssh/id_ed25519_server
```

## Éviter de saisir la passphrase à chaque connexion

Saisir la passphrase à chaque connexion peut devenir contraignant lorsque plusieurs connexions SSH sont réalisées quotidiennement.

Pour résoudre ce problème, il est possible d'utiliser un agent SSH.

L'agent SSH conserve temporairement la clé déchiffrée en mémoire après une authentification réussie.

Démarrer l'agent :

```bash
eval "$(ssh-agent -s)"
```

Charger la clé privée :

```bash
ssh-add ~/.ssh/id_ed25519_server
```

La passphrase sera demandée une seule fois.

Les connexions SSH suivantes pourront alors utiliser automatiquement la clé tant que la session reste active.

Cette approche constitue généralement le meilleur compromis entre sécurité et confort d'utilisation.

> Dans un environnement de laboratoire ou de démonstration, il est possible d'utiliser une clé sans passphrase afin de simplifier les manipulations. En revanche, dans un contexte de production ou d'administration réelle, l'utilisation d'une passphrase est fortement recommandée.



---

# Pare-feu

Si un pare-feu est actif, il doit autoriser les connexions SSH.

Exemple avec UFW :

```bash
sudo ufw allow 22/tcp
```

ou si un port personnalisé est utilisé :

```bash
sudo ufw allow 2222/tcp
```


Vérification :

```bash
sudo ufw status
```

---

# Vérification finale

Avant de poursuivre, les éléments suivants doivent être validés :
* La machine est sous Debian
* La machine est joignable sur le réseau
* Le service SSH est démarré
* Python 3 est installé
* L'utilisateur d'administration existe
* L'utilisateur dispose des droits sudo
* La connexion SSH fonctionne
* Le pare-feu autorise le trafic SSH

Lorsque tous ces points sont validés, la machine est prête à être administrée par Ansible et le déploiement de Docker peut commencer.
