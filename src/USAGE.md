# دليل الاستخدام

## التنصيب السريع

```bash
chmod +x deploy.sh
./deploy.sh
```

## كيف يعمل النظام؟

النظام يعمل polling كل 60 ثانية:

1. **يجلب الأحداث** من Supabase API
2. **يحمل الصور** (صورة الوجه + البطاقة)
3. **يكشف الوجوه المكررة** في قاعدة البيانات المحلية
4. **يضيف العامل** إلى HikCentral
5. **يمنح الصلاحيات** (Privilege Group)
6. **يحفظ في قاعدة البيانات** المحلية

## أنواع الأحداث

### worker.created
إضافة عامل جديد

### worker.blocked
حظر عامل (إزالة الصلاحيات)

### worker.deleted
حذف عامل نهائياً

## الـ Dashboard

### الصفحة الرئيسية
- إحصائيات العمال
- الأحداث الأخيرة
- حالة النظام

### صفحة العمال
- قائمة جميع العمال
- البحث والفلترة
- عرض التفاصيل

### صفحة السجلات
- جميع API requests
- الـ headers والـ body
- الأخطاء والنجاحات

## تعديل الإعدادات

افتح ملف `/opt/hydepark-sync/config.py` وعدل القيم:

```python
# مثال: تغيير فترة المزامنة
SYNC_INTERVAL_SECONDS = 120  # كل دقيقتين

# مثال: تغيير عتبة التشابه
FACE_SIMILARITY_THRESHOLD = 0.85
```

بعد التعديل:
```bash
sudo systemctl restart hydepark-sync
```

## حل المشاكل

### النظام لا يعمل
```bash
sudo systemctl status hydepark-sync
sudo journalctl -u hydepark-sync -n 50
```

### Dashboard لا يفتح
```bash
# تحقق من البورت
sudo netstat -tulpn | grep 8080

# أو
sudo ss -tulpn | grep 8080
```

### الوجوه لا تُضاف
- تحقق من السجلات في Dashboard
- تأكد من جودة الصور
- راجع إعدادات HikCentral

## النسخ الاحتياطي

```bash
# نسخ قاعدة البيانات
cp /opt/hydepark-sync/data/workers.json ~/workers_backup_$(date +%Y%m%d).json

# نسخ الصور
tar -czf ~/faces_backup_$(date +%Y%m%d).tar.gz /opt/hydepark-sync/data/faces/
```

## الاستعادة

```bash
# استعادة قاعدة البيانات
cp ~/workers_backup_20250120.json /opt/hydepark-sync/data/workers.json

# استعادة الصور
tar -xzf ~/faces_backup_20250120.tar.gz -C /
```
