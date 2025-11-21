# HydePark Sync System

نظام مزامنة محلي احترافي يربط بين تطبيق Supabase ونظام HikCentral للأمان.

## 🚀 التنصيب السريع

```bash
# 1. Clone المشروع
git clone https://github.com/YOUR_REPO/hydepark-sync.git
cd hydepark-sync

# 2. شغل التنصيب التلقائي
chmod +x deploy.sh
./deploy.sh
```

**خلاص! النظام يشتغل لوحده** ✅

السكريبت بيعمل **كل حاجة** أوتوماتيك:
- ✅ تنضيف أي installation قديم
- ✅ تنصيب كل الـ dependencies
- ✅ ضبط الـ firewall
- ✅ إعداد البيئة وقاعدة البيانات
- ✅ تشغيل الخدمة
- ✅ فحص شامل بعد التنصيب

## 📊 الوصول للـ Dashboard

```
http://YOUR_SERVER_IP:8080
```

**بيانات الدخول:**
- Username: `admin`
- Password: `123456`

## 🎯 المميزات

- 🔄 مزامنة تلقائية كل 60 ثانية
- 👤 كشف الوجوه المكررة بالذكاء الاصطناعي
- 📊 Dashboard ويب متقدم لمراقبة العمليات
- 📝 تسجيل شامل لكل API requests
- 🖼️ معالجة احترافية للصور
- 🔐 نظام آمن بدون ملفات .env

## 📁 التعديلات على الإعدادات

عدل الملف: `/opt/hydepark-sync/config.py`

```bash
sudo nano /opt/hydepark-sync/config.py
# عدل القيم اللي عايزها
sudo systemctl restart hydepark-sync
```

## 🔧 الأوامر المهمة

```bash
# السجلات الحية
sudo journalctl -u hydepark-sync -f

# إعادة تشغيل
sudo systemctl restart hydepark-sync

# حالة الخدمة
sudo systemctl status hydepark-sync

# إيقاف الخدمة
sudo systemctl stop hydepark-sync

# تشغيل الخدمة
sudo systemctl start hydepark-sync
```

## 🛠️ حل المشاكل

### إذا Dashboard مش شغال:

```bash
# شوف السجلات
sudo journalctl -u hydepark-sync -n 100

# أو شغل يدوي عشان تشوف الخطأ
cd /opt/hydepark-sync
source venv/bin/activate
python main.py
```

### فحص صحة النظام:

```bash
cd /opt/hydepark-sync
./post_deploy_check.sh
```

## 🗑️ إلغاء التنصيب

```bash
sudo systemctl stop hydepark-sync
sudo systemctl disable hydepark-sync
sudo rm /etc/systemd/system/hydepark-sync.service
sudo rm -rf /opt/hydepark-sync
sudo systemctl daemon-reload
```

## 📂 بنية المشروع

```
/opt/hydepark-sync/
├── api/                  # وحدات الاتصال بالـ APIs
├── processors/           # معالجات الأحداث والصور
├── dashboard/            # تطبيق الويب
├── utils/               # أدوات مساعدة
├── data/                # البيانات والصور
├── config.py            # الإعدادات (hardcoded)
├── main.py              # نقطة البداية
└── database.py          # قاعدة البيانات المحلية
```

## 📝 ملاحظات مهمة

- ⚡ النظام يعمل بدون اتصال إنترنت مباشر
- 🔒 كل الإعدادات في `config.py` (بدون .env)
- 🌐 السيرفر لازم يوصل HikCentral على الشبكة المحلية
- 💾 كل البيانات محفوظة في `/opt/hydepark-sync/data/`

## 📖 المزيد من الوثائق

- [دليل الاستخدام التفصيلي](USAGE.md)
- [طرق النقل للسيرفر](DEPLOY_TO_SERVER.md)

## 🆘 الدعم

لو عندك مشكلة:

1. شوف السجلات: `sudo journalctl -u hydepark-sync -n 100`
2. شغل الفحص: `./post_deploy_check.sh`
3. جرب التشغيل اليدوي

---

**Built with ❤️ for seamless deployment**
