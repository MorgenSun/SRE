 for i in $(virsh list --name);do scp /etc/hosts root@$i:/etc/hosts;done 
