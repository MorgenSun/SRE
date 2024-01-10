#!/bin/bash
rm -rf  /home/lab/addtionaldrive/*
for i in {20..24};do virsh snapshot-revert  --domain  centos$i --snapshotname init0 ;done
for i in {20..24};do qemu-img create -f qcow2 /home/lab/addtionaldrive/centos"$i"add1.qcow2 10G  && \
qemu-img create -f qcow2 /home/lab/addtionaldrive/centos"$i"add2.qcow2 10G  && \
virsh attach-disk centos$i /home/lab/addtionaldrive/centos"$i"add1.qcow2 vdb --persistent --subdriver qcow2  && \
virsh attach-disk centos$i /home/lab/addtionaldrive/centos"$i"add2.qcow2 vdc --persistent --subdriver qcow2  && \
virsh setmaxmem --size 16777216 --domain centos$i && \
virsh start centos$i && \
virsh setmem --size 16777216 --domain centos$i ;done