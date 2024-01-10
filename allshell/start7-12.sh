#!/bin/bash
for i in  {26..31} ;do virsh snapshot-revert  --domain  centos$i --snapshotname init0 ;done
for i in  {26..31} ;do virsh setmaxmem --size 8388608 --domain centos$i ;done
for i in  {26..31} ;do virsh start centos$i ;done
for i in  {26..31} ;do virsh setmem --size 8388608 --domain centos$i ;done


