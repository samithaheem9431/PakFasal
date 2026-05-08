import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../domain/entities/weather_models.dart';
import '../providers/weather_provider.dart';

/// Search-first screen for picking a city. Shows the user's saved cities
/// at the top and lets them search live. Selecting a result pops back to
/// the weather screen with the selection applied.
class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    context.read<WeatherProvider>().clearSearch();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      context.read<WeatherProvider>().searchCities(value);
    });
  }

  Future<void> _select(WeatherLocation location) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    await context.read<WeatherProvider>().selectLocation(location);
    if (!mounted) return;
    messenger.clearSnackBars();
    navigator.pop();
  }

  Future<void> _useCurrentLocation() async {
    final navigator = Navigator.of(context);
    await context.read<WeatherProvider>().useCurrentLocation();
    if (!mounted) return;
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PakFasalScaffold(
      title: l10n.t('weatherSearchCity'),
      showBack: true,
      showBottomNavigation: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          children: [
            _SearchField(
              controller: _controller,
              focusNode: _focusNode,
              onChanged: _onChanged,
              onClear: () {
                _controller.clear();
                context.read<WeatherProvider>().clearSearch();
              },
            ),
            const SizedBox(height: 12),
            _UseGpsTile(onTap: _useCurrentLocation),
            const SizedBox(height: 12),
            Expanded(
              child: Consumer<WeatherProvider>(
                builder: (context, provider, _) {
                  return _SearchBody(
                    provider: provider,
                    onSelect: _select,
                    query: _controller.text,
                    onRemove: (loc) =>
                        provider.removeSavedLocation(loc),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: onClear,
                ),
        ),
        hintText: l10n.t('weatherSearchCityHint'),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }
}

class _UseGpsTile extends StatelessWidget {
  const _UseGpsTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: AppColors.primaryGreen.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.my_location_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.t('weatherUseCurrentLocation'),
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryGreen,
                    fontSize: 13.5,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBody extends StatelessWidget {
  const _SearchBody({
    required this.provider,
    required this.onSelect,
    required this.onRemove,
    required this.query,
  });

  final WeatherProvider provider;
  final ValueChanged<WeatherLocation> onSelect;
  final ValueChanged<WeatherLocation> onRemove;
  final String query;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final showSearchResults = query.trim().length >= 2;

    if (showSearchResults) {
      if (provider.isSearching) {
        return const Center(child: CircularProgressIndicator());
      }
      if (provider.searchError != null) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.t('weatherSearchError'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      if (provider.searchResults.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              l10n.t('weatherNoSearchResults'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }
      return ListView.separated(
        itemCount: provider.searchResults.length,
        separatorBuilder: (_, __) => const SizedBox(height: 6),
        itemBuilder: (_, i) => _LocationTile(
          location: provider.searchResults[i],
          onTap: () => onSelect(provider.searchResults[i]),
        ),
      );
    }

    // Saved locations view (no active query)
    if (provider.savedLocations.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.t('weatherSearchCityHint'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            l10n.t('weatherSavedLocations'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12.5,
              color: AppColors.darkGreen,
              letterSpacing: 0.4,
            ),
          ),
        ),
        for (final loc in provider.savedLocations) ...[
          _LocationTile(
            location: loc,
            onTap: () => onSelect(loc),
            onRemove: () => onRemove(loc),
          ),
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _LocationTile extends StatelessWidget {
  const _LocationTile({
    required this.location,
    required this.onTap,
    this.onRemove,
  });

  final WeatherLocation location;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Material(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.location_city_rounded,
                  color: AppColors.primaryGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  location.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18),
                  onPressed: onRemove,
                  tooltip: l10n.t('weatherRemove'),
                ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
