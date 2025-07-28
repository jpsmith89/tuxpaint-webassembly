#!/bin/bash

# Build Tux Paint WebAssembly Version
# This script compiles Tux Paint using Emscripten to create a web application

set -e

echo "Building Tux Paint WebAssembly version..."

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

# Create build directory
mkdir -p build

# Change to build directory
cd build

# Configure with CMake
echo "Configuring build with CMake..."
cmake ../src/tuxpaint \
    -DCMAKE_TOOLCHAIN_FILE=../emsdk/upstream/emscripten/cmake/Modules/Platform/Emscripten.cmake \
    -DCMAKE_BUILD_TYPE=Release \
    -DSDL2_DIR=../emsdk/upstream/emscripten/cache/sysroot/lib/cmake/SDL2 \
    -DSDL2_MIXER_DIR=../emsdk/upstream/emscripten/cache/sysroot/lib/cmake/SDL2_mixer \
    -DSDL2_IMAGE_DIR=../emsdk/upstream/emscripten/cache/sysroot/lib/cmake/SDL2_image \
    -DSDL2_TTF_DIR=../emsdk/upstream/emscripten/cache/sysroot/lib/cmake/SDL2_ttf \
    -DCMAKE_C_FLAGS="-s USE_SDL=2 -s USE_SDL_MIXER=2 -s USE_SDL_IMAGE=2 -s USE_SDL_TTF=2 -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] -s EXPORTED_FUNCTIONS=['_main']" \
    -DCMAKE_EXE_LINKER_FLAGS="-s USE_SDL=2 -s USE_SDL_MIXER=2 -s USE_SDL_IMAGE=2 -s USE_SDL_TTF=2 -s ALLOW_MEMORY_GROWTH=1 -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] -s EXPORTED_FUNCTIONS=['_main']"

# Build the project
echo "Building Tux Paint..."
make -j$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)

# Copy the built files to web directory
echo "Copying built files to web directory..."
mkdir -p ../web
cp tuxpaint.* ../web/ 2>/dev/null || true
cp *.wasm ../web/ 2>/dev/null || true
cp *.js ../web/ 2>/dev/null || true

# Return to project root
cd ..

echo "Build complete! Files are in the web/ directory."
echo "You can now serve the web directory with: python3 -m http.server 8000" 