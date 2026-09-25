import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../data/marketplace_labels.dart';
import '../../domain/entities/product.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang =
        context.watch<LocalizationController>().locale.languageCode;
    final title = product.title(lang);
    final description = product.description(lang);
    final cropLabel = MarketplaceLabels.crop(product.crop, lang);
    final categoryLabel = MarketplaceLabels.category(product.category, lang);
    final phone = product.primaryPhone;

    return PakFasalScaffold(
      title: l10n.t('marketDetail'),
      child: ListView(
        padding: PakFasalFloatingBottomBar.scrollPadding(
          context,
          left: 16,
          top: 16,
          right: 16,
          bottom: 16,
        ),
        children: [
          if (product.images.isNotEmpty)
            SizedBox(
              height: 220,
              child: PageView.builder(
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  final url = product.images[index];
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == product.images.length - 1 ? 0 : 8,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.success.withValues(alpha: 0.12),
                          child: const Icon(Icons.image, size: 60),
                        ),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Container(
                  color: AppColors.success.withValues(alpha: 0.12),
                  child: const Icon(Icons.agriculture_outlined, size: 60),
                ),
              ),
            ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (product.company.isNotEmpty)
            Text(
              '${l10n.t('marketCompany')}: ${product.company}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          if (cropLabel.isNotEmpty)
            Text('${l10n.t('marketCrop')}: $cropLabel'),
          if (categoryLabel.isNotEmpty)
            Text('${l10n.t('marketCategory')}: $categoryLabel'),
          if (product.sku.isNotEmpty)
            Text('${l10n.t('marketSku')}: ${product.sku}'),
          if (phone != null) Text('${l10n.t('marketPhone')}: $phone'),
          const SizedBox(height: 10),
          Text(
            product.priceLabel(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreen,
            ),
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(description, style: const TextStyle(fontSize: 16, height: 1.4)),
          ],
          if (phone != null) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () => _makePhoneCall(context, phone),
              icon: const Icon(Icons.call),
              label: Text(l10n.t('callCompany')),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => _openWhatsapp(context, phone),
              icon: const Icon(Icons.chat),
              label: Text(l10n.t('whatsapp')),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    final opened = await launchUrl(uri);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).t('couldNotOpenDialer')),
        ),
      );
    }
  }

  Future<void> _openWhatsapp(BuildContext context, String phone) async {
    final cleanNumber = phone.replaceAll(RegExp(r'[^\d+]'), '').replaceAll('+', '');
    final uri = Uri.parse('https://wa.me/$cleanNumber');
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).t('couldNotOpenWhatsapp')),
        ),
      );
    }
  }
}
