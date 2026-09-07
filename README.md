# تطبيق تتبع الدوام والمواصلات (Transport Tracker)

تطبيق Flutter بسيط لتتبع مكان العمل اليومي وحساب إجمالي بدل المواصلات شهرياً،
مع دعم كامل لأرشيف الشهور السابقة.

## هيكل المشروع

```
transport_tracker/
├── pubspec.yaml
└── lib/
    ├── main.dart                      # نقطة الدخول + تهيئة Hive + دعم RTL
    ├── models/
    │   └── day_record.dart            # نموذج بيانات اليوم (موقع + قيمة مواصلات)
    ├── services/
    │   └── storage_service.dart       # طبقة التخزين المحلي (Hive) + حساب الإجمالي الشهري
    ├── utils/
    │   └── date_helper.dart           # أسماء الأشهر/الأيام بالعربي وتنسيق المفاتيح
    ├── widgets/
    │   ├── month_selector.dart        # التنقل بين الشهر الحالي والأرشيف
    │   └── day_selector.dart          # شريط أفقي لأيام الشهر المحدد
    └── screens/
        └── home_screen.dart           # الشاشة الرئيسية التي تجمع كل شيء
```

## كيف يعمل دعم الأرشيف

كل يوم يُخزَّن بمفتاح فريد بصيغة `yyyy-MM-dd` داخل صندوق Hive واحد.
هذا يعني أن بيانات كل الشهور (الحالي والسابقة) محفوظة دائماً في نفس المكان.
عند اختيار شهر من `MonthSelector`، يقوم `StorageService.monthTotal()`
بجمع كل السجلات التي تبدأ بنفس بادئة الشهر (`yyyy-MM`) تلقائياً — فلا حاجة
لأي عملية "أرشفة" منفصلة، كل شيء متاح فوراً بالرجوع بالأسهم للخلف.

## خطوات التشغيل (على جهازك)

1. **تثبيت Flutter** (إن لم يكن مثبتاً): اتبع التعليمات في
   https://docs.flutter.dev/get-started/install

2. **إنشاء مشروع Flutter رسمي فارغ** (لتوليد مجلدات android/ios التي لم تُرفق هنا):
   ```bash
   flutter create transport_tracker_app
   ```

3. **استبدال الملفات**: انسخ ملف `pubspec.yaml` ومجلد `lib/` بالكامل من هذا
   المشروع إلى داخل `transport_tracker_app` (استبدل الملفات الموجودة).

4. **تثبيت الحزم**:
   ```bash
   cd transport_tracker_app
   flutter pub get
   ```

5. **تجربة التطبيق على المحاكي أو الهاتف**:
   ```bash
   flutter run
   ```

6. **تصدير ملف APK النهائي**:
   ```bash
   flutter build apk --release
   ```
   سيكون الملف الناتج في:
   `build/app/outputs/flutter-apk/app-release.apk`

## ملاحظات

- الخط `Cairo` مذكور في `main.dart` كخيار اختياري لخط عربي جميل. إن لم
  تُضِف ملفات الخط لمجلد `assets/fonts` وتُعرّفها في `pubspec.yaml`،
  فلتفادي أي مشاكل احذف السطر `fontFamily: 'Cairo'` من `main.dart` وسيعمل
  التطبيق بالخط الافتراضي للنظام بدون أي مشاكل.
- لا حاجة لتشغيل `build_runner` أو توليد أي أكواد إضافية؛ التخزين يعتمد
  على `Box<Map>` مباشرة في Hive لتبسيط الصيانة.
