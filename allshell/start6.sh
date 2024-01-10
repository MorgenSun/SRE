#!/bin/bash
for i in  {20..25} ;do virsh snapshot-revert  --domain  centos$i --snapshotname init0 ;done
for i in  {20..25} ;do virsh setmaxmem --size 8388608 --domain centos$i ;done
for i in  {20..25} ;do virsh start centos$i ;done
for i in  {20..25} ;do virsh setmem --size 8388608 --domain centos$i ;done


