#!/bin/bash

# HydePark Sync System - Update Script
# This script updates the application to the latest version

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
APP_NAME="hydepark-sync"
INSTALL_DIR="/opt/$APP_NAME"
SERVICE_NAME="hydepark-sync.service"
BACKUP_DIR="/opt/${APP_NAME}_backups"

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

check_installation() {
    print_header "التحقق من التثبيت الحالي"
    
    if [ ! -d "$INSTALL_DIR" ]; then
        print_error "التطبيق غير مثبت في $INSTALL_DIR"
        print_info "استخدم سكريبت deploy.sh للتثبيت الأول"
        exit 1
    fi
    
    if ! systemctl list-unit-files | grep -q "$SERVICE_NAME"; then
        print_error "خدمة $SERVICE_NAME غير موجودة"
        exit 1
    fi
    
    print_success "التثبيت الحالي موجود"
}

stop_service() {
    print_header "إيقاف الخدمة"
    
    if sudo systemctl is-active --quiet $SERVICE_NAME; then
        print_info "إيقاف $SERVICE_NAME..."
        sudo systemctl stop $SERVICE_NAME
        print_success "تم إيقاف الخدمة"
    else
        print_info "الخدمة غير عاملة"
    fi
}

create_backup() {
    print_header "إنشاء نسخة احتياطية"
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_PATH="$BACKUP_DIR/backup_$TIMESTAMP"
    
    print_info "إنشاء مجلد النسخ الاحتياطية..."
    sudo mkdir -p "$BACKUP_DIR"
    
    print_info "نسخ الملفات الحالية إلى $BACKUP_PATH..."
    sudo cp -r "$INSTALL_DIR" "$BACKUP_PATH"
    
    print_success "تم إنشاء نسخة احتياطية في $BACKUP_PATH"
    
    # Keep only last 5 backups
    print_info "الاحتفاظ بآخر 5 نسخ احتياطية فقط..."
    cd "$BACKUP_DIR"
    ls -t | tail -n +6 | xargs -r sudo rm -rf
    
    echo "$BACKUP_PATH" > /tmp/last_backup_path
}

update_code() {
    print_header "تحديث الكود"
    
    SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
    
    print_info "نسخ الملفات المحدثة..."
    
    # Copy files but preserve .env and data
    rsync -av --exclude='venv' \
              --exclude='__pycache__' \
              --exclude='.git' \
              --exclude='*.pyc' \
              --exclude='data' \
              --exclude='.env' \
              "$SCRIPT_DIR/" "$INSTALL_DIR/"
    
    print_success "تم تحديث الكود"
}

update_dependencies() {
    print_header "تحديث المكتبات"
    
    cd "$INSTALL_DIR"
    source venv/bin/activate
    
    print_info "ترقية pip..."
    pip install --upgrade pip
    
    print_info "تحديث المكتبات من requirements.txt..."
    pip install --upgrade -r requirements.txt
    
    print_success "تم تحديث المكتبات"
}

check_env_file() {
    print_header "التحقق من ملف الإعدادات"
    
    cd "$INSTALL_DIR"
    
    if [ ! -f .env ]; then
        print_error "ملف .env غير موجود!"
        print_info "نسخ .env.example..."
        cp .env.example .env
        print_warning "يجب عليك تعديل ملف .env قبل بدء الخدمة"
    else
        print_success "ملف .env موجود"
        
        # Check for new variables in .env.example
        print_info "التحقق من متغيرات جديدة في .env.example..."
        
        while IFS= read -r line; do
            if [[ $line =~ ^[A-Z_]+= ]]; then
                VAR_NAME=$(echo "$line" | cut -d'=' -f1)
                if ! grep -q "^$VAR_NAME=" .env; then
                    print_warning "متغير جديد وجد: $VAR_NAME"
                    echo "# Added by update script - $(date)" >> .env
                    echo "$line" >> .env
                    print_info "تم إضافة $VAR_NAME إلى .env"
                fi
            fi
        done < .env.example
    fi
}

