#!/bin/bash

# Quick fix script for the current installation issue

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}HydePark Sync - إصلاح التثبيت${NC}"
echo -e "${BLUE}========================================${NC}\n"

INSTALL_DIR="/opt/hydepark-sync"

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${RED}✗ مجلد التثبيت غير موجود${NC}"
    exit 1
fi

cd "$INSTALL_DIR"

if [ ! -d "venv" ]; then
    echo -e "${RED}✗ البيئة الافتراضية غير موجودة${NC}"
    exit 1
fi

echo -e "${BLUE}ℹ تفعيل البيئة الافتراضية...${NC}"
source venv/bin/activate

echo -e "${BLUE}ℹ تنظيف التثبيت السابق...${NC}"
pip uninstall -y numpy dlib face-recognition opencv-python 2>/dev/null || true

echo -e "${BLUE}ℹ ترقية pip و setuptools...${NC}"
pip install --upgrade pip setuptools wheel

echo -e "${BLUE}ℹ تثبيت numpy (متوافق مع Python 3.12)...${NC}"
pip install "numpy>=1.26.0"

echo -e "${BLUE}ℹ تثبيت المكتبات الأساسية...${NC}"
pip install flask==3.0.0 werkzeug==3.0.1 requests==2.31.0 python-dotenv==1.0.0
pip install schedule==1.2.0 cryptography==41.0.7 pyjwt==2.8.0 Pillow==10.1.0

echo -e "${BLUE}ℹ تثبيت opencv-python...${NC}"
pip install opencv-python

echo -e "${BLUE}ℹ تثبيت dlib (قد يستغرق 5-10 دقائق)...${NC}"
echo -e "${YELLOW}⚠ من فضلك انتظر، dlib يحتاج وقت للتجميع...${NC}"

if pip install dlib; then
    echo -e "${GREEN}✓ تم تثبيت dlib بنجاح${NC}"
else
    echo -e "${YELLOW}⚠ فشل تثبيت dlib، جاري المحاولة بطريقة أخرى...${NC}"
    pip install dlib --no-cache-dir --no-build-isolation
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ فشل تثبيت dlib${NC}"
        echo -e "${YELLOW}ℹ يمكنك تخطي face recognition مؤقتاً${NC}"
        read -p "هل تريد المتابعة بدون face recognition؟ (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
fi

echo -e "${BLUE}ℹ تثبيت face-recognition...${NC}"
if pip install face-recognition; then
    echo -e "${GREEN}✓ تم تثبيت face-recognition بنجاح${NC}"
else
    echo -e "${YELLOW}⚠ فشل تثبيت face-recognition${NC}"
fi

echo -e "\n${GREEN}✓ اكتمل إصلاح التثبيت!${NC}\n"

echo -e "${BLUE}المكتبات المثبتة:${NC}"
pip list | grep -E "(flask|requests|numpy|dlib|face-recognition|opencv)" || echo "جاري التحميل..."

echo -e "\n${BLUE}الخطوات التالية:${NC}"
echo -e "  1. تحقق من ملف .env: ${YELLOW}nano $INSTALL_DIR/.env${NC}"
echo -e "  2. ابدأ الخدمة: ${YELLOW}sudo systemctl start hydepark-sync${NC}"
echo -e "  3. تابع السجلات: ${YELLOW}sudo journalctl -u hydepark-sync -f${NC}"

deactivate
