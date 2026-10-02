/// Structured Privacy Policy copy for the in-app screen (EN / UR).
///
/// Keep aligned with `docs/legal/privacy-policy.html` when you change disclosures.
class PrivacyPolicyContent {
  const PrivacyPolicyContent._();

  static const lastUpdated = '2 October 2026';

  static List<PrivacySection> sectionsFor(String languageCode) {
    if (languageCode == 'ur') return _ur;
    return _en;
  }

  static const _en = <PrivacySection>[
    PrivacySection(
      title: 'Who we are',
      body:
          'PakFasal helps Pakistani farmers with weather, '
          'soil advice, learning, marketplace discovery, crop calendars, and related tools. '
          'This policy explains what data we collect, why, and how you can control it.',
    ),
    PrivacySection(
      title: 'Data we collect',
      body:
          '• Account: name/display name, email, and user ID (email/password or Google Sign-In).\n'
          '• Profile photo (optional): stored with Cloudinary and linked to your profile.\n'
          '• Location: approximate and/or precise location when allowed, for local weather. You can search by city instead.\n'
          '• Farming data you enter: sensor/soil readings, crop plantings, and similar inputs.\n'
          '• Microphone (optional): only when you use voice input (e.g. Ask AI).\n'
          '• Camera / photos (optional): only to pick or capture a profile photo.\n'
          '• Diagnostics: crash and error reports via Firebase Crashlytics.\n'
          '• Advertising identifiers: when ads are shown (Google AdMob). Development builds may use Google test ad units.\n'
          '• Local preferences: language, saved cities, biometric lock, and similar on-device settings.',
    ),
    PrivacySection(
      title: 'How we use data',
      body:
          'We use data to provide farming features, authenticate you, improve reliability, '
          'show advertising that supports the free app, and respond to support requests.\n\n'
          'We do not sell your personal information.',
    ),
    PrivacySection(
      title: 'Sharing with service providers',
      body:
          '• Google Firebase — Authentication, Firestore, Crashlytics\n'
          '• Google Sign-In — if you choose Google login\n'
          '• Google AdMob — ads and related advertising identifiers\n'
          '• Cloudinary — optional profile image hosting\n'
          '• OpenWeather / weather APIs — coordinates or city queries for forecasts\n\n'
          'These providers process data under their policies and our configuration.',
    ),
    PrivacySection(
      title: 'Permissions',
      body:
          'Location (weather), camera/photos (profile), microphone (voice input), '
          'notifications (crop reminders), and biometric (optional app lock). '
          'You can deny or revoke permissions in system settings.',
    ),
    PrivacySection(
      title: 'Deletion & your choices',
      body:
          'In-app: Profile → Delete account removes your Auth account and associated cloud data '
          '(profile, sensor readings, crop plantings) plus local auth artifacts.\n\n'
          'Outside the app: use the Account deletion web page or email support@pakfasal.app '
          'from your registered address with subject “PakFasal Account Deletion”.',
    ),
    PrivacySection(
      title: 'Children',
      body:
          'PakFasal is intended for farmers and general adult users. It is not directed at '
          'children under 13 (or the minimum age in your country).',
    ),
    PrivacySection(
      title: 'Contact',
      body:
          'Email: support@pakfasal.app\n'
          'WhatsApp: +92 316 4945717',
    ),
  ];

  static const _ur = <PrivacySection>[
    PrivacySection(
      title: 'ہم کون ہیں',
      body:
          'پاک فصل پاکستانی کسانوں کے لیے موسم، مٹی کی مشورت، تعلیم، '
          'مارکیٹ پلیس، فصل کیلنڈر اور متعلقہ ٹولز فراہم کرتی ہے۔ یہ پالیسی بتاتی ہے کہ ہم کون سا '
          'ڈیٹا جمع کرتے ہیں، کیوں، اور آپ اسے کیسے کنٹرول کر سکتے ہیں۔',
    ),
    PrivacySection(
      title: 'جمع کردہ ڈیٹا',
      body:
          '• اکاؤنٹ: نام، ای میل، یوزر آئی ڈی (ای میل/پاس ورڈ یا گوگل سائن اِن)۔\n'
          '• پروفائل تصویر (اختیاری): Cloudinary پر محفوظ۔\n'
          '• مقام: موسم کے لیے (آپ شہر تلاش بھی کر سکتے ہیں)۔\n'
          '• زرعی ڈیٹا: سینسر ریڈنگز، فصل کی پودے کاری وغیرہ۔\n'
          '• مائیکروفون (اختیاری): صرف آواز سے ان پٹ۔\n'
          '• کیمرہ (اختیاری): صرف پروفائل تصویر۔\n'
          '• تشخیصی رپورٹس: Firebase Crashlytics۔\n'
          '• اشتہاری شناخت کنندگان: Google AdMob (ٹیسٹ مرحلے میں ٹیسٹ ad IDs)۔\n'
          '• مقامی ترجیحات: زبان، محفوظ شہر، بائیو میٹرک لاک۔',
    ),
    PrivacySection(
      title: 'استعمال',
      body:
          'فیچرز چلانا، لاگ اِن، استحکام بہتر بنانا، مفت ایپ کے لیے اشتہارات، اور سپورٹ۔\n\n'
          'ہم آپ کا ذاتی ڈیٹا فروخت نہیں کرتے۔',
    ),
    PrivacySection(
      title: 'شیئرنگ',
      body:
          'Firebase، Google Sign-In، AdMob، Cloudinary، اور موسمی APIs — صرف ایپ چلانے کے لیے۔',
    ),
    PrivacySection(
      title: 'اجازتیں',
      body:
          'مقام، کیمرہ/تصاویر، مائیکروفون، نوٹیفکیشنز، بائیو میٹرک — سسٹم سیٹنگز سے بند کر سکتے ہیں۔',
    ),
    PrivacySection(
      title: 'حذف کرنا',
      body:
          'ایپ میں: پروفائل → اکاؤنٹ حذف کریں۔\n'
          'ایپ کے باہر: اکاؤنٹ ڈیلیٹ ویب صفحہ یا support@pakfasal.app پر درخواست بھیجیں۔',
    ),
    PrivacySection(
      title: 'بچے',
      body:
          'پاک فصل عام بالغ صارفین / کسانوں کے لیے ہے۔ 13 سال سے کم عمر بچوں کے لیے نہیں۔',
    ),
    PrivacySection(
      title: 'رابطہ',
      body:
          'ای میل: support@pakfasal.app\n'
          'واٹس ایپ: +92 316 4945717',
    ),
  ];
}

class PrivacySection {
  const PrivacySection({required this.title, required this.body});

  final String title;
  final String body;
}
