# دليل التثبيت النظيف - Clean Deployment Guide

## 🎯 التثبيت من الصفر بدون أخطاء

هذا الدليل للتثبيت النظيف 100% من أول مرة.

---

## ✅ المتطلبات قبل البدء

- [ ] Ubuntu 18.04 أو أحدث
- [ ] صلاحيات sudo
- [ ] اتصال LAN بـ HikCentral
- [ ] 2GB RAM على الأقل
- [ ] 10GB مساحة فارغة

---

## 🧹 الخطوة 1: تنظيف التثبيت القديم (إن وُجد)

```bash
# إيقاف الخدمة
sudo systemctl stop hydepark-sync 2>/dev/null || true

# حذف الخدمة
sudo systemctl disable hydepark-sync 2>/dev/null || true
sudo rm -f /etc/systemd/system/hydepark-sync.service
sudo systemctl daemon-reload

# حذف مجلد التثبيت
sudo rm -rf /opt/hydepark-sync

# حذف النسخ الاحتياطية (اختياري)
# sudo rm -rf /opt/hydepark-sync_backups

echo "✓ تم التنظيف بنجاح"
```

---

## 🔍 الخطوة 2: التحقق من الملفات المصدرية

```bash
# الانتقال لمجلد الكود
cd ~/Hikcentralhyde/src

# التحقق من جميع الملفات المطلوبة
bash PRE_DEPLOY_CHECK.sh
```

### ✅ يجب أن ترى:

```
========================================
Pre-Deployment Check
========================================

Checking required files...
✓ deploy.sh
✓ update.sh
✓ main.py
✓ config.py
✓ database.py
✓ requirements.txt
✓ .env.example
...

Checking .env.example content...
✓ SUPABASE_URL
✓ SUPABASE_BEARER_TOKEN
✓ SUPABASE_API_KEY
✓ HIKCENTRAL_BASE_URL
✓ HIKCENTRAL_APP_KEY
✓ HIKCENTRAL_APP_SECRET
✓ DASHBOARD_PASSWORD (needs to be changed after deploy)

Checking Python syntax...
✓ All Python files valid

========================================
Summary
========================================
✓ All checks passed!

You can proceed with deployment:
  bash deploy.sh
```

### ❌ إذا ظهرت أخطاء:

```bash
# إذا كان .env.example مفقود أو فارغ
# سيتم إنشاؤه تلقائياً من deploy.sh

# إذا كانت ملفات Python بها أخطاء syntax
# راجع الملف وصحح الأخطاء
```

---

## 🚀 الخطوة 3: التثبيت

```bash
cd ~/Hikcentralhyde/src

# إعطاء صلاحيات التنفيذ
chmod +x *.sh

# بدء التثبيت
bash deploy.sh
```

---

## 📋 الخطوة 4: الإجابة على الأسئلة

### السؤال 1: المتابعة؟
```
هل تريد المتابعة؟ (y/n): y
```

### السؤال 2: حذف المجلد القديم (إن وُجد)
```
المجلد موجود مسبقاً، هل تريد حذفه؟ (y/n): y
```

### السؤال 3: تعديل .env
```
هل تريد فتح ملف .env الآن للتعديل؟ (y/n): n
```
**اختر `n` - هنعدله بعدين**

### السؤال 4: الجدار الناري
```
هل تريد فتح منفذ Dashboard (8080)؟ (y/n): y
```

### السؤال 5: بدء الخدمة
```
هل تريد بدء الخدمة الآن؟ (y/n): n
```
**اختر `n` - عشان نعدل كلمة المرور الأول**

---

## ⏱️ انتظر التثبيت (10-15 دقيقة)

### المراحل:

1. ✅ تثبيت متطلبات النظام (2 دقيقة)
2. ✅ نسخ الملفات (30 ثانية)
3. ✅ إنشاء venv (1 دقيقة)
4. ✅ تثبيت numpy (2 دقيقة)
5. ✅ تثبيت المكتبات الأساسية (1 دقيقة)
6. ✅ تثبيت opencv (5 دقائق - تنزيل 67MB)
7. ✅ تثبيت dlib (5-10 دقائق - تجميع) ⏳
8. ✅ تثبيت face-recognition (1 دقيقة)
9. ✅ إنشاء المجلدات والملفات
10. ✅ إعداد systemd service

