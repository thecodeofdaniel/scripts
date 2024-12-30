#!/bin/env bash

# Check if directory argument is provided
if [ $# -ne 1 ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi

directory="$1"

# Check if directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory '$directory' does not exist"
    exit 1
fi

# Change to the specified directory
cd "$directory" || exit 1

# Counter for new filenames
count=1

# Process files (not directories) sorted by creation time
while IFS= read -r file; do
    # Skip if it's a directory
    [ -d "$file" ] && continue

    # Get file extension
    extension="${file##*.}"

    # Create new filename with padded number
    new_name=$(printf "%02d.%s" "$count" "$extension")

    # Rename file if it's different from the new name
    if [ "$file" != "$new_name" ]; then
        mv "$file" "$new_name"
        echo "Renamed: $file -> $new_name"
    fi

    ((count++))

# Use stat to sort by creation time (birth time if available, modification time as fallback)
done < <(find . -maxdepth 1 -type f -printf '%T@ %p\n' | sort -n | cut -d' ' -f2-)
