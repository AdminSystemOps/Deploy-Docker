# 05 - Dépannage

## Introduction

Ce document regroupe les problèmes les plus fréquemment rencontrés lors de l'utilisation du projet Deploy-Docker.

Avant de chercher une erreur complexe, il est recommandé de vérifier les éléments suivants :

* le Control Node est correctement préparé ;
* l'environnement virtuel Python est activé ;
* la machine cible est joignable sur le réseau ;
* le service SSH fonctionne ;
* Python est installé sur la machine cible ;
* l'inventaire Ansible est correctement renseigné.

Dans la majorité des cas, le problème provient de l'un de ces éléments.

---

# Vérifier la connectivité Ansible

Avant toute opération, tester la communication avec la machine cible.

```bash
ansible docker_hosts -i inventory.yml -m ping
```

Résultat attendu :

```text
srv-docker | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Si cette commande ne fonctionne pas, le playbook Docker ne fonctionnera pas non plus.

---

# Erreur : Host unreachable

Exemple :

```text
UNREACHABLE! => {
    "msg": "Failed to connect to the host via ssh"
}
```

Cette erreur indique qu'Ansible ne parvient pas à joindre la machine cible.

Vérifier :

* l'adresse IP renseignée dans l'inventaire ;
* le nom DNS utilisé ;
* le port SSH ;
* le routage réseau ;
* le pare-feu.

Tester la connexion manuellement :

```bash
ssh sysadmin@192.168.1.10
```

Si la connexion SSH échoue, Ansible échouera également.

---

# Erreur : Connection refused

Exemple :

```text
ssh: connect to host 192.168.1.10 port 22: Connection refused
```

Cette erreur indique généralement que le service SSH n'est pas démarré.

Sur la machine cible :

```bash
sudo systemctl status ssh
```

Démarrer le service :

```bash
sudo systemctl enable --now ssh
```

---

# Erreur : Permission denied (publickey)

Exemple :

```text
Permission denied (publickey)
```

Cette erreur apparaît lorsqu'une authentification par clé SSH est utilisée mais que la clé privée ne correspond pas à la clé publique enregistrée sur le serveur.

Vérifier :

* le chemin renseigné dans `ansible_ssh_private_key_file` ;
* la présence de la clé publique dans `~/.ssh/authorized_keys` ;
* les permissions du dossier `.ssh`.

Tester la connexion :

```bash
ssh -i ~/.ssh/id_ed25519_server sysadmin@192.168.1.10
```

---

# Erreur : Host key verification failed

Exemple :

```text
Host key verification failed
```

Cette erreur apparaît lorsque l'empreinte SSH du serveur a changé.

Cela peut arriver :

* après une réinstallation du serveur ;
* après la recréation d'une machine virtuelle ;
* après le remplacement du système d'exploitation.

Afficher l'entrée concernée :

```bash
ssh-keygen -F 192.168.1.10
```

Supprimer l'ancienne empreinte :

```bash
ssh-keygen -R 192.168.1.10
```

Puis se reconnecter :

```bash
ssh sysadmin@192.168.1.10
```

---

# Erreur : sudo password is required

Exemple :

```text
Missing sudo password
```

ou

```text
sudo: a password is required
```

L'utilisateur utilisé par Ansible ne dispose pas des informations nécessaires pour exécuter des commandes administratives.

Vérifier :

```yaml
ansible_become_password:
```

dans l'inventaire lorsque l'authentification par mot de passe est utilisée.

Vérifier également que l'utilisateur appartient au groupe sudo :

```bash
groups sysadmin
```

---

# Erreur : Python not found

Exemple :

```text
/bin/sh: python3: command not found
```

Ansible nécessite Python sur la machine cible.

Installation :

```bash
sudo apt update
sudo apt install -y python3
```

Vérification :

```bash
python3 --version
```

---

# Erreur lors de l'installation des paquets Docker

Exemple :

```text
Failed to update apt cache
```

ou

```text
Unable to locate package docker-ce
```

Vérifier :

* la connectivité Internet de la machine cible ;
* la résolution DNS ;
* la présence du dépôt Docker.

Tester :

```bash
curl https://download.docker.com
```

Puis :

```bash
apt policy docker-ce
```

---

# Erreur : docker command not found

Exemple :

```text
docker: command not found
```

Docker n'est pas installé ou l'installation a échoué.

Vérifier :

```bash
dpkg -l | grep docker
```

Puis relancer le playbook :

```bash
ansible-playbook -i inventory.yml playbook.yml
```

---

# Erreur : Cannot connect to the Docker daemon

Exemple :

```text
Cannot connect to the Docker daemon
```

Le service Docker n'est probablement pas démarré.

Vérifier :

```bash
sudo systemctl status docker
```

Démarrer le service :

```bash
sudo systemctl start docker
```

Activer le démarrage automatique :

```bash
sudo systemctl enable docker
```

---

# Erreur : permission denied while trying to connect to the Docker daemon socket

Exemple :

```text
permission denied while trying to connect to the Docker daemon socket
```

L'utilisateur n'appartient pas au groupe Docker ou sa session n'a pas encore pris en compte la modification.

Vérifier :

```bash
groups
```

Le groupe suivant doit apparaître :

```text
docker
```

Si nécessaire, se déconnecter puis se reconnecter au serveur.

---

# Vérifier le service Docker

Contrôle rapide :

```bash
systemctl status docker
```

Résultat attendu :

```text
active (running)
```

---

# Vérifier Docker Compose

Contrôle :

```bash
docker compose version
```

Résultat attendu :

```text
Docker Compose version vX.X.X
```

---

# Vérifier le fonctionnement complet de Docker

Télécharger et exécuter un conteneur de test :

```bash
docker run hello-world
```

Résultat attendu :

```text
Hello from Docker!
```

Si ce message apparaît, Docker fonctionne correctement.

---

# Augmenter le niveau de détail d'Ansible

Pour obtenir davantage d'informations lors du diagnostic, il est possible d'utiliser le mode verbeux.

Niveau intermédiaire :

```bash
ansible-playbook -i inventory.yml playbook.yml -vv
```

Niveau avancé :

```bash
ansible-playbook -i inventory.yml playbook.yml -vvv
```

Niveau débogage complet :

```bash
ansible-playbook -i inventory.yml playbook.yml -vvvv
```

Ces options permettent d'obtenir davantage d'informations sur les connexions SSH, les modules Ansible exécutés et les éventuelles erreurs rencontrées.

---

# Vérification finale

Si les commandes suivantes fonctionnent :

```bash
ansible docker_hosts -i inventory.yml -m ping
```

```bash
docker --version
```

```bash
docker compose version
```

```bash
docker run hello-world
```

alors l'installation Docker est considérée comme opérationnelle.
