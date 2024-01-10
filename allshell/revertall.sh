#!/bin/bash
for i in $(virsh list --name);do ssh root@$i init 0 ;done 
for i in  {20..30} ;do virsh snapshot-revert  --domain  centos$i --snapshotname init0 ;done
virsh snapshot-revert --domain centos100 --snapshotname nginx
