import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  static const Map<String, List<_CropActivity>> _cropDataEn = {
    'Wheat': [
      _CropActivity(
        stage: 'Sowing',
        month: 'Oct - Nov',
        description: 'Prepare soil and sow wheat seeds.',
        icon: Icons.spa_rounded,
        color: AppColors.primaryGreen,
      ),
      _CropActivity(
        stage: 'Irrigation',
        month: 'Dec - Jan',
        description: 'Provide first and second watering as needed.',
        icon: Icons.water_drop_rounded,
        color: AppColors.weatherBlue,
      ),
      _CropActivity(
        stage: 'Fertilizer',
        month: 'February',
        description: 'Apply urea and balanced nutrients.',
        icon: Icons.eco_rounded,
        color: AppColors.lightGreen,
      ),
      _CropActivity(
        stage: 'Harvest',
        month: 'April',
        description: 'Harvest crop when grains are mature.',
        icon: Icons.agriculture_rounded,
        color: AppColors.warning,
      ),
    ],
    'Rice': [
      _CropActivity(
        stage: 'Sowing',
        month: 'May - Jun',
        description: 'Raise nursery and transplant healthy seedlings.',
        icon: Icons.spa_rounded,
        color: AppColors.primaryGreen,
      ),
      _CropActivity(
        stage: 'Irrigation',
        month: 'Jun - Jul',
        description: 'Maintain standing water in early growth stage.',
        icon: Icons.water_drop_rounded,
        color: AppColors.weatherBlue,
      ),
      _CropActivity(
        stage: 'Harvest',
        month: 'October',
        description: 'Harvest when panicles turn golden.',
        icon: Icons.agriculture_rounded,
        color: AppColors.warning,
      ),
    ],
    'Cotton': [
      _CropActivity(
        stage: 'Sowing',
        month: 'Apr - May',
        description: 'Sow cotton in warm and dry conditions.',
        icon: Icons.spa_rounded,
        color: AppColors.primaryGreen,
      ),
      _CropActivity(
        stage: 'Irrigation',
        month: 'May - Jun',
        description: 'Schedule irrigation based on soil moisture.',
        icon: Icons.water_drop_rounded,
        color: AppColors.weatherBlue,
      ),
      _CropActivity(
        stage: 'Harvest',
        month: 'September',
        description: 'Pick cotton bolls in dry weather.',
        icon: Icons.agriculture_rounded,
        color: AppColors.warning,
      ),
    ],
  };

  static const Map<String, List<_CropActivity>> _cropDataUr = {
    'Wheat': [
      _CropActivity(
        stage: 'بوائی',
        month: 'اکتوبر - نومبر',
        description: 'زمین تیار کریں اور گندم کے بیج بوئیں۔',
        icon: Icons.spa_rounded,
        color: AppColors.primaryGreen,
      ),
      _CropActivity(
        stage: 'آبپاشی',
        month: 'دسمبر - جنوری',
        description: 'ضرورت کے مطابق پہلی اور دوسری آبپاشی کریں۔',
        icon: Icons.water_drop_rounded,
        color: AppColors.weatherBlue,
      ),
      _CropActivity(
        stage: 'کھاد',
        month: 'فروری',
        description: 'یوریا اور متوازن غذائی اجزا ڈالیں۔',
        icon: Icons.eco_rounded,
        color: AppColors.lightGreen,
      ),
      _CropActivity(
        stage: 'کٹائی',
        month: 'اپریل',
        description: 'دانے پکنے پر فصل کی کٹائی کریں۔',
        icon: Icons.agriculture_rounded,
        color: AppColors.warning,
      ),
    ],
    'Rice': [
      _CropActivity(
        stage: 'بوائی',
        month: 'مئی - جون',
        description: 'نرسری تیار کریں اور صحت مند پنیری منتقل کریں۔',
        icon: Icons.spa_rounded,
        color: AppColors.primaryGreen,
      ),
      _CropActivity(
        stage: 'آبپاشی',
        month: 'جون - جولائی',
        description: 'ابتدائی بڑھوتری میں کھیت میں مناسب پانی برقرار رکھیں۔',
        icon: Icons.water_drop_rounded,
        color: AppColors.weatherBlue,
      ),
      _CropActivity(
        stage: 'کٹائی',
        month: 'اکتوبر',
        description: 'بالیاں سنہری ہونے پر فصل کاٹیں۔',
        icon: Icons.agriculture_rounded,
        color: AppColors.warning,
      ),
    ],
    'Cotton': [
      _CropActivity(
        stage: 'بوائی',
        month: 'اپریل - مئی',
        description: 'گرم اور خشک موسم میں کپاس کی بوائی کریں۔',
        icon: Icons.spa_rounded,
        color: AppColors.primaryGreen,
      ),
      _CropActivity(
        stage: 'آبپاشی',
        month: 'مئی - جون',
        description: 'مٹی کی نمی کے مطابق آبپاشی کا شیڈول بنائیں۔',
        icon: Icons.water_drop_rounded,
        color: AppColors.weatherBlue,
      ),
      _CropActivity(
        stage: 'کٹائی',
        month: 'ستمبر',
        description: 'خشک موسم میں کپاس کے ٹینڈے چنیں۔',
        icon: Icons.agriculture_rounded,
        color: AppColors.warning,
      ),
    ],
  };

  late String _selectedCrop = 'Wheat';

  String _localizedCropName(AppLocalizations l10n, String crop) {
    return switch (crop) {
      'Wheat' => l10n.t('cropWheat'),
      'Rice' => l10n.t('cropRice'),
      'Cotton' => l10n.t('cropCotton'),
      'Sugarcane' => l10n.t('cropSugarcane'),
      'Maize' => l10n.t('cropMaize'),
      _ => crop,
    };
  }

  IconData _iconForCrop(String crop) {
    return switch (crop) {
      'Wheat' => Icons.grass_rounded,
      'Rice' => Icons.rice_bowl_rounded,
      'Cotton' => Icons.filter_vintage_rounded,
      'Sugarcane' => Icons.eco_rounded,
      'Maize' => Icons.local_florist_rounded,
      _ => Icons.eco_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final isUrdu = l10n.locale.languageCode == 'ur';
    final cropData = isUrdu ? _cropDataUr : _cropDataEn;
    final activities = cropData[_selectedCrop] ?? [];

    return PakFasalScaffold(
      title: l10n.t('cropCalendar'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Background
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            decoration: BoxDecoration(
              color: scheme.surface,
              border: Border(
                bottom: BorderSide(color: scheme.outlineVariant.withValues(alpha: 0.5)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.t('selectCrop'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(height: 14),

                // Horizontal Crop Selector
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: cropData.keys.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final crop = cropData.keys.elementAt(index);
                      final isSelected = _selectedCrop == crop;
                      return ChoiceChip(
                        label: Row(
                          children: [
                            Icon(
                              _iconForCrop(crop),
                              size: 18,
                              color: isSelected ? AppColors.white : AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _localizedCropName(l10n, crop),
                              style: TextStyle(
                                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                color: isSelected ? AppColors.white : AppColors.darkText,
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: AppColors.primaryGreen,
                        backgroundColor: AppColors.paleGreen,
                        showCheckmark: false,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                          side: BorderSide(
                            color: isSelected ? AppColors.primaryGreen : AppColors.divider,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedCrop = crop);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Timeline Content
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeOutCubic,
              child: ListView.builder(
                key: ValueKey(_selectedCrop),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  final isLast = index == activities.length - 1;
                  return _FadeSlideIn(
                    delayMs: index * 100,
                    child: _TimelineTile(
                      activity: activity,
                      isLast: isLast,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Custom Timeline Tile Widget ───────────────────────────────────────────
class _TimelineTile extends StatelessWidget {
  const _TimelineTile({
    required this.activity,
    required this.isLast,
  });

  final _CropActivity activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Left Line & Dot indicator
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: activity.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: activity.color.withValues(alpha: 0.5)),
                  ),
                  child: Icon(
                    activity.icon,
                    size: 18,
                    color: activity.color,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: scheme.outlineVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: scheme.outlineVariant.withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activity.stage,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.paleGreen,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            activity.month,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Model ─────────────────────────────────────────────────────────────
class _CropActivity {
  const _CropActivity({
    required this.stage,
    required this.month,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String stage;
  final String month;
  final String description;
  final IconData icon;
  final Color color;
}

// ── Reusable Animation Wrapper ─────────────────────────────────────────────
class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.child,
    this.delayMs = 0,
  });

  final Widget child;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final delayFactor = (delayMs / 600).clamp(0.0, 0.6);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed = ((value - delayFactor) / (1 - delayFactor)).clamp(0.0, 1.0);
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}