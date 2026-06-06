#!/usr/bin/env bash
set -euo pipefail

ansible-playbook -i inventory.yml playbook.yml