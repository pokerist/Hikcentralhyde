# 🚀 دليل النشر - HydePark Sync System

## نظرة عامة

هذا الدليل يشرح كيفية نشر النظام بشكل نظيف من الصفر.

---

## ✅ ما الجديد في هذه النسخة؟

### 1. **Clean Deployment**
- يزيل التثبيت القديم تلقائياً
- يحفظ نسخة احتياطية من `data/` و `.env`
- يسطب نسخة نظيفة جديدة
- يستعيد بياناتك وإعداداتك

### 2. **HikCentral Authentication Fix**
- تم إصلاح توليد الـ signature
- الآن يعمل مع HikCentral بشكل صحيح
- `HIKCENTRAL_BASE_URL` يجب أن يكون `https://IP:PORT` فقط (بدون `/artemis`)

### 3. **Auto-Recovery**
- إذا فشل التحديث، يستعيد النسخة القديمة تلقائياً
- نسخ احتياطية تلقائية (آخر 5 نسخ)

---

## 📋 خطوات النشر

### على السيرفر:

```bash
# 1. الذهاب لمجلد المشروع
cd ~/Hikcentralhyde/src

# 2. تشغيل سكريبت النشر
bash deploy.sh
```

**السكريبت سيسألك:**
- هل تريد المتابعة؟ → اضغط `y`
- هل تريد حذف التثبيت القديم؟ → اضغط `y` (سيحفظ data و .env)
- هل تريد فتح .env للتعديل؟ → اضغط `n` (إذا كان موجود من قبل)
- هل تريد فتح منفذ 8080؟ → اضغط `y`
- هل تريد بدء الخدمة؟ → اضغط `y`

---

## ⚙️ إعداد `.env`

**مهم:** تأكد من الإعدادات التالية:

```env
# HikCentral - لاحظ بدون /artemis
HIKCENTRAL_BASE_URL=https://10.127.0.2
HIKCENTRAL_APP_KEY=22452825
HIKCENTRAL_APP_SECRET=Q9bWogAziordVdIngfoa
```

**❌ خطأ:**
```env
HIKCENTRAL_BASE_URL=https://10.127.0.2/artemis  # غلط!
```

**✅ صح:**
```env
HIKCENTRAL_BASE_URL=https://10.127.0.2  # صح!
```

النظام سيضيف `/artemis/api/...` تلقائياً في الكود.

---

## 🔄 التحديث

### لتحديث نسخة موجودة:

```bash
cd ~/Hikcentralhyde/src
bash update.sh
```

**السكريبت سيقوم بـ:**
1. إيقاف الخدمة
2. نسخة احتياطية كاملة
3. تحديث الكود
4. تحديث المكتبات
5. بدء الخدمة
6. إذا فشل → استعادة النسخة الاحتياطية تلقائياً

---

## 🧪 اختبار التثبيت

### 1. التحقق من الخدمة:
```bash
sudo systemctl status hydepark-sync
```

**يجب أن ترى:** `active (running)`

### 2. مراقبة السجلات:
```bash
sudo journalctl -u hydepark-sync -f
```

**يجب أن ترى:**
```
Starting sync job...
Fetching pending events...
SUPABASE GET /admin/events/pending - 200 - XXXms
Fetched 0 pending events
```

### 3. اختبار Dashboard:
```bash
# اعرف IP السيرفر
hostname -I
```

افتح في المتصفح: `http://SERVER_IP:8080`
- Username: `admin`
- Password: من `.env`

### 4. اختبار HikCentral Signature:
```bash
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_hikcentral_signature.py
deactivate
```

**يجب أن ترى:** `✅ SIGNATURE MATCHES!`

---

## 🐛 حل المشاكل الشائعة

### المشكلة 1: `data/workers.json not found`
```bash
cd /opt/hydepark-sync
sudo mkdir -p data/faces data/id_cards
sudo bash -c 'echo "[]" > data/workers.json'
sudo bash -c 'echo "[]" > data/request_logs.json'
sudo systemctl restart hydepark-sync
```

