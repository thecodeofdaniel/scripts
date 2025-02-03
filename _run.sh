#!/bin/env bash

# Get the directory where the script is located
SCRIPTS_DIR="$(dirname "$(readlink -f "$0")")"
LAUNCHER_NAME=$(basename "$0")

# Find executable scripts in the directory, sort them, and store in an array
# Exclude the launcher script itself
SCRIPTS=($(find "$SCRIPTS_DIR" -maxdepth 1 -type f -executable ! -name "$LAUNCHER_NAME" | sort))

# Check if there are any scripts available
if [[ ${#SCRIPTS[@]} -eq 0 ]]; then
  echo "No executable scripts found in $SCRIPTS_DIR"
  exit 1
fi

# Display scripts with numbers
echo "Available scripts:"
for i in "${!SCRIPTS[@]}"; do
  echo "$((i + 1))) $(basename "${SCRIPTS[i]}")"
done

# Prompt the user to select a script
read -p "Select a script to run (1-${#SCRIPTS[@]}): " choice

# Validate input
if ! [[ "$choice" =~ ^[0-9]+$ ]] || (( choice < 1 || choice > ${#SCRIPTS[@]} )); then
  echo "Invalid selection."
  exit 1
fi

# Get the selected script
selected_script="${SCRIPTS[choice-1]}"

# Prompt for arguments
read -p "Enter arguments for the script (press Enter for none): " -r args

# Run the selected script with the provided arguments
if [ -z "$args" ]; then
    "$selected_script"
else
    # Split the args string into an array and execute
    eval "$selected_script $args"
fi
