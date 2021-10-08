# Prisma Cloud Simple Resource Type Inventory Script

[![CodeFactor](https://www.codefactor.io/repository/github/kyle9021/prisma_resource_type_simple_inventory/badge/main)](https://www.codefactor.io/repository/github/kyle9021/prisma_resource_type_simple_inventory/overview/main)

## REQUIREMENTS:

git needs to be installed

* debian/ubuntu: `sudo apt-get install git`
* rhel/fedora: `sudo yum install git`
* macos: `sudo brew install git`

jq needs to be installed: 

* debian/ubuntu: `sudo apt install jq`
* rhel/fedora: `sudo yum install jq`
* macos: `sudo brew install jq`

Recommendations for hardening are: store variables in a secret manager of choice or export the access_keys/secret_key as env variables in a separate script. 

Decision here is to use environment variables to simplify the workflow and mitigate risk of including credentials in the script.

_note: if bash_history is turned on the keys will be in the bash_history_ 

To clear .bash_history and create a new .bash_history file:

```bash
rm $HOME/.bash_history
touch $HOME/.bash_history
```

Access key and secret key should be created in the Prisma Cloud Enterprise Edition Console under: Settings > Accesskeys

## INSTRUCTIONS:

* install requirements jq and git
* export the environment variables in shell with the below commands

### COMMANDS:

```bash
git clone https://github.com/Kyle9021/prisma_resource_type_simple_inventory
cd prisma_resource_type_simple_inventory/
export ACCESSKEY="<ACCESS_KEY_FROM_CONSOLE_HERE>"
export SECRETKEY="<SECRET_KEY_FROM_CONSOLE_HERE>"
export APIURL="<PRISMA_API_URL_HERE"
bash ./resource_type_inventory_script.sh
```
