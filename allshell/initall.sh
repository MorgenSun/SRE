#!/bin/bash
for i in  {20..30} ;do virsh snapshot-revert  --domain  centos$i --snapshotname init0 ;done
for i in  {20..30} ;do virsh setmaxmem --size 16777216 --domain centos$i ;done
for i in  {20..30} ;do virsh start centos$i ;done
for i in  {20..30} ;do virsh setmem --size 16777216 --domain centos$i ;done

virsh snapshot-revert --domain centos100 --snapshotname nginx
virsh start centos100
