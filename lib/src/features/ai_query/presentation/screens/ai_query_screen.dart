import 'package:flutter/material.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';

class AiQueryScreen extends StatelessWidget {
  const AiQueryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PakFasalScaffold(
      title: l10n.t('askAi'),
      showBack: true,
      child: const SizedBox.expand(),
    );
  }
}
