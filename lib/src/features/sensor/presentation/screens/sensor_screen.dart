import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/repositories/sensor_repository.dart';
import '../../domain/entities/sensor_reading.dart';
import '../../../weather/data/repositories/weather_repository.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen>
    with WidgetsBindingObserver {
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _phController = TextEditingController();
  final GlobalKey<FormState> _manualFormKey = GlobalKey<FormState>();
  final SensorRepository _sensorRepository = SensorRepository();
  final WeatherRepository _weatherRepository = WeatherRepository();
  final FlutterTts _flutterTts = FlutterTts();
  StreamSubscription<List<SensorReading>>? _sensorSubscription;

  final List<SensorReading> _history = [];
  SensorReading? _sessionLatestReading;

  String _selectedCrop = 'Wheat';
  int? _rainChancePercent;
  bool _isSubmitting = false;
  bool _isResettingGraphs = false;
  bool _isWeatherLoading = true;
  bool _isSpeakingRecommendation = false;
  bool _isInputValid = false;
  String? _speakingRecommendationSection;
  String? _expandedRecommendationSection;
  DateTime? _lastWeatherSyncAt;
  SensorRuleSet _ruleSet = SensorRuleSet.fallback();
  Timer? _weatherAutoRefreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _configureTts();
    _loadRuleConfig();
    _loadCurrentRainChance();
    _moistureController.addListener(_recomputeInputValidity);
    _phController.addListener(_recomputeInputValidity);
    _weatherAutoRefreshTimer = Timer.periodic(const Duration(minutes: 10), (_) {
      if (!mounted) return;
      _loadCurrentRainChance();
    });
    _sensorSubscription = _sensorRepository.watchRecentReadings().listen(
      (readings) {
        if (!mounted) return;
        setState(() {
          _history
            ..clear()
            ..addAll(readings);
        });
      },
    );
  }

  void _recomputeInputValidity() {
    final moisture = double.tryParse(_moistureController.text.trim());
    final ph = double.tryParse(_phController.text.trim());
    final isValid =
        moisture != null &&
        moisture >= 0 &&
        moisture <= 100 &&
        ph != null &&
        ph >= 0 &&
        ph <= 14;
    if (isValid != _isInputValid) {
      setState(() => _isInputValid = isValid);
    }
  }

  String? _validateMoisture(String? value, AppLocalizations l10n) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return l10n.t('sensorMoistureRequired');
    final parsed = double.tryParse(raw);
    if (parsed == null) return l10n.t('sensorInvalidNumber');
    if (parsed < 0 || parsed > 100) return l10n.t('sensorMoistureRange');
    return null;
  }

  String? _validatePh(String? value, AppLocalizations l10n) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return l10n.t('sensorPhRequired');
    final parsed = double.tryParse(raw);
    if (parsed == null) return l10n.t('sensorInvalidNumber');
    if (parsed < 0 || parsed > 14) return l10n.t('sensorPhRange');
    return null;
  }

  Future<void> _loadRuleConfig() async {
    try {
      final ruleSet = await _sensorRepository.fetchRuleSet();
      if (!mounted) return;
      setState(() => _ruleSet = ruleSet);
    } catch (_) {
      // Keep fallback defaults when config is unavailable.
    }
  }

  Future<void> _loadCurrentRainChance() async {
    if (mounted) {
      setState(() => _isWeatherLoading = true);
    }

    try {
      // Fast path: get cached value quickly (if available).
      final cached = await _weatherRepository.fetchCurrentWeather();
      if (!mounted) return;
      setState(() {
        _rainChancePercent = cached.rainChancePercent;
        _lastWeatherSyncAt = DateTime.now();
      });

      // Background refresh: fetch fresh weather and update silently.
      _weatherRepository
          .fetchCurrentWeather(forceRefresh: true)
          .then((fresh) {
            if (!mounted) return;
            setState(() {
              _rainChancePercent = fresh.rainChancePercent;
              _lastWeatherSyncAt = DateTime.now();
              _isWeatherLoading = false;
            });
          })
          .catchError((_) {
            if (!mounted) return;
            setState(() => _isWeatherLoading = false);
          });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _rainChancePercent = null;
        _isWeatherLoading = false;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _weatherAutoRefreshTimer?.cancel();
    _sensorSubscription?.cancel();
    _flutterTts.stop();
    _moistureController.removeListener(_recomputeInputValidity);
    _phController.removeListener(_recomputeInputValidity);
    _moistureController.dispose();
    _phController.dispose();
    super.dispose();
  }

  Future<void> _configureTts() async {
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeakingRecommendation = false;
        _speakingRecommendationSection = null;
      });
    });
    _flutterTts.setCancelHandler(() {
      if (!mounted) return;
      setState(() {
        _isSpeakingRecommendation = false;
        _speakingRecommendationSection = null;
      });
    });
    _flutterTts.setErrorHandler((_) {
      if (!mounted) return;
      setState(() {
        _isSpeakingRecommendation = false;
        _speakingRecommendationSection = null;
      });
    });
  }

  Future<void> _toggleSpeakSection({
    required String sectionKey,
    required String text,
  }) async {
    final l10n = AppLocalizations.of(context);
    if (_isSpeakingRecommendation && _speakingRecommendationSection == sectionKey) {
      await _flutterTts.stop();
      if (!mounted) return;
      setState(() {
        _isSpeakingRecommendation = false;
        _speakingRecommendationSection = null;
      });
      return;
    }

    if (_isSpeakingRecommendation &&
        _speakingRecommendationSection != null &&
        _speakingRecommendationSection != sectionKey) {
      await _flutterTts.stop();
      if (!mounted) return;
    }

    final didSpeak = await _speakWithRetry(text);
    if (!mounted) return;
    if (didSpeak) {
      setState(() {
        _isSpeakingRecommendation = true;
        _speakingRecommendationSection = sectionKey;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('voiceServiceUnavailable'))),
      );
    }
  }

  Future<bool> _speakWithRetry(String text) async {
    final languageCode = Localizations.localeOf(context).languageCode;
    final ttsLocale = languageCode == 'ur' ? 'ur-PK' : 'en-US';

    for (var attempt = 0; attempt < 4; attempt++) {
      final languageResult = await _flutterTts.setLanguage(ttsLocale);
      if (_isLanguageUnavailable(languageResult)) {
        await Future.delayed(const Duration(milliseconds: 250));
        continue;
      }

      final speakResult = await _flutterTts.speak(text);
      if (speakResult == 1 || speakResult == '1') {
        return true;
      }

      await Future.delayed(const Duration(milliseconds: 250));
    }
    return false;
  }

  bool _isLanguageUnavailable(dynamic languageResult) {
    if (languageResult is int) {
      // Android TTS codes: 0/1/2 are available, negatives are unsupported.
      return languageResult < 0;
    }
    if (languageResult is String) {
      final parsed = int.tryParse(languageResult);
      if (parsed != null) return parsed < 0;
    }
    return languageResult == null;
  }

  String _cardSpeakKey(String sectionKey) => '$sectionKey-card';

  String _detailsSpeakKey(String sectionKey) => '$sectionKey-details';

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadCurrentRainChance();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final latest = _sessionLatestReading;
    final moistureSeries = _history.map((e) => e.soilMoisture).toList();
    final phSeries = _history.map((e) => e.phLevel).toList();
    final latestRecommendationResult = latest == null
        ? null
        : _buildRuleBasedRecommendation(
            moisture: latest.soilMoisture,
            ph: latest.phLevel,
            crop: latest.crop ?? _selectedCrop,
            rainChancePercent: latest.rainChancePercent ?? (_rainChancePercent ?? 0),
            config: _ruleSet.forCrop(latest.crop ?? _selectedCrop),
          );

    return PakFasalScaffold(
      title: l10n.t('sensorData'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ManualInputCard(
            formKey: _manualFormKey,
            cropValue: _selectedCrop,
            rainChancePercent: _rainChancePercent,
            isWeatherLoading: _isWeatherLoading,
            lastWeatherSyncLabel: _lastWeatherSyncAt == null
                ? null
                : '${l10n.t('lastUpdated')}: ${TimeOfDay.fromDateTime(_lastWeatherSyncAt!).format(context)}',
            moistureController: _moistureController,
            phController: _phController,
            moistureValidator: (value) => _validateMoisture(value, l10n),
            phValidator: (value) => _validatePh(value, l10n),
            onCropChanged: (value) => setState(() => _selectedCrop = value),
            onSubmit: (_isSubmitting || !_isInputValid)
                ? null
                : _handleManualSubmit,
            onRefreshWeather: _isWeatherLoading ? null : _loadCurrentRainChance,
          ),
          const SizedBox(height: 12),
          _SensorCard(
            title: l10n.t('soilMoisture'),
            value: '${(latest?.soilMoisture ?? 0).toStringAsFixed(0)}%',
            status: _statusForMoisture(l10n, latest?.soilMoisture ?? 0),
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _SensorCard(
            title: l10n.t('phLevel'),
            value: (latest?.phLevel ?? 0).toStringAsFixed(1),
            status: _statusForPh(l10n, latest?.phLevel ?? 0),
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: l10n.t('soilMoistureTrend'),
            lineColor: AppColors.success,
            unitSuffix: '%',
            points: moistureSeries,
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: l10n.t('phTrend'),
            lineColor: AppColors.warning,
            unitSuffix: '',
            points: phSeries,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _isResettingGraphs ? null : _resetGraphData,
              icon: _isResettingGraphs
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.restart_alt),
              label: Text(
                l10n.locale.languageCode == 'ur'
                    ? 'گراف ری سیٹ کریں'
                    : 'Reset Graph',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.t('dssRecommendation'),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  if ((latest?.recommendationPriority ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _PriorityBadge(
                      label: _localizedPriorityLabel(
                        l10n,
                        latest!.recommendationPriority!,
                      ),
                      color: _priorityColor(latest.recommendationPriority!),
                    ),
                  ],
                  const SizedBox(height: 6),
                  if (latestRecommendationResult == null)
                    _RecommendationPlaceholderCard(
                      title: l10n.locale.languageCode == 'ur'
                          ? 'ابھی سفارش موجود نہیں'
                          : 'No recommendation yet',
                      subtitle: l10n.locale.languageCode == 'ur'
                          ? 'سینسر ویلیوز درج کریں اور "Generate DSS" دبائیں۔'
                          : 'Enter sensor values and tap "Generate DSS" to see plans.',
                    )
                  else ...[
                    _RecommendationPlanCard(
                      title: l10n.locale.languageCode == 'ur'
                          ? 'آبپاشی پلان'
                          : 'Irrigation Plan',
                      preview: latestRecommendationResult.irrigationCardText,
                      isExpanded: _expandedRecommendationSection == 'irrigation',
                      isSpeaking: _isSpeakingRecommendation &&
                          _speakingRecommendationSection ==
                              _cardSpeakKey('irrigation'),
                      onToggleView: () => _toggleRecommendationView(
                        sectionKey: 'irrigation',
                        title: l10n.locale.languageCode == 'ur'
                            ? 'آبپاشی پلان'
                            : 'Irrigation Plan',
                        fullText: latestRecommendationResult.irrigationPlan.isEmpty
                            ? latestRecommendationResult.irrigationCardText
                            : latestRecommendationResult.irrigationPlan,
                      ),
                      onSpeak: () => _toggleSpeakSection(
                        sectionKey: _cardSpeakKey('irrigation'),
                        text: latestRecommendationResult.irrigationCardText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RecommendationPlanCard(
                      title: l10n.locale.languageCode == 'ur'
                          ? 'مٹی اور کھاد پلان'
                          : 'Soil Plan',
                      preview: latestRecommendationResult.soilCardText,
                      isExpanded: _expandedRecommendationSection == 'soil',
                      isSpeaking:
                          _isSpeakingRecommendation &&
                          _speakingRecommendationSection == _cardSpeakKey('soil'),
                      onToggleView: () => _toggleRecommendationView(
                        sectionKey: 'soil',
                        title: l10n.locale.languageCode == 'ur'
                            ? 'مٹی اور کھاد پلان'
                            : 'Soil Plan',
                        fullText: latestRecommendationResult.soilPlan.isEmpty
                            ? latestRecommendationResult.soilCardText
                            : latestRecommendationResult.soilPlan,
                      ),
                      onSpeak: () => _toggleSpeakSection(
                        sectionKey: _cardSpeakKey('soil'),
                        text: latestRecommendationResult.soilCardText,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RecommendationPlanCard(
                      title: l10n.locale.languageCode == 'ur'
                          ? 'مستقبل رسک'
                          : 'Risk Future',
                      preview: latestRecommendationResult.riskPreview,
                      isExpanded: _expandedRecommendationSection == 'risk',
                      isSpeaking:
                          _isSpeakingRecommendation &&
                          _speakingRecommendationSection == _cardSpeakKey('risk'),
                      onToggleView: () => _toggleRecommendationView(
                        sectionKey: 'risk',
                        title: l10n.locale.languageCode == 'ur'
                            ? 'مستقبل رسک'
                            : 'Risk Future',
                        fullText: latestRecommendationResult.futureRisk.isEmpty
                            ? latestRecommendationResult.riskPreview
                            : latestRecommendationResult.futureRisk,
                      ),
                      onSpeak: () => _toggleSpeakSection(
                        sectionKey: _cardSpeakKey('risk'),
                        text: latestRecommendationResult.riskPreview,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _RecommendationPlanCard(
                      title: l10n.locale.languageCode == 'ur'
                          ? 'مانیٹرنگ پلان'
                          : 'Monitoring Plan',
                      preview: latestRecommendationResult.monitoringPreview,
                      isExpanded: _expandedRecommendationSection == 'monitoring',
                      isSpeaking: _isSpeakingRecommendation &&
                          _speakingRecommendationSection ==
                              _cardSpeakKey('monitoring'),
                      onToggleView: () => _toggleRecommendationView(
                        sectionKey: 'monitoring',
                        title: l10n.locale.languageCode == 'ur'
                            ? 'مانیٹرنگ پلان'
                            : 'Monitoring Plan',
                        fullText: latestRecommendationResult.monitoringPlan.isEmpty
                            ? latestRecommendationResult.monitoringPreview
                            : latestRecommendationResult.monitoringPlan,
                      ),
                      onSpeak: () => _toggleSpeakSection(
                        sectionKey: _cardSpeakKey('monitoring'),
                        text: latestRecommendationResult.monitoringPreview,
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.t('lastUpdated')}: ${latest == null ? '-' : '${latest.timestamp.hour}:${latest.timestamp.minute.toString().padLeft(2, '0')}'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _exportReadings,
              icon: const Icon(Icons.ios_share),
              label: Text(l10n.t('sensorExportReadings')),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleRecommendationView({
    required String sectionKey,
    required String title,
    required String fullText,
  }) {
    _showRecommendationDetails(
      title: title,
      details: fullText,
      sectionKey: sectionKey,
    );
  }

  Future<void> _showRecommendationDetails({
    required String title,
    required String details,
    required String sectionKey,
  }) async {
    final effectiveDetails = details.trim().isEmpty
        ? (AppLocalizations.of(context).locale.languageCode == 'ur'
              ? 'اس سیکشن کی تفصیل ابھی دستیاب نہیں۔'
              : 'Detailed recommendation is not available for this section yet.')
        : details;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDetailsSpeaking =
                _isSpeakingRecommendation &&
                _speakingRecommendationSection == _detailsSpeakKey(sectionKey);
            return AlertDialog(
              title: Text(title),
              content: SingleChildScrollView(
                child: SelectableText(
                  effectiveDetails,
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
              actions: [
                TextButton.icon(
                  onPressed: () async {
                    if (isDetailsSpeaking) {
                      await _flutterTts.stop();
                      if (!mounted) return;
                      setState(() {
                        _isSpeakingRecommendation = false;
                        _speakingRecommendationSection = null;
                      });
                      setDialogState(() {});
                      return;
                    }
                    await _toggleSpeakSection(
                      sectionKey: _detailsSpeakKey(sectionKey),
                      text: effectiveDetails,
                    );
                    if (!mounted) return;
                    setDialogState(() {});
                  },
                  icon: Icon(
                    isDetailsSpeaking
                        ? Icons.stop_circle_outlined
                        : Icons.volume_up_rounded,
                  ),
                  label: Text(isDetailsSpeaking ? 'Stop' : 'Speak'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleManualSubmit() {
    if (_isSubmitting) return;
    final l10n = AppLocalizations.of(context);
    final formState = _manualFormKey.currentState;
    if (formState == null || !formState.validate()) return;
    final moisture = double.tryParse(_moistureController.text.trim());
    final ph = double.tryParse(_phController.text.trim());
    if (moisture == null || ph == null) return;
    final rainChance = _rainChancePercent ?? 0;
    final result = _buildRuleBasedRecommendation(
      moisture: moisture,
      ph: ph,
      crop: _selectedCrop,
      rainChancePercent: rainChance,
      config: _ruleSet.forCrop(_selectedCrop),
    );

    setState(() => _isSubmitting = true);
    _sensorRepository
        .addReading(
          soilMoisture: moisture,
          phLevel: ph,
          crop: _selectedCrop,
          rainChancePercent: rainChance,
          recommendationSummary: result.summary,
          recommendationDetails: result.details,
          recommendationPriority: result.priority,
        )
        .then((_) {
          if (!mounted) return;
          setState(() {
            final newReading = SensorReading(
              soilMoisture: moisture,
              phLevel: ph,
              timestamp: DateTime.now(),
              crop: _selectedCrop,
              rainChancePercent: rainChance,
              recommendationSummary: result.summary,
              recommendationDetails: result.details,
              recommendationPriority: result.priority,
            );
            _sessionLatestReading = newReading;
            // Update the chart optimistically instead of waiting for the
            // Firestore snapshot round-trip (which can lag behind when the
            // new document's serverTimestamp hasn't resolved yet). The
            // live listener will reconcile `_history` with the authoritative
            // list as soon as its next snapshot arrives.
            _history.add(newReading);
            _moistureController.clear();
            _phController.clear();
            _isSubmitting = false;
          });
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() => _isSubmitting = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.t('sensorRecommendationText'))),
          );
        });
  }

  _RecommendationResult _buildRuleBasedRecommendation({
    required double moisture,
    required double ph,
    required String crop,
    required int rainChancePercent,
    required SensorRuleConfig config,
  }) {
    final l10n = AppLocalizations.of(context);
    final isUrdu = l10n.locale.languageCode == 'ur';
    final summaryParts = <String>[];
    final irrigationActions = <String>[];
    final fertilizerActions = <String>[];
    final riskNotes = <String>[];
    final monitoringPlan = <String>[];
    final rainExpected = rainChancePercent >= config.rainChanceThreshold;
    final cropName = _localizedCropName(l10n, crop);
    var irrigationCardText = isUrdu ? 'آبپاشی شیڈول چیک کریں۔' : 'Check irrigation schedule.';
    var soilCardText = isUrdu
        ? 'مٹی کی حالت کے مطابق کھاد دیں۔'
        : 'Apply fertilizer based on soil condition.';

    // Moisture / irrigation rules.
    if (moisture < config.moistureLowThreshold && !rainExpected) {
      summaryParts.add(l10n.t('sensorRecIrrigateSoon'));
      irrigationCardText = isUrdu
          ? 'نمی کم ہے، آج یا کل ہلکی آبپاشی کریں۔'
          : 'Moisture is low, do light irrigation today or tomorrow.';
      irrigationActions.add(
        isUrdu
            ? 'فوری آبپاشی کریں: اگلے 12-24 گھنٹے میں ہلکی/درمیانی آبپاشی دیں (قاعدہ M1)۔'
            : 'Irrigate soon: apply a light to moderate irrigation within 12-24 hours (Rule M1).',
      );
      irrigationActions.add(
        isUrdu
            ? 'پانی وقفوں میں دیں تاکہ مٹی اچھی طرح جذب کرے اور بہاؤ کم ہو۔'
            : 'Use split irrigation turns so soil can absorb water and runoff stays low.',
      );
      riskNotes.add(
        isUrdu
            ? 'کم نمی کی وجہ سے فصل میں پانی کے دباؤ اور پیداوار میں کمی کا خطرہ ہے۔'
            : 'Low moisture may cause crop water stress and reduce yield.',
      );
    } else if (moisture < config.moistureLowThreshold && rainExpected) {
      summaryParts.add(l10n.t('sensorRecWaitRain'));
      irrigationCardText = isUrdu
          ? 'بارش متوقع ہے، ابھی آبپاشی روکیں اور دوبارہ چیک کریں۔'
          : 'Rain is expected, hold irrigation and check again.';
      irrigationActions.add(
        isUrdu
            ? 'بارش متوقع ہے، فوری آبپاشی روکیں اور 12-24 گھنٹے بعد نمی دوبارہ چیک کریں (قاعدہ M2)۔'
            : 'Rain is likely, hold irrigation now and re-check soil moisture in 12-24 hours (Rule M2).',
      );
      irrigationActions.add(
        isUrdu
            ? 'اگر بارش نہ ہو تو پھر کنٹرولڈ آبپاشی کریں۔'
            : 'If rain does not occur, apply controlled irrigation afterwards.',
      );
      riskNotes.add(
        isUrdu
            ? 'غلط وقت پر پانی دینے سے پانی اور لاگت دونوں ضائع ہو سکتے ہیں۔'
            : 'Irrigating before expected rain can waste water and increase cost.',
      );
    } else if (moisture > config.moistureHighThreshold) {
      summaryParts.add(l10n.t('sensorRecReduceIrrigation'));
      irrigationCardText = isUrdu
          ? 'نمی زیادہ ہے، اگلی آبپاشی دیر سے کریں۔'
          : 'Moisture is high, delay the next irrigation.';
      irrigationActions.add(
        isUrdu
            ? 'آبپاشی کا وقفہ بڑھائیں اور اگلی آبپاشی تاخیر سے دیں (قاعدہ M3)۔'
            : 'Increase irrigation interval and delay the next watering cycle (Rule M3).',
      );
      irrigationActions.add(
        isUrdu
            ? 'کھیت میں نکاسی (drainage) بہتر رکھیں تاکہ پانی کھڑا نہ ہو۔'
            : 'Improve field drainage to prevent standing water.',
      );
      riskNotes.add(
        isUrdu
            ? 'زیادہ نمی سے جڑ سڑن، فنگس اور غذائی عدم توازن کا خطرہ بڑھتا ہے۔'
            : 'Excess moisture can increase risk of root rot, fungal issues, and nutrient imbalance.',
      );
    } else {
      summaryParts.add(l10n.t('sensorRecMoistureOk'));
      irrigationCardText = isUrdu
          ? 'نمی ٹھیک ہے، موجودہ آبپاشی جاری رکھیں۔'
          : 'Moisture is fine, continue current irrigation.';
      irrigationActions.add(
        isUrdu
            ? 'نمی مناسب حد میں ہے، موجودہ آبپاشی شیڈول برقرار رکھیں (قاعدہ M4)۔'
            : 'Moisture is in an acceptable band; continue current irrigation schedule (Rule M4).',
      );
    }

    // pH / fertilizer and soil amendment rules.
    if (ph < config.phLowThreshold) {
      summaryParts.add(l10n.t('sensorRecAcidic'));
      soilCardText = isUrdu
          ? 'پی ایچ کم ہے، چونا اور متوازن کھاد دیں۔'
          : 'pH is low, use lime and balanced fertilizer.';
      fertilizerActions.add(
        isUrdu
            ? 'مٹی تیزابی ہے: زرعی چونا مناسب مقدار میں شامل کریں (قاعدہ P1)۔'
            : 'Soil is acidic: apply agricultural lime in recommended dose (Rule P1).',
      );
      fertilizerActions.add(
        isUrdu
            ? 'متوازن NPK کھاد چھوٹی قسطوں میں دیں اور نامیاتی مادہ بڑھائیں۔'
            : 'Apply balanced NPK in split doses and increase organic matter.',
      );
      riskNotes.add(
        isUrdu
            ? 'تیزابی مٹی میں غذائی اجزاء کی دستیابی متاثر ہو سکتی ہے۔'
            : 'Acidic soil can reduce nutrient availability to the crop.',
      );
    } else if (ph > config.phHighThreshold) {
      summaryParts.add(l10n.t('sensorRecAlkaline'));
      soilCardText = isUrdu
          ? 'پی ایچ زیادہ ہے، جپسم اور نامیاتی مادہ شامل کریں۔'
          : 'pH is high, add gypsum and organic matter.';
      fertilizerActions.add(
        isUrdu
            ? 'مٹی الکلائن ہے: جپسم اور اچھی کوالٹی کا نامیاتی مادہ شامل کریں (قاعدہ P2)۔'
            : 'Soil is alkaline: add gypsum and quality organic matter (Rule P2).',
      );
      fertilizerActions.add(
        isUrdu
            ? 'یوریا/ڈی اے پی ایک ساتھ زیادہ مقدار میں نہ دیں، چھوٹی قسطوں میں کھاد دیں۔'
            : 'Avoid heavy one-time urea/DAP dose; apply fertilizers in split doses.',
      );
      riskNotes.add(
        isUrdu
            ? 'زیادہ پی ایچ میں کچھ غذائی اجزاء پودے کے لئے کم دستیاب ہو جاتے ہیں۔'
            : 'High pH can lock nutrients and reduce uptake efficiency.',
      );
    } else {
      summaryParts.add('${l10n.t('sensorRecPhSuitable')} $cropName');
      soilCardText = isUrdu
          ? 'پی ایچ مناسب ہے، متوازن کھاد پلان جاری رکھیں۔'
          : 'pH is suitable, continue balanced fertilizer plan.';
      fertilizerActions.add(
        isUrdu
            ? 'پی ایچ $cropName کے لئے مناسب ہے، متوازن کھاد منصوبہ جاری رکھیں (قاعدہ P3)۔'
            : 'pH is suitable for $cropName; continue a balanced fertilizer plan (Rule P3).',
      );
    }

    monitoringPlan.add(
      isUrdu
          ? 'اگلی سینسر ریڈنگ 24 گھنٹے میں لیں اور ٹرینڈ کا موازنہ کریں۔'
          : 'Take the next sensor reading within 24 hours and compare trends.',
    );
    monitoringPlan.add(
      isUrdu
          ? 'بارش کے بعد نمی اور پی ایچ دوبارہ چیک کریں تاکہ فیصلہ اپڈیٹ ہو سکے۔'
          : 'After rainfall, re-check moisture and pH to validate the plan.',
    );
    monitoringPlan.add(
      isUrdu
          ? 'اگر اگلی دو ریڈنگز میں بہتری نہ آئے تو کھاد/آبپاشی پلان دوبارہ ایڈجسٹ کریں۔'
          : 'If the next two readings do not improve, adjust irrigation/fertilizer plan again.',
    );

    final priority = _calculatePriority(
      moisture: moisture,
      ph: ph,
      rainChancePercent: rainChancePercent,
      config: config,
    );
    final priorityLabel = isUrdu
        ? switch (priority) {
            'HIGH' => 'زیادہ',
            'MEDIUM' => 'درمیانہ',
            _ => 'کم',
          }
        : switch (priority) {
            'HIGH' => 'High',
            'MEDIUM' => 'Medium',
            _ => 'Low',
          };

    final details = isUrdu
        ? 'ترجیحی سطح: $priorityLabel\n'
              'تشخیصی خلاصہ: ${summaryParts.join('، ')}۔\n'
              'ان پٹ ڈیٹا: نمی ${moisture.toStringAsFixed(1)}٪، پی ایچ ${ph.toStringAsFixed(1)}، بارش امکان $rainChancePercent٪، فصل $cropName۔\n'
              'لاگو تھریش ہولڈز: نمی کم < ${config.moistureLowThreshold}، نمی زیادہ > ${config.moistureHighThreshold}، پی ایچ کم < ${config.phLowThreshold}، پی ایچ زیادہ > ${config.phHighThreshold}، بارش حد >= ${config.rainChanceThreshold}٪۔\n'
              'آبپاشی پلان: ${irrigationActions.join(' ')}\n'
              'کھاد/مٹی اصلاح: ${fertilizerActions.join(' ')}\n'
              'رسک نوٹس: ${riskNotes.isEmpty ? 'کوئی بڑا فوری رسک نہیں۔' : riskNotes.join(' ')}\n'
              'مانیٹرنگ پلان: ${monitoringPlan.join(' ')}'
        : 'Priority level: $priorityLabel\n'
              'Decision summary: ${summaryParts.join(', ')}.\n'
              'Input data: moisture ${moisture.toStringAsFixed(1)}%, pH ${ph.toStringAsFixed(1)}, rain chance $rainChancePercent%, crop $cropName.\n'
              'Applied thresholds: low moisture < ${config.moistureLowThreshold}, high moisture > ${config.moistureHighThreshold}, low pH < ${config.phLowThreshold}, high pH > ${config.phHighThreshold}, rain threshold >= ${config.rainChanceThreshold}%.\n'
              'Irrigation plan: ${irrigationActions.join(' ')}\n'
              'Fertilizer/soil plan: ${fertilizerActions.join(' ')}\n'
              'Risk notes: ${riskNotes.isEmpty ? 'No major immediate risk.' : riskNotes.join(' ')}\n'
              'Monitoring plan: ${monitoringPlan.join(' ')}';
    final irrigationPlan = isUrdu
        ? 'موجودہ صورتحال: نمی ${moisture.toStringAsFixed(1)}٪ ہے اور بارش امکان $rainChancePercent٪ ہے۔ '
              'تجویز کردہ آبپاشی اقدامات: ${irrigationActions.join(' ')} '
              'عملی نوٹ: اگلے 24 گھنٹے میں نمی دوبارہ چیک کریں اور اسی کے مطابق آبپاشی ایڈجسٹ کریں۔'
        : 'Current status: moisture is ${moisture.toStringAsFixed(1)}% and rain chance is $rainChancePercent%. '
              'Recommended irrigation actions: ${irrigationActions.join(' ')} '
              'Practical note: re-check moisture within the next 24 hours and adjust irrigation accordingly.';
    final soilPlan = isUrdu
        ? 'موجودہ صورتحال: پی ایچ ${ph.toStringAsFixed(1)} ہے، فصل $cropName۔ '
              'تجویز کردہ مٹی/کھاد اقدامات: ${fertilizerActions.join(' ')} '
              'عملی نوٹ: کھاد قسطوں میں دیں اور اگلی ریڈنگ پر پی ایچ کا دوبارہ جائزہ لیں۔'
        : 'Current status: pH is ${ph.toStringAsFixed(1)} for crop $cropName. '
              'Recommended soil/fertilizer actions: ${fertilizerActions.join(' ')} '
              'Practical note: apply fertilizer in split doses and review pH again on the next reading.';
    final futureRisk = riskNotes.isEmpty
        ? (isUrdu
              ? 'فی الحال کوئی بڑا فوری رسک سامنے نہیں آیا، مگر ریڈنگز باقاعدگی سے مانیٹر کریں۔'
              : 'No major immediate risk is detected right now, but keep monitoring readings regularly.')
        : (isUrdu
              ? 'ممکنہ رسک: ${riskNotes.join(' ')} حفاظتی اقدام: آبپاشی اور کھاد فیصلے اگلی ریڈنگ کے مطابق اپڈیٹ کریں۔'
              : 'Potential risk: ${riskNotes.join(' ')} Preventive action: update irrigation and fertilizer decisions based on the next reading.');
    final monitoringPlanText = isUrdu
        ? 'مانیٹرنگ شیڈول: ${monitoringPlan.join(' ')} '
              'فالو اپ: اگر دو مسلسل ریڈنگز میں بہتری نہ ہو تو پلان دوبارہ ترتیب دیں۔'
        : 'Monitoring schedule: ${monitoringPlan.join(' ')} '
              'Follow-up: if there is no improvement in two consecutive readings, revise the plan.';

    return _RecommendationResult(
      summary: '${summaryParts.join('. ')}.',
      details: details,
      priority: priority,
      irrigationPlan: irrigationPlan,
      soilPlan: soilPlan,
      futureRisk: futureRisk,
      monitoringPlan: monitoringPlanText,
      irrigationPreview: _ultraShortPreview(irrigationPlan),
      soilPreview: _ultraShortPreview(soilPlan),
      riskPreview: _ultraShortPreview(futureRisk),
      monitoringPreview: _ultraShortPreview(monitoringPlanText),
      irrigationCardText: _ultraShortPreview(irrigationCardText),
      soilCardText: _ultraShortPreview(soilCardText),
    );
  }

  String _ultraShortPreview(String value) {
    final sentence = value
        .split(RegExp(r'(?<=[.!؟۔])\s+'))
        .firstWhere((part) => part.trim().isNotEmpty, orElse: () => value)
        .trim()
        .replaceAll(RegExp(r'\s+'), ' ');
    if (sentence.length <= 60) return sentence;
    return '${sentence.substring(0, 57)}...';
  }

  String _calculatePriority({
    required double moisture,
    required double ph,
    required int rainChancePercent,
    required SensorRuleConfig config,
  }) {
    var score = 0;

    if (moisture < (config.moistureLowThreshold - 10) ||
        moisture > (config.moistureHighThreshold + 10)) {
      score += 2;
    } else if (moisture < config.moistureLowThreshold ||
        moisture > config.moistureHighThreshold) {
      score += 1;
    }

    if (ph < (config.phLowThreshold - 0.7) || ph > (config.phHighThreshold + 0.7)) {
      score += 2;
    } else if (ph < config.phLowThreshold || ph > config.phHighThreshold) {
      score += 1;
    }

    if (moisture < config.moistureLowThreshold &&
        rainChancePercent < config.rainChanceThreshold) {
      score += 1;
    }

    if (score >= 3) return 'HIGH';
    if (score >= 2) return 'MEDIUM';
    return 'LOW';
  }

  Future<void> _resetGraphData() async {
    final l10n = AppLocalizations.of(context);
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            l10n.locale.languageCode == 'ur' ? 'تصدیق درکار' : 'Confirmation',
          ),
          content: Text(
            l10n.locale.languageCode == 'ur'
                ? 'کیا آپ گراف کی پرانی ہسٹری ختم کرنا چاہتے ہیں؟'
                : 'Do you want to clear old graph history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.locale.languageCode == 'ur' ? 'نہیں' : 'No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.locale.languageCode == 'ur' ? 'ہاں' : 'Yes'),
            ),
          ],
        );
      },
    );

    if (shouldReset != true || !mounted) return;
    setState(() => _isResettingGraphs = true);

    try {
      await _sensorRepository.clearAllReadings();
      if (!mounted) return;
      setState(() {
        _history.clear();
        _isResettingGraphs = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.locale.languageCode == 'ur'
                ? 'گراف ہسٹری ری سیٹ ہو گئی ہے۔'
                : 'Graph history has been reset.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      setState(() => _isResettingGraphs = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.locale.languageCode == 'ur'
                ? 'گراف ری سیٹ نہیں ہو سکا، دوبارہ کوشش کریں۔'
                : 'Could not reset graph, please try again.',
          ),
        ),
      );
    }
  }

  Future<void> _exportReadings() async {
    final l10n = AppLocalizations.of(context);
    final selectedCropLabel = _localizedCropName(l10n, _selectedCrop);
    final header = 'timestamp,crop,soilMoisture,phLevel';
    final rows = _history
        .map(
          (e) =>
              '${e.timestamp.toIso8601String()},$selectedCropLabel,${e.soilMoisture.toStringAsFixed(1)},${e.phLevel.toStringAsFixed(1)}',
        )
        .join('\n');
    final csv = '$header\n$rows';

    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('sensorCopiedClipboard'))));
  }

  String _statusForMoisture(AppLocalizations l10n, double value) {
    if (value >= 60) return l10n.t('good');
    if (value >= 45) return l10n.t('moderate');
    return l10n.t('bad');
  }

  String _statusForPh(AppLocalizations l10n, double value) {
    if (value >= 6.0 && value <= 7.0) return l10n.t('good');
    if (value >= 5.5 && value < 6.0) return l10n.t('moderate');
    return l10n.t('bad');
  }

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

  String _localizedPriorityLabel(AppLocalizations l10n, String priority) {
    final isUrdu = l10n.locale.languageCode == 'ur';
    return switch (priority) {
      'HIGH' => isUrdu ? 'ترجیح: زیادہ' : 'Priority: High',
      'MEDIUM' => isUrdu ? 'ترجیح: درمیانہ' : 'Priority: Medium',
      _ => isUrdu ? 'ترجیح: کم' : 'Priority: Low',
    };
  }

  Color _priorityColor(String priority) {
    return switch (priority) {
      'HIGH' => AppColors.error,
      'MEDIUM' => AppColors.warning,
      _ => AppColors.success,
    };
  }
}

class _ManualInputCard extends StatelessWidget {
  const _ManualInputCard({
    required this.formKey,
    required this.cropValue,
    required this.rainChancePercent,
    required this.isWeatherLoading,
    required this.lastWeatherSyncLabel,
    required this.moistureController,
    required this.phController,
    required this.moistureValidator,
    required this.phValidator,
    required this.onCropChanged,
    required this.onSubmit,
    required this.onRefreshWeather,
  });

  final GlobalKey<FormState> formKey;
  final String cropValue;
  final int? rainChancePercent;
  final bool isWeatherLoading;
  final String? lastWeatherSyncLabel;
  final TextEditingController moistureController;
  final TextEditingController phController;
  final FormFieldValidator<String> moistureValidator;
  final FormFieldValidator<String> phValidator;
  final ValueChanged<String> onCropChanged;
  final VoidCallback? onSubmit;
  final VoidCallback? onRefreshWeather;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Form(
          key: formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.t('sensorManualInputTitle'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: cropValue,
                decoration: InputDecoration(
                  labelText: l10n.t('sensorCropLabel'),
                ),
                items: const ['Wheat', 'Rice', 'Cotton']
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          switch (e) {
                            'Wheat' => l10n.t('cropWheat'),
                            'Rice' => l10n.t('cropRice'),
                            'Cotton' => l10n.t('cropCotton'),
                            _ => e,
                          },
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) onCropChanged(value);
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: moistureController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.t('sensorMoistureInput'),
                  suffixText: '%',
                  helperText: '0 - 100',
                ),
                validator: moistureValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: phController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                ],
                decoration: InputDecoration(
                  labelText: l10n.t('sensorPhInput'),
                  helperText: '0 - 14',
                ),
                validator: phValidator,
              ),
              const SizedBox(height: 6),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.t('sensorRainExpected')),
                subtitle: Text(
                  isWeatherLoading
                      ? 'Fetching current weather...'
                      : rainChancePercent == null
                      ? 'Unavailable'
                      : '$rainChancePercent% chance of rain${lastWeatherSyncLabel == null ? '' : '\n$lastWeatherSyncLabel'}',
                ),
                trailing: IconButton(
                  onPressed: onRefreshWeather,
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh weather',
                ),
              ),
              ElevatedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.analytics_outlined),
                label: Text(l10n.t('sensorGenerateDss')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SensorCard extends StatelessWidget {
  const _SensorCard({
    required this.title,
    required this.value,
    required this.status,
    required this.color,
  });

  final String title;
  final String value;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(value, style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                status,
                style: TextStyle(color: color, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({
    required this.title,
    required this.points,
    required this.lineColor,
    required this.unitSuffix,
  });

  final String title;
  final List<double> points;
  final Color lineColor;
  final String unitSuffix;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (points.isEmpty) {
      return const SizedBox.shrink();
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            SizedBox(
              height: 170,
              child: LineChart(
                LineChartData(
                  minY: _minY(points),
                  maxY: _maxY(points),
                  gridData: const FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final idx = value.toInt();
                          return Text('${l10n.t('dayShort')}${idx + 1}');
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: points
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value))
                          .toList(),
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${AppLocalizations.of(context).t('latest')}: ${points.last.toStringAsFixed(1)}$unitSuffix',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  double _minY(List<double> values) {
    final min = values.reduce((a, b) => a < b ? a : b);
    return min - (min * 0.08);
  }

  double _maxY(List<double> values) {
    final max = values.reduce((a, b) => a > b ? a : b);
    return max + (max * 0.08);
  }
}

class _RecommendationResult {
  const _RecommendationResult({
    required this.summary,
    required this.details,
    required this.priority,
    required this.irrigationPlan,
    required this.soilPlan,
    required this.futureRisk,
    required this.monitoringPlan,
    required this.irrigationPreview,
    required this.soilPreview,
    required this.riskPreview,
    required this.monitoringPreview,
    required this.irrigationCardText,
    required this.soilCardText,
  });

  final String summary;
  final String details;
  final String priority;
  final String irrigationPlan;
  final String soilPlan;
  final String futureRisk;
  final String monitoringPlan;
  final String irrigationPreview;
  final String soilPreview;
  final String riskPreview;
  final String monitoringPreview;
  final String irrigationCardText;
  final String soilCardText;
}

class _RecommendationPlanCard extends StatelessWidget {
  const _RecommendationPlanCard({
    required this.title,
    required this.preview,
    required this.isExpanded,
    required this.isSpeaking,
    required this.onToggleView,
    required this.onSpeak,
  });

  final String title;
  final String preview;
  final bool isExpanded;
  final bool isSpeaking;
  final VoidCallback onToggleView;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(preview),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onSpeak,
                  icon: Icon(
                    isSpeaking ? Icons.stop_circle_outlined : Icons.volume_up_rounded,
                  ),
                  label: Text(isSpeaking ? 'Stop' : 'Speak'),
                ),
                TextButton(
                  onPressed: onToggleView,
                  child: const Text('View'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationPlaceholderCard extends StatelessWidget {
  const _RecommendationPlaceholderCard({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, color: AppColors.mutedText),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
