#!/bin/bash

# HydePark Sync System - Deployment Script
# This script automates the initial deployment on Ubuntu server

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
APP_NAME="hydepark-sync"
INSTALL_DIR="/opt/$APP_NAME"
SERVICE_NAME="hydepark-sync.service"
CURRENT_USER=$(whoami)

# Functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

check_root() {
    if [ "$EUID" -eq 0 ]; then 
        print_error "لا تشغل هذا السكريبت بصلاحيات root"
        print_info "استخدم: bash deploy.sh"
        exit 1
    fi
}

check_ubuntu() {
    if [ ! -f /etc/os-release ]; then
        print_error "نظام التشغيل غير مدعوم"
        exit 1
    fi
    
    . /etc/os-release
    if [ "$ID" != "ubuntu" ]; then
        print_warning "هذا السكريبت مصمم لـ Ubuntu، قد يحتاج تعديلات على $ID"
    fi
}

install_system_dependencies() {
    print_header "تثبيت متطلبات النظام"
    
    print_info "تحديث قائمة الحزم..."
    sudo apt update
    
    print_info "تثبيت Python و Git..."
    sudo apt install -y python3 python3-pip python3-venv git
    
    print_info "تثبيت أدوات التطوير..."
    sudo apt install -y build-essential cmake pkg-config
    
    print_info "تثبيت مكتبات معالجة الصور..."
    sudo apt install -y libopenblas-dev liblapack-dev
    sudo apt install -y libx11-dev libgtk-3-dev
    sudo apt install -y libjpeg-dev libpng-dev libtiff-dev
    
    print_success "تم تثبيت جميع متطلبات النظام"
}

create_install_directory() {
    print_header "إنشاء مجلد التثبيت"
    
    if [ -d "$INSTALL_DIR" ]; then
        print_warning "المجلد $INSTALL_DIR موجود مسبقاً"
        read -p "هل تريد حذفه وإعادة التثبيت؟ (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "حذف المجلد القديم..."
            sudo rm -rf "$INSTALL_DIR"
        else
            print_error "تم الإلغاء"
            exit 1
        fi
    fi
    
    print_info "إنشاء مجلد $INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    sudo chown $CURRENT_USER:$CURRENT_USER "$INSTALL_DIR"
    
    print_success "تم إنشاء مجلد التثبيت"
}

copy_application_files() {
    print_header "نسخ ملفات التطبيق"
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    print_info "نسخ الملفات من $SCRIPT_DIR إلى $INSTALL_DIR"
    
    # Copy all files except venv, __pycache__, and .git
    rsync -av --exclude='venv' \
              --exclude='__pycache__' \
              --exclude='.git' \
              --exclude='*.pyc' \
              --exclude='data' \
              --exclude='.env' \
              "$SCRIPT_DIR/" "$INSTALL_DIR/"
    
    print_success "تم نسخ ملفات التطبيق"
}

create_virtual_environment() {
    print_header "إنشاء البيئة الافتراضية"
    
    cd "$INSTALL_DIR"
    
    print_info "إنشاء venv..."
    python3 -m venv venv
    
    print_info "تفعيل البيئة الافتراضية..."
    source venv/bin/activate
    
    print_info "ترقية pip..."
    pip install --upgrade pip
    
    print_success "تم إنشاء البيئة الافتراضية"
}

install_python_dependencies() {
    print_header "تثبيت مكتبات Python"
    
    cd "$INSTALL_DIR"
    source venv/bin/activate
    
    print_info "تثبيت المكتبات من requirements.txt..."
    print_warning "قد يستغرق تثبيت dlib و face-recognition عدة دقائق..."
    
    # Use the special installation script
    if [ -f "install_requirements.sh" ]; then
        bash install_requirements.sh
    else
        # Fallback to manual installation
        print_info "ترقية pip و setuptools..."
        pip install --upgrade pip setuptools wheel
        
        print_info "تثبيت numpy أولاً..."
        pip install "numpy>=1.26.0"
        
        print_info "تثبيت المكتبات الأساسية..."
        pip install flask==3.0.0 werkzeug==3.0.1 requests==2.31.0 python-dotenv==1.0.0
        pip install schedule==1.2.0 cryptography==41.0.7 pyjwt==2.8.0 Pillow==10.1.0
        
        print_info "تثبيت opencv-python..."
        pip install opencv-python
        
        print_info "تثبيت dlib (قد يستغرق 5-10 دقائق)..."
        pip install dlib || print_warning "فشل تثبيت dlib، سيتم المحاولة لاحقاً"
        
        print_info "تثبيت face-recognition..."
        pip install face-recognition || print_warning "فشل تثبيت face-recognition، قد تحتاج تثبيته يدوياً"
    fi
    
    print_success "تم تثبيت جميع مكتبات Python"
}

