#!/bin/bash

SUBSCRIPTION=$1
KEYVAULT=$2
ACCOUNT_NAME=$3
CONTAINER_NAME=$4


IFS=$'\n'

help() {
{
   # Display Help
   echo "Donwload all secrets from the keyvault and save them in a sorage account."
   echo
   echo "Syntax: $0 <subscroption> <key vault name> <storage account name> <container name> [-h]"
   echo "options:"
   echo "h     Print this Help."
   echo
}
}

backup_secret() {
    # copy a the secret file into a storage account
    # param:
    #  - secret file

    if [  -f  ./out/$1 ] ; then
        az storage blob upload \
        --account-name ${ACCOUNT_NAME} \
        --container-name ${CONTAINER_NAME} \
        --file ./out/$1 \
        --name $1

        rm ./out/$1

    else
        echo "${1} does not exist."
    fi


}

while getopts ":h" option; do
   case $option in
      h) # display Help
         help
         exit;;
     \?) # incorrect option
         echo "Error: Invalid option"
         exit;;
   esac
done


if [ $# != 4 ] ; then
    help
    exit 1
fi

main() {

    mkdir -p out

    secret_list=$(az keyvault secret list --vault-name $KEYVAULT --subscription $SUBSCRIPTION --query '[].id' -o tsv | awk -F / '{print $NF}' )

    for secret in $secret_list; do
        echo "> ${secret}"
        az keyvault secret backup --file ./out/${secret} --name $secret --vault-name $KEYVAULT --subscription $SUBSCRIPTION
        backup_secret ${secret}
    done

    echo "Done !!!"
}

main
