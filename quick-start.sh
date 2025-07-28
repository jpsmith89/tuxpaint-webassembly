#!/bin/bash

# Tux Paint WebAssembly - Quick Start Script
# This script automates the entire setup and build process

set -e

echo "🎨 Tux Paint WebAssembly - Quick Start"
echo "======================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
print_status "Checking prerequisites..."

# Check if Emscripten is available
if ! command -v emcc &> /dev/null; then
    print_warning "Emscripten not found in PATH"
    print_status "Setting up Emscripten environment..."
    
    if [ -f "emsdk/emsdk_env.sh" ]; then
        source emsdk/emsdk_env.sh
        print_success "Emscripten environment loaded"
    else
        print_error "Emscripten SDK not found. Please ensure emsdk is properly installed."
        exit 1
    fi
else
    print_success "Emscripten found"
fi

# Check if Git is available
if ! command -v git &> /dev/null; then
    print_error "Git is required but not installed. Please install Git first."
    exit 1
fi

print_success "Git found"

# Check if CMake is available
if ! command -v cmake &> /dev/null; then
    print_error "CMake is required but not installed. Please install CMake first."
    exit 1
fi

print_success "CMake found"

echo ""

# Step 1: Download Tux Paint source
print_status "Step 1: Downloading Tux Paint source code..."
if [ -d "src/tuxpaint" ]; then
    print_warning "Tux Paint source already exists. Updating..."
    cd src/tuxpaint
    git pull origin master
    cd ../..
else
    ./scripts/download_tuxpaint.sh
fi

print_success "Tux Paint source code ready"
echo ""

# Step 2: Build WebAssembly version
print_status "Step 2: Building WebAssembly version..."
print_warning "This may take several minutes on first build..."

# Try the simple build first
if ./scripts/build_simple.sh; then
    print_success "Simple build completed successfully"
else
    print_warning "Simple build failed, trying CMake build..."
    if ./scripts/build_wasm.sh; then
        print_success "CMake build completed successfully"
    else
        print_error "Both build methods failed. Please check the error messages above."
        exit 1
    fi
fi

echo ""

# Step 3: Check build results
print_status "Step 3: Checking build results..."

if [ -f "web/tuxpaint.html" ] || [ -f "web/tuxpaint.js" ] || [ -f "web/tuxpaint.wasm" ]; then
    print_success "WebAssembly files generated successfully"
    
    echo ""
    print_status "Build Summary:"
    echo "  📁 Source: src/tuxpaint/"
    echo "  📁 Build: build/"
    echo "  📁 Web: web/"
    
    if [ -f "web/tuxpaint.html" ]; then
        echo "  ✅ HTML: web/tuxpaint.html"
    fi
    if [ -f "web/tuxpaint.js" ]; then
        echo "  ✅ JavaScript: web/tuxpaint.js"
    fi
    if [ -f "web/tuxpaint.wasm" ]; then
        echo "  ✅ WebAssembly: web/tuxpaint.wasm"
    fi
    
else
    print_error "No WebAssembly files found in web/ directory"
    print_status "Checking build directory for files..."
    ls -la build/ || true
    exit 1
fi

echo ""

# Step 4: Start local server
print_status "Step 4: Starting local development server..."

# Check if Python is available
if command -v python3 &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null; then
    PYTHON_CMD="python"
else
    print_error "Python is required to start the local server. Please install Python."
    exit 1
fi

print_success "Starting server with $PYTHON_CMD..."
echo ""
echo "🌐 Tux Paint WebAssembly is now running!"
echo "========================================"
echo ""
echo "📱 Open your browser and go to:"
echo "   http://localhost:8000"
echo ""
echo "📁 Or open the HTML file directly:"
if [ -f "web/tuxpaint.html" ]; then
    echo "   file://$(pwd)/web/tuxpaint.html"
elif [ -f "web/index.html" ]; then
    echo "   file://$(pwd)/web/index.html"
fi
echo ""
echo "🛑 To stop the server, press Ctrl+C"
echo ""
echo "📚 For deployment options, see: docs/DEPLOYMENT.md"
echo ""

# Start the server
cd web
$PYTHON_CMD -m http.server 8000 