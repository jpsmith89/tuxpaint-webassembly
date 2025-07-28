#!/bin/bash

# Download Tux Paint Source Code
# This script downloads the latest Tux Paint source code from the official repository

set -e

echo "Downloading Tux Paint source code..."

# Create src directory if it doesn't exist
mkdir -p src

# Change to src directory
cd src

# Check if tuxpaint directory already exists
if [ -d "tuxpaint" ]; then
    echo "Tux Paint source already exists. Updating..."
    cd tuxpaint
    git pull origin master
else
    echo "Cloning Tux Paint repository..."
    # Clone the official Tux Paint repository
    git clone https://git.code.sf.net/p/tuxpaint/code tuxpaint
    cd tuxpaint
fi

# Checkout the latest stable release
echo "Checking out latest stable release..."
git checkout master

echo "Tux Paint source code downloaded successfully!"
echo "Source location: $(pwd)"

# Return to project root
cd ../..

echo "Download complete. You can now run ./scripts/build_wasm.sh to build the WebAssembly version." 