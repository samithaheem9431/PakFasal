/// One marketplace listing from Firestore (`products`), managed by the
/// PakFasal admin panel. Both languages are kept on the model so switching
/// the app language re-renders instantly without a re-fetch.
class Product {
  const Product({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.descriptionEn,
    required this.descriptionUr,
    required this.price,
    required this.currency,
    required this.crop,
    required this.category,
    required this.company,
    required this.images,
    required this.phones,
    required this.sku,
    required this.isActive,
  });

  final String id;
  final String titleEn;
  final String titleUr;
  final String descriptionEn;
  final String descriptionUr;
  final double price;
  final String currency;
  final String crop;
  final String category;
  final String company;
  final List<String> images;
  final List<String> phones;
  final String sku;
  final bool isActive;

  bool get hasImage => images.any((u) => u.trim().isNotEmpty);
  String get imageUrl {
    for (final url in images) {
      final trimmed = url.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return '';
  }

  String? get primaryPhone {
    for (final phone in phones) {
      final trimmed = phone.trim();
      if (trimmed.isNotEmpty) return trimmed;
    }
    return null;
  }

  String title(String lang) => _pick(titleEn, titleUr, lang);
  String description(String lang) => _pick(descriptionEn, descriptionUr, lang);

  String priceLabel() {
    final currency = this.currency.isEmpty ? 'PKR' : this.currency;
    final amount = price == price.roundToDouble()
        ? price.toInt().toString()
        : price.toStringAsFixed(2);
    // Manual thousands separator so we don't depend on locale digits.
    final parts = amount.split('.');
    final whole = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    final formatted =
        parts.length > 1 ? '$whole.${parts[1]}' : whole;
    return '$currency $formatted';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleEn': titleEn,
        'titleUr': titleUr,
        'descriptionEn': descriptionEn,
        'descriptionUr': descriptionUr,
        'price': price,
        'currency': currency,
        'crop': crop,
        'category': category,
        'company': company,
        'images': images,
        'phones': phones,
        'sku': sku,
        'isActive': isActive,
      };

  factory Product.fromJson(Map<String, dynamic> json) {
    final title = _asMap(json['title']);
    final description = _asMap(json['description']);
    // Prefer nested bilingual maps (Firestore), fall back to flat cache keys.
    final titleEn = _str(title['en']).isNotEmpty
        ? _str(title['en'])
        : _str(json['titleEn']);
    final titleUr = _str(title['ur']).isNotEmpty
        ? _str(title['ur'])
        : _str(json['titleUr']);
    final descriptionEn = _str(description['en']).isNotEmpty
        ? _str(description['en'])
        : _str(json['descriptionEn']);
    final descriptionUr = _str(description['ur']).isNotEmpty
        ? _str(description['ur'])
        : _str(json['descriptionUr']);

    final resolved = _resolveCropAndCategory(
      crop: _str(json['crop']),
      category: _str(json['category']),
    );

    return Product(
      id: _str(json['id']),
      titleEn: titleEn,
      titleUr: titleUr,
      descriptionEn: descriptionEn,
      descriptionUr: descriptionUr,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      currency: _str(json['currency']).isEmpty
          ? 'PKR'
          : _str(json['currency']),
      crop: resolved.crop,
      category: resolved.category,
      company: _str(json['company']),
      images: _stringList(json['images']),
      phones: _stringList(json['phones']),
      sku: _str(json['sku']),
      isActive: json['isActive'] != false,
    );
  }

  static const _legacyCropValues = {'wheat', 'rice', 'cotton'};

  /// Older admin docs stored crop slug in `category`.
  static ({String crop, String category}) _resolveCropAndCategory({
    required String crop,
    required String category,
  }) {
    if (crop.isNotEmpty) {
      return (
        crop: crop,
        category: _legacyCropValues.contains(category) ? '' : category,
      );
    }
    if (_legacyCropValues.contains(category)) {
      return (crop: category, category: '');
    }
    return (crop: '', category: category);
  }

  static String _pick(String en, String ur, String lang) {
    if (lang == 'ur') {
      return ur.trim().isNotEmpty ? ur : en;
    }
    return en.trim().isNotEmpty ? en : ur;
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return value.map((k, v) => MapEntry(k.toString(), v));
    }
    return const {};
  }

  static String _str(dynamic value) => value == null ? '' : value.toString().trim();

  static List<String> _stringList(dynamic value) {
    if (value is! List) return const [];
    return value
        .map((e) => e?.toString().trim() ?? '')
        .where((e) => e.isNotEmpty)
        .toList();
  }
}
