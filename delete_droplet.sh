#!/bin/bash

API_URL="https://api.digitalocean.com/v2"
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
DROPLET_ID=$(curl -s http://169.254.169.254/metadata/v1/id)
PRIVATE_IPV4=$(curl -s http://169.254.169.254/metadata/v1/interfaces/private/0/ipv4/address)
BALANCER="xxx.xxx.xxx.xxx"

# Get CPU qty
CPU=$(cat /proc/cpuinfo | grep "^processor" | wc -l)
# Calculate droplet average load 5min
LOAD_5=$(cat /proc/loadavg | awk '{print $2}')
LOAD_AVERAGE_5=$(($(echo ${LOAD_5} | awk '{print 100 * $1}') / ${CPU}))
# Droplet average 5min load < 25% then delete droplet
if [ ${LOAD_AVERAGE_5} -le 25 ] ; then
# Remove IP from load balancer
ssh -q -oStrictHostKeyChecking=no -i /home/helix/.ssh/id_rsa helix@${BALANCER} sed -i "/${PRIVATE_IPV4}/d" /home/helix/backend.txt
# Delete droplet now
curl -s -X DELETE "${API_URL}/droplets/${DROPLET_ID}" -H "Authorization: Bearer ${TOKEN}" -H "Content-Type: application/json" >/dev/null 2>&1
fi
