import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
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
        month: 'Oct-Nov',
        description: 'Prepare soil and sow wheat seeds.',
      ),
      _CropActivity(
        stage: 'Irrigation',
        month: 'Dec-Jan',
        description: 'Provide first and second watering as needed.',
      ),
      _CropActivity(
        stage: 'Fertilizer',
        month: 'Feb',
        description: 'Apply urea and balanced nutrients.',
      ),
      _CropActivity(
        stage: 'Harvest',
        month: 'April',
        description: 'Harvest crop when grains are mature.',
      ),
    ],
    'Rice': [
      _CropActivity(
        stage: 'Sowing',
        month: 'May-Jun',
        description: 'Raise nursery and transplant healthy seedlings.',
      ),
      _CropActivity(
        stage: 'Irrigation',
        month: 'Jun-Jul',
        description: 'Maintain standing water in early growth stage.',
      ),
      _CropActivity(
        stage: 'Harvest',
        month: 'October',
        description: 'Harvest when panicles turn golden.',
      ),
    ],
    'Cotton': [
      _CropActivity(
        stage: 'Sowing',
        month: 'Apr-May',
        description: 'Sow cotton in warm and dry conditions.',
      ),
      _CropActivity(
        stage: 'Irrigation',
        month: 'May-Jun',
        description: 'Schedule irrigation based on soil moisture.',
      ),
      _CropActivity(
        stage: 'Harvest',
        month: 'September',
        description: 'Pick cotton bolls in dry weather.',
      ),
    ],
  };

  static const Map<String, List<_CropActivity>> _cropDataUr = {
    'Wheat': [
      _CropActivity(
        stage: 'بوائی',
        month: 'اکتوبر-نومبر',
        description: 'زمین تیار کریں اور گندم کے بیج بوئیں۔',
      ),
      _CropActivity(
        stage: 'آبپاشی',
        month: 'دسمبر-جنوری',
        description: 'ضرورت کے مطابق پہلی اور دوسری آبپاشی کریں۔',
      ),
      _CropActivity(
        stage: 'کھاد',
        month: 'فروری',
        description: 'یوریا اور متوازن غذائی اجزا ڈالیں۔',
      ),
      _CropActivity(
        stage: 'کٹائی',
        month: 'اپریل',
        description: 'دانے پکنے پر فصل کی کٹائی کریں۔',
      ),
    ],
    'Rice': [
      _CropActivity(
        stage: 'بوائی',
        month: 'مئی-جون',
        description: 'نرسری تیار کریں اور صحت مند پنیری منتقل کریں۔',
      ),
      _CropActivity(
        stage: 'آبپاشی',
        month: 'جون-جولائی',
        description: 'ابتدائی بڑھوتری میں کھیت میں مناسب پانی برقرار رکھیں۔',
      ),
      _CropActivity(
        stage: 'کٹائی',
        month: 'اکتوبر',
        description: 'بالیاں سنہری ہونے پر فصل کاٹیں۔',
      ),
    ],
    'Cotton': [
      _CropActivity(
        stage: 'بوائی',
        month: 'اپریل-مئی',
        description: 'گرم اور خشک موسم میں کپاس کی بوائی کریں۔',
      ),
      _CropActivity(
        stage: 'آبپاشی',
        month: 'مئی-جون',
        description: 'مٹی کی نمی کے مطابق آبپاشی کا شیڈول بنائیں۔',
      ),
      _CropActivity(
        stage: 'کٹائی',
        month: 'ستمبر',
        description: 'خشک موسم میں کپاس کے ٹینڈے چنیں۔',
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isUrdu = l10n.locale.languageCode == 'ur';
    final cropData = isUrdu ? _cropDataUr : _cropDataEn;
    final activities = cropData[_selectedCrop] ?? [];

    return PakFasalScaffold(
      title: l10n.t('cropCalendar'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.t('selectCrop'),
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: _selectedCrop,
              isExpanded: true,
              items: cropData.keys
                  .map(
                    (crop) => DropdownMenuItem(
                      value: crop,
                      child: Text(_localizedCropName(l10n, crop)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedCrop = value);
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ListView.separated(
                itemCount: activities.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final activity = activities[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity.stage,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activity.month,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            activity.description,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CropActivity {
  const _CropActivity({
    required this.stage,
    required this.month,
    required this.description,
  });

  final String stage;
  final String month;
  final String description;
}