---

## ✅ الخطوة 5: التحقق من نجاح التثبيت

```bash
# التحقق من وجود المجلدات
ls -la /opt/hydepark-sync/data/

# يجب أن ترى:
# drwxr-xr-x faces/
# drwxr-xr-x id_cards/
# -rw-r--r-- workers.json
# -rw-r--r-- request_logs.json
```

---

## ⚙️ الخطوة 6: تعديل كلمة المرور

```bash
nano /opt/hydepark-sync/.env
```

**غيّر السطر ده فقط:**
```env
DASHBOARD_PASSWORD=YourSecurePassword123!
```

**احفظ:** `Ctrl+O` ثم `Enter` ثم `Ctrl+X`

---

## 🧪 الخطوة 7: اختبار الإعدادات

```bash
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py
deactivate
```

### ✅ يجب أن ترى:

```
============================================================
HydePark Sync - Configuration Test
============================================================

📡 Supabase Configuration:
✓ SUPABASE_URL: ***
✓ SUPABASE_BEARER_TOKEN: ***
✓ SUPABASE_API_KEY: ***

🏢 HikCentral Configuration:
✓ HIKCENTRAL_BASE_URL: ***
✓ HIKCENTRAL_APP_KEY: ***
✓ HIKCENTRAL_APP_SECRET: ***
✓ HIKCENTRAL_USER_ID: admin
✓ HIKCENTRAL_ORG_INDEX_CODE: 1
✓ HIKCENTRAL_PRIVILEGE_GROUP_ID: 3
✓ VERIFY_SSL: false

🖥️  Dashboard Configuration:
✓ DASHBOARD_HOST: 0.0.0.0
✓ DASHBOARD_PORT: 8080
✓ DASHBOARD_USERNAME: admin
✓ DASHBOARD_PASSWORD: ***

⚙️  System Configuration:
✓ SYNC_INTERVAL_SECONDS: 60
✓ FACE_MATCH_THRESHOLD: 0.8
✓ DATA_DIR: ./data

============================================================
✓ Configuration is valid! You can start the service.

Next steps:
  1. sudo systemctl restart hydepark-sync
  2. sudo systemctl status hydepark-sync
  3. Open http://your-server-ip:8080
============================================================
```

---

## 🎬 الخطوة 8: بدء الخدمة

```bash
# بدء الخدمة
sudo systemctl start hydepark-sync

# التحقق من الحالة
sudo systemctl status hydepark-sync
```

### ✅ يجب أن ترى:

```
● hydepark-sync.service - HydePark Sync Service
     Loaded: loaded
     Active: active (running) since ...
```

---

## 📊 الخطوة 9: مراقبة السجلات

```bash
sudo journalctl -u hydepark-sync -f
```

### ✅ يجب أن ترى:

```
============================================================
HydePark Sync System Starting
============================================================
Supabase URL: https://xrkxxqhoglrimiljfnml...
HikCentral URL: https://10.127.0.2/artemis
Sync Interval: 60 seconds
Dashboard: http://0.0.0.0:8080
Data Directory: /opt/hydepark-sync/data
============================================================
Dashboard started successfully
Starting sync job...
Fetching pending events...
SUPABASE GET /admin/events/pending - 200 - XXXms
Fetched 0 pending events
Sync job completed
```

### ❌ إذا ظهرت أخطاء:

**خطأ: Cannot import dlib**
```bash
# إعادة تثبيت dlib
cd /opt/hydepark-sync
source venv/bin/activate
pip uninstall dlib -y
pip install dlib
deactivate
sudo systemctl restart hydepark-sync
```

**خطأ: No such file or directory: data/workers.json**
```bash
# إعادة إنشاء المجلدات
cd /opt/hydepark-sync
mkdir -p data/faces data/id_cards
echo '[]' > data/workers.json
echo '[]' > data/request_logs.json
chmod 755 data data/faces data/id_cards
chmod 644 data/*.json
sudo systemctl restart hydepark-sync
```

