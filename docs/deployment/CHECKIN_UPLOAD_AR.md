# ملفات ربط الحالة اليومية

1. ارفعي `patient_checkin.php` إلى مجلد `api_doctor` بجانب `db.php`.
2. في `caregiver_dashboard.php` أضيفي `created_at, updated_at` بعد `checkin_date`
   داخل استعلام `daily_checkins`.
3. داخل مصفوفة `latest_checkin` أضيفي:

```php
'created_at' => $checkin['created_at'],
'updated_at' => $checkin['updated_at'],
```

بعد ذلك أعيدي بناء مشروع `web` وارفعي محتويات مجلد `dist`.

التحقق الأمني موجود داخل `patient_checkin.php`: لا يستطيع الطبيب أو المعالج
عرض الحالة إلا إذا كان لديه تكليف فعال للمريض في `web_patient_assignments`.
