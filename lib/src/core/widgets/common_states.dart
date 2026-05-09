import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

class LoadingStateCard extends StatelessWidget {
  const LoadingStateCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(width: 12),
            Text(localizations.t('loading')),
          ],
        ),
      ),
    );
  }
}

class ErrorStateCard extends StatelessWidget {
  const ErrorStateCard({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Card(
      color: scheme.errorContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.t('errorState'),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: scheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 140,
              child: ElevatedButton(
                onPressed: onRetry,
                child: Text(localizations.t('retry')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