**خطأ: 401 Unauthorized**
```bash
# التحقق من Bearer Token في .env
grep SUPABASE_BEARER_TOKEN /opt/hydepark-sync/.env

# التحقق من أن الكود بيبعت الاثنين مع بعض
grep -A 10 "_get_headers" /opt/hydepark-sync/api/supabase_api.py
```

---

## 🌐 الخطوة 10: فتح Dashboard

في المتصفح:
```
http://عنوان-السيرفر:8080
```

**تسجيل الدخول:**
- Username: `admin`
- Password: (اللي حطيته في .env)

### ✅ يجب تشوف:

- **Dashboard الرئيسية:**
  - Total Workers: 0
  - Total API Requests: عدد
  - Success Rate: نسبة مئوية
  - Recent API Requests: قائمة

- **Request Logs:**
  - Supabase requests بـ status 200
  - لا توجد أخطاء 401 أو 500

---

## 🔍 الخطوة 11: الفحص الشامل

```bash
bash /opt/hydepark-sync/verify_setup.sh
```

### ✅ يجب أن ترى:

```
========================================
HydePark Sync - Setup Verification
========================================

1. Checking installation...
✓ Installation directory exists

2. Checking .env file...
✓ .env file exists
✓ Configuration is valid! You can start the service.

3. Checking systemd service...
✓ Service is registered
✓ Service is enabled (auto-start)
✓ Service is running

4. Checking network connectivity...
✓ Can reach Supabase
✓ Can reach HikCentral server

5. Checking Dashboard...
✓ Dashboard is listening on port 8080
  Access at: http://192.168.1.X:8080

6. Checking firewall...
✓ Port 8080 is open in firewall

7. Checking disk space...
✓ Disk space OK (XX% used)

8. Checking data directories...
✓ Data directory exists
  Workers in database: 0
  Face images stored: 0

========================================
✓ System is ready!

Dashboard Access:
  http://192.168.1.X:8080
  http://localhost:8080

Login Credentials:
  Username: admin
  Password: (check .env file)

Useful Commands:
  View logs: sudo journalctl -u hydepark-sync -f
  Check status: sudo systemctl status hydepark-sync
  Restart: sudo systemctl restart hydepark-sync
========================================
```

---

## ✅ Checklist النهائي

- [ ] ✅ النظام مثبت في `/opt/hydepark-sync`
- [ ] ✅ الخدمة شغالة: `systemctl status hydepark-sync`
- [ ] ✅ Dashboard بيفتح على المتصفح
- [ ] ✅ قدرت تسجل دخول
- [ ] ✅ Request Logs بتظهر طلبات بـ status 200
- [ ] ✅ لا توجد أخطاء في السجلات
- [ ] ✅ مجلدات data موجودة وفيها ملفات json
- [ ] ✅ غيرت كلمة مرور Dashboard
- [ ] ✅ المنفذ 8080 مفتوح في الجدار الناري
- [ ] ✅ النظام بيعمل sync كل 60 ثانية

---

## 🎉 تم بنجاح!

النظام دلوقتي جاهز ويعمل 100%!

### الخطوات التالية:

1. **اختبار إضافة عامل:**
   - أضف عامل في النظام الأونلاين
   - راقب السجلات: `sudo journalctl -u hydepark-sync -f`
   - شوف في Dashboard

2. **إعداد النسخ الاحتياطي:**
   - راجع `DEPLOYMENT_AR.md` قسم "النسخ الاحتياطية"

3. **المراقبة:**
   - تابع Dashboard يومياً
   - راجع السجلات أسبوعياً

---

## 🆘 حصلت مشكلة؟

```bash
# 1. اعرض آخر 50 سطر من السجلات
sudo journalctl -u hydepark-sync -n 50

# 2. شغّل الفحص الشامل
bash /opt/hydepark-sync/verify_setup.sh

# 3. اختبر الإعدادات
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py
deactivate

# 4. لو لسه فيه مشكلة، ابعت السجلات:
sudo journalctl -u hydepark-sync -n 100 > ~/hydepark-logs.txt
```

---

**Good luck! 🚀**
