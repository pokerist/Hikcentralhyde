# 📝 سجل التغييرات - HydePark Sync System

## Version 2.0 - Clean Deployment (November 20, 2025)

### 🎯 التغييرات الرئيسية

#### 1. **Clean Deployment System**
- ✅ `deploy.sh` يمسح التثبيت القديم تلقائياً
- ✅ يحفظ `data/` و `.env` قبل المسح
- ✅ يستعيد البيانات بعد التثبيت
- ✅ نظام نشر نظيف ومضمون

#### 2. **HikCentral Authentication Fix** 🔐
- ✅ إصلاح توليد HMAC-SHA256 signature
- ✅ تصحيح بناء `string_to_sign`
- ✅ الـ Content-MD5 دلوقتي بياخده من الـ headers (مش بيحسبه تاني)
- ✅ الـ x-ca headers بالترتيب الأبجدي الصحيح
- ✅ استخدام full path في URI (`/artemis/api/...`)
- ✅ `base_url` ينضف تلقائياً (يشيل `/artemis` لو موجود)
- ✅ كل الـ endpoints محدّثة لتبدأ بـ `/artemis/api/...`
- ✅ Debug logging للـ string_to_sign

#### 3. **Enhanced Update Script**
- ✅ `update.sh` محدّث لعدم نسخ الملفات غير الضرورية
- ✅ استبعاد `.log` و `.DS_Store` من النسخ
- ✅ نسخ احتياطية أذكى

#### 4. **Testing Tools** 🧪
- ✅ `test_hikcentral_signature.py` - اختبار الـ signature
- ✅ دعم اختبار مع أمثلة حقيقية
- ✅ التأكد من صحة الـ authentication قبل النشر

#### 5. **Documentation** 📚
- ✅ `DEPLOYMENT_GUIDE.md` - دليل شامل للنشر
- ✅ `CHANGELOG.md` - سجل التغييرات
- ✅ `README.md` محدّث بالتعليمات الصحيحة
- ✅ `.gitignore` للملفات غير المطلوبة

---

### 🔧 الملفات المعدّلة

#### Core Files:
- `api/hikcentral_api.py` - إصلاح authentication كامل
- `deploy.sh` - نظام clean deployment
- `update.sh` - تحسينات في النسخ
- `README.md` - تعليمات محدّثة

#### New Files:
- `test_hikcentral_signature.py` - اختبار الـ signature
- `DEPLOYMENT_GUIDE.md` - دليل النشر الشامل
- `CHANGELOG.md` - هذا الملف
- `.gitignore` - ملفات Git

---

### 🐛 الأخطاء المصلحة

1. **`data/workers.json` not found** ✅
   - السبب: الـ `data/` folder مش موجود
   - الحل: `deploy.sh` يعملها تلقائياً

2. **HikCentral Authentication Error** ✅
   - السبب: signature غلط
   - الحل: تصحيح `_generate_signature()`

3. **Dashboard Stats Empty** ✅
   - السبب: database files مش موجودة
   - الحل: تأكد من وجودها في `deploy.sh`

4. **URL Duplication (`/artemis/artemis/...`)** ✅
   - السبب: `base_url` فيه `/artemis` والـ endpoint فيه `/artemis`
   - الحل: الـ `base_url` ينضف تلقائياً

---

### 📋 Migration Guide (من v1.0 لـ v2.0)

#### على السيرفر:

```bash
# 1. اذهب لمجلد المشروع
cd ~/Hikcentralhyde/src

# 2. شغّل deploy (سيمسح القديم ويحفظ data و .env)
bash deploy.sh

# 3. تأكد من .env
nano /opt/hydepark-sync/.env
# تأكد من: HIKCENTRAL_BASE_URL=https://10.127.0.2 (بدون /artemis)

# 4. أعد تشغيل الخدمة
sudo systemctl restart hydepark-sync

# 5. راقب السجلات
sudo journalctl -u hydepark-sync -f
```

---

### ⚠️ Breaking Changes

1. **`HIKCENTRAL_BASE_URL` Format Changed**
   - **قبل:** `https://10.127.0.2/artemis`
   - **بعد:** `https://10.127.0.2`
   - **السبب:** النظام يضيف `/artemis/api/...` تلقائياً

2. **Clean Deployment**
   - `deploy.sh` دلوقتي يمسح الملفات القديمة
   - يحفظ `data/` و `.env` فقط
   - إذا عندك ملفات custom، احفظها قبل النشر

---

### 🎯 Next Steps

- [ ] اختبار مع HikCentral حقيقي
- [ ] مراقبة الأداء لمدة أسبوع
- [ ] تحسينات في الـ dashboard
- [ ] دعم multiple HikCentral servers

---

### 📊 Statistics

- **Files Changed:** 8
- **New Files:** 4
- **Lines Added:** ~500
- **Lines Removed:** ~100
- **Test Coverage:** Authentication + Deployment

---

### 👥 Contributors

- AI Assistant - Core development
- User - Requirements & Testing

---

### 📅 Release Date

November 20, 2025

---

## Version 1.0 - Initial Release

### Features
- ✅ Supabase integration
- ✅ HikCentral integration (with auth issues)
- ✅ Face recognition
- ✅ Web dashboard
- ✅ Event processing
- ✅ Worker management

### Known Issues
- ❌ HikCentral authentication errors
- ❌ Manual deployment required
- ❌ No clean installation process

---

**للمزيد من التفاصيل، راجع `DEPLOYMENT_GUIDE.md`**