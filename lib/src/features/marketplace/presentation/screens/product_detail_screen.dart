import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/product.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return PakFasalScaffold(
      title: l10n.t('marketDetail'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.success.withValues(alpha: 0.12),
                  child: const Icon(Icons.image, size: 60),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            product.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text('${l10n.t('marketCompany')}: ${product.companyName}'),
          Text('${l10n.t('marketCategory')}: ${product.category}'),
          if (product.location != null)
            Text('${l10n.t('marketLocation')}: ${product.location}'),
          Text('${l10n.t('phone')}: ${product.phone}'),
          const SizedBox(height: 10),
          Text(
            'PKR ${product.price.toStringAsFixed(0)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          Text(product.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () => _makePhoneCall(context, product.phone),
            icon: const Icon(Icons.call),
            label: Text(l10n.t('callCompany')),
          ),
          const SizedBox(height: 10),
          if (product.whatsappNumber != null)
            OutlinedButton.icon(
              onPressed: () => _openWhatsapp(context, product.whatsappNumber!),
              icon: const Icon(Icons.chat),
              label: Text(l10n.t('whatsapp')),
            ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).t('couldNotOpenDialer'))),
      );
    }
  }

  Future<void> _openWhatsapp(BuildContext context, String phone) async {
    final cleanNumber = phone.replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$cleanNumber');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).t('couldNotOpenWhatsapp'))),
      );
    }
  }
}
