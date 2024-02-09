#!/bin/env bash

# The name of the profile for firefox
PROFILE_NAME="Daniel"

# Firefox and Brave profiles
FIREFOX="$HOME/.mozilla/firefox/$PROFILE_NAME"
BRAVE="$HOME/.config/BraveSoftware/Brave-Browser/Default"


# This will insert an existing profile to firefox
function _insertion
{
    counter=0

    if [ -d "./$PROFILE_NAME-firefox" ]; then
        cp "./$PROFILE_NAME-firefox" "$FIREFOX"
        ((counter++))
    fi

    if [ -d "./$PROFILE_NAME-brave" ]; then
        cp "./$PROFILE_NAME-brave" "$BRAVE"
        ((counter++))
    fi

    printf "Inserted $counter profiles\n"
}


function _extraction
{
    counter=0
    cp "$0" "$DEST" # copy this script to destination

    if [ -d "$FIREFOX" ]; then
        cp -r "$FIREFOX" "$DEST/$PROFILE_NAME-firefox"
        ((counter++))
    fi

    if [ -d "$BRAVE" ]; then
        cp -r "$BRAVE" "$DEST/$PROFILE_NAME-brave"
        ((counter++))
    fi

    printf "Extracted $counter profiles\n"
}


# User will determine the location of where these profiles will be
function _getDest() {
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
            _getDest
        fi
    else
        _getDest
    fi
}


# User selects between extraction or insertion
function _selection
{
    read -p "Do you want to extract or insert? [e/i]: " choice

    if   [ "$choice" == 'e' ]; then
        _getDest
        _extraction
    elif [ "$choice" == 'i' ]; then
        _insertion
    else
        _selection
    fi
}

_selection
