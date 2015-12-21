#!/bin/bash

API_URL="https://api.digitalocean.com/v2"
TOKEN="xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
NODE_ID=$(echo $RANDOM)
IMAGE_ID="xxxxxxx"
SSH="xxxxxx"

# Get CPU qty
CPU=$(cat /proc/cpuinfo | grep "^processor" | wc -l)
# Calculate droplet average load 5min
LOAD_5=$(cat /proc/loadavg | awk '{print $1}')
LOAD_AVERAGE_5=$(($(echo ${LOAD_5} | awk '{print 100 * $1}') / ${CPU}))
# Droplet average 5min load > 75% then create new droplet
if [ ${LOAD_AVERAGE_5} -ge 75 ] ; then
curl -s -X POST "${API_URL}/droplets" \
  -d"{\"name\":\"magento-web-node-${NODE_ID}\",\"region\":\"nyc1\",\"size\":\"2gb\",\"private_networking\":true,\"image\":\"${IMAGE_ID}\",\"ssh_keys\":[${SSH}]}" \
	-H "Authorization: Bearer ${TOKEN}" \
	-H "Content-Type: application/json"  >/dev/null 2>&1
fi
