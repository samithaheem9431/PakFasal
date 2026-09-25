import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/language_toggle_button.dart';

/// Shared visual tokens matching the PakFasal auth mockups.
class AuthDesign {
  AuthDesign._();

  static const Color deepGreen = Color(0xFF0B4D36);
  static const Color gradientStart = Color(0xFF0B4D36);
  static const Color gradientEnd = Color(0xFF67B14B);
  static const Color fieldBorder = Color(0xFFD9E2DC);
  static const Color fieldFill = Color(0xFFFFFFFF);
  static const Color labelColor = Color(0xFF2F3A35);
  static const Color mutedLabel = Color(0xFF7A8580);
  static const Color cardShadow = Color(0x1A0B4D36);
  static const Color biometricBox = Color(0xFFF3F5F4);

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientEnd],
  );
}

/// Scales auth layout to fit one screen without scrolling.
///
/// Uses the device's physical screen size (not keyboard-resized height) so
/// focusing a text field never changes scale / "zooms" the UI.
class AuthLayoutMetrics {
  AuthLayoutMetrics._({
    required this.scale,
    required this.width,
    required this.height,
  });

  /// Reference phone height used by the mockups (includes form card).
  static const double designHeight = 860;

  final double scale;
  final double width;
  final double height;

  factory AuthLayoutMetrics.of(BuildContext context) {
    final view = View.of(context);
    final screenH = view.physicalSize.height / view.devicePixelRatio;
    final screenW = view.physicalSize.width / view.devicePixelRatio;
    final viewPadding = MediaQuery.viewPaddingOf(context);
    // viewPadding is stable when the IME opens; size/viewInsets are not.
    final available = screenH - viewPadding.top - viewPadding.bottom;
    final scale = (available / designHeight).clamp(0.58, 1.0);
    return AuthLayoutMetrics._(
      scale: scale,
      width: screenW,
      height: available,
    );
  }

  bool get isCompact => scale < 0.85;
  bool get isTight => scale < 0.74;

  double s(double value) => value * scale;

  double get heroSize => s(isTight ? 58 : (isCompact ? 80 : 100));
  double get titleSize => s(22).clamp(16.0, 22.0);
  double get welcomeSize => s(22).clamp(17.0, 24.0);
  double get subtitleSize => s(13).clamp(11.0, 14.0);
  double get labelSize => s(13).clamp(11.0, 13.5);
  double get fieldFontSize =>
      // Android zooms focused inputs when font size is under 16sp.
      s(15).clamp(16.0, 17.0);
  double get buttonHeight => s(48).clamp(40.0, 50.0);
  double get outlinedHeight => s(46).clamp(38.0, 48.0);
  double get cardRadius => s(26).clamp(16.0, 26.0);
  double get fieldRadius => s(12).clamp(8.0, 12.0);
  double get cardPadH => s(16).clamp(10.0, 18.0);
  double get cardPadV => s(14).clamp(8.0, 16.0);
  double get pagePadH => width >= 600 ? 28.0 : s(18).clamp(12.0, 20.0);
  double get gapXs => s(3).clamp(2.0, 3.0);
  double get gapSm => s(5).clamp(2.0, 5.0);
  double get gapMd => s(10).clamp(4.0, 10.0);
  double get gapLg => s(12).clamp(6.0, 12.0);
  double get fieldContentV => s(11).clamp(7.0, 12.0);
  double get iconSize => s(20).clamp(16.0, 20.0);
  double get topBarHeight => s(40).clamp(34.0, 40.0);
}

/// Fits auth content on one screen without shrinking/zooming when typing.
class AuthFitViewport extends StatefulWidget {
  const AuthFitViewport({super.key, required this.builder});

  final Widget Function(BuildContext context, AuthLayoutMetrics metrics)
      builder;

  @override
  State<AuthFitViewport> createState() => _AuthFitViewportState();
}

class _AuthFitViewportState extends State<AuthFitViewport> {
  /// Locked on first layout so keyboard open/close never changes sizes.
  AuthLayoutMetrics? _lockedMetrics;

