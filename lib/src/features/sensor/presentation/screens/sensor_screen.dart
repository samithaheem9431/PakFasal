import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  final TextEditingController _moistureController = TextEditingController();
  final TextEditingController _phController = TextEditingController();

  final List<_ManualReading> _history = [
    _ManualReading(soilMoisture: 42, phLevel: 6.2, timestamp: DateTime.now()),
    _ManualReading(soilMoisture: 47, phLevel: 6.0, timestamp: DateTime.now()),
    _ManualReading(soilMoisture: 52, phLevel: 5.9, timestamp: DateTime.now()),
    _ManualReading(soilMoisture: 58, phLevel: 5.8, timestamp: DateTime.now()),
  ];

  String _selectedCrop = 'Wheat';
  bool _rainExpected = false;
  String _recommendation = '';
  final List<String> _savedSessions = [];

  @override
  void dispose() {
    _moistureController.dispose();
    _phController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final latest = _history.isNotEmpty ? _history.last : null;
    final moistureSeries = _history.map((e) => e.soilMoisture).toList();
    final phSeries = _history.map((e) => e.phLevel).toList();

    return PakFasalScaffold(
      title: l10n.t('sensorData'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ManualInputCard(
            cropValue: _selectedCrop,
            rainExpected: _rainExpected,
            moistureController: _moistureController,
            phController: _phController,
            onCropChanged: (value) => setState(() => _selectedCrop = value),
            onRainChanged: (value) => setState(() => _rainExpected = value),
            onSubmit: _handleManualSubmit,
          ),
          const SizedBox(height: 12),
          _SensorCard(
            title: l10n.t('soilMoisture'),
            value: '${(latest?.soilMoisture ?? 0).toStringAsFixed(0)}%',
            status: _statusForMoisture(l10n, latest?.soilMoisture ?? 0),
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _SensorCard(
            title: l10n.t('phLevel'),
            value: (latest?.phLevel ?? 0).toStringAsFixed(1),
            status: _statusForPh(l10n, latest?.phLevel ?? 0),
            color: Colors.orange,
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: l10n.t('soilMoistureTrend'),
            lineColor: Colors.green,
            unitSuffix: '%',
            points: moistureSeries,
          ),
          const SizedBox(height: 12),
          _ChartCard(
            title: l10n.t('phTrend'),
            lineColor: Colors.orange,
            unitSuffix: '',
            points: phSeries,
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
                  Text(
                    _recommendation.isEmpty
                        ? l10n.t('sensorRecommendationText')
                        : _recommendation,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${l10n.t('lastUpdated')}: ${_history.isNotEmpty ? '${_history.last.timestamp.hour}:${_history.last.timestamp.minute.toString().padLeft(2, '0')}' : '-'}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _saveSession,
                  icon: const Icon(Icons.save_alt),
                  label: Text(l10n.t('sensorSaveSession')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _exportReadings,
                  icon: const Icon(Icons.ios_share),
                  label: Text(l10n.t('sensorExportReadings')),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _handleManualSubmit() {
    final moisture = double.tryParse(_moistureController.text.trim());
    final ph = double.tryParse(_phController.text.trim());
    if (moisture == null || ph == null) return;

    setState(() {
      _history.add(
        _ManualReading(
          soilMoisture: moisture,
          phLevel: ph,
          timestamp: DateTime.now(),
        ),
      );
      _recommendation = _buildRecommendation(moisture: moisture, ph: ph);
      _moistureController.clear();
      _phController.clear();
    });
  }

  String _buildRecommendation({required double moisture, required double ph}) {
    final l10n = AppLocalizations.of(context);
    final parts = <String>[];
    if (moisture < 45 && !_rainExpected) {
      parts.add(l10n.t('sensorRecIrrigateSoon'));
    } else if (moisture < 45 && _rainExpected) {
      parts.add(l10n.t('sensorRecWaitRain'));
    } else if (moisture > 75) {
      parts.add(l10n.t('sensorRecReduceIrrigation'));
    } else {
      parts.add(l10n.t('sensorRecMoistureOk'));
    }

    if (ph < 5.5) {
      parts.add(l10n.t('sensorRecAcidic'));
    } else if (ph > 7.5) {
      parts.add(l10n.t('sensorRecAlkaline'));
    } else {
      parts.add('${l10n.t('sensorRecPhSuitable')} ${_localizedCropName(l10n, _selectedCrop)}');
    }

    return '${parts.join('. ')}.';
  }

  void _saveSession() {
    final l10n = AppLocalizations.of(context);
    final selectedCropLabel = _localizedCropName(l10n, _selectedCrop);
    final latest = _history.last;
    final entry =
        '${latest.timestamp.toIso8601String()} | crop=$selectedCropLabel | moisture=${latest.soilMoisture.toStringAsFixed(1)} | ph=${latest.phLevel.toStringAsFixed(1)}';
    setState(() => _savedSessions.add(entry));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('sensorSessionSaved'))));
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
}

class _ManualInputCard extends StatelessWidget {
  const _ManualInputCard({
    required this.cropValue,
    required this.rainExpected,
    required this.moistureController,
    required this.phController,
    required this.onCropChanged,
    required this.onRainChanged,
    required this.onSubmit,
  });

  final String cropValue;
  final bool rainExpected;
  final TextEditingController moistureController;
  final TextEditingController phController;
  final ValueChanged<String> onCropChanged;
  final ValueChanged<bool> onRainChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
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
              decoration: InputDecoration(labelText: l10n.t('sensorCropLabel')),
              items: const [
                'Wheat',
                'Rice',
                'Cotton',
              ]
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
            TextField(
              controller: moistureController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: l10n.t('sensorMoistureInput'),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(labelText: l10n.t('sensorPhInput')),
            ),
            const SizedBox(height: 6),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: rainExpected,
              title: Text(l10n.t('sensorRainExpected')),
              onChanged: onRainChanged,
            ),
            ElevatedButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.analytics_outlined),
              label: Text(l10n.t('sensorGenerateDss')),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualReading {
  const _ManualReading({
    required this.soilMoisture,
    required this.phLevel,
    required this.timestamp,
  });

  final double soilMoisture;
  final double phLevel;
  final DateTime timestamp;
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
