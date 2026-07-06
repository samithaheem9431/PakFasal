import 'package:flutter/material.dart';

/// Shared visual building blocks for the Learning module's sub-screens
/// (YouTube videos, Articles, Pests & Diseases, and their detail views), so
/// search boxes, filter chips, empty states, loading skeletons and detail
/// headers look and behave identically everywhere instead of each screen
/// inventing its own slightly-different variant.

/// Small eyebrow-style label shown above a filter/chip row, e.g. "FILTER BY
/// CROP" or "BROWSE BY CATEGORY". Kept as its own widget so the type scale
/// never drifts between screens.
class LearningSectionLabel extends StatelessWidget {
  const LearningSectionLabel(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: scheme.onSurfaceVariant,
        letterSpacing: 0.2,
      ),
    );
  }
}

/// Title + hint pair shown at the top of a learning list screen, directly
/// under the app bar and before any search box / filters, so every
/// sub-screen opens with the same "what am I looking at" framing.
class LearningIntro extends StatelessWidget {
  const LearningIntro({
    super.key,
    required this.title,
    required this.hint,
  });

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: scheme.onSurface,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hint,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

/// Unified rounded search field used by every Learning sub-screen that
/// supports search (videos, articles).
class LearningSearchField extends StatelessWidget {
  const LearningSearchField({
    super.key,
    required this.controller,
    required this.hint,
  });

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      textInputAction: TextInputAction.search,
      style: TextStyle(
        color: scheme.onSurface,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        prefixIcon: Icon(Icons.search_rounded, color: scheme.primary, size: 22),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: controller.clear,
              icon: Icon(Icons.close_rounded,
                  color: scheme.onSurfaceVariant, size: 20),
            );
          },
        ),
        filled: true,
        fillColor: scheme.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
      ),
    );
  }
}

/// Unified pill-shaped filter chip (crop filter, category filter, etc.)
/// shared by the videos and articles screens.
class LearningChip extends StatelessWidget {
  const LearningChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? scheme.primaryContainer : scheme.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? scheme.primary : scheme.outlineVariant,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: scheme.primary.withValues(alpha: 0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
            color: isSelected
                ? scheme.onPrimaryContainer
                : scheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

/// Unified empty-state card (soft icon circle + message) for any Learning
/// list screen with no results, replacing the mix of a bare text line, a
/// filled banner and an icon banner that used to exist across screens.
class LearningEmptyCard extends StatelessWidget {
  const LearningEmptyCard({
    super.key,
    required this.message,
    this.icon = Icons.info_outline_rounded,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.7)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: scheme.primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: scheme.onSurface,
                height: 1.4,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gentle pulsing fade, so skeleton placeholders read as "loading" rather
/// than a static grey block.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.55, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
      ),
      child: widget.child,
    );
  }
}

/// A single skeleton placeholder block. Pass [height] for a fixed-height
/// row (list skeletons) or omit it to fill the available space (grid
/// skeletons).
class LearningSkeletonBlock extends StatelessWidget {
  const LearningSkeletonBlock({
    super.key,
    this.height,
    this.borderRadius = 16,
  });

  final double? height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final block = DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
    return _Pulse(
      child: height != null
          ? SizedBox(height: height, width: double.infinity, child: block)
          : SizedBox.expand(child: block),
    );
  }
}

/// Vertical skeleton for videos/articles lists: one taller "featured" block
/// followed by shorter row blocks.
class LearningListSkeleton extends StatelessWidget {
  const LearningListSkeleton({
    super.key,
    this.rowCount = 3,
    this.featured = true,
  });

  final int rowCount;
  final bool featured;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(rowCount, (i) {
        final isFeatured = featured && i == 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: LearningSkeletonBlock(height: isFeatured ? 180 : 86),
        );
      }),
    );
  }
}

/// A 2-column skeleton grid, matching the crop selection screen's layout.
class LearningGridSkeleton extends StatelessWidget {
  const LearningGridSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.92,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) =>
          const LearningSkeletonBlock(borderRadius: 18),
    );
  }
}

/// Shared header for detail screens (crop diseases, article reader): an
/// icon badge next to a title and a caller-supplied subtitle row, so both
/// screens open with pixel-identical framing.
class LearningDetailHeader extends StatelessWidget {
  const LearningDetailHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final Widget subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 28, color: scheme.primary),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: scheme.onSurface,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              subtitle,
            ],
          ),
        ),
      ],
    );
  }
}