create_data_directories() {
    print_header "إنشاء مجلدات البيانات"
    
    cd "$INSTALL_DIR"
    
    mkdir -p data/faces
    mkdir -p data/id_cards
    
    # Create empty database files
    echo "[]" > data/workers.json
    echo "[]" > data/request_logs.json
    
    print_success "تم إنشاء مجلدات البيانات"
}

configure_environment() {
    print_header "إعداد ملف الإعدادات"
    
    cd "$INSTALL_DIR"
    
    if [ -f .env ]; then
        print_warning "ملف .env موجود مسبقاً"
        read -p "هل تريد الاحتفاظ به؟ (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            rm .env
            cp .env.example .env
            print_info "تم إنشاء ملف .env جديد من .env.example"
        fi
    else
        cp .env.example .env
        print_info "تم إنشاء ملف .env من .env.example"
    fi
    
    print_warning "يجب عليك تعديل ملف .env وإضافة البيانات الحقيقية!"
    print_info "استخدم: nano $INSTALL_DIR/.env"
    
    read -p "هل تريد فتح ملف .env الآن للتعديل؟ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        nano .env
    fi
}

setup_systemd_service() {
    print_header "إعداد خدمة Systemd"
    
    # Update service file with correct paths
    cat > /tmp/$SERVICE_NAME << EOF
[Unit]
Description=HydePark Sync Service
After=network.target

[Service]
Type=simple
User=$CURRENT_USER
WorkingDirectory=$INSTALL_DIR
Environment="PATH=$INSTALL_DIR/venv/bin"
ExecStart=$INSTALL_DIR/venv/bin/python $INSTALL_DIR/main.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
    
    print_info "نسخ ملف الخدمة إلى systemd..."
    sudo cp /tmp/$SERVICE_NAME /etc/systemd/system/$SERVICE_NAME
    sudo rm /tmp/$SERVICE_NAME
    
    print_info "إعادة تحميل systemd..."
    sudo systemctl daemon-reload
    
    print_info "تفعيل الخدمة للتشغيل التلقائي عند بدء النظام..."
    sudo systemctl enable $SERVICE_NAME
    
    print_success "تم إعداد خدمة Systemd"
}

configure_firewall() {
    print_header "إعداد الجدار الناري"
    
    if command -v ufw &> /dev/null; then
        read -p "هل تريد فتح منفذ Dashboard (8080) على الجدار الناري؟ (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "فتح منفذ 8080..."
            sudo ufw allow 8080/tcp
            print_success "تم فتح منفذ 8080"
        else
            print_warning "تذكر أن تفتح المنفذ يدوياً إذا احتجت الوصول من أجهزة أخرى"
        fi
    else
        print_info "UFW غير مثبت، تخطي إعداد الجدار الناري"
    fi
}

test_configuration() {
    print_header "اختبار الإعدادات"
    
    cd "$INSTALL_DIR"
    source venv/bin/activate
    
    print_info "التحقق من إمكانية استيراد المكتبات..."
    
    python3 << EOF
try:
    import flask
    import requests
    import face_recognition
    import schedule
    print("✓ جميع المكتبات متوفرة")
    exit(0)
except ImportError as e:
    print(f"✗ خطأ في استيراد المكتبات: {e}")
    exit(1)
EOF
    
    if [ $? -eq 0 ]; then
        print_success "اختبار المكتبات نجح"
    else
        print_error "فشل اختبار المكتبات"
        exit 1
    fi
}

