#!/bin/env bash

# Description: This will create a new SSH key for your GitHub

function _create_sshkey()
{
    ssh-keygen -t ed25519 -C "$git_email"
    eval "$(ssh-agent -s)"

    printf "\n\e[4mCopy the contents below and add it to your Github account\n\e[0m"
    cat "$HOME/.ssh/id_ed25519.pub"
}

# Get Git username
git_username=$(git config --get user.name)

# Get Git email
git_email=$(git config --get user.email)

# Prompt the user to enter Git username if it's empty
if [ -z "$git_username" ]; then
    read -rp "Enter your GitHub username: " git_username
    git config --global user.name "$git_username"
fi

# Prompt the user to enter Git email if it's empty
if [ -z "$git_email" ]; then
    read -rp "Enter GitHub email: " git_email
    git config --global user.email "$git_email"
fi

_create_sshkey
