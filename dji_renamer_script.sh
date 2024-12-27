#!/bin/env bash

if [ "$#" -ne 2 ]; then
    echo "Error: Both directory and format arguments are required"
    echo "Usage: $0 directory [original|custom]"
    exit 1
fi

if [ ! -d "$1" ]; then
    echo "Error: '$1' is not a directory"
    exit 1
fi

TARGET_DIR="$1"
FORMAT="$2"

if [[ ! "$FORMAT" =~ ^(original|custom)$ ]]; then
    echo "Error: Second argument must be 'original' or 'custom'"
    exit 1
fi

find "$TARGET_DIR" -type f -name "DJI*" | while read -r file; do
    BASENAME=$(basename "$file")
    EXTENSION="${BASENAME##*.}"

    if [ "$FORMAT" = "custom" ]; then
        # Convert from DJI_20241226142618_0001_D.MP4 to DJI-2024-12-26_14:26:18_0001_D.MP4
        if [[ "$BASENAME" =~ ^DJI_([0-9]{4})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})([0-9]{2})_([0-9]{4}_D)\.(.+)$ ]]; then
            YEAR="${BASH_REMATCH[1]}"
            MONTH="${BASH_REMATCH[2]}"
            DAY="${BASH_REMATCH[3]}"
            HOUR="${BASH_REMATCH[4]}"
            MINUTE="${BASH_REMATCH[5]}"
            SECOND="${BASH_REMATCH[6]}"
            SUFFIX="${BASH_REMATCH[7]}"
            EXT="${BASH_REMATCH[8]}"

            NEW_FILENAME="DJI-${YEAR}-${MONTH}-${DAY}_${HOUR}:${MINUTE}:${SECOND}_${SUFFIX}.${EXT}"
            DIRNAME=$(dirname "$file")
            echo "Converting to custom: '$DIRNAME/$NEW_FILENAME'"
            mv "$file" "$DIRNAME/$NEW_FILENAME"
        fi
    else
        # Convert from DJI-2024-12-26_14:26:18_0001_D.MP4 to DJI_20241226142618_0001_D.MP4
        if [[ "$BASENAME" =~ ^DJI-([0-9]{4})-([0-9]{2})-([0-9]{2})_([0-9]{2}):([0-9]{2}):([0-9]{2})_([0-9]{4}_D)\.(.+)$ ]]; then
            YEAR="${BASH_REMATCH[1]}"
            MONTH="${BASH_REMATCH[2]}"
            DAY="${BASH_REMATCH[3]}"
            HOUR="${BASH_REMATCH[4]}"
            MINUTE="${BASH_REMATCH[5]}"
            SECOND="${BASH_REMATCH[6]}"
            SUFFIX="${BASH_REMATCH[7]}"
            EXT="${BASH_REMATCH[8]}"

            TIMESTAMP="${YEAR}${MONTH}${DAY}${HOUR}${MINUTE}${SECOND}"
            ORIGINAL_FILENAME="DJI_${TIMESTAMP}_${SUFFIX}.${EXT}"
            DIRNAME=$(dirname "$file")
            echo "Converting to original: '$DIRNAME/$ORIGINAL_FILENAME'"
            mv "$file" "$DIRNAME/$ORIGINAL_FILENAME"
        fi
    fi
done