  @override
  Widget build(BuildContext context) {
    _lockedMetrics ??= AuthLayoutMetrics.of(context);
    final metrics = _lockedMetrics!;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.clamp(280.0, 520.0);
        // Always use the locked screen height — not the keyboard-shrunk constraint.
        final minH = metrics.height;

        return SingleChildScrollView(
          // Stable physics (switching Never↔Clamping feels like a zoom jump).
          physics: const ClampingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.only(bottom: keyboard),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minH),
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: maxW,
                child: widget.builder(context, metrics),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key, required this.child});

  final Widget child;

  static const Color fillColor = Color(0xFFE8F3EA);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : fillColor,
        image: isDark
            ? null
            : const DecorationImage(
                image: AssetImage('assets/images/auth/auth_bg.png'),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
      ),
      child: child,
    );
  }
}

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({
    super.key,
    required this.title,
    required this.metrics,
    this.showBack = false,
    this.centerTitle = false,
    this.leading,
  });

  final String title;
  final AuthLayoutMetrics metrics;
  final bool showBack;
  final bool centerTitle;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final titleStyle = TextStyle(
      fontSize: metrics.titleSize,
      fontWeight: FontWeight.w800,
      color: AuthDesign.deepGreen,
      letterSpacing: 0.2,
      height: 1.1,
    );

    final leadingWidget = showBack
        ? IconButton(
            onPressed: () => Navigator.maybePop(context),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(
              minWidth: metrics.topBarHeight,
              minHeight: metrics.topBarHeight,
            ),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: metrics.s(20).clamp(16.0, 20.0),
              color: AuthDesign.deepGreen,
            ),
          )
        : leading ??
            Container(
              width: metrics.s(36).clamp(30.0, 36.0),
              height: metrics.s(36).clamp(30.0, 36.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x140B4D36),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.eco_rounded,
                color: AuthDesign.deepGreen,
                size: metrics.s(22).clamp(18.0, 22.0),
              ),
            );

    const language = LanguageToggleButton(
      variant: LanguageToggleVariant.onSurface,
      showChevron: true,
    );

    if (centerTitle) {
      return Padding(
        padding: EdgeInsets.fromLTRB(8, metrics.gapXs, 16, 0),
        child: SizedBox(
          height: metrics.topBarHeight,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(alignment: Alignment.centerLeft, child: leadingWidget),
              Text(title, style: titleStyle),
              const Align(alignment: Alignment.centerRight, child: language),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(16, metrics.gapXs, 16, 0),
      child: SizedBox(
        height: metrics.topBarHeight,
        child: Row(
          children: [
            leadingWidget,
            SizedBox(width: metrics.gapSm + 2),
            Expanded(child: Text(title, style: titleStyle)),
            language,
          ],
        ),
      ),
    );
  }
}

class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.heroAsset,
    required this.title,
    required this.subtitle,
    required this.metrics,
  });

  final String heroAsset;
  final String title;
  final String subtitle;
  final AuthLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: metrics.heroSize,
          height: metrics.heroSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AuthDesign.deepGreen.withValues(alpha: 0.18),
                blurRadius: metrics.s(22),
                offset: Offset(0, metrics.s(8)),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(heroAsset, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: metrics.gapMd),
        Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: metrics.welcomeSize,
            fontWeight: FontWeight.w800,
            color: AuthDesign.deepGreen,
            letterSpacing: 0.2,
            height: 1.15,
          ),
        ),
        SizedBox(height: metrics.gapXs),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: metrics.subtitleSize,
            fontWeight: FontWeight.w500,
            color: AuthDesign.mutedLabel,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.metrics,
    required this.child,
  });

  final AuthLayoutMetrics metrics;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(metrics.cardRadius),
        boxShadow: [
          BoxShadow(
            color: AuthDesign.cardShadow,
            blurRadius: metrics.s(28).clamp(16.0, 28.0),
            offset: Offset(0, metrics.s(12).clamp(6.0, 12.0)),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        metrics.cardPadH,
        metrics.cardPadV,
        metrics.cardPadH,
        metrics.cardPadV * 0.85,
      ),
      child: child,
    );
  }
}

class AuthFieldLabel extends StatelessWidget {
  const AuthFieldLabel(this.text, {super.key, required this.metrics});

  final String text;
  final AuthLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: metrics.labelSize,
        fontWeight: FontWeight.w700,
        color: AuthDesign.labelColor,
        letterSpacing: 0.1,
      ),
    );
  }
}