### المشكلة 2: Dashboard فاضي
- تأكد من وجود `data/workers.json` و `data/request_logs.json`
- راجع السجلات: `sudo journalctl -u hydepark-sync -n 50`

### المشكلة 3: HikCentral Authentication Error
- تأكد من `HIKCENTRAL_BASE_URL` بدون `/artemis`
- تأكد من `APP_KEY` و `APP_SECRET` صحيحين
- شغّل: `python3 test_hikcentral_signature.py`

### المشكلة 4: الخدمة لا تبدأ
```bash
# عرض الأخطاء
sudo journalctl -u hydepark-sync -n 50 --no-pager | grep -i error

# اختبار الإعدادات
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_config.py
deactivate
```

---

## 📁 هيكل الملفات

```
/opt/hydepark-sync/
├── api/
│   ├── hikcentral_api.py    # ✅ Updated with correct signature
│   └── supabase_api.py
├── dashboard/
│   ├── app.py
│   └── templates/
├── processors/
│   ├── event_processor.py
│   └── image_processor.py
├── utils/
│   ├── logger.py
│   └── sanitizer.py
├── data/                     # Preserved during updates
│   ├── workers.json
│   ├── request_logs.json
│   ├── faces/
│   └── id_cards/
├── venv/                     # Recreated during deployment
├── .env                      # Preserved during updates
├── main.py
├── config.py
├── database.py
└── requirements.txt
```

---

## 🔐 الأمان

### التأكد من الـ Permissions:
```bash
cd /opt/hydepark-sync
ls -la data/
```

يجب أن تكون:
- `data/` → `755` (rwxr-xr-x)
- `workers.json` → `644` (rw-r--r--)
- `request_logs.json` → `644` (rw-r--r--)

### تغيير كلمة مرور Dashboard:
```bash
nano /opt/hydepark-sync/.env
# عدّل DASHBOARD_PASSWORD
sudo systemctl restart hydepark-sync
```

---

## 📊 المراقبة

### عرض الإحصائيات:
- Dashboard: `http://SERVER_IP:8080`
- Workers: `http://SERVER_IP:8080/workers`
- Logs: `http://SERVER_IP:8080/logs`

### السجلات:
```bash
# Live logs
sudo journalctl -u hydepark-sync -f

# Last 100 lines
sudo journalctl -u hydepark-sync -n 100 --no-pager

# Errors only
sudo journalctl -u hydepark-sync | grep -i error

# Today's logs
sudo journalctl -u hydepark-sync --since today
```

---

## 🔄 النسخ الاحتياطية

### موقع النسخ الاحتياطية:
```bash
ls -lh /opt/hydepark-sync_backups/
```

### استعادة نسخة احتياطية يدوياً:
```bash
sudo systemctl stop hydepark-sync
sudo cp -r /opt/hydepark-sync_backups/backup_YYYYMMDD_HHMMSS /opt/hydepark-sync
sudo systemctl start hydepark-sync
```

---

## ✨ الميزات الجديدة

1. ✅ **Clean Deployment** - تنظيف تلقائي
2. ✅ **HikCentral Auth Fix** - authentication صحيح
3. ✅ **Auto-Recovery** - استعادة تلقائية عند الفشل
4. ✅ **Smart Backup** - نسخ احتياطية ذكية (آخر 5)
5. ✅ **Signature Test** - اختبار الـ signature

---

## 📞 الدعم

إذا واجهت مشكلة:
1. راجع السجلات: `sudo journalctl -u hydepark-sync -n 100`
2. شغّل: `bash /opt/hydepark-sync/verify_setup.sh`
3. اختبر: `python3 /opt/hydepark-sync/test_config.py`
4. اختبر: `python3 /opt/hydepark-sync/test_hikcentral_signature.py`

---

**تم! 🎉**