update_database_schema() {
    print_header "التحقق من قاعدة البيانات"
    
    cd "$INSTALL_DIR"
    
    # Check if data directory exists
    if [ ! -d "data" ]; then
        print_info "إنشاء مجلد data..."
        mkdir -p data/faces data/id_cards
    fi
    
    # Check if database files exist
    if [ ! -f "data/workers.json" ]; then
        print_info "إنشاء workers.json..."
        echo "[]" > data/workers.json
    fi
    
    if [ ! -f "data/request_logs.json" ]; then
        print_info "إنشاء request_logs.json..."
        echo "[]" > data/request_logs.json
    fi
    
    print_success "قاعدة البيانات جاهزة"
}

start_service() {
    print_header "بدء الخدمة"
    
    print_info "بدء $SERVICE_NAME..."
    sudo systemctl start $SERVICE_NAME
    
    sleep 3
    
    if sudo systemctl is-active --quiet $SERVICE_NAME; then
        print_success "الخدمة تعمل بنجاح!"
    else
        print_error "فشل في بدء الخدمة"
        print_info "عرض السجلات:"
        sudo journalctl -u $SERVICE_NAME -n 30 --no-pager
        
        print_warning "محاولة استرجاع النسخة الاحتياطية..."
        rollback
        exit 1
    fi
}

rollback() {
    print_header "استرجاع النسخة الاحتياطية"
    
    if [ -f /tmp/last_backup_path ]; then
        BACKUP_PATH=$(cat /tmp/last_backup_path)
        
        if [ -d "$BACKUP_PATH" ]; then
            print_info "استرجاع من $BACKUP_PATH..."
            sudo systemctl stop $SERVICE_NAME
            sudo rm -rf "$INSTALL_DIR"
            sudo cp -r "$BACKUP_PATH" "$INSTALL_DIR"
            sudo systemctl start $SERVICE_NAME
            
            print_success "تم استرجاع النسخة الاحتياطية"
        else
            print_error "النسخة الاحتياطية غير موجودة"
        fi
    else
        print_error "لا يوجد معلومات عن النسخة الاحتياطية"
    fi
}

print_summary() {
    print_header "ملخص التحديث"
    
    echo -e "${GREEN}✓ تم تحديث HydePark Sync بنجاح!${NC}\n"
    
    echo -e "${BLUE}التغييرات:${NC}"
    echo -e "  • تم تحديث الكود"
    echo -e "  • تم تحديث المكتبات"
    echo -e "  • تم إنشاء نسخة احتياطية"
    echo ""
    
    echo -e "${BLUE}التحقق من الخدمة:${NC}"
    echo -e "  • ${YELLOW}sudo systemctl status $SERVICE_NAME${NC}"
    echo -e "  • ${YELLOW}sudo journalctl -u $SERVICE_NAME -f${NC}"
    echo ""
    
    echo -e "${BLUE}النسخ الاحتياطية:${NC}"
    echo -e "  • الموقع: ${YELLOW}$BACKUP_DIR${NC}"
    echo -e "  • عدد النسخ: ${YELLOW}$(ls -1 $BACKUP_DIR 2>/dev/null | wc -l)${NC}"
    echo ""
}

# Main execution
main() {
    clear
    
    print_header "HydePark Sync System - سكريبت التحديث"
    
    echo -e "${BLUE}هذا السكريبت سيقوم بـ:${NC}"
    echo "  1. إيقاف الخدمة"
    echo "  2. إنشاء نسخة احتياطية"
    echo "  3. تحديث الكود"
    echo "  4. تحديث المكتبات"
    echo "  5. بدء الخدمة"
    echo ""
    
    read -p "هل تريد المتابعة؟ (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "تم الإلغاء"
        exit 1
    fi
    
    check_installation
    stop_service
    create_backup
    update_code
    update_dependencies
    check_env_file
    update_database_schema
    start_service
    print_summary
    
    print_success "انتهى التحديث بنجاح! 🎉"
}

# Run main function
main
