#!/bin/bash

# Test WebAssembly compilation with a simple C program

set -e

echo "🧪 Testing WebAssembly Compilation"
echo "=================================="

# Setup Emscripten environment
source emsdk/emsdk_env.sh

echo "✅ Emscripten environment loaded"

# Create web directory if it doesn't exist
mkdir -p web

echo "🔨 Compiling test program to WebAssembly..."

# Compile the test program with minimal flags
emcc test_simple.c \
    -o web/test_simple.html \
    -s USE_SDL=2 \
    -s ALLOW_MEMORY_GROWTH=1 \
    -s EXPORTED_RUNTIME_METHODS=['ccall','cwrap'] \
    -s EXPORTED_FUNCTIONS=['_main','_draw_circle','_draw_rectangle','_clear_screen'] \
    -s ENVIRONMENT=web \
    -std=c99 \
    -O2

echo "✅ Compilation completed!"

# Check if files were created
if [ -f "web/test_simple.html" ]; then
    echo "✅ HTML file created: web/test_simple.html"
fi

if [ -f "web/test_simple.js" ]; then
    echo "✅ JavaScript file created: web/test_simple.js"
fi

if [ -f "web/test_simple.wasm" ]; then
    echo "✅ WebAssembly file created: web/test_simple.wasm"
fi

echo ""
echo "🌐 Starting test server..."
echo "📱 Open your browser and go to: http://localhost:8000/test_simple.html"
echo "🛑 Press Ctrl+C to stop the server"
echo ""

# Start the server
cd web
python3 -m http.server 8000 