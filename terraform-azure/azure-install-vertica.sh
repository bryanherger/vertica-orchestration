#!/bin/bash
echo TODO - scripted install
VM_PREFIX=$1
VM_COUNT=$2
BASENAME=$3
for ((i = 0 ; i < $VM_COUNT ; i++)); do
  echo "$VM_PREFIX$i" >> instances.txt
done
python list2csv.py < instances.txt > instances.csv
HOSTS_CSV=`cat instances.csv`
declare host_array
host_array=()
while read p; do
  host_array+=($p)
  INSTALL_CONFIG_HOST=$p
done <instances.txt
for p in "${host_array[@]}"
do
  echo "instance: $p"
  scp -o stricthostkeychecking=false /vertica/tmp/*.rpm $BASENAME@$p:/tmp
  scp -o stricthostkeychecking=false ~/.ssh/id_rsa $BASENAME@$p:~/.ssh/id_rsa
  ssh -o stricthostkeychecking=false $BASENAME@$p sudo yum install -y /tmp/*.rpm
  ssh -o stricthostkeychecking=false $BASENAME@$p sudo systemctl start haveged
  ssh -o stricthostkeychecking=false $BASENAME@$p sudo mkdir -p /root/.ssh
  ssh -o stricthostkeychecking=false $BASENAME@$p sudo cp /home/$BASENAME/.ssh/id_rsa /root/.ssh/id_rsa
done
echo $HOSTS_CSV $INSTALL_CONFIG_HOST
echo $INSTALL_CONFIG_HOST > install_config_host.csv
ssh -o stricthostkeychecking=false $BASENAME@$INSTALL_CONFIG_HOST sudo -n -H /opt/vertica/sbin/install_vertica -s $HOSTS_CSV -d /vertica/data --failure-threshold NONE --dba-user-password-disabled -T -L CE -Y
echo ssh -o stricthostkeychecking=false $BASENAME@$INSTALL_CONFIG_HOST sudo -n -H -u dbadmin /opt/vertica/bin/admintools -t create_db --hosts $HOSTS_CSV -d `hostname|sed 's/-/_/g'` -p Vertica1 -c /vertica/data -D /vertica/data
ssh -o stricthostkeychecking=false $BASENAME@$INSTALL_CONFIG_HOST sudo -n -H -u dbadmin /opt/vertica/bin/admintools -t create_db --hosts $HOSTS_CSV -d `hostname|sed 's/-/_/g'` -p Vertica1

