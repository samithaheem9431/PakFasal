import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../localization/localization_controller.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LocalizationController>();

    return OutlinedButton.icon(
      onPressed: controller.toggleLanguage,
      icon: const Icon(Icons.language),
      label: Text(controller.isUrdu ? 'اردو' : 'EN'),
    );
  }
}
