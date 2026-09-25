/// Display labels for marketplace crop / category slugs stored in Firestore.
class MarketplaceLabels {
  MarketplaceLabels._();

  static const _cropEn = {
    'wheat': 'Wheat',
    'rice': 'Rice',
    'cotton': 'Cotton',
  };

  static const _cropUr = {
    'wheat': 'گندم',
    'rice': 'چاول',
    'cotton': 'کپاس',
  };

  static const _categoryEn = {
    'fungicides': 'Fungicides',
    'herbicides': 'Herbicides',
    'insecticides': 'Insecticides',
    'seedcare': 'Seed Care',
    'specialty-nutrition': 'Specialty Nutrition',
  };

  static const _categoryUr = {
    'fungicides': 'فنجیسائیڈز',
    'herbicides': 'جڑی بوٹی مار',
    'insecticides': 'کیڑے مار',
    'seedcare': 'بیج کی دیکھ بھال',
    'specialty-nutrition': 'خصوصی غذائیت',
  };

  static String crop(String slug, String languageCode) {
    final key = slug.trim().toLowerCase();
    if (key.isEmpty) return '';
    if (languageCode == 'ur') {
      return _cropUr[key] ?? _titleCase(slug);
    }
    return _cropEn[key] ?? _titleCase(slug);
  }

  static String category(String slug, String languageCode) {
    final key = slug.trim().toLowerCase();
    if (key.isEmpty) return '';
    if (languageCode == 'ur') {
      return _categoryUr[key] ?? _titleCase(slug.replaceAll('-', ' '));
    }
    return _categoryEn[key] ?? _titleCase(slug.replaceAll('-', ' '));
  }

  static String _titleCase(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return trimmed;
    return trimmed
        .split(RegExp(r'\s+'))
        .map((w) {
          if (w.isEmpty) return w;
          return '${w[0].toUpperCase()}${w.substring(1)}';
        })
        .join(' ');
  }
}
