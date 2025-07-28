#!/bin/bash

# Build Tux Paint WebAssembly
# This script compiles the actual Tux Paint source code to WebAssembly

set -e

echo "🎨 Building Tux Paint WebAssembly..."

# Check if Emscripten is available
if [ ! -f "./emsdk/upstream/emscripten/emcc" ]; then
    echo "❌ Emscripten not found. Please run: ./emsdk/emsdk install latest && ./emsdk/emsdk activate latest"
    exit 1
fi

# Source Emscripten environment
source ./emsdk/emsdk_env.sh

# Create build directory
mkdir -p build
cd build

# Configure with CMake
echo "🔧 Configuring CMake..."
cmake .. -DCMAKE_BUILD_TYPE=Release

# Build
echo "🔨 Building Tux Paint..."
make -j$(sysctl -n hw.ncpu)

# Copy assets
echo "📁 Copying assets..."
mkdir -p web/data
mkdir -p web/stamps
mkdir -p web/fonts
mkdir -p web/sounds

# Copy Tux Paint data files
cp -r ../tuxpaint-0.9.35/data/* web/data/ 2>/dev/null || echo "⚠️  No data files found"
cp -r ../tuxpaint-0.9.35/stamps/* web/stamps/ 2>/dev/null || echo "⚠️  No stamp files found"
cp -r ../tuxpaint-0.9.35/fonts/* web/fonts/ 2>/dev/null || echo "⚠️  No font files found"
cp -r ../tuxpaint-0.9.35/sounds/* web/sounds/ 2>/dev/null || echo "⚠️  No sound files found"

echo "✅ Tux Paint WebAssembly build complete!"
echo "📁 Output files are in: build/web/"
echo "🌐 To test locally: cd build/web && python3 -m http.server 8000" 