InputDecoration authInputDecoration({
  required String hintText,
  required IconData prefixIcon,
  required AuthLayoutMetrics metrics,
  Widget? suffixIcon,
  bool isDense = false,
}) {
  return InputDecoration(
    isDense: true,
    hintText: hintText,
    hintStyle: TextStyle(
      color: const Color(0xFFA0AAA5),
      fontWeight: FontWeight.w500,
      fontSize: metrics.fieldFontSize,
    ),
    filled: true,
    fillColor: AuthDesign.fieldFill,
    prefixIcon: Icon(
      prefixIcon,
      color: AuthDesign.mutedLabel,
      size: metrics.iconSize,
    ),
    suffixIcon: suffixIcon,
    contentPadding: EdgeInsets.symmetric(
      horizontal: metrics.s(14).clamp(10.0, 14.0),
      vertical: metrics.fieldContentV,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(metrics.fieldRadius),
      borderSide: const BorderSide(color: AuthDesign.fieldBorder, width: 1.2),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(metrics.fieldRadius),
      borderSide: const BorderSide(color: AuthDesign.fieldBorder, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(metrics.fieldRadius),
      borderSide: const BorderSide(color: AuthDesign.deepGreen, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(metrics.fieldRadius),
      borderSide: const BorderSide(color: AppColors.error, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(metrics.fieldRadius),
      borderSide: const BorderSide(color: AppColors.error, width: 1.6),
    ),
    errorStyle: TextStyle(fontSize: metrics.s(11).clamp(9.5, 12.0), height: 1),
  );
}

class AuthGradientButton extends StatelessWidget {
  const AuthGradientButton({
    super.key,
    required this.metrics,
    required this.isLoading,
    required this.label,
    required this.loadingLabel,
    required this.onPressed,
  });

  final AuthLayoutMetrics metrics;
  final bool isLoading;
  final String label;
  final String loadingLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: metrics.buttonHeight,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isLoading ? null : AuthDesign.buttonGradient,
        color: isLoading ? const Color(0xFFE8ECE9) : null,
        boxShadow: isLoading
            ? const []
            : [
                BoxShadow(
                  color: AuthDesign.deepGreen.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: isLoading
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: metrics.s(18),
                        height: metrics.s(18),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AuthDesign.mutedLabel,
                        ),
                      ),
                      SizedBox(width: metrics.gapSm + 2),
                      Text(
                        loadingLabel,
                        style: TextStyle(
                          color: AuthDesign.mutedLabel,
                          fontWeight: FontWeight.w600,
                          fontSize: metrics.fieldFontSize,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: metrics.s(16).clamp(13.5, 16.0),
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(width: metrics.gapSm + 2),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.white,
                        size: metrics.s(20).clamp(16.0, 20.0),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider(this.label, {super.key, required this.metrics});

  final String label;
  final AuthLayoutMetrics metrics;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: Color(0xFFD8DFDB), thickness: 1),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: metrics.gapMd),
          child: Text(
            label,
            style: TextStyle(
              color: AuthDesign.mutedLabel,
              fontSize: metrics.s(12).clamp(10.0, 12.0),
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: Color(0xFFD8DFDB), thickness: 1),
        ),
      ],
    );
  }
}

class AuthOutlinedButton extends StatelessWidget {
  const AuthOutlinedButton({
    super.key,
    required this.metrics,
    required this.label,
    required this.onPressed,
    this.icon = Icons.person_add_alt_1_rounded,
  });

  final AuthLayoutMetrics metrics;
  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: metrics.outlinedHeight,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: metrics.s(20).clamp(16.0, 20.0)),
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: metrics.s(15).clamp(13.0, 15.0),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AuthDesign.deepGreen,
          side: const BorderSide(color: AuthDesign.deepGreen, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class AuthBiometricTile extends StatelessWidget {
  const AuthBiometricTile({
    super.key,
    required this.metrics,
    required this.enabled,
    required this.title,
    required this.subtitle,
    required this.onChanged,
  });

  final AuthLayoutMetrics metrics;
  final bool enabled;
  final String title;
  final String subtitle;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        metrics.s(12).clamp(8.0, 12.0),
        metrics.s(8).clamp(5.0, 10.0),
        metrics.s(6).clamp(4.0, 8.0),
        metrics.s(8).clamp(5.0, 10.0),
      ),
      decoration: BoxDecoration(
        color: AuthDesign.biometricBox,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: metrics.s(38).clamp(30.0, 40.0),
            height: metrics.s(38).clamp(30.0, 40.0),
            decoration: const BoxDecoration(
              color: Color(0xFFE4F3E8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fingerprint_rounded,
              color: AuthDesign.deepGreen,
              size: metrics.s(22).clamp(16.0, 22.0),
            ),
          ),
          SizedBox(width: metrics.gapSm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: metrics.s(13).clamp(11.0, 13.0),
                    fontWeight: FontWeight.w700,
                    color: AuthDesign.labelColor,
                    height: 1.15,
                  ),
                ),
                if (!metrics.isTight) ...[
                  SizedBox(height: metrics.gapXs * 0.5),
                  Text(
                    subtitle,
                    maxLines: metrics.isCompact ? 2 : 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: metrics.s(11).clamp(9.5, 11.0),
                      fontWeight: FontWeight.w500,
                      color: AuthDesign.mutedLabel,
                      height: 1.25,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: enabled,
            onChanged: onChanged,
            activeColor: AppTheme.primaryGreen,
            activeTrackColor: AuthDesign.gradientEnd.withValues(alpha: 0.55),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    );
  }
}
