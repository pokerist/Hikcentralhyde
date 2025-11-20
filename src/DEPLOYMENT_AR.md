# دليل التثبيت والتحديث - HydePark Sync System

هذا الدليل يشرح بالتفصيل كيفية تثبيت وتحديث نظام HydePark Sync على السيرفر.

---

## 📋 المتطلبات قبل البدء

### 1. السيرفر
- نظام تشغيل: Ubuntu 18.04 أو أحدث
- معالج: 2 نواة على الأقل
- ذاكرة RAM: 2 جيجابايت على الأقل
- مساحة تخزين: 10 جيجابايت على الأقل
- اتصال LAN بسيرفر HikCentral

### 2. الصلاحيات
- صلاحيات sudo على السيرفر
- **لا تستخدم مستخدم root مباشرة**

### 3. المعلومات المطلوبة
قبل البدء، جهز هذه المعلومات:

#### من Supabase:
- `SUPABASE_BASE_URL` - رابط الـ API
- `SUPABASE_API_KEY` - مفتاح الـ API
- أو `SUPABASE_AUTH_BEARER` - توكن المصادقة

#### من HikCentral:
- `HIKCENTRAL_BASE_URL` - عنوان سيرفر HikCentral (مثال: https://10.127.0.2/artemis)
- `HIKCENTRAL_APP_KEY` - مفتاح التطبيق (App Key)
- `HIKCENTRAL_APP_SECRET` - كود سري للتطبيق (App Secret)
- `HIKCENTRAL_ORG_INDEX_CODE` - كود المؤسسة (Organization Index Code)
- `HIKCENTRAL_PRIVILEGE_GROUP_ID` - معرف مجموعة الصلاحيات

#### للـ Dashboard:
- `DASHBOARD_USERNAME` - اسم مستخدم Dashboard
- `DASHBOARD_PASSWORD` - كلمة سر قوية

---

## 🚀 التثبيت الأول (First-time Deployment)

### الخطوة 1: رفع الملفات للسيرفر

#### الطريقة الأولى: باستخدام Git

```bash
# على السيرفر
cd ~
git clone <repository-url> hydepark-sync-source
cd hydepark-sync-source
```

#### الطريقة الثانية: باستخدام SCP

```bash
# على جهازك المحلي
cd /path/to/hydepark-sync
tar -czf hydepark-sync.tar.gz .
scp hydepark-sync.tar.gz user@server-ip:~/

# على السيرفر
cd ~
tar -xzf hydepark-sync.tar.gz
mv hydepark-sync hydepark-sync-source
cd hydepark-sync-source
```

#### الطريقة الثالثة: باستخدام SFTP

يمكنك استخدام برنامج FileZilla أو WinSCP لرفع المجلد كامل.

### الخطوة 2: إعطاء صلاحيات التنفيذ للسكريبتات

```bash
cd ~/hydepark-sync-source
chmod +x deploy.sh
chmod +x update.sh
```

### الخطوة 3: تشغيل سكريبت التثبيت

```bash
bash deploy.sh
```

**ماذا سيحدث؟**

السكريبت سيقوم تلقائياً بـ:

1. ✅ تثبيت متطلبات النظام (Python, CMake, إلخ)
2. ✅ إنشاء مجلد `/opt/hydepark-sync`
3. ✅ نسخ ملفات التطبيق
4. ✅ إنشاء البيئة الافتراضية (Virtual Environment)
5. ✅ تثبيت المكتبات Python (قد يستغرق 5-10 دقائق)
6. ✅ إنشاء مجلدات البيانات
7. ✅ إعداد ملف الإعدادات `.env`
8. ✅ إنشاء خدمة Systemd
9. ✅ تكوين الجدار الناري (اختياري)
10. ✅ بدء الخدمة

### الخطوة 4: أثناء التثبيت - الأسئلة التفاعلية

#### السؤال 1: المتابعة؟
```
هل تريد المتابعة؟ (y/n):
```
اضغط `y` ثم Enter

#### السؤال 2: المجلد موجود مسبقاً (إن وُجد)
```
المجلد /opt/hydepark-sync موجود مسبقاً
هل تريد حذفه وإعادة التثبيت؟ (y/n):
```
- اضغط `y` لحذفه وإعادة التثبيت
- اضغط `n` للإلغاء

#### السؤال 3: ملف .env موجود مسبقاً (إن وُجد)
```
ملف .env موجود مسبقاً
هل تريد الاحتفاظ به؟ (y/n):
```
- اضغط `y` للاحتفاظ بالإعدادات الحالية
- اضغط `n` لإنشاء ملف جديد

#### السؤال 4: تعديل ملف .env
```
هل تريد فتح ملف .env الآن للتعديل؟ (y/n):
```
- اضغط `y` لفتح محرر nano للتعديل
- اضغط `n` للتعديل لاحقاً

#### السؤال 5: الجدار الناري
```
هل تريد فتح منفذ Dashboard (8080) على الجدار الناري؟ (y/n):
```
- اضغط `y` إذا كنت تريد الوصول من أجهزة أخرى
- اضغط `n` إذا كنت ستستخدم Dashboard محلياً فقط

#### السؤال 6: بدء الخدمة
```
هل تريد بدء الخدمة الآن؟ (y/n):
```
- اضغط `y` لبدء الخدمة فوراً
- اضغط `n` لبدئها لاحقاً

### الخطوة 5: تعديل ملف الإعدادات

إذا لم تعدل ملف `.env` أثناء التثبيت، افتحه الآن:

```bash
nano /opt/hydepark-sync/.env
```

**املأ القيم الحقيقية:**

```env
# Supabase Configuration
SUPABASE_BASE_URL=https://xrkxxqhoglrimiljfnml.supabase.co/functions/v1/make-server-2c3121a9
SUPABASE_API_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_AUTH_BEARER=

# HikCentral Configuration
HIKCENTRAL_BASE_URL=https://10.127.0.2/artemis
HIKCENTRAL_APP_KEY=23456789
HIKCENTRAL_APP_SECRET=QKyQZu2h5T9dSbwvP...
HIKCENTRAL_USER_ID=admin
HIKCENTRAL_ORG_INDEX_CODE=1
HIKCENTRAL_PRIVILEGE_GROUP_ID=3
HIKCENTRAL_VERIFY_SSL=false

# Dashboard Configuration
DASHBOARD_HOST=0.0.0.0
DASHBOARD_PORT=8080
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=MySecurePassword123!
```

**للحفظ في nano:**
- اضغط `Ctrl + O` ثم `Enter` للحفظ
- اضغط `Ctrl + X` للخروج

### الخطوة 6: إعادة تشغيل الخدمة

بعد تعديل `.env`:

```bash
sudo systemctl restart hydepark-sync
```

### الخطوة 7: التحقق من نجاح التثبيت

```bash
# التحقق من حالة الخدمة
sudo systemctl status hydepark-sync

# يجب أن ترى:
# ● hydepark-sync.service - HydePark Sync Service
#    Loaded: loaded (/etc/systemd/system/hydepark-sync.service; enabled)
#    Active: active (running) since ...
```

```bash
# عرض السجلات المباشرة
sudo journalctl -u hydepark-sync -f

# يجب أن ترى:
# HydePark Sync System Starting
# Dashboard started successfully
# Starting sync job...
```

### الخطوة 8: الوصول إلى Dashboard

افتح المتصفح وانتقل إلى:

```
http://عنوان-السيرفر:8080
```

مثال:
- `http://192.168.1.100:8080`
- `http://10.127.0.5:8080`

**تسجيل الدخول:**
- اسم المستخدم: ما وضعته في `DASHBOARD_USERNAME`
- كلمة المرور: ما وضعته في `DASHBOARD_PASSWORD`

---

## 🔄 التحديث (Update)

عندما تريد تحديث التطبيق لإصدار جديد:

### الخطوة 1: رفع الملفات الجديدة للسيرفر

```bash
# على السيرفر
cd ~/hydepark-sync-source

# إذا كنت تستخدم Git
git pull

# أو إذا رفعت ملفات جديدة بـ SCP
# تأكد أن الملفات الجديدة في ~/hydepark-sync-source
```

### الخطوة 2: تشغيل سكريبت التحديث

```bash
cd ~/hydepark-sync-source
bash update.sh
```

**ماذا سيحدث؟**

السكريبت سيقوم تلقائياً بـ:

1. ✅ إيقاف الخدمة مؤقتاً
2. ✅ إنشاء نسخة احتياطية كاملة في `/opt/hydepark-sync_backups`
3. ✅ نسخ الملفات المحدثة (مع الحفاظ على .env والبيانات)
4. ✅ تحديث المكتبات Python
5. ✅ التحقق من متغيرات جديدة في .env
6. ✅ بدء الخدمة
7. ✅ التحقق من نجاح التحديث

**إذا فشل التحديث:**
- السكريبت سيسترجع النسخة الاحتياطية تلقائياً
- التطبيق سيعود للعمل بالإصدار القديم

### الخطوة 3: التحقق من نجاح التحديث

```bash
# التحقق من حالة الخدمة
sudo systemctl status hydepark-sync

# عرض آخر السجلات
sudo journalctl -u hydepark-sync -n 50
```

---

## 📊 الأوامر الأساسية

### إدارة الخدمة

```bash
# بدء الخدمة
sudo systemctl start hydepark-sync

# إيقاف الخدمة
sudo systemctl stop hydepark-sync

# إعادة تشغيل الخدمة
sudo systemctl restart hydepark-sync

# عرض حالة الخدمة
sudo systemctl status hydepark-sync

# تفعيل التشغيل التلقائي عند بدء النظام
sudo systemctl enable hydepark-sync

# تعطيل التشغيل التلقائي
sudo systemctl disable hydepark-sync
```

### عرض السجلات

```bash
# عرض آخر 50 سطر من السجلات
sudo journalctl -u hydepark-sync -n 50

# عرض السجلات المباشرة (Live)
sudo journalctl -u hydepark-sync -f

# عرض سجلات اليوم فقط
sudo journalctl -u hydepark-sync --since today

# عرض سجلات آخر ساعة
sudo journalctl -u hydepark-sync --since "1 hour ago"

# البحث عن كلمة معينة في السجلات
sudo journalctl -u hydepark-sync | grep "ERROR"
```

### تعديل الإعدادات

```bash
# فتح ملف الإعدادات
nano /opt/hydepark-sync/.env

# بعد التعديل، احفظ وأعد تشغيل الخدمة
sudo systemctl restart hydepark-sync
```

### عرض البيانات

```bash
# عرض قاعدة بيانات العمال
cat /opt/hydepark-sync/data/workers.json | python3 -m json.tool | less

# عرض سجلات API
cat /opt/hydepark-sync/data/request_logs.json | python3 -m json.tool | less

# حساب عدد العمال
cat /opt/hydepark-sync/data/workers.json | python3 -c "import sys, json; print(len(json.load(sys.stdin)))"
```

---

## 🔧 حل المشاكل الشائعة

### المشكلة 1: الخدمة لا تبدأ

**الأعراض:**
```bash
sudo systemctl status hydepark-sync
# Active: failed (Result: exit-code)
```

**الحلول:**

1. **التحقق من ملف .env:**
```bash
nano /opt/hydepark-sync/.env
# تأكد من أن جميع القيم المطلوبة موجودة
```

2. **التحقق من السجلات:**
```bash
sudo journalctl -u hydepark-sync -n 50
# ابحث عن رسائل الخطأ
```

3. **اختبار يدوي:**
```bash
cd /opt/hydepark-sync
source venv/bin/activate
python3 main.py
# سترى الأخطاء مباشرة
```

### المشكلة 2: Dashboard لا يعمل

**الأعراض:**
- لا يمكن الوصول إلى `http://server-ip:8080`

**الحلول:**

1. **التحقق من المنفذ:**
```bash
sudo netstat -tlnp | grep 8080
# يجب أن ترى python يستمع على المنفذ 8080
```

2. **التحقق من الجدار الناري:**
```bash
sudo ufw status
# تأكد أن المنفذ 8080 مفتوح
sudo ufw allow 8080/tcp
```

3. **تغيير المنفذ:**
```bash
nano /opt/hydepark-sync/.env
# غير DASHBOARD_PORT=8080 إلى منفذ آخر
sudo systemctl restart hydepark-sync
```

### المشكلة 3: خطأ في Face Recognition

**الأعراض:**
```
ImportError: cannot import name 'face_recognition'
```

**الحل:**
```bash
cd /opt/hydepark-sync
source venv/bin/activate

# إعادة تثبيت المكتبات
pip uninstall dlib face-recognition -y
pip install dlib
pip install face-recognition

# إعادة تشغيل الخدمة
deactivate
sudo systemctl restart hydepark-sync
```

### المشكلة 4: اتصال HikCentral فاشل

**الأعراض:**
```
HikCentral API error: Connection refused
```

**الحلول:**

1. **اختبار الاتصال:**
```bash
ping 10.127.0.2
curl -k https://10.127.0.2/artemis/api/system/v1/health
```

2. **التحقق من SSL:**
```bash
nano /opt/hydepark-sync/.env
# تأكد من:
HIKCENTRAL_VERIFY_SSL=false
```

3. **التحقق من البيانات:**
```bash
# تأكد من صحة:
# HIKCENTRAL_APP_KEY
# HIKCENTRAL_APP_SECRET
```

### المشكلة 5: الذاكرة ممتلئة

**الأعراض:**
```bash
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        10G   9.8G  200M  98% /
```

**الحلول:**

1. **حذف السجلات القديمة:**
```bash
# تنظيف سجلات النظام
sudo journalctl --vacuum-time=7d

# تنظيف سجلات التطبيق
cd /opt/hydepark-sync
rm hydepark-sync.log
sudo systemctl restart hydepark-sync
```

2. **حذف النسخ الاحتياطية القديمة:**
```bash
sudo rm -rf /opt/hydepark-sync_backups/*
```

3. **أرشفة الصور القديمة:**
```bash
cd /opt/hydepark-sync/data
tar -czf ~/old_images_$(date +%Y%m%d).tar.gz faces/ id_cards/
# يمكنك نقل الأرشيف لمكان آخر ثم حذف الصور
```

---

## 🔒 نصائح الأمان

### 1. تأمين Dashboard

**استخدم كلمة سر قوية:**
```env
DASHBOARD_PASSWORD=P@ssw0rd!2024#Strong
```

**قيّد الوصول بـ IP معين:**
```bash
# السماح فقط من شبكة داخلية
sudo ufw allow from 192.168.1.0/24 to any port 8080

# أو من IP محدد فقط
sudo ufw allow from 192.168.1.50 to any port 8080
```

**استخدم HTTPS (اختياري):**
```bash
# ضع Nginx كـ Reverse Proxy مع SSL
sudo apt install nginx certbot
# ثم اتبع دليل إعداد Nginx + Let's Encrypt
```

### 2. تأمين ملف .env

```bash
# تغيير صلاحيات الملف
sudo chmod 600 /opt/hydepark-sync/.env

# التأكد من المالك
sudo chown $USER:$USER /opt/hydepark-sync/.env
```

### 3. النسخ الاحتياطية المنتظمة

**إنشاء سكريبت للنسخ الاحتياطي التلقائي:**

```bash
# إنشاء السكريبت
nano ~/backup-hydepark.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/backup/hydepark"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# نسخ البيانات
tar -czf $BACKUP_DIR/data_$DATE.tar.gz /opt/hydepark-sync/data/

# نسخ الإعدادات
cp /opt/hydepark-sync/.env $BACKUP_DIR/.env_$DATE

# حذف النسخ الأقدم من 30 يوم
find $BACKUP_DIR -name "*.tar.gz" -mtime +30 -delete

echo "Backup completed: $BACKUP_DIR"
```

```bash
# جعل السكريبت قابل للتنفيذ
chmod +x ~/backup-hydepark.sh

# إضافة إلى Crontab (يومياً عند 3 صباحاً)
crontab -e
# أضف:
0 3 * * * /home/your_username/backup-hydepark.sh
```

---

## 📈 المراقبة والصيانة

### مراقبة الأداء

```bash
# استخدام الموارد
top -p $(pgrep -f "python.*main.py")

# استخدام الذاكرة
ps aux | grep "python.*main.py"

# حجم البيانات
du -sh /opt/hydepark-sync/data/
```

### الصيانة الدورية

**يومياً:**
- ✅ تحقق من Dashboard للأخطاء
- ✅ راجع Workers المحظورين

**أسبوعياً:**
- ✅ راجع السجلات: `sudo journalctl -u hydepark-sync --since "7 days ago" | grep ERROR`
- ✅ تحقق من مساحة القرص: `df -h`

**شهرياً:**
- ✅ نسخ احتياطي شامل
- ✅ تحديث المكتبات: `bash update.sh`
- ✅ مراجعة الصور المخزنة

---

## 🆘 الدعم

إذا واجهت مشكلة:

1. **راجع السجلات أولاً:**
```bash
sudo journalctl -u hydepark-sync -n 100
```

2. **تحقق من حالة الخدمة:**
```bash
sudo systemctl status hydepark-sync
```

3. **اختبر الاتصال:**
```bash
# Supabase
curl https://xrkxxqhoglrimiljfnml.supabase.co/functions/v1/make-server-2c3121a9/admin/events/stats

# HikCentral
curl -k https://10.127.0.2/artemis/
```

4. **راجع ملف الإعدادات:**
```bash
cat /opt/hydepark-sync/.env
```

---

## ✅ Checklist قبل الإطلاق

قبل تشغيل النظام في الإنتاج:

- [ ] تم تثبيت جميع المتطلبات
- [ ] تم تعديل ملف .env بالبيانات الصحيحة
- [ ] تم اختبار الاتصال بـ Supabase
- [ ] تم اختبار الاتصال بـ HikCentral
- [ ] تم الوصول إلى Dashboard بنجاح
- [ ] تم تغيير كلمة مرور Dashboard الافتراضية
- [ ] تم إعداد النسخ الاحتياطية التلقائية
- [ ] تم تقييد الوصول للـ Dashboard (Firewall)
- [ ] تم اختبار إضافة عامل تجريبي
- [ ] تم مراجعة السجلات والتأكد من عدم وجود أخطاء

---

**بالتوفيق! 🎉**

إذا كان عندك أي استفسار، راجع ملف `README.md` الرئيسي أو اتصل بفريق الدعم.
