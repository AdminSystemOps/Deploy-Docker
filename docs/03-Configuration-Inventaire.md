# 03 - Configuration de l'inventaire Ansible

## Introduction

L'inventaire Ansible est le fichier qui indique à Ansible quelles machines doivent être administrées.

Dans ce projet, l'inventaire permet de définir la ou les machines Debian sur lesquelles Docker doit être installé.

Selon le contexte, la machine cible peut être :

* un VPS distant ;
* une machine virtuelle Debian ;
* un serveur physique Debian ;
* le Control Node lui-même.

Le projet fournit plusieurs fichiers d'exemple afin de couvrir les cas d'usage les plus courants.

---

# Pourquoi utiliser des fichiers d'exemple ?

Dans un projet public, il ne faut jamais publier un inventaire réel.

Un inventaire peut contenir des informations sensibles ou propres à ton infrastructure :

* adresses IP publiques ;
* noms DNS internes ;
* noms d'utilisateurs ;
* chemins de clés privées ;
* mots de passe SSH ;
* mots de passe sudo.

Pour cette raison, le projet fournit uniquement des fichiers d'exemple dont le nom se termine par :

```text
.example
```

Avant d'utiliser le playbook, il faut copier le fichier d'exemple adapté à ton contexte vers un fichier réel nommé :

```text
inventory.yml
```

Le fichier `inventory.yml` est ignoré par Git grâce au fichier `.gitignore`.

Cela permet de conserver une documentation exploitable sans publier les informations propres à ton environnement.

---

# Les fichiers d'inventaire disponibles

Le projet fournit quatre modèles d'inventaire.

```text
inventory_password.yml.example
inventory_sshkey.yml.example
inventory_root_sshkey.yml.example
inventory_localhost.yml.example
```

Chaque fichier correspond à un contexte différent.

| Fichier                             | Cas d'usage                                         |
| ----------------------------------- | --------------------------------------------------- |
| `inventory_password.yml.example`    | Connexion SSH avec mot de passe                     |
| `inventory_sshkey.yml.example`      | Connexion SSH avec clé privée                       |
| `inventory_root_sshkey.yml.example` | Connexion SSH directe avec le compte root           |
| `inventory_localhost.yml.example`   | Installation de Docker sur le Control Node lui-même |

---

# Choisir le bon inventaire

## Cas 1 - Connexion SSH par mot de passe

Ce cas est utile lorsque le serveur vient d'être installé et que seule une authentification par mot de passe est disponible.

Exemple :

```text
Control Node
    |
    | SSH + mot de passe
    v
Serveur Debian distant
```

Fichier à utiliser :

```bash
cp inventory_password.yml.example inventory.yml
```

Exemple de contenu :

```yaml
---
all:
  children:
    docker_hosts:
      hosts:
        srv-docker:
          ansible_host: 192.168.1.10
          ansible_user: sysadmin
          ansible_port: 22
          ansible_password: MotDePasse
          ansible_become_password: MotDePasseSudo
```

Dans cet exemple :

* `ansible_host` correspond à l'adresse IP ou au nom DNS de la machine cible
* `ansible_user` correspond au compte utilisé pour la connexion SSH
* `ansible_port` correspond au port SSH
* `ansible_password` correspond au mot de passe SSH
* `ansible_become_password` correspond au mot de passe utilisé pour l'élévation de privilèges avec `sudo`

Ce mode est simple à comprendre, mais il est moins sécurisé qu'une authentification par clé SSH.

Il peut être utilisé dans un environnement de test ou lors du premier accès à une machine, mais il est préférable de passer ensuite à une authentification par clé.

---

## Cas 2 - Connexion SSH par clé privée

Ce cas est recommandé pour l'administration régulière d'une machine Linux.

Exemple :

```text
Control Node
    |
    | SSH + clé privée
    v
Serveur Debian distant
```

Fichier à utiliser :

```bash
cp inventory_sshkey.yml.example inventory.yml
```

Exemple de contenu :

```yaml
---
all:
  children:
    docker_hosts:
      hosts:
        srv-docker:
          ansible_host: 192.168.1.10
          ansible_user: sysadmin
          ansible_port: 22
          ansible_become_password: MotDePasseSudo
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519_server
```

Dans cet exemple :

* `ansible_host` correspond à l'adresse IP ou au nom DNS de la machine cible
* `ansible_user` correspond au compte utilisé pour la connexion SSH
* `ansible_port` correspond au port SSH
* `ansible_become_password` correspond au mot de passe sudo
* `ansible_ssh_private_key_file` correspond au chemin local de la clé privée utilisée pour se connecter

La clé privée reste sur le Control Node.

