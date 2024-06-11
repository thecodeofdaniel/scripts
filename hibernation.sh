#!/bin/env bash

function _addHibernation() {
    # Ask for the user for swapsize
    while true; do
        read -rp "Enter size of swapfile (this is in GB): " swapSize

        # Check if the input is empty
        if [[ -z "$swapSize" ]]; then
            echo "Error: Please enter a swapSize."
            continue
        fi

        # Check if the input is a swapSize
        if [[ ! "$swapSize" =~ ^[0-9]+$ ]]; then
            echo "Error: '$swapSize' is not a valid swapSize."
            continue
        fi

        # If the input is valid, break the loop
        break
    done

    # Create/Activate swapfile and add to fstab file
    sudo fallocate -l ${swapSize}G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap defaults 0 0' | sudo tee -a /etc/fstab

    # Grab UUID and offset of swapfile
    UUID=$(findmnt -no UUID -T /swapfile)
    offset=$(sudo filefrag -v /swapfile | awk '{ if($1=="0:"){print $4} }' | sed 's/\.$//' | sed 's/\.$//')

    # Kernel stub
    sudo kernelstub -a "resume=UUID=$UUID resume_offset=$offset"

    # Add following line to file
    mkdir -p /etc/initramfs-tools/conf.d
    sudo touch /etc/initramfs-tools/conf.d/resume
    echo "resume=UUID=$UUID resume_offset=$offset" | sudo tee /etc/initramfs-tools/conf.d/resume

    # Update the configurations
    sudo update-initramfs -u
}

function _removeHibernation() {
    # Grab UUID and offset of swapfile
    UUID=$(findmnt -no UUID -T /swapfile)
    offset=$(sudo filefrag -v /swapfile | awk '{ if($1=="0:"){print $4} }' | sed 's/\.$//' | sed 's/\.$//')

    # Turn off swap and remove the file
    sudo swapoff /swapfile
    sudo rm /swapfile

    # Remove form kernel stub
    sudo kernelstub -d "resume=UUID=$UUID resume_offset=$offset"

    # This is how my default /boot/efi/loader/entries/Pop_OS-current.conf looks like
    # title Pop!_OS
    # linux /EFI/Pop_OS-16db1146-5ca1-4227-8d01-ebf715a26fc6/vmlinuz.efi
    # initrd /EFI/Pop_OS-16db1146-5ca1-4227-8d01-ebf715a26fc6/initrd.img
    # options root=UUID=16db1146-5ca1-4227-8d01-ebf715a26fc6 ro quiet loglevel=0
    # systemd.show_status=false splash

    # Remove the following file
    sudo rm /etc/initramfs-tools/conf.d/resume

    # Update the configurations
    sudo update-initramfs -u

    # Tell user to remove following line from /etc/fstab
    echo "Remove the following line from /etc/fstab\
    /swapfile none swap defaults 0 0"
}


read -rp "Enter y or n (default is y): " response

response=${response,,}  # Convert to lowercase
response=${response:-y}  # If empty, default to 'y'

if [[ $response == "y" ]]; then
    _addHibernation
elif [[ $response == "n" ]]; then
    _removeHibernation
else
    echo "Invalid input. Please enter y or n."
fi
