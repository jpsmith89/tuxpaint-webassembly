#!/bin/bash

# Setup GitHub Pages for Tux Paint WebAssembly Demo

set -e

echo "🚀 Setting up GitHub Pages for Tux Paint WebAssembly"
echo "===================================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if git is available
if ! command -v git &> /dev/null; then
    print_error "Git is required but not installed."
    exit 1
fi

# Check if web files exist
if [ ! -f "web/test_simple.html" ]; then
    print_warning "WebAssembly files not found. Running compilation first..."
    ./test_compile.sh &
    sleep 10
    kill %1 2>/dev/null || true
fi

print_info "Setting up GitHub Pages deployment..."

# Initialize git repository if not already done
if [ ! -d ".git" ]; then
    print_info "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: Tux Paint WebAssembly project"
fi

print_info "Creating deployment branch for GitHub Pages..."

# Create and switch to gh-pages branch
git checkout -b gh-pages 2>/dev/null || git checkout gh-pages

# Copy web files to root of gh-pages branch
print_info "Copying WebAssembly files..."
cp -r web/* .

# Add and commit the web files
git add .
git commit -m "Deploy Tux Paint WebAssembly demo to GitHub Pages"

print_success "Local setup complete!"
echo ""
print_info "Next steps:"
echo "============"
echo ""
echo "1. Create a new repository on GitHub:"
echo "   - Go to https://github.com/new"
echo "   - Name it: tuxpaint-webassembly"
echo "   - Make it public"
echo "   - Don't initialize with README"
echo ""
echo "2. Push to GitHub:"
echo "   git remote add origin https://github.com/jpsmith89/tuxpaint-webassembly.git"
echo "   git push -u origin gh-pages"
echo ""
echo "3. Enable GitHub Pages:"
echo "   - Go to repository Settings → Pages"
echo "   - Source: Deploy from a branch"
echo "   - Branch: gh-pages"
echo "   - Folder: / (root)"
echo "   - Click Save"
echo ""
echo "4. Your app will be available at:"
echo "   https://jpsmith89.github.io/tuxpaint-webassembly/"
echo ""

read -p "Would you like me to help you create the repository and push the code? (y/n): " choice

if [[ $choice =~ ^[Yy]$ ]]; then
    print_info "Creating repository and pushing code..."
    
    # Create repository using GitHub CLI if available, otherwise provide instructions
    if command -v gh &> /dev/null; then
        print_info "Using GitHub CLI to create repository..."
        gh repo create tuxpaint-webassembly --public --description "Tux Paint WebAssembly - Drawing program for kids in the browser"
        git remote add origin https://github.com/jpsmith89/tuxpaint-webassembly.git
        git push -u origin gh-pages
        print_success "Repository created and code pushed!"
    else
        print_info "GitHub CLI not found. Please follow the manual steps above."
        echo ""
        print_info "Manual commands to run:"
        echo "git remote add origin https://github.com/jpsmith89/tuxpaint-webassembly.git"
        echo "git push -u origin gh-pages"
    fi
else
    print_info "Please follow the manual steps above to complete the deployment."
fi

echo ""
print_success "GitHub Pages setup instructions completed!"
print_info "Your Tux Paint WebAssembly demo will be live once you complete the steps above." 