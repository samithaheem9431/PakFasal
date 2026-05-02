import 'package:flutter/material.dart';

import '../../../core/localization/app_localizations.dart';

/// Localizable keys for one pest or disease. Resolved via [resolve].
class CropDiseaseRef {
  const CropDiseaseRef({
    required this.nameKey,
    required this.descKey,
    required this.symptomKeys,
    required this.solutionKeys,
  });

  final String nameKey;
  final String descKey;
  final List<String> symptomKeys;
  final List<String> solutionKeys;

  CropDiseaseEntry resolve(AppLocalizations l10n) {
    return CropDiseaseEntry(
      name: l10n.t(nameKey),
      shortDescription: l10n.t(descKey),
      symptoms: symptomKeys.map(l10n.t).toList(),
      solutions: solutionKeys.map(l10n.t).toList(),
    );
  }
}

/// Resolved strings for UI (built from [CropDiseaseRef] + locale).
class CropDiseaseEntry {
  const CropDiseaseEntry({
    required this.name,
    required this.shortDescription,
    required this.symptoms,
    required this.solutions,
  });

  final String name;
  final String shortDescription;
  final List<String> symptoms;
  final List<String> solutions;
}

/// A crop with its known diseases (keys → localized text).
class CropWithDiseases {
  const CropWithDiseases({
    required this.id,
    required this.nameKey,
    required this.icon,
    required this.diseases,
  });

  final String id;
  /// Localization key, e.g. [cropCotton], [cropWheat], [cropRice].
  final String nameKey;
  final IconData icon;
  final List<CropDiseaseRef> diseases;
}

/// Static reference data for the Keera aur Bimariyaan module.
abstract final class CropDiseasesCatalog {
  CropDiseasesCatalog._();

  static const List<CropWithDiseases> crops = [
    CropWithDiseases(
      id: 'cotton',
      nameKey: 'cropCotton',
      icon: Icons.filter_vintage_rounded,
      diseases: [
        CropDiseaseRef(
          nameKey: 'cdCottonLcvName',
          descKey: 'cdCottonLcvDesc',
          symptomKeys: ['cdCottonLcvSym1', 'cdCottonLcvSym2'],
          solutionKeys: ['cdCottonLcvSol1', 'cdCottonLcvSol2'],
        ),
        CropDiseaseRef(
          nameKey: 'cdCottonBollName',
          descKey: 'cdCottonBollDesc',
          symptomKeys: ['cdCottonBollSym1', 'cdCottonBollSym2'],
          solutionKeys: ['cdCottonBollSol1', 'cdCottonBollSol2'],
        ),
        CropDiseaseRef(
          nameKey: 'cdCottonWfName',
          descKey: 'cdCottonWfDesc',
          symptomKeys: ['cdCottonWfSym1', 'cdCottonWfSym2'],
          solutionKeys: ['cdCottonWfSol1', 'cdCottonWfSol2'],
        ),
      ],
    ),
    CropWithDiseases(
      id: 'wheat',
      nameKey: 'cropWheat',
      icon: Icons.grass_rounded,
      diseases: [
        CropDiseaseRef(
          nameKey: 'cdWheatRustName',
          descKey: 'cdWheatRustDesc',
          symptomKeys: ['cdWheatRustSym1'],
          solutionKeys: ['cdWheatRustSol1', 'cdWheatRustSol2'],
        ),
        CropDiseaseRef(
          nameKey: 'cdWheatSmutName',
          descKey: 'cdWheatSmutDesc',
          symptomKeys: ['cdWheatSmutSym1'],
          solutionKeys: ['cdWheatSmutSol1'],
        ),
        CropDiseaseRef(
          nameKey: 'cdWheatAphidName',
          descKey: 'cdWheatAphidDesc',
          symptomKeys: ['cdWheatAphidSym1', 'cdWheatAphidSym2'],
          solutionKeys: ['cdWheatAphidSol1'],
        ),
      ],
    ),
    CropWithDiseases(
      id: 'rice',
      nameKey: 'cropRice',
      icon: Icons.rice_bowl_rounded,
      diseases: [
        CropDiseaseRef(
          nameKey: 'cdRiceBlbName',
          descKey: 'cdRiceBlbDesc',
          symptomKeys: ['cdRiceBlbSym1'],
          solutionKeys: ['cdRiceBlbSol1', 'cdRiceBlbSol2'],
        ),
        CropDiseaseRef(
          nameKey: 'cdRiceBlastName',
          descKey: 'cdRiceBlastDesc',
          symptomKeys: ['cdRiceBlastSym1'],
          solutionKeys: ['cdRiceBlastSol1', 'cdRiceBlastSol2'],
        ),
        CropDiseaseRef(
          nameKey: 'cdRiceBorerName',
          descKey: 'cdRiceBorerDesc',
          symptomKeys: ['cdRiceBorerSym1'],
          solutionKeys: ['cdRiceBorerSol1', 'cdRiceBorerSol2'],
        ),
      ],
    ),
  ];

  static CropWithDiseases? byId(String id) {
    for (final c in crops) {
      if (c.id == id) return c;
    }
    return null;
  }
}