Seule la clé publique correspondante doit être copiée sur le serveur distant.


---

## Cas 3 - Connexion directe avec le compte root

Certains VPS sont livrés avec un accès direct au compte `root`, souvent par clé SSH.

Ce mode est fréquent chez certains hébergeurs.

Exemple :

```text
Control Node
    |
    | SSH root + clé privée
    v
VPS Debian distant
```

Fichier à utiliser :

```bash
cp inventory_root_sshkey.yml.example inventory.yml
```

Exemple de contenu :

```yaml
---
all:
  children:
    docker_hosts:
      hosts:
        srv-docker:
          ansible_host: 192.168.1.10
          ansible_user: root
          ansible_port: 22
          ansible_ssh_private_key_file: ~/.ssh/id_ed25519_server
```

Dans ce cas, le playbook s'exécute directement avec les droits root.

L'élévation de privilèges avec `sudo` n'est donc pas nécessaire, même si le playbook utilise `become: true`.

Ce mode est pratique pour un premier déploiement, mais il est généralement préférable de créer ensuite un utilisateur d'administration dédié et de désactiver la connexion SSH directe en root.

---

## Cas 4 - Installation sur le Control Node lui-même

Il est aussi possible d'utiliser le playbook pour installer Docker directement sur le Control Node.

Ce cas est utile si la machine qui exécute Ansible est aussi celle qui hébergera les conteneurs Docker.

Exemple :

```text
Control Node
    |
    | exécution locale
    v
Control Node
```

Fichier à utiliser :

```bash
cp inventory_localhost.yml.example inventory.yml
```

Exemple de contenu :

```yaml
---
all:
  children:
    docker_hosts:
      hosts:
        localhost:
          ansible_connection: local
          ansible_python_interpreter: /usr/bin/python
```

Dans ce mode, Ansible n'utilise pas SSH.

Il exécute les tâches localement sur la machine.

L'utilisateur qui lance le playbook doit toutefois disposer de droits `sudo`, car l'installation de Docker modifie le système.

Test recommandé avant exécution :

```bash
sudo whoami
```

Résultat attendu :

```text
root
```

---

# Tester l'inventaire

Avant d'exécuter le playbook complet, il est recommandé de tester la connexion Ansible.

Commande :

```bash
ansible docker_hosts -i inventory.yml -m ping
```

Si tout fonctionne, Ansible doit retourner :

```text
srv-docker | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Pour une installation locale avec `inventory_localhost.yml.example`, le résultat peut ressembler à ceci :

```text
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

Ce test ne vérifie pas Docker.

Il vérifie uniquement qu'Ansible arrive à communiquer avec la machine cible.

---

# Tester l'élévation de privilèges

Le playbook installe des paquets système et modifie des services.

Il doit donc pouvoir obtenir des droits d'administration.

Test :

```bash
ansible docker_hosts -i inventory.yml -m command -a "whoami" --become
```

Résultat attendu :

```text
srv-docker | CHANGED | rc=0 >>
root
```

Si le résultat n'est pas `root`, le playbook risque d'échouer lors de l'installation de Docker.

---

# Variables importantes dans l'inventaire

Les variables les plus utilisées dans ce projet sont les suivantes.

| Variable                       | Rôle                                      |
| ------------------------------ | ----------------------------------------- |
| `ansible_host`                 | Adresse IP ou nom DNS de la machine cible |
| `ansible_user`                 | Utilisateur SSH utilisé pour la connexion |
| `ansible_port`                 | Port SSH utilisé                          |
| `ansible_password`             | Mot de passe SSH                          |
| `ansible_become_password`      | Mot de passe sudo                         |
| `ansible_ssh_private_key_file` | Chemin local de la clé privée             |
| `ansible_connection: local`    | Exécution locale sans SSH                 |

---

# Bonnes pratiques

Ne versionne jamais le fichier réel :

```text
inventory.yml
```

Ne publie jamais :
* une clé privée SSH
* un mot de passe SSH
* un mot de passe sudo
* une adresse IP publique sensible
* un inventaire de production

Les fichiers `.example` servent uniquement de modèles.

Ils doivent être copiés puis adaptés localement.

---

# Vérification finale

Avant de passer au déploiement de Docker, vérifie les points suivants :
* le bon fichier `.example` a été copié vers `inventory.yml`
* l'adresse IP ou le nom DNS de la machine cible est correct
* l'utilisateur SSH est correct
* le port SSH est correct
* la méthode d'authentification correspond au contexte
* la connexion Ansible fonctionne avec le module `ping`
* l'élévation de privilèges fonctionne avec `--become`

Lorsque ces points sont validés, l'inventaire est prêt et le playbook Docker peut être exécuté.
