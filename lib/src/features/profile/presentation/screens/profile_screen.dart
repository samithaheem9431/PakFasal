import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/localization/localization_controller.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/auth_required_dialog.dart';
import '../../../../core/widgets/pakfasal_scaffold.dart';
import '../../../auth/presentation/providers/auth_session_controller.dart';
import '../../../auth/presentation/providers/biometric_lock_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  bool _isSaving = false;
  String? _lastSyncedName;
  bool _animateIn = false;

  static const _headerAsset = 'assets/images/profile/header_bg.jpg';
  static const _cardRadius = 20.0;
  static const _pageBg = Color(0xFFF3F6F4);
  static const _signOutBg = Color(0xFFFCE8E8);
  static const _signOutBorder = Color(0xFFF3C4C4);
  static const _signOutFg = Color(0xFFB71C1C);
  static const _mintButtonBg = Color(0xFFE8F5E9);
  static const _mintIconBg = Color(0xFFE2F3E6);

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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncNameFromSession(String displayName) {
    if (_lastSyncedName == displayName) return;
    _nameController.text = displayName;
    _lastSyncedName = displayName;
  }

  Future<void> _saveName(
    AuthSessionController auth,
    AppLocalizations l10n,
  ) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final err = await auth.updateUserName(_nameController.text);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (err != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t(err))));
      return;
    }
    _lastSyncedName = auth.userName?.trim();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('profileUpdated'))));
  }

  Future<void> _changeProfilePhoto(AuthSessionController auth) async {
    final l10n = AppLocalizations.of(context);
    final allowed = await ensureRegisteredUser(context);
    if (!allowed || !mounted) return;

    final hasPhoto = auth.userPhotoUrl != null;

    final action = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_camera_outlined),
                  title: Text(l10n.t('takePhoto')),
                  onTap: () => Navigator.pop(sheetContext, 'camera'),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library_outlined),
                  title: Text(l10n.t('chooseFromGallery')),
                  onTap: () => Navigator.pop(sheetContext, 'gallery'),
                ),
                if (hasPhoto)
                  ListTile(
                    leading: Icon(
                      Icons.delete_outline_rounded,
                      color: Theme.of(sheetContext).colorScheme.error,
                    ),
                    title: Text(
                      l10n.t('removeProfilePhoto'),
                      style: TextStyle(
                        color: Theme.of(sheetContext).colorScheme.error,
                      ),
                    ),
                    onTap: () => Navigator.pop(sheetContext, 'remove'),
                  ),
              ],
            ),
          ),
        );
      },
    );
    if (action == null || !mounted) return;

    if (action == 'remove') {
      final err = await auth.removeProfilePhoto();
      if (!mounted) return;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.t(err))));
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('profilePhotoRemoved'))));
      return;
    }

    if (!AppConfig.hasCloudinaryConfig) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t('cloudinaryNotConfigured'))),
      );
      return;
    }

    final source =
        action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    final picked = await _imagePicker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final err = await auth.updateProfilePhoto(File(picked.path));
    if (!mounted) return;
    if (err != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t(err))));
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.t('profilePhotoUpdated'))));
  }

  Future<void> _toggleBiometricLock(
    BiometricLockController lock,
    AppLocalizations l10n,
    bool enable,
  ) async {
    final ok = await lock.setEnabled(
      enable,
      reason: l10n.t('biometricEnableReason'),
    );
    if (!mounted) return;
    if (!ok && lock.lastError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t(lock.lastError!))),
      );
    }
  }

  Future<void> _confirmDeleteAccount(
    AuthSessionController auth,
    AppLocalizations l10n,
  ) async {
    final passwordController = TextEditingController();
    final needsPassword = auth.isPasswordUser && !auth.isGoogleUser;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(l10n.t('deleteAccountTitle')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.t('deleteAccountMessage')),
              if (needsPassword) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: l10n.t('password'),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: Text(l10n.t('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: _signOutFg,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.t('deleteAccountConfirm')),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      passwordController.dispose();
      return;
    }

    final err = await auth.deleteAccount(
      password: needsPassword ? passwordController.text : null,
    );
    passwordController.dispose();
    if (!mounted) return;

    if (err == 'googleSignInCancelled') return;
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.t(err))),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.t('accountDeleted'))),
    );
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthSessionController>();
    final themeController = context.watch<ThemeController>();
    final localizationController = context.watch<LocalizationController>();
    final biometricLock = context.watch<BiometricLockController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topInset = MediaQuery.paddingOf(context).top;

    final displayName = auth.userName?.trim().isNotEmpty == true
        ? auth.userName!.trim()
        : 'Farmer';
    _syncNameFromSession(displayName);
    final email = auth.userEmail?.trim() ?? '-';
    final photoUrl = auth.userPhotoUrl;
    final uploading = auth.isUploadingPhoto;
    final pageBg = isDark ? AppColors.darkSurface : _pageBg;
    final isRegistered = auth.currentUser != null && !auth.isGuestUser;

    return PakFasalScaffold(
      title: l10n.t('profile'),
      showBottomNavigation: true,
      showBack: false,
      hideAppBar: true,
      showLanguageToggle: false,
      backgroundColor: pageBg,
      child: ListView(
        padding: PakFasalFloatingBottomBar.scrollPadding(
          context,
          bottom: 16,
        ),
        children: [
          _ProfileScenicHeader(
            topInset: topInset,
            title: l10n.t('profile'),
            subtitle: l10n.t('profileSubtitle'),
            asset: _headerAsset,
            languageButton: _HeaderLanguagePill(
              label: localizationController.isUrdu ? 'اردو' : 'EN',
              onTap: localizationController.toggleLanguage,
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _FadeSlideIn(
                    animate: _animateIn,
                    delayMs: 20,
                    child: _ProfileCard(
                      displayName: displayName,
                      emailLabel: '${l10n.t('email')}: $email',
                      photoUrl: photoUrl,
                      uploading: uploading,
                      changePhotoLabel: uploading
                          ? l10n.t('uploadingPhoto')
                          : l10n.t('changeProfilePhoto'),
                      onChangePhoto: uploading
                          ? null
                          : () => _changeProfilePhoto(auth),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FadeSlideIn(
                    animate: _animateIn,
                    delayMs: 90,
                    child: _UsernameCard(
                      formKey: _formKey,
                      nameController: _nameController,
                      usernameLabel: l10n.t('username'),
                      helperText: l10n.t('usernameHintAppear'),
                      hintText: l10n.t('usernameHint'),
                      isSaving: _isSaving,
                      saveLabel: _isSaving
                          ? l10n.t('saving')
                          : l10n.t('saveChanges'),
                      onSave: _isSaving ? null : () => _saveName(auth, l10n),
                      usernameRequired: l10n.t('usernameRequired'),
                      usernameMinLength: l10n.t('usernameMinLength'),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _FadeSlideIn(
                    animate: _animateIn,
                    delayMs: 160,
                    child: _SettingsCard(
                      isLightMode: !themeController.isDarkMode,
                      lightModeTitle: themeController.isDarkMode
                          ? l10n.t('darkMode')
                          : l10n.t('lightMode'),
                      lightModeHint: themeController.isDarkMode
                          ? l10n.t('darkModeHint')
                          : l10n.t('lightModeHint'),
                      onToggleTheme: themeController.toggleTheme,
                      languageTitle: l10n.t('language'),
                      languageHint: l10n.t('languageHint'),
                      languageCode:
                          localizationController.isUrdu ? 'اردو' : 'EN',
                      onToggleLanguage: localizationController.toggleLanguage,
                      showBiometricLock: isRegistered &&
                          biometricLock.isDeviceSupported,
                      biometricLockEnabled: biometricLock.isEnabled,
                      biometricLockTitle: l10n.t('biometricAppLock'),
                      biometricLockHint: l10n.t('biometricAppLockHint'),
                      onToggleBiometricLock: biometricLock.isBusy
                          ? null
                          : (value) => _toggleBiometricLock(
                                biometricLock,
                                l10n,
                                value,
                              ),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _FadeSlideIn(
                    animate: _animateIn,
                    delayMs: 230,
                    child: _AccountActionsCard(
                      isDark: isDark,
                      signOutLabel: l10n.t('authSignOut'),
                      onSignOut: auth.isBusy
                          ? null
                          : () async {
                              await auth.signOut();
                              if (!context.mounted) return;
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.login,
                                (_) => false,
                              );
                            },
                      showDeleteAccount: isRegistered,
                      deleteAccountLabel: auth.isDeletingAccount
                          ? l10n.t('deletingAccount')
                          : l10n.t('deleteAccount'),
                      isDeletingAccount: auth.isDeletingAccount,
                      onDeleteAccount: auth.isDeletingAccount
                          ? null
                          : () => _confirmDeleteAccount(auth, l10n),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileScenicHeader extends StatelessWidget {
  const _ProfileScenicHeader({
    required this.topInset,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.languageButton,
  });

  final double topInset;
  final String title;
  final String subtitle;
  final String asset;
  final Widget languageButton;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg =
        isDark ? AppColors.darkSurface : const Color(0xFFF3F6F4);

    return SizedBox(
      height: topInset + 168,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            asset,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.15),
            cacheWidth: (MediaQuery.sizeOf(context).width *
                    MediaQuery.devicePixelRatioOf(context))
                .round()
                .clamp(480, 1400),
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => Container(
              color: isDark
                  ? AppColors.darkSurfaceMid
                  : const Color(0xFF1B5E20),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.38),
                  Colors.black.withValues(alpha: 0.18),
                  pageBg.withValues(alpha: 0.55),
                  pageBg,
                ],
                stops: const [0.0, 0.42, 0.82, 1.0],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 16,
            top: topInset + 10,
            // Pin language pill on the physical right in Urdu (RTL) too.
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Directionality(
                      textDirection: Directionality.of(context),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 13.5,
                              fontWeight: FontWeight.w500,
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  languageButton,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSurfaceCard extends StatelessWidget {
  const _ProfileSurfaceCard({
    required this.child,
    required this.isDark,
  });

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceHigh : Colors.white,
        borderRadius: BorderRadius.circular(_ProfileScreenState._cardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.07),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.displayName,
    required this.emailLabel,
    required this.photoUrl,
    required this.uploading,
    required this.changePhotoLabel,
    required this.onChangePhoto,
    required this.isDark,
  });

  final String displayName;
  final String emailLabel;
  final String? photoUrl;
  final bool uploading;
  final String changePhotoLabel;
  final VoidCallback? onChangePhoto;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final initial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'F';

    return _ProfileSurfaceCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onChangePhoto,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: AppColors.paleGreen,
                    backgroundImage: photoUrl != null
                        ? CachedNetworkImageProvider(photoUrl!)
                        : null,
                    child: photoUrl == null
                        ? Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryGreen,
                            ),
                          )
                        : null,
                  ),
                  Positioned(
                    right: -1,
                    bottom: -1,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkSurfaceHigh
                              : Colors.white,
                          width: 2.5,
                        ),
                      ),
                      child: uploading
                          ? const Padding(
                              padding: EdgeInsets.all(6),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(
                              Icons.camera_alt_rounded,
                              size: 14,
                              color: Colors.white,
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.darkText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? Colors.white70
                          : AppColors.mutedText,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onChangePhoto,
                      borderRadius: BorderRadius.circular(10),
                      child: Ink(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.primaryGreen.withValues(alpha: 0.22)
                              : _ProfileScreenState._mintButtonBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.primaryGreen.withValues(
                              alpha: 0.45,
                            ),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              size: 16,
                              color: isDark
                                  ? AppColors.lightGreen
                                  : AppColors.primaryGreen,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                changePhotoLabel,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.lightGreen
                                      : AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UsernameCard extends StatelessWidget {
  const _UsernameCard({
    required this.formKey,
    required this.nameController,
    required this.usernameLabel,
    required this.helperText,
    required this.hintText,
    required this.isSaving,
    required this.saveLabel,
    required this.onSave,
    required this.usernameRequired,
    required this.usernameMinLength,
    required this.isDark,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController nameController;
  final String usernameLabel;
  final String helperText;
  final String hintText;
  final bool isSaving;
  final String saveLabel;
  final VoidCallback? onSave;
  final String usernameRequired;
  final String usernameMinLength;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _ProfileSurfaceCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                usernameLabel,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.darkText,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                helperText,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                  color: isDark ? Colors.white60 : AppColors.mutedText,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: nameController,
                textInputAction: TextInputAction.done,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.darkText,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  prefixIcon: Icon(
                    Icons.person_outline_rounded,
                    color: isDark ? Colors.white54 : AppColors.mutedText,
                  ),
                  filled: true,
                  fillColor: isDark
                      ? AppColors.darkSurfaceMid
                      : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : const Color(0xFFE0E5E1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                      color: isDark
                          ? Colors.white24
                          : const Color(0xFFE0E5E1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                      color: AppColors.primaryGreen,
                      width: 1.5,
                    ),
                  ),
                ),
                validator: (value) {
                  final name = value?.trim() ?? '';
                  if (name.isEmpty) return usernameRequired;
                  if (name.length < 3) return usernameMinLength;
                  return null;
                },
                onFieldSubmitted: (_) => onSave?.call(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1B5E20),
                        Color(0xFF43A047),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withValues(alpha: 0.28),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.white70,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (isSaving)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        else
                          const Icon(Icons.save_outlined, size: 20),
                        const SizedBox(width: 8),
                        Text(saveLabel),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.isLightMode,
    required this.lightModeTitle,
    required this.lightModeHint,
    required this.onToggleTheme,
    required this.languageTitle,
    required this.languageHint,
    required this.languageCode,
    required this.onToggleLanguage,
    required this.showBiometricLock,
    required this.biometricLockEnabled,
    required this.biometricLockTitle,
    required this.biometricLockHint,
    required this.onToggleBiometricLock,
    required this.isDark,
  });

  final bool isLightMode;
  final String lightModeTitle;
  final String lightModeHint;
  final VoidCallback onToggleTheme;
  final String languageTitle;
  final String languageHint;
  final String languageCode;
  final VoidCallback onToggleLanguage;
  final bool showBiometricLock;
  final bool biometricLockEnabled;
  final String biometricLockTitle;
  final String biometricLockHint;
  final ValueChanged<bool>? onToggleBiometricLock;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return _ProfileSurfaceCard(
      isDark: isDark,
      child: Column(
        children: [
          _SettingsRow(
            icon: isLightMode
                ? Icons.wb_sunny_rounded
                : Icons.dark_mode_rounded,
            title: lightModeTitle,
            subtitle: lightModeHint,
            isDark: isDark,
            trailing: Switch(
              value: isLightMode,
              activeColor: AppColors.primaryGreen,
              activeTrackColor: AppColors.lightGreen,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: const Color(0xFFBDBDBD),
              onChanged: (_) => onToggleTheme(),
            ),
          ),
          Divider(
            height: 1,
            indent: 68,
            endIndent: 16,
            color: isDark ? Colors.white12 : const Color(0xFFE8EEE9),
          ),
          _SettingsRow(
            icon: Icons.language_rounded,
            title: languageTitle,
            subtitle: languageHint,
            isDark: isDark,
            trailing: Material(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : const Color(0xFFF0F3F1),
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: onToggleLanguage,
                borderRadius: BorderRadius.circular(18),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        languageCode,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? Colors.white
                              : AppColors.darkText,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: isDark
                            ? Colors.white70
                            : AppColors.mutedText,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (showBiometricLock) ...[
            Divider(
              height: 1,
              indent: 68,
              endIndent: 16,
              color: isDark ? Colors.white12 : const Color(0xFFE8EEE9),
            ),
            _SettingsRow(
              icon: Icons.fingerprint_rounded,
              title: biometricLockTitle,
              subtitle: biometricLockHint,
              isDark: isDark,
              trailing: Switch(
                value: biometricLockEnabled,
                activeColor: AppColors.primaryGreen,
                activeTrackColor: AppColors.lightGreen,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFBDBDBD),
                onChanged: onToggleBiometricLock,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryGreen.withValues(alpha: 0.25)
                  : _ProfileScreenState._mintIconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 22,
              color: isDark ? AppColors.lightGreen : AppColors.primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.3,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _AccountActionsCard extends StatelessWidget {
  const _AccountActionsCard({
    required this.isDark,
    required this.signOutLabel,
    required this.onSignOut,
    required this.showDeleteAccount,
    required this.deleteAccountLabel,
    required this.isDeletingAccount,
    required this.onDeleteAccount,
  });

  final bool isDark;
  final String signOutLabel;
  final VoidCallback? onSignOut;
  final bool showDeleteAccount;
  final String deleteAccountLabel;
  final bool isDeletingAccount;
  final VoidCallback? onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return _ProfileSurfaceCard(
      isDark: isDark,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          children: [
            _DangerActionButton(
              label: signOutLabel,
              icon: Icons.logout_rounded,
              onPressed: onSignOut,
              isDark: isDark,
              filled: true,
            ),
            if (showDeleteAccount) ...[
              const SizedBox(height: 10),
              _DangerActionButton(
                label: deleteAccountLabel,
                icon: Icons.delete_forever_rounded,
                onPressed: onDeleteAccount,
                isDark: isDark,
                filled: false,
                showSpinner: isDeletingAccount,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DangerActionButton extends StatelessWidget {
  const _DangerActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.isDark,
    required this.filled,
    this.showSpinner = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;
  final bool filled;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    final fg = isDark ? Colors.white : AppColors.error;
    final bg = filled
        ? (isDark ? const Color(0xFF3A2222) : _ProfileScreenState._signOutBg)
        : Colors.transparent;
    final border = isDark
        ? const Color(0xFF6B3A3A)
        : _ProfileScreenState._signOutBorder;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border, width: filled ? 1.2 : 1.4),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: isDark ? 0.18 : 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: showSpinner
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: fg,
                            ),
                          )
                        : Icon(icon, size: 18, color: fg),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: fg,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderLanguagePill extends StatelessWidget {
  const _HeaderLanguagePill({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.language_rounded,
                size: 16,
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primaryGreen,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 16,
                color: AppColors.primaryGreen,
              ),
            ],
          ),
        ),
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
