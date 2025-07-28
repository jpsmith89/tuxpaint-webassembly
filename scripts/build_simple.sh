#!/bin/bash

# Simple Tux Paint WebAssembly Build
# Direct Emscripten compilation approach

set -e

echo "Building Tux Paint WebAssembly (simple approach)..."

# Check if Emscripten is available
if ! command -v emcc &> /dev/null; then
    echo "Error: Emscripten not found. Please run: source emsdk/emsdk_env.sh"
    exit 1
fi

# Check if Tux Paint source exists
if [ ! -d "src/tuxpaint" ]; then
    echo "Error: Tux Paint source not found. Please run: ./scripts/download_tuxpaint.sh"
    exit 1
fi

# Create web directory
mkdir -p web

# Change to Tux Paint source directory
cd src/tuxpaint

# Find main source files
MAIN_SRC=$(find . -name "*.c" -not -path "./src/win32/*" -not -path "./src/macosx/*" | head -20)

echo "Found source files: $MAIN_SRC"

# Compile with Emscripten
echo "Compiling with Emscripten..."
emcc $MAIN_SRC \
    -o ../../web/tuxpaint.html \
    -s USE_SDL=2 \
    -s USE_SDL_MIXER=2 \
    -s USE_SDL_IMAGE=2 \
    -s USE_SDL_TTF=2 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] \
    -s EXPORTED_FUNCTIONS=['_main'] \
    -s FULL_ES2=1 \
    -s FULL_ES3=1 \
    -s USE_WEBGL2=1 \
    -s MIN_WEBGL_VERSION=2 \
    -s SUPPORT_ERRNO=1 \
    -s SUPPORT_LONGJMP=1 \
    -s SUPPORT_C_EXCEPTIONS=1 \
    -s ASSERTIONS=1 \
    -s SAFE_HEAP=1 \
    -s STACK_OVERFLOW_CHECK=1 \
    -s INITIAL_MEMORY=33554432 \
    -s MAXIMUM_MEMORY=268435456 \
    -s ALLOW_TABLE_GROWTH=1 \
    -s ENVIRONMENT=web \
    -s MODULARIZE=1 \
    -s EXPORT_NAME='TuxPaint' \
    --preload-file data@/data \
    --preload-file stamps@/stamps \
    --preload-file fonts@/fonts \
    --preload-file sounds@/sounds \
    -I./src \
    -I./src/include \
    -std=c99 \
    -O2

# Return to project root
cd ../..

echo "Build complete! Files are in the web/ directory."
echo "Open web/tuxpaint.html in your browser to run Tux Paint." 