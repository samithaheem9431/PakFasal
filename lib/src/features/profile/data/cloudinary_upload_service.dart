import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

/// Uploads profile images to Cloudinary via an unsigned upload preset.
///
/// Client-side guards (size / type) reduce abuse of the unsigned preset.
/// Also configure the preset in Cloudinary dashboard with matching limits
/// (allowed formats + max file size) so server-side enforcement stays in force.
class CloudinaryUploadService {
  CloudinaryUploadService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  /// Max profile photo size accepted before upload (5 MB).
  static const int maxBytes = 5 * 1024 * 1024;

  /// Extensions allowed for profile photos (lowercase, no dot).
  static const Set<String> allowedExtensions = {
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  bool get isConfigured =>
      AppConfig.cloudinaryCloudName.isNotEmpty &&
      AppConfig.cloudinaryUploadPreset.isNotEmpty;

  /// Validates [imageFile] for size and type. Throws [StateError] with a
  /// localization key on failure.
  Future<void> validateProfileImage(File imageFile) async {
    if (!await imageFile.exists()) {
      throw StateError('profilePhotoUploadFailed');
    }

    final ext = _extensionOf(imageFile.path);
    if (!allowedExtensions.contains(ext)) {
      throw StateError('profilePhotoInvalidType');
    }

    final length = await imageFile.length();
    if (length <= 0) {
      throw StateError('profilePhotoUploadFailed');
    }
    if (length > maxBytes) {
      throw StateError('profilePhotoTooLarge');
    }

    // Sniff magic bytes so a renamed .exe cannot slip through as .jpg.
    final header = await imageFile.openRead(0, 16).first;
    if (!_looksLikeAllowedImage(header, ext)) {
      throw StateError('profilePhotoInvalidType');
    }
  }

  /// Uploads [imageFile] and returns the secure HTTPS URL.
  ///
  /// Stores under `pakfasal/profiles/{userId}_{timestamp}` so each farmer
  /// keeps a unique image path without needing the unsigned-forbidden
  /// `overwrite` parameter.
  Future<String> uploadProfileImage({
    required File imageFile,
    required String userId,
  }) async {
    if (!isConfigured) {
      throw StateError('cloudinaryNotConfigured');
    }

    await validateProfileImage(imageFile);

    final cloudName = AppConfig.cloudinaryCloudName;
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = AppConfig.cloudinaryUploadPreset
      ..fields['folder'] = 'pakfasal/profiles'
      // Unique id per upload (unsigned presets cannot send overwrite=true).
      ..fields['public_id'] =
          '${userId}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final streamed = await _client.send(request);
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      debugPrint(
        'Cloudinary upload failed (${streamed.statusCode}): $body',
      );
      throw StateError('profilePhotoUploadFailed');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw StateError('profilePhotoUploadFailed');
    }

    final url = (decoded['secure_url'] ?? decoded['url'])?.toString();
    if (url == null || url.isEmpty) {
      throw StateError('profilePhotoUploadFailed');
    }
    return url;
  }

  static String _extensionOf(String path) {
    final name = path.replaceAll('\\', '/').split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot < 0 || dot == name.length - 1) return '';
    return name.substring(dot + 1).toLowerCase();
  }

  static bool _looksLikeAllowedImage(List<int> bytes, String ext) {
    if (bytes.length < 3) return false;

    // JPEG: FF D8 FF
    final isJpeg =
        bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF;
    // PNG: 89 50 4E 47
    final isPng = bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47;
    // WEBP: RIFF....WEBP
    final isWebp = bytes.length >= 12 &&
        bytes[0] == 0x52 &&
        bytes[1] == 0x49 &&
        bytes[2] == 0x46 &&
        bytes[3] == 0x46 &&
        bytes[8] == 0x57 &&
        bytes[9] == 0x45 &&
        bytes[10] == 0x42 &&
        bytes[11] == 0x50;

    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return isJpeg;
      case 'png':
        return isPng;
      case 'webp':
        return isWebp;
      default:
        return isJpeg || isPng || isWebp;
    }
  }
}
