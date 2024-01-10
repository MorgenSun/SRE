#!/bin/bash

for i in $(virsh list --all| grep -v 'running' | awk '{print $2}' | grep centos);do virsh start $i;done
#for i in  {20..24} ;do virsh snapshot-revert  --domain  centos$i --snapshotname init0 ;done
#for i in  {20..24} ;do virsh setmaxmem --size 16777216 --domain centos$i ;done
#for i in  {20..24} ;do virsh start centos$i ;done
#for i in  {20..24} ;do virsh setmem --size 16777216 --domain centos$i ;done
