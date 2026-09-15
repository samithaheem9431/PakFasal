import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';

/// Uploads profile images to Cloudinary via an unsigned upload preset.
class CloudinaryUploadService {
  CloudinaryUploadService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  bool get isConfigured =>
      AppConfig.cloudinaryCloudName.isNotEmpty &&
      AppConfig.cloudinaryUploadPreset.isNotEmpty;

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
}
