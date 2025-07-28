#!/bin/bash

# Build Tux Paint WebAssembly directly with Emscripten
# This script compiles the actual Tux Paint source code to WebAssembly using emcc directly

set -e

echo "🎨 Building Tux Paint WebAssembly directly..."

# Check if Emscripten is available
if [ ! -f "./emsdk/upstream/emscripten/emcc" ]; then
    echo "❌ Emscripten not found. Please run: ./emsdk/emsdk install latest && ./emsdk/emsdk activate latest"
    exit 1
fi

# Source Emscripten environment
source ./emsdk/emsdk_env.sh

# Create output directory
mkdir -p web

# Compile directly with emcc
echo "🔨 Compiling Tux Paint with Emscripten..."
emcc tuxpaint-0.9.35/src/tuxpaint_wasm.c \
    -o web/tuxpaint.html \
    -s USE_SDL=2 \
    -s USE_SDL_IMAGE=2 \
    -s USE_SDL_TTF=2 \
    -s USE_SDL_MIXER=2 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] \
    -s EXPORTED_FUNCTIONS=['_main','_tuxpaint_init','_tuxpaint_set_color','_tuxpaint_clear_canvas','_tuxpaint_set_brush_size'] \
    -s ENVIRONMENT=web \
    -std=c99 \
    -O2

# Copy assets
echo "📁 Copying assets..."
mkdir -p web/data
mkdir -p web/stamps
mkdir -p web/fonts
mkdir -p web/sounds

# Copy Tux Paint data files
cp -r tuxpaint-0.9.35/data/* web/data/ 2>/dev/null || echo "⚠️  No data files found"
cp -r tuxpaint-0.9.35/stamps/* web/stamps/ 2>/dev/null || echo "⚠️  No stamp files found"
cp -r tuxpaint-0.9.35/fonts/* web/fonts/ 2>/dev/null || echo "⚠️  No font files found"
cp -r tuxpaint-0.9.35/sounds/* web/sounds/ 2>/dev/null || echo "⚠️  No sound files found"

echo "✅ Tux Paint WebAssembly build complete!"
echo "📁 Output files are in: web/"
echo "🌐 To test locally: cd web && python3 -m http.server 8000" 