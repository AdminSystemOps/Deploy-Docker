# 01 - Prérequis sur le Control Node

## Introduction

Avant de pouvoir déployer Docker sur un serveur distant, il est nécessaire de disposer d'une machine d'administration appelée **Control Node**.

Le Control Node est la machine depuis laquelle Ansible sera exécuté. C'est lui qui se connectera aux serveurs distants via SSH pour effectuer les opérations d'installation et de configuration.

Dans le cadre de ce projet, le Control Node peut être :

* Une machine Linux physique
* Une machine virtuelle Linux
* Un poste de travail sous Linux
* Une machine d'administration dédiée

Les exemples présentés dans cette documentation ont été réalisés sous Debian.

---

# Pourquoi utiliser un environnement virtuel Python ?

Ansible est une application Python.

Il serait possible d'installer Ansible directement sur le système d'exploitation avec :

```bash
sudo apt install ansible
```

Cependant, cette méthode présente plusieurs inconvénients :

* La version disponible dans les dépôts est parfois ancienne.
* Plusieurs projets peuvent nécessiter des versions différentes d'Ansible.
* Les dépendances Python du système peuvent entrer en conflit avec celles d'Ansible.
* La suppression du projet peut devenir compliquée.

Pour éviter ces problèmes, il est recommandé d'utiliser un **environnement virtuel Python**.

Un environnement virtuel permet d'isoler complètement les dépendances d'un projet dans un dossier dédié.

Chaque projet peut ainsi disposer de ses propres versions de Python, Ansible et autres bibliothèques sans impacter le reste du système.

Cette approche est aujourd'hui considérée comme une bonne pratique dans l'écosystème Python.

---

# Vérifier la présence de Python

Ansible nécessite Python sur le Control Node.

Vérifie sa présence :

```bash
python3 --version
```

Exemple :

```text
Python 3.13.5
```
Pour l'environnement virtuel Python, exécute cette commande :

```bash
virtualenv --version
```

Exemple :

```text
virtualenv 21.2.4 from /usr/lib/python3/dist-packages/virtualenv/__init__.py
```

Si Python et virtualenv ne sont pas installés :

```bash
sudo apt update
sudo apt install python3 python3-venv python3-pip
```

---

# Création de l'environnement virtuel

Place-toi dans le répertoire du projet :

```bash
cd Deploy-Docker
```

Créer l'environnement virtuel :

```bash
python3 -m venv .venv
```

Cette commande crée un dossier `.venv` contenant un environnement Python isolé.

---

# Activation de l'environnement virtuel

Avant d'utiliser Ansible, active l'environnement :

```bash
source .venv/bin/activate
```

Le terminal affiche généralement :

```text
(.venv) utilisateur@machine:~/Deploy-Docker$
```

Cela indique que toutes les commandes Python seront exécutées dans l'environnement virtuel du projet.

---

# Installation des dépendances

Le projet utilise un fichier `requirements.txt`.

Ce fichier centralise l'ensemble des dépendances Python nécessaires.

Exemple :

```text
ansible
```

Installer les dépendances :

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Selon la vitesse de la connexion Internet, l'opération peut prendre quelques minutes.

---

# Vérification de l'installation

Vérifier la version d'Ansible :

```bash
ansible --version
```

Exemple :

```text
ansible [core 2.20.3]
```

---

# Mise à jour des dépendances

Pour mettre à jour les dépendances du projet :

```bash
pip install --upgrade -r requirements.txt
```

---

# Désactivation de l'environnement virtuel

Une fois le travail terminé :

```bash
deactivate
```

Le terminal revient alors à son environnement Python normal.

---

# Suppression de l'environnement virtuel

Si l'environnement doit être recréé :

```bash
rm -rf .venv
```

Puis :

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

---

# Vérification finale

Avant de poursuivre la documentation, les commandes suivantes doivent fonctionner :

```bash
python3 --version
```

```bash
ansible --version
```


Si ces trois commandes retournent une version, le Control Node est prêt à exécuter le projet Deploy-Docker.
