# 🔧 Quick Fix - HikCentral Authentication

## المشكلة

```
ERROR - HikCentral error: api AK/SK signature authentication failed,Invalid Signature!
```

## الحل السريع 🚀

### على السيرفر:

```bash
# 1. اذهب لمجلد المشروع
cd ~/Hikcentralhyde/src

# 2. شغّل التحديث (سيصلح الـ signature تلقائياً)
bash update.sh
```

**أو** إذا كنت تريد تثبيت نظيف:

```bash
cd ~/Hikcentralhyde/src
bash deploy.sh
```

---

## التحقق من الإصلاح ✅

### 1. اختبر الـ Signature:

```bash
cd /opt/hydepark-sync
source venv/bin/activate
python3 test_hikcentral_signature.py
deactivate
```

**يجب أن تشاهد:**
```
✅ SIGNATURE MATCHES!
The implementation is correct!
```

### 2. راقب السجلات:

```bash
sudo journalctl -u hydepark-sync -f
```

**يجب أن تشاهد:**
```
INFO - Successfully added person: XXXXXXXX (ID: XXXXX)
INFO - Successfully added person to privilege group: XXXXX
```

**بدون:**
```
ERROR - HikCentral error: api AK/SK signature authentication failed
```

---

## التفاصيل التقنية 🔍

### ما الذي تم إصلاحه؟

**الـ `string_to_sign` القديم (غلط):**
```
POST
application/json
9rm2KDeuNBnIkroQ+bu3dA==
application/json;charset=UTF-8
/artemis/api/resource/v1/person/single/add
```

**مفيش الـ x-ca headers!** ❌

---

**الـ `string_to_sign` الجديد (صح):**
```
POST
application/json
9rm2KDeuNBnIkroQ+bu3dA==
application/json;charset=UTF-8
x-ca-key:22452825
x-ca-nonce:0049395a-85a5-4991-8240-148dcf3e3612
x-ca-timestamp:1592894521052
/artemis/api/resource/v1/person/single/add
```

**فيه الـ x-ca headers!** ✅

---

### التغييرات في الكود:

#### في `api/hikcentral_api.py`:

**قبل:**
```python
# Add Content-MD5 only if body exists
if body:
    content_md5 = self._get_content_md5(body)
    parts.append(content_md5)
```

**بعد:**
```python
# Add Content-MD5 if present in headers
if 'Content-MD5' in headers:
    parts.append(headers['Content-MD5'])

# ... then add x-ca headers ...
parts.append(f"x-ca-key:{headers['X-Ca-Key']}")
parts.append(f"x-ca-nonce:{headers['X-Ca-Nonce']}")
parts.append(f"x-ca-timestamp:{headers['X-Ca-Timestamp']}")
```

---

## الخطوات التالية

1. ✅ تحديث الكود: `bash update.sh`
2. ✅ اختبار: `python3 test_hikcentral_signature.py`
3. ✅ مراقبة السجلات: `sudo journalctl -u hydepark-sync -f`
4. ✅ تجربة إضافة worker جديد من التطبيق

---

## إذا مازالت المشكلة موجودة

### تحقق من الإعدادات:

```bash
nano /opt/hydepark-sync/.env
```

**تأكد من:**
```env
HIKCENTRAL_BASE_URL=https://10.127.0.2  # بدون /artemis
HIKCENTRAL_APP_KEY=22452825             # صح
HIKCENTRAL_APP_SECRET=Q9bWogAziordVdIngfoa  # صح
```

### أعد تشغيل الخدمة:

```bash
sudo systemctl restart hydepark-sync
sudo journalctl -u hydepark-sync -f
```

---

## للدعم الكامل

راجع: `DEPLOYMENT_GUIDE.md`

---

**تم! 🎉**
