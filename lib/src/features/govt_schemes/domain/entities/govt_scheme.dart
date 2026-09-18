/// One government scheme document from Firestore (`govt_schemes`), managed by
/// the PakFasal admin panel. Both languages are kept on the model so switching
/// the app language re-renders instantly without a re-fetch.
class GovtScheme {
  const GovtScheme({
    required this.id,
    required this.titleEn,
    required this.titleUr,
    required this.descriptionEn,
    required this.descriptionUr,
    required this.categoryEn,
    required this.categoryUr,
    required this.departmentEn,
    required this.departmentUr,
    required this.province,
    required this.eligibilityEn,
    required this.eligibilityUr,
    required this.benefitsEn,
    required this.benefitsUr,
    required this.deadline,
    required this.status,
    required this.applyUrl,
    required this.website,
    required this.imageUrl,
    required this.featured,
    required this.order,
  });

  final String id;
  final String titleEn;
  final String titleUr;
  final String descriptionEn;
  final String descriptionUr;
  final String categoryEn;
  final String categoryUr;
  final String departmentEn;
  final String departmentUr;
  final String province;
  final List<String> eligibilityEn;
  final List<String> eligibilityUr;
  final List<String> benefitsEn;
  final List<String> benefitsUr;

  /// ISO date `YYYY-MM-DD`, or empty when open-ended.
  final String deadline;
  final String status;
  final String applyUrl;
  final String website;
  final String imageUrl;
  final bool featured;
  final int order;

  bool get isActive => status == 'active';
  bool get hasImage => imageUrl.trim().isNotEmpty;
  bool get hasApplyUrl => applyUrl.trim().isNotEmpty;
  bool get hasWebsite => website.trim().isNotEmpty;

  String title(String lang) => _pick(titleEn, titleUr, lang);
  String description(String lang) => _pick(descriptionEn, descriptionUr, lang);
  String category(String lang) => _pick(categoryEn, categoryUr, lang);
  String department(String lang) => _pick(departmentEn, departmentUr, lang);
  List<String> eligibility(String lang) =>
      _pickList(eligibilityEn, eligibilityUr, lang);
  List<String> benefits(String lang) =>
      _pickList(benefitsEn, benefitsUr, lang);

  /// First eligibility point for compact list cards.
  String eligibilityPreview(String lang) {
    final list = eligibility(lang);
    if (list.isEmpty) return '';
    return list.first;
  }

  /// Icon key derived from category for cards / empty-image fallbacks.
  String get iconKey {
    final c = categoryEn.toLowerCase();
    if (c.contains('subsid') || c.contains('سبسڈی')) return 'card';
    if (c.contains('insur') || c.contains('انشور')) return 'shield';
    if (c.contains('loan') || c.contains('credit') || c.contains('قرض')) {
      return 'bank';
    }
    if (c.contains('seed') || c.contains('بیج')) return 'seed';
    if (c.contains('water') || c.contains('irrig') || c.contains('پانی')) {
      return 'water';
    }
    if (c.contains('equip') || c.contains('machin') || c.contains('آلات')) {
      return 'tractor';
    }
    if (c.contains('train') || c.contains('تربیت')) return 'school';
    return 'spa';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'titleEn': titleEn,
        'titleUr': titleUr,
        'descriptionEn': descriptionEn,
        'descriptionUr': descriptionUr,
        'categoryEn': categoryEn,
        'categoryUr': categoryUr,
        'departmentEn': departmentEn,
        'departmentUr': departmentUr,
        'province': province,
        'eligibilityEn': eligibilityEn,
        'eligibilityUr': eligibilityUr,
        'benefitsEn': benefitsEn,
        'benefitsUr': benefitsUr,
        'deadline': deadline,
        'status': status,
        'applyUrl': applyUrl,
        'website': website,
        'imageUrl': imageUrl,
        'featured': featured,
        'order': order,
      };

  factory GovtScheme.fromJson(Map<String, dynamic> json) {
    return GovtScheme(
      id: json['id'] as String? ?? '',
      titleEn: json['titleEn'] as String? ?? '',
      titleUr: json['titleUr'] as String? ?? '',
      descriptionEn: json['descriptionEn'] as String? ?? '',
      descriptionUr: json['descriptionUr'] as String? ?? '',
      categoryEn: json['categoryEn'] as String? ?? '',
      categoryUr: json['categoryUr'] as String? ?? '',
      departmentEn: json['departmentEn'] as String? ?? '',
      departmentUr: json['departmentUr'] as String? ?? '',
      province: json['province'] as String? ?? '',
      eligibilityEn: _stringList(json['eligibilityEn']),
      eligibilityUr: _stringList(json['eligibilityUr']),
      benefitsEn: _stringList(json['benefitsEn']),
      benefitsUr: _stringList(json['benefitsUr']),
      deadline: json['deadline'] as String? ?? '',
      status: (json['status'] as String? ?? 'active').toLowerCase(),
      applyUrl: json['applyUrl'] as String? ?? '',
      website: json['website'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      featured: json['featured'] as bool? ?? false,
      order: (json['order'] as num?)?.toInt() ?? 0,
    );
  }

  static String _pick(String en, String ur, String languageCode) {
    if (languageCode == 'ur' && ur.trim().isNotEmpty) return ur;
    return en;
  }

  static List<String> _pickList(
    List<String> en,
    List<String> ur,
    String languageCode,
  ) {
    if (languageCode == 'ur' && ur.isNotEmpty) return ur;
    return en;
  }

  static List<String> _stringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((s) => s.trim().isNotEmpty).toList();
    }
    if (raw is String && raw.trim().isNotEmpty) return [raw.trim()];
    return const [];
  }
}
