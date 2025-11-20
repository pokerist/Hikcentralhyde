#!/bin/bash

# Script to install Python requirements in the correct order
# This handles the special case of dlib and face-recognition

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Ensure we're in the right directory
if [ ! -f "requirements.txt" ]; then
    print_error "requirements.txt not found!"
    exit 1
fi

print_info "Step 1: Upgrading pip, setuptools, and wheel..."
pip install --upgrade pip setuptools wheel

print_success "Core tools upgraded"

print_info "Step 2: Installing build dependencies..."
pip install cmake

print_success "CMake installed"

print_info "Step 3: Installing numpy (this may take a few minutes)..."
pip install "numpy>=1.26.0"

print_success "NumPy installed"

print_info "Step 4: Installing basic dependencies..."
pip install flask==3.0.0 werkzeug==3.0.1 requests==2.31.0 python-dotenv==1.0.0
pip install schedule==1.2.0 cryptography==41.0.7 pyjwt==2.8.0 Pillow==10.1.0

print_success "Basic dependencies installed"

print_info "Step 5: Installing opencv-python..."
pip install opencv-python

print_success "OpenCV installed"

print_info "Step 6: Installing dlib (this will take 5-10 minutes)..."
print_warning "Please be patient, dlib needs to compile from source..."

# Try to install dlib
if pip install dlib; then
    print_success "dlib installed successfully"
else
    print_warning "dlib installation failed, trying alternative method..."
    
    # Alternative: install pre-built wheel if available
    pip install --upgrade cmake
    pip install dlib --no-cache-dir
    
    if [ $? -eq 0 ]; then
        print_success "dlib installed successfully (alternative method)"
    else
        print_error "Failed to install dlib"
        print_info "You may need to install it manually or skip face recognition"
        exit 1
    fi
fi

print_info "Step 7: Installing face-recognition..."
pip install face-recognition

print_success "face-recognition installed"

print_success "All dependencies installed successfully!"
echo ""
echo -e "${BLUE}Installed packages:${NC}"
pip list | grep -E "(flask|requests|numpy|dlib|face-recognition|opencv)"
