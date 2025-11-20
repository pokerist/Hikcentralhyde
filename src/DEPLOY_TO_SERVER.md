# نقل المشروع للسيرفر

## الطريقة الأولى: Git Clone (موصى بها)

```bash
# على السيرفر
cd ~
git clone https://github.com/YOUR_USERNAME/hydepark-sync.git
cd hydepark-sync
chmod +x deploy.sh
./deploy.sh
```

## الطريقة الثانية: نسخ مباشر

### 1. على جهازك المحلي

```bash
# اضغط المشروع
tar -czf hydepark-sync.tar.gz .

# انقله للسيرفر
scp hydepark-sync.tar.gz user@SERVER_IP:~/
```

### 2. على السيرفر

```bash
# فك الضغط
cd ~
tar -xzf hydepark-sync.tar.gz
cd hydepark-sync

# شغل التنصيب
chmod +x deploy.sh
./deploy.sh
```

## بعد التنصيب

```bash
# شوف السجلات
sudo journalctl -u hydepark-sync -f

# Dashboard
http://YOUR_SERVER_IP:8080
Username: admin
Password: 123456
```

## تعديل الإعدادات

افتح `/opt/hydepark-sync/config.py` وعدل:
- معلومات Supabase
- معلومات HikCentral  
- إعدادات Dashboard

```bash
sudo nano /opt/hydepark-sync/config.py
sudo systemctl restart hydepark-sync
```

## الأوامر المهمة

```bash
# حالة الخدمة
sudo systemctl status hydepark-sync

# إعادة تشغيل
sudo systemctl restart hydepark-sync

# إيقاف
sudo systemctl stop hydepark-sync

# تشغيل
sudo systemctl start hydepark-sync

# السجلات الفورية
sudo journalctl -u hydepark-sync -f

# آخر 100 سطر من السجلات
sudo journalctl -u hydepark-sync -n 100
```

## مسح كل حاجة

```bash
sudo systemctl stop hydepark-sync
sudo systemctl disable hydepark-sync
sudo rm /etc/systemd/system/hydepark-sync.service
sudo rm -rf /opt/hydepark-sync
sudo systemctl daemon-reload
```
