#!/bin/env bash

# The name of the profile for firefox
PROFILE_NAME="DANIEL"

# Firefox and Brave profiles
FIREFOX_PROFILE_LOC="$HOME/.mozilla/firefox/$PROFILE_NAME"
BRAVE_PROFILE_LOC="$HOME/.config/BraveSoftware/Brave-Browser/Default"


# This will insert an existing profile to firefox
function _USBtoComputer
{
    # check if Firefox profile on USB exists
    if [ -d "./$PROFILE_NAME-firefox" ]; then
        cp "./$PROFILE_NAME-firefox" "$FIREFOX_PROFILE_LOC"
        printf "Copied Firefox profile from USB to computer\n"
    fi

    # check if Brave profile on USB exists
    if [ -d "./$PROFILE_NAME-brave" ]; then
        cp "./$PROFILE_NAME-brave" "$BRAVE_PROFILE_LOC"
        printf "Copied Brave profile from USB to computer\n"
    fi
}


function _computerToUSB
{
    cp "$0" "$DEST" # copy this script to destination

    # check if Firefox profile on computer exists
    if [ -d "$FIREFOX_PROFILE_LOC" ]; then
        cp -r "$FIREFOX_PROFILE_LOC" "$DEST/$PROFILE_NAME-firefox"
        printf "Copied Firefox profile from Computer to USB\n"
    fi

    # check if Brave profile on computer exists
    if [ -d "$BRAVE_PROFILE_LOC" ]; then
        cp -r "$BRAVE_PROFILE_LOC" "$DEST/$PROFILE_NAME-brave"
        printf "Copied Brave profile from Computer to USB\n"
    fi
}


# User will determine the location of where these profiles will be
function _getUSBLocation() {
    DEST=""

    # Ask where the user wants to copy the profile to
    echo
    lsblk -o NAME,SIZE,MOUNTPOINT
    printf "\e[32m\nIn which directory (MOUNTPOINT) should I copy the profile to?:\e[0m "
    read dest

    # Confirm his option
    printf "\nThis is the directory you chose: \e[4m$dest\e[0m\n"
    printf "\e[33mAre you sure? [Y/n]:\e[0m "
    read confirm

    # If yes continue
    if [ "$confirm" == "" ] || [ "${confirm^^}" == 'Y' ]; then
        if [ -d "$dest" ]; then
            DEST="$dest"
        else
            printf "\e[31m\e[4m$dest\e[0m\e[31m DOES NOT exist\e[0m\n"
            _getUSBLocation
        fi
    else
        _getUSBLocation
    fi
}


# User selects between extraction or insertion
function _selection
{
    printf "Do you want to copy profile from...\n"
    printf "1. Computer to USB\n"
    printf "2. USB to Computer\n"
    read -p "Select [1|2]: " choice

    if   [ $choice == 1 ]; then
        _getUSBLocation
        _computerToUSB
    elif [ $choice == 2 ]; then
        _USBtoComputer
    else
        _selection
    fi
}

_selection
