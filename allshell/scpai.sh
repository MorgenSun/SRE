 for i in $(virsh list --name| grep -v 100);do scp -r /root/AI root@$i:/root;done 
