# حل مشكلة التثبيت - numpy & dlib

## المشكلة

عند تثبيت المكتبات، ظهرت رسالة خطأ:
```
pip._vendor.pyproject_hooks._impl.BackendUnavailable: Cannot import 'setuptools.build_meta'
```

**السبب:** numpy 1.24.3 و dlib 19.24.2 غير متوافقين مع Python 3.12.

---

## ✅ الحل السريع

### الطريقة 1: استخدام سكريبت الإصلاح (موصى به)

```bash
cd /opt/hydepark-sync
chmod +x fix_installation.sh
bash fix_installation.sh
```

هذا السكريبت سيقوم بـ:
- ✅ تنظيف التثبيت الفاشل
- ✅ ترقية pip و setuptools
- ✅ تثبيت numpy إصدار متوافق (>=1.26.0)
- ✅ تثبيت opencv-python
- ✅ تثبيت dlib (مع معالجة الأخطاء)
- ✅ تثبيت face-recognition

---

### الطريقة 2: التثبيت اليدوي

```bash
cd /opt/hydepark-sync
source venv/bin/activate

# 1. ترقية pip و setuptools
pip install --upgrade pip setuptools wheel

# 2. تثبيت numpy (إصدار متوافق)
pip install "numpy>=1.26.0"

# 3. تثبيت المكتبات الأساسية
pip install flask==3.0.0 werkzeug==3.0.1 requests==2.31.0 python-dotenv==1.0.0
pip install schedule==1.2.0 cryptography==41.0.7 pyjwt==2.8.0 Pillow==10.1.0

# 4. تثبيت opencv
pip install opencv-python

# 5. تثبيت dlib (سيستغرق 5-10 دقائق)
pip install dlib

# 6. تثبيت face-recognition
pip install face-recognition

# 7. التحقق من التثبيت
pip list | grep -E "(flask|numpy|dlib|face)"

deactivate
```

---

### الطريقة 3: التثبيت بدون Face Recognition (الأسرع)

إذا كنت تريد تشغيل النظام بسرعة بدون face recognition:

```bash
cd /opt/hydepark-sync
source venv/bin/activate

# تثبيت كل شيء ما عدا face recognition
pip install --upgrade pip setuptools wheel
pip install "numpy>=1.26.0"
pip install flask==3.0.0 werkzeug==3.0.1 requests==2.31.0 python-dotenv==1.0.0
pip install schedule==1.2.0 cryptography==41.0.7 pyjwt==2.8.0 Pillow==10.1.0

deactivate
```

**ملحوظة:** بدون face recognition، النظام سيعمل ولكن لن يكتشف الوجوه المكررة.

---

## 🚀 بعد إصلاح التثبيت

### 1. تحديث ملف .env

```bash
nano /opt/hydepark-sync/.env
```

تأكد من:
- ✅ `SUPABASE_URL` موجود وصحيح
- ✅ `SUPABASE_BEARER_TOKEN` موجود
- ✅ `HIKCENTRAL_APP_KEY` و `HIKCENTRAL_APP_SECRET` موجودين
- ✅ `DASHBOARD_PASSWORD` تم تغييرها من الافتراضية

### 2. اختبار الإعدادات

```bash
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py
deactivate
```

### 3. بدء الخدمة

```bash
sudo systemctl start hydepark-sync
```

### 4. التحقق من الخدمة

```bash
# عرض الحالة
sudo systemctl status hydepark-sync

# عرض السجلات المباشرة
sudo journalctl -u hydepark-sync -f
```

### 5. فحص شامل

```bash
bash /opt/hydepark-sync/verify_setup.sh
```

---

## 📊 التحقق من نجاح التثبيت

### اختبار Python

```bash
cd /opt/hydepark-sync
source venv/bin/activate

python3 << EOF
try:
    import flask
    import requests
    import numpy
    import cv2
    print("✓ المكتبات الأساسية: OK")
    
    try:
        import dlib
        import face_recognition
        print("✓ Face Recognition: OK")
    except ImportError:
        print("⚠ Face Recognition: Not installed (optional)")
    
    print("\nإصدارات المكتبات:")
    print(f"  NumPy: {numpy.__version__}")
    print(f"  Flask: {flask.__version__}")
    
except ImportError as e:
    print(f"✗ خطأ: {e}")
    exit(1)
EOF

deactivate
```

---

## ⚙️ تعطيل Face Recognition مؤقتاً

إذا لم يعمل dlib، يمكنك تعطيل Face Recognition:

### 1. تعديل `processors/image_processor.py`

```bash
nano /opt/hydepark-sync/processors/image_processor.py
```

في بداية الملف، أضف:

```python
# Disable face recognition if not available
try:
    import face_recognition
    FACE_RECOGNITION_AVAILABLE = True
except ImportError:
    FACE_RECOGNITION_AVAILABLE = False
    print("Warning: face_recognition not available")
```

### 2. تعديل الدوال

في كل دالة تستخدم face_recognition، أضف:

```python
def get_face_encoding(self, image_path):
    if not FACE_RECOGNITION_AVAILABLE:
        logger.warning("Face recognition not available, skipping...")
        return None
    # ... بقية الكود
```

---

## 🔧 إعادة محاولة التثبيت الكامل

إذا أردت البدء من جديد:

```bash
# 1. إيقاف الخدمة
sudo systemctl stop hydepark-sync

# 2. حذف البيئة الافتراضية
sudo rm -rf /opt/hydepark-sync/venv

# 3. إعادة التثبيت
cd ~/Hikcentralhyde/src  # أو المجلد اللي فيه الكود
bash deploy.sh
```

---

## 📝 ملاحظات مهمة

### بالنسبة لـ dlib:
- ⏱️ **يحتاج وقت**: التثبيت يستغرق 5-10 دقائق
- 💾 **يحتاج موارد**: يحتاج 2GB RAM و CPU قوي أثناء التجميع
- 🔨 **يحتاج أدوات**: cmake و build-essential (مثبتة مسبقاً)

### بالنسبة لـ numpy:
- ✅ **Python 3.12**: يحتاج numpy >= 1.26.0
- ❌ **numpy 1.24.3**: غير متوافق مع Python 3.12

### بالنسبة لـ face-recognition:
- 📦 **يعتمد على**: dlib و numpy و opencv
- ⚠️ **اختياري**: النظام يعمل بدونه (لكن بدون كشف الوجوه المكررة)

---

## 🆘 إذا استمرت المشكلة

### خيار 1: استخدام Docker (مستقبلاً)
قد نضيف Dockerfile لتسهيل التثبيت.

### خيار 2: استخدام إصدار Python أقدم
```bash
# تثبيت Python 3.11
sudo apt install python3.11 python3.11-venv

# إعادة إنشاء venv
cd /opt/hydepark-sync
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
bash install_requirements.sh
```

### خيار 3: تثبيت dlib من الـ source
```bash
cd /tmp
git clone https://github.com/davisking/dlib.git
cd dlib
mkdir build
cd build
cmake ..
cmake --build .
cd ..
python3 setup.py install
```

---

## ✅ التحقق النهائي

بعد حل المشكلة، نفذ:

```bash
# 1. فحص الإعدادات
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py

# 2. بدء الخدمة
sudo systemctl start hydepark-sync

# 3. فحص شامل
bash verify_setup.sh

# 4. الوصول للـ Dashboard
# http://server-ip:8080
```

---

**تم الحل؟ رائع! 🎉**

لو لسه ف��ه مشكلة، ابعتلي السجلات:
```bash
sudo journalctl -u hydepark-sync -n 50
```
