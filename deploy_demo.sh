#!/bin/bash

# Deploy Tux Paint WebAssembly Demo to Free Hosting

set -e

echo "🚀 Deploying Tux Paint WebAssembly Demo"
echo "======================================="

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

# Check if web files exist
if [ ! -f "web/test_simple.html" ]; then
    print_warning "WebAssembly files not found. Running compilation first..."
    ./test_compile.sh &
    sleep 10
    kill %1 2>/dev/null || true
fi

print_info "Choose your deployment option:"
echo ""
echo "1. GitHub Pages (Free, requires GitHub account)"
echo "2. Netlify (Free, drag & drop deployment)"
echo "3. Vercel (Free, excellent performance)"
echo "4. Firebase Hosting (Free, Google's hosting)"
echo "5. Local testing only"
echo ""

read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        print_info "Setting up GitHub Pages deployment..."
        echo ""
        echo "📋 Steps for GitHub Pages:"
        echo "1. Create a new GitHub repository"
        echo "2. Upload the 'web' folder contents"
        echo "3. Enable GitHub Pages in repository settings"
        echo "4. Your app will be available at: https://yourusername.github.io/repository-name/"
        echo ""
        echo "📁 Files to upload:"
        ls -la web/
        echo ""
        print_success "Ready for GitHub Pages deployment!"
        ;;
    2)
        print_info "Setting up Netlify deployment..."
        echo ""
        echo "📋 Steps for Netlify:"
        echo "1. Go to https://netlify.com"
        echo "2. Sign up for free account"
        echo "3. Drag and drop the 'web' folder to deploy"
        echo "4. Get a free URL like: https://your-app-name.netlify.app"
        echo ""
        print_success "Ready for Netlify deployment!"
        ;;
    3)
        print_info "Setting up Vercel deployment..."
        echo ""
        echo "📋 Steps for Vercel:"
        echo "1. Go to https://vercel.com"
        echo "2. Sign up for free account"
        echo "3. Import your project or drag 'web' folder"
        echo "4. Get a free URL like: https://your-app-name.vercel.app"
        echo ""
        print_success "Ready for Vercel deployment!"
        ;;
    4)
        print_info "Setting up Firebase Hosting..."
        echo ""
        echo "📋 Steps for Firebase:"
        echo "1. Install Firebase CLI: npm install -g firebase-tools"
        echo "2. Run: firebase login"
        echo "3. Run: firebase init hosting"
        echo "4. Set public directory to 'web'"
        echo "5. Run: firebase deploy"
        echo ""
        print_success "Ready for Firebase deployment!"
        ;;
    5)
        print_info "Local testing only..."
        echo ""
        echo "🌐 Start local server:"
        echo "cd web && python3 -m http.server 8000"
        echo ""
        echo "📱 Open in browser: http://localhost:8000/test_simple.html"
        echo ""
        print_success "Local testing ready!"
        ;;
    *)
        print_warning "Invalid choice. Using local testing."
        ;;
esac

echo ""
print_info "Quick Test Commands:"
echo "======================"
echo ""
echo "🔧 Recompile: ./test_compile.sh"
echo "🌐 Local server: cd web && python3 -m http.server 8000"
echo "📱 Test URL: http://localhost:8000/test_simple.html"
echo ""
print_success "Tux Paint WebAssembly is ready for testing!" 