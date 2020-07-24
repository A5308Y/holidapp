#!/bin/bash

if [[ $(doctl compute droplet list | grep holidapp-prod) ]]; then
    echo "holidapp-prod already exists"
    exit 1
else
    echo "Creating holidapp-prod droplet"
fi

doctl compute droplet create --wait --region fra1 --image ubuntu-20-04-x64 --size s-1vcpu-1gb holidapp-prod --ssh-keys 797406
export HOLIDAPP_IP=`doctl compute droplet list --format "Name,PublicIPv4" | grep holidapp-prod | awk '{print $2}'`
echo Please add A-record $HOLIDAPP_IP for holidapp with your DNS provider
read -r -p "Press any key to continue..." key

scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null provisioning/set_up_docker.sh root@$HOLIDAPP_IP:
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null root@$HOLIDAPP_IP "bash set_up_docker.sh &"
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -r provisioning/* holidapp@$HOLIDAPP_IP:
scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null provisioning/.env-prod holidapp@$HOLIDAPP_IP:
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null holidapp@$HOLIDAPP_IP "docker-compose up -d"
ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null holidapp@$HOLIDAPP_IP "bash init-letsencrypt.sh"
