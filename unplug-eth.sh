#!/bin/env bash

# This emulates plugging/unplugging a network cable for a VM in QEMU
# Here's the post I used to figure this out:
# https://unix.stackexchange.com/questions/81044/emulate-unplugging-a-network-cable-with-qemu-kvm

function _plug_unplug()
{
    name=$1

    vnet=$(sudo virsh domifaddr $name | grep vnet | awk '{print $1}')

    status=$(sudo virsh domif-getlink $name $vnet | awk '{print $2}')

    if [ $status == "down" ]; then
        status="up"
    else
        status="down"
    fi

    echo "$name's $vnet is now $status"

    sudo virsh domif-setlink $name $vnet $status
}

if [ -z $1 ]; then
    echo "Pass in the name of VM"
else
    _plug_unplug $1
fi
