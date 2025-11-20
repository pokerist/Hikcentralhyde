# دليل البداية السريعة ⚡

## للمستعجلين 🚀

### التثبيت في 5 دقائق

```bash
# 1. رفع الملفات للسيرفر وفك الضغط
cd ~
# (استخدم SCP أو SFTP لرفع الملفات)

# 2. إعطاء صلاحيات التنفيذ
chmod +x deploy.sh update.sh

# 3. تشغيل التثبيت
bash deploy.sh

# 4. تعديل الإعدادات
nano /opt/hydepark-sync/.env
# املأ البيانات ثم: Ctrl+O ثم Enter ثم Ctrl+X

# 5. إعادة التشغيل
sudo systemctl restart hydepark-sync

# 6. التحقق
sudo systemctl status hydepark-sync
```

### الوصول إلى Dashboard

افتح المتصفح:
```
http://عنوان-السيرفر:8080
```

---

## الأوامر الأساسية 📝

### التحكم بالخدمة

```bash
# بدء
sudo systemctl start hydepark-sync

# إيقاف
sudo systemctl stop hydepark-sync

# إعادة تشغيل
sudo systemctl restart hydepark-sync

# الحالة
sudo systemctl status hydepark-sync
```

### السجلات

```bash
# عرض مباشر
sudo journalctl -u hydepark-sync -f

# آخر 50 سطر
sudo journalctl -u hydepark-sync -n 50

# البحث عن أخطاء
sudo journalctl -u hydepark-sync | grep ERROR
```

### التحديث

```bash
cd ~/hydepark-sync-source
bash update.sh
```

---

## ملف .env المطلوب ⚙️

**الحد الأدنى المطلوب:**

```env
# Supabase (أحدهما على الأقل)
SUPABASE_BASE_URL=https://xrkxxqhoglrimiljfnml.supabase.co/functions/v1/make-server-2c3121a9
SUPABASE_API_KEY=your_key_here

# HikCentral (كلها مطلوبة)
HIKCENTRAL_BASE_URL=https://10.127.0.2/artemis
HIKCENTRAL_APP_KEY=your_app_key
HIKCENTRAL_APP_SECRET=your_app_secret
HIKCENTRAL_VERIFY_SSL=false

# Dashboard (غيّر كلمة المرور!)
DASHBOARD_USERNAME=admin
DASHBOARD_PASSWORD=change_this_password
```

---

## حل المشاكل السريع 🔧

### الخدمة لا تعمل؟

```bash
# 1. شوف السجلات
sudo journalctl -u hydepark-sync -n 50

# 2. اختبر يدوي
cd /opt/hydepark-sync
source venv/bin/activate
python3 main.py
```

### Dashboard لا يفتح؟

```bash
# 1. تحقق من المنفذ
sudo netstat -tlnp | grep 8080

# 2. افتح الجدار الناري
sudo ufw allow 8080/tcp
```

### اتصال HikCentral فاشل؟

```bash
# اختبر الاتصال
ping 10.127.0.2
curl -k https://10.127.0.2/artemis/
```

---

## الملفات المهمة 📁

```
/opt/hydepark-sync/           # مجلد التثبيت الرئيسي
├── .env                      # الإعدادات (الأهم!)
├── data/
│   ├── workers.json         # قاعدة بيانات العمال
│   └── request_logs.json    # سجلات API
├── hydepark-sync.log        # ملف السجلات
└── venv/                    # البيئة الافتراضية

/opt/hydepark-sync_backups/   # النسخ الاحتياطية
```

---

## Dashboard Pages

### 1. الرئيسية `/`
- إحصائيات النظام
- آخر الطلبات

### 2. السجلات `/logs`
- جميع طلبات API
- تصفية وبحث
- تصدير CSV/JSON

### 3. العمال `/workers`
- قائمة العمال
- حالة المزامنة
- معرفات HikCentral

---

## Checklist ✅

قبل التشغيل:
- [ ] الملفات مرفوعة للسيرفر
- [ ] تم تشغيل `bash deploy.sh`
- [ ] ملف `.env` معبأ بالبيانات الصحيحة
- [ ] الخدمة تعمل: `sudo systemctl status hydepark-sync`
- [ ] Dashboard يفتح: `http://server-ip:8080`
- [ ] غيرت كلمة مرور Dashboard

---

**كل حاجة تمام؟ تمام! 🎉**

للتفاصيل الكاملة، راجع `DEPLOYMENT_AR.md`
