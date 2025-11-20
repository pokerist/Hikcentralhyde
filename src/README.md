# HydePark Sync System

نظام مزامنة محلي يربط بين تطبيق Supabase و HikCentral للأمان.

## المميزات

- ✅ مزامنة تلقائية كل 60 ثانية
- ✅ كشف الوجوه المكررة
- ✅ Dashboard ويب لمراقبة العمليات
- ✅ تسجيل شامل للـ API requests
- ✅ معالجة الصور وكشف الوجوه

## التنصيب

### على سيرفر Ubuntu جديد

```bash
# 1. Clone المشروع
git clone https://github.com/YOUR_REPO/hydepark-sync.git
cd hydepark-sync

# 2. شغل script التنصيب
chmod +x deploy.sh
./deploy.sh
```

**خلاص! النظام يشتغل تلقائياً** ✅

## الوصول للـ Dashboard

افتح المتصفح على:
```
http://YOUR_SERVER_IP:8080
```

**بيانات الدخول:**
- Username: `admin`
- Password: `123456`

## الأوامر المهمة

```bash
# عرض السجلات
sudo journalctl -u hydepark-sync -f

# إعادة تشغيل
sudo systemctl restart hydepark-sync

# إيقاف الخدمة
sudo systemctl stop hydepark-sync

# تشغيل الخدمة
sudo systemctl start hydepark-sync

# حالة الخدمة
sudo systemctl status hydepark-sync
```

## المجلدات المهمة

```
/opt/hydepark-sync/          # البرنامج الرئيسي
/opt/hydepark-sync/data/     # البيانات والصور
```

## إلغاء التنصيب

```bash
sudo systemctl stop hydepark-sync
sudo systemctl disable hydepark-sync
sudo rm /etc/systemd/system/hydepark-sync.service
sudo rm -rf /opt/hydepark-sync
sudo systemctl daemon-reload
```

## الملاحظات

- النظام يشتغل بدون اتصال إنترنت مباشر
- كل الإعدادات في ملف `config.py`
- السيرفر لازم يقدر يوصل للـ HikCentral على الشبكة المحلية

## الدعم

لو في مشكلة، شوف السجلات:
```bash
sudo journalctl -u hydepark-sync -n 100
```
