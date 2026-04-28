import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/widgets/offline_badge.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../providers/marketplace_provider.dart';
import '../widgets/product_card.dart';
import 'product_detail_screen.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MarketplaceProvider(),
      child: const _MarketplaceView(),
    );
  }
}

class _MarketplaceView extends StatefulWidget {
  const _MarketplaceView();

  @override
  State<_MarketplaceView> createState() => _MarketplaceViewState();
}

class _MarketplaceViewState extends State<_MarketplaceView> {
  bool _animateIn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _animateIn = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final provider = context.watch<MarketplaceProvider>();
    final products = provider.filteredProducts;

    return PakFasalScaffold(
      title: l10n.t('marketplace'),
      isOffline: provider.isOffline,
      child: Column(
        children: [
          _FadeSlideIn(
            animate: _animateIn,
            delayMs: 20,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: provider.setSearchQuery,
                decoration: InputDecoration(
                  hintText: l10n.t('marketSearchHint'),
                  prefixIcon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          _FadeSlideIn(
            animate: _animateIn,
            delayMs: 80,
            child: SizedBox(
              height: 44,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: provider.categories
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: provider.selectedCategory == category,
                          onSelected: (_) => provider.setCategory(category),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          _FadeSlideIn(
            animate: _animateIn,
            delayMs: 140,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: DropdownButtonFormField<String>(
                value: provider.selectedCompany,
                decoration: InputDecoration(
                  labelText: l10n.t('marketFilterCompany'),
                ),
                items: provider.companies
                    .map(
                      (company) => DropdownMenuItem(
                        value: company,
                        child: Text(company),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) provider.setCompany(value);
                },
              ),
            ),
          ),
          if (provider.isOffline)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const OfflineBadge(isOffline: true, isCompact: true),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.t('marketOfflineCached'))),
                ],
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              child: products.isEmpty
                  ? Center(
                      key: const ValueKey('empty-market'),
                      child: Text(l10n.t('marketNoProducts')),
                    )
                  : ListView.separated(
                      key: const ValueKey('products-list'),
                      padding: const EdgeInsets.all(12),
                      itemCount: products.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _FadeSlideIn(
                          animate: _animateIn,
                          delayMs: (180 + (index * 35)).clamp(180, 520),
                          child: ProductCard(
                            product: product,
                            isFavorite: provider.isFavorite(product.id),
                            onFavoriteTap: () =>
                                provider.toggleFavorite(product.id),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ProductDetailScreen(product: product),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeSlideIn extends StatelessWidget {
  const _FadeSlideIn({
    required this.child,
    required this.animate,
    required this.delayMs,
  });

  final Widget child;
  final bool animate;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final delayFactor = (delayMs / 700).clamp(0.0, 0.6);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: animate ? 1 : 0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final delayed = ((value - delayFactor) / (1 - delayFactor)).clamp(
          0.0,
          1.0,
        );
        return Opacity(
          opacity: delayed,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - delayed)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
