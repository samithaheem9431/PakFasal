import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../domain/entities/crop_calendar_models.dart';
import '../utils/crop_calendar_visuals.dart';

Future<void> showAddPlantingSheet({
  required BuildContext context,
  required List<CropType> crops,
  required List<CropArea> areas,
  required CropType initialCrop,
  required CropArea initialArea,
  required Future<void> Function({
    required CropType crop,
    required CropArea area,
    required DateTime sowingDate,
    required String fieldLabel,
    required bool remindersEnabled,
  }) onSubmit,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return _AddPlantingSheet(
        crops: crops,
        areas: areas,
        initialCrop: initialCrop,
        initialArea: initialArea,
        onSubmit: onSubmit,
      );
    },
  );
}

class _AddPlantingSheet extends StatefulWidget {
  const _AddPlantingSheet({
    required this.crops,
    required this.areas,
    required this.initialCrop,
    required this.initialArea,
    required this.onSubmit,
  });

  final List<CropType> crops;
  final List<CropArea> areas;
  final CropType initialCrop;
  final CropArea initialArea;
  final Future<void> Function({
    required CropType crop,
    required CropArea area,
    required DateTime sowingDate,
    required String fieldLabel,
    required bool remindersEnabled,
  }) onSubmit;

  @override
  State<_AddPlantingSheet> createState() => _AddPlantingSheetState();
}

class _AddPlantingSheetState extends State<_AddPlantingSheet> {
  late CropType _crop = widget.initialCrop;
  late CropArea _area = widget.initialArea;
  late DateTime _sowingDate = DateTime.now();
  late final TextEditingController _labelController;
  bool _reminders = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController();
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _sowingDate,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 1, 12, 31),
    );
    if (picked != null) {
      setState(() => _sowingDate = picked);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await widget.onSubmit(
        crop: _crop,
        area: _area,
        sowingDate: _sowingDate,
        fieldLabel: _labelController.text,
        remindersEnabled: _reminders,
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('cropCalSaveFailed'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.t('cropCalAddPlanting'),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: l10n.t('cropCalFieldLabel'),
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 14),
            Text(l10n.t('selectCrop'),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.crops.map((crop) {
                final selected = crop == _crop;
                return ChoiceChip(
                  selected: selected,
                  label: Text(
                    l10n.t(CropCalendarVisuals.cropLabelKey(crop)),
                  ),
                  onSelected: (_) => setState(() => _crop = crop),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text(l10n.t('cropCalAreasTitle'),
                style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: widget.areas.map((area) {
                final selected = area == _area;
                return ChoiceChip(
                  selected: selected,
                  label: Text(
                    l10n.t(CropCalendarVisuals.areaLabelKey(area)),
                  ),
                  onSelected: (_) => setState(() => _area = area),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.t('cropCalSowingDate')),
              subtitle: Text(
                '${_sowingDate.day.toString().padLeft(2, '0')}/'
                '${_sowingDate.month.toString().padLeft(2, '0')}/'
                '${_sowingDate.year}',
              ),
              trailing: Icon(Icons.calendar_month_rounded, color: scheme.primary),
              onTap: _pickDate,
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.t('cropCalReminders')),
              value: _reminders,
              onChanged: (v) => setState(() => _reminders = v),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.t('cropCalSavePlanting')),
            ),
          ],
        ),
      ),
    );
  }
}
