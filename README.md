# Deploy-Docker

Déploiement automatisé de Docker Engine sur Debian à l'aide d'Ansible.
Dépôt GitHub : https://github.com/AdminSystemOps/Deploy-Docker

## Présentation

Deploy-Docker est un projet Ansible permettant d'installer automatiquement Docker Engine sur une machine Debian.

Le projet a été conçu pour faciliter le déploiement rapide d'environnements Docker sur différents types d'infrastructures :
* VPS chez un hébergeur (OVH, Scaleway, Hetzner, Contabo, etc.)
* Machine virtuelle sous VMware Workstation
* Machine virtuelle sous VirtualBox
* Machine virtuelle hébergée sur Proxmox VE
* Serveur physique Debian

L'objectif est de disposer d'une procédure simple, reproductible et documentée permettant de préparer une machine à l'exécution de conteneurs Docker.

---

## Fonctionnement

Le playbook réalise automatiquement les opérations suivantes :
* Vérification de la distribution Linux cible
* Suppression des anciens paquets Docker incompatibles
* Installation des dépendances requises
* Ajout du dépôt officiel Docker
* Installation de Docker Engine
* Installation de Docker Compose Plugin
* Activation du service Docker
* Ajout des utilisateurs souhaités au groupe Docker

---

## Structure du projet

```text
Deploy-Docker/
├── README.md
├── LICENSE
├── .gitignore
│
├── ansible.cfg
├── playbook.yml
├── install-docker.sh
│
├── inventory_localhost.yml.example
├── inventory_password.yml.example
├── inventory_sshkey.yml.example
├── inventory_root_sshkey.yml.example
│
├── requirements.txt
│
└── docs/
    ├── 01-Prerequis-ControlNode.md
    ├── 02-Prerequis-Cible.md
    ├── 03-Configuration-Inventaire.md
    ├── 04-Deploiement-Docker.md
    └── 05-Depannage.md
```

---

## Documentation

Avant de lancer le playbook, il est recommandé de lire les documents suivants :

| Document                       | Description                           |
| ------------------------------ | ------------------------------------- |
| 01-Prerequis-ControlNode.md    | Préparation de la machine Ansible     |
| 02-Prerequis-Cible.md          | Préparation du serveur Debian cible   |
| 03-Configuration-Inventaire.md | Configuration de l'inventaire Ansible |
| 04-Deploiement-Docker.md       | Déploiement de Docker                 |
| 05-Depannage.md                | Résolution des problèmes courants     |

---

## Déploiement rapide

Cloner le dépôt GitHub :

```bash
git clone https://github.com/AdminSystemOps/Deploy-Docker.git
cd Deploy-Docker
```

Créer un environnement virtuel Python :

```bash
python3 -m venv .venv
source .venv/bin/activate
```

Installer les dépendances :

```bash
pip install --upgrade pip
pip install -r requirements.txt
```

Choisir un modèle d'inventaire :

```bash
cp inventory_sshkey.yml.example inventory.yml
```

Modifier le fichier :

```bash
nano inventory.yml
```

Lancer le déploiement :

```bash
chmod +x install-docker.sh
./install-docker.sh
```

---

## Vérification

Une fois le playbook exécuté, reconnecte-toi à la machine cible puis vérifie :

```bash
docker --version
```

et :

```bash
docker compose version
```

Les commandes doivent retourner la version installée de Docker et Docker Compose.

---

## Licence

Ce projet est distribué sous licence MIT.
