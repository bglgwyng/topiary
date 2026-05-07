#!/bin/bash

# This is a comment - it describes what the script does.
# The 'shebang' on line 1 tells the system to use the Bash interpreter.

# Check if an argument was provided
if [ -z "$1" ]; then
  echo "Usage: $0 [your_name]"
  exit 1
fi

# Store the first argument in a variable
NAME=$1

# Print a greeting to the terminal
echo "Hello, $NAME! Today is $(date)."
