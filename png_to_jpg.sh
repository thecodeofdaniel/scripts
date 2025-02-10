#!/bin/env bash

# Extract filename without extension
filename="${1%.*}"

# Convert PNG to JPG
ffmpeg -i "$1" -q:v 2 "${filename}.jpg"