start_service() {
    print_header "بدء الخدمة"
    
    read -p "هل تريد بدء الخدمة الآن؟ (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "بدء خدمة $SERVICE_NAME..."
        sudo systemctl start $SERVICE_NAME
        
        sleep 3
        
        if sudo systemctl is-active --quiet $SERVICE_NAME; then
            print_success "الخدمة تعمل بنجاح!"
        else
            print_error "فشل في بدء الخدمة"
            print_info "عرض آخر 20 سطر من السجلات:"
            sudo journalctl -u $SERVICE_NAME -n 20 --no-pager
            exit 1
        fi
    else
        print_info "يمكنك بدء الخدمة لاحقاً باستخدام:"
        print_info "sudo systemctl start $SERVICE_NAME"
    fi
}

print_summary() {
    print_header "ملخص التثبيت"
    
    echo -e "${GREEN}✓ تم تثبيت HydePark Sync بنجاح!${NC}\n"
    
    echo -e "${BLUE}معلومات مهمة:${NC}"
    echo -e "  • مجلد التثبيت: ${YELLOW}$INSTALL_DIR${NC}"
    echo -e "  • ملف الإعدادات: ${YELLOW}$INSTALL_DIR/.env${NC}"
    echo -e "  • ملف السجلات: ${YELLOW}$INSTALL_DIR/hydepark-sync.log${NC}"
    echo -e "  • اسم الخدمة: ${YELLOW}$SERVICE_NAME${NC}"
    echo ""
    
    echo -e "${BLUE}الأوامر المفيدة:${NC}"
    echo -e "  • عرض حالة الخدمة:"
    echo -e "    ${YELLOW}sudo systemctl status $SERVICE_NAME${NC}"
    echo -e "  • عرض السجلات المباشرة:"
    echo -e "    ${YELLOW}sudo journalctl -u $SERVICE_NAME -f${NC}"
    echo -e "  • إيقاف الخدمة:"
    echo -e "    ${YELLOW}sudo systemctl stop $SERVICE_NAME${NC}"
    echo -e "  • إعادة تشغيل الخدمة:"
    echo -e "    ${YELLOW}sudo systemctl restart $SERVICE_NAME${NC}"
    echo -e "  • تعديل الإعدادات:"
    echo -e "    ${YELLOW}nano $INSTALL_DIR/.env${NC}"
    echo ""
    
    echo -e "${BLUE}الوصول إلى Dashboard:${NC}"
    LOCAL_IP=$(hostname -I | awk '{print $1}')
    echo -e "  • ${YELLOW}http://localhost:8080${NC}"
    echo -e "  • ${YELLOW}http://$LOCAL_IP:8080${NC}"
    echo -e "  • اسم المستخدم: ${YELLOW}admin${NC}"
    echo -e "  • كلمة المرور: ${YELLOW}(حسب ما في ملف .env)${NC}"
    echo ""
    
    echo -e "${RED}⚠ خطوات مهمة بعد التثبيت:${NC}"
    echo -e "  1. تحديث ملف .env بالبيانات الحقيقية"
    echo -e "  2. إعادة تشغيل الخدمة بعد التعديل"
    echo -e "  3. فحص السجلات للتأكد من عدم وجود أخطاء"
    echo ""
}

# Main execution
main() {
    clear
    
    print_header "HydePark Sync System - سكريبت التثبيت"
    
    echo -e "${BLUE}هذا السكريبت سيقوم بـ:${NC}"
    echo "  1. تثبيت متطلبات النظام"
    echo "  2. إنشاء مجلد التثبيت في /opt"
    echo "  3. نسخ ملفات التطبيق"
    echo "  4. إنشاء البيئة الافتراضية"
    echo "  5. تثبيت مكتبات Python"
    echo "  6. إعداد خدمة Systemd"
    echo "  7. بدء الخدمة"
    echo ""
    
    read -p "هل تريد المتابعة؟ (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "تم الإلغاء"
        exit 1
    fi
    
    check_root
    check_ubuntu
    install_system_dependencies
    create_install_directory
    copy_application_files
    create_virtual_environment
    install_python_dependencies
    create_data_directories
    configure_environment
    setup_systemd_service
    configure_firewall
    test_configuration
    start_service
    print_summary
    
    print_success "انتهى التثبيت بنجاح! 🎉"
}

# Run main function
main