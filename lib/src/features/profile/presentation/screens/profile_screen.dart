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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final auth = context.watch<AuthSessionController>();
    final themeController = context.watch<ThemeController>();
    final localizationController = context.watch<LocalizationController>();

    final displayName = auth.userName?.trim().isNotEmpty == true
        ? auth.userName!.trim()
        : 'Farmer';
    _syncNameFromSession(displayName);
    final email = auth.userEmail?.trim() ?? '-';
    final photoUrl = auth.userPhotoUrl;
    final uploading = auth.isUploadingPhoto;

    return PakFasalScaffold(
      title: l10n.t('profile'),
      showBack: false,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FadeSlideIn(
            animate: _animateIn,
            delayMs: 20,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: uploading ? null : () => _changeProfilePhoto(auth),
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: AppColors.paleGreen,
                            backgroundImage: photoUrl != null
                                ? CachedNetworkImageProvider(photoUrl)
                                : null,
                            child: photoUrl == null
                                ? Text(
                                    displayName.isNotEmpty
                                        ? displayName[0].toUpperCase()
                                        : 'F',
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryGreen,
                                    ),
                                  )
                                : null,
                          ),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.surface,
                                width: 2,
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${l10n.t('email')}: $email',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: uploading
                                ? null
                                : () => _changeProfilePhoto(auth),
                            icon: const Icon(Icons.photo_camera_outlined, size: 18),
                            label: Text(
                              uploading
                                  ? l10n.t('uploadingPhoto')
                                  : l10n.t('changeProfilePhoto'),
                            ),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryGreen,
                              padding: EdgeInsets.zero,
                              alignment: Alignment.centerLeft,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FadeSlideIn(
            animate: _animateIn,
            delayMs: 90,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l10n.t('username'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        textInputAction: TextInputAction.done,
                        decoration: InputDecoration(
                          hintText: l10n.t('usernameHint'),
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) {
                            return l10n.t('usernameRequired');
                          }
                          if (name.length < 3) {
                            return l10n.t('usernameMinLength');
                          }
                          return null;
                        },
                        onFieldSubmitted: (_) => _saveName(auth, l10n),
                      ),
                      const SizedBox(height: 12),
                      AnimatedScale(
                        scale: _isSaving ? 0.99 : 1,
                        duration: const Duration(milliseconds: 180),
                        child: ElevatedButton(
                          onPressed: _isSaving
                              ? null
                              : () => _saveName(auth, l10n),
                          style: ElevatedButton.styleFrom(
                            textStyle: const TextStyle(
                              inherit: false,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.1,
                              fontFamily: 'Roboto',
                            ),
                          ),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 220),
                            child: Row(
                              key: ValueKey(_isSaving),
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSaving)
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(Icons.save_outlined),
                                const SizedBox(width: 8),
                                Text(
                                  _isSaving
                                      ? l10n.t('saving')
                                      : l10n.t('saveChanges'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FadeSlideIn(
            animate: _animateIn,
            delayMs: 160,
            child: Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: themeController.isDarkMode,
                    title: Text(
                      themeController.isDarkMode
                          ? l10n.t('darkMode')
                          : l10n.t('lightMode'),
                    ),
                    secondary: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Icon(
                        themeController.isDarkMode
                            ? Icons.dark_mode
                            : Icons.light_mode,
                        key: ValueKey(themeController.isDarkMode),
                      ),
                    ),
                    onChanged: (_) => themeController.toggleTheme(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(l10n.t('language')),
                    trailing: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        localizationController.isUrdu ? 'اردو' : 'EN',
                        key: ValueKey(localizationController.isUrdu),
                      ),
                    ),
                    onTap: localizationController.toggleLanguage,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          _FadeSlideIn(
            animate: _animateIn,
            delayMs: 230,
            child: ElevatedButton(
              onPressed: () async {
                await auth.signOut();
                if (!context.mounted) return;
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                textStyle: const TextStyle(
                  inherit: false,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.1,
                  fontFamily: 'Roboto',
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.logout_rounded),
                  const SizedBox(width: 8),
                  Text(l10n.t('authSignOut')),
                ],
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
