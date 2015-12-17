#!/bin/bash
#Push site updates from master server to front end web servers via rsync
BALANCER="xxx.xxx.xxx.xxx"
now=$(date +"%d.%m.%Y %T")
DROPLETS=$(ssh -q -oStrictHostKeyChecking=no -i /home/helix/.ssh/id_dsa helix@${BALANCER} cat /home/helix/backend/backend.txt)
webservers=(${DROPLETS})
status="/home/helix/html/magento/datasync.status.html"

if [ ! -z "${DROPLETS}" ]; then

if [ -d /tmp/.rsync.lock ]; then
echo "FAILURE : rsync lock exists : Perhaps there is a lot of new data to push to front end web servers." > $status
exit 1
fi

touch /tmp/.rsync.lock

if [ $? = "1" ]; then
echo "FAILURE : can not create lock" > $status
exit 1
else
echo "SUCCESS : created lock" > $status
fi

for DROPLET in ${webservers[@]}; do

echo "===== Beginning rsync of ${DROPLET} ====="

nice -n 20 /usr/bin/rsync -azx --timeout=30 --delete -e 'ssh -q -oStrictHostKeyChecking=no -i /home/helix/.ssh/id_rsa' --exclude-from=/home/helix/exclude.list  /home/helix/html/magento/ helix@${DROPLET}:/home/helix/html/magento/

if [ $? = "1" ]; then
echo "Time of sync: ${now}" > $status
echo "<br/>" >> $status
echo "FAILURE : rsync failed." >> $status
exit 1
fi

echo "===== Completed rsync of ${DROPLET} =====";
done

/bin/rm -rf /tmp/.rsync.lock
echo "Time of sync: ${now}" > $status
echo "<br/>" >> $status
echo "SUCCESS : rsync completed successfully" >> $status
fi
