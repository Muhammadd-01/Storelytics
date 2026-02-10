import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

final storageServiceProvider = Provider((ref) => StorageService());

class StorageService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Uploads a file to Supabase Storage and returns the public URL.
  /// Works across all platforms (Web, Mobile, Desktop).
  Future<String> uploadFile({
    required XFile file,
    required String bucketName,
    required String pathPrefix,
  }) async {
    try {
      final fileName = path.basename(file.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '$pathPrefix/${timestamp}_$fileName';

      // Read as bytes for cross-platform support (Web/Windows/Mobile)
      final bytes = await file.readAsBytes();

      await _supabase.storage
          .from(bucketName)
          .uploadBinary(
            filePath,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final String publicUrl = _supabase.storage
          .from(bucketName)
          .getPublicUrl(filePath);

      return publicUrl;
    } catch (e) {
      debugPrint('Supabase Upload Error: $e');
      throw Exception(
        'Upload Failed: ${e.toString().contains('403') ? 'Permissions Denied (RLS)' : e.toString()}',
      );
    }
  }

  /// Specialized method for uploading store verification images.
  Future<String> uploadStoreVerificationImage({
    required XFile file,
    required String storeId,
    required String type, // 'nic' or 'certification'
  }) async {
    return uploadFile(
      file: file,
      bucketName: 'verification',
      pathPrefix: 'stores/$storeId',
    );
  }

  /// Specialized method for uploading inventory item images.
  Future<String> uploadItemImage({
    required XFile file,
    required String storeId,
  }) async {
    return uploadFile(
      file: file,
      bucketName: 'items',
      pathPrefix: 'stores/$storeId',
    );
  }

  /// Specialized method for uploading profile images.
  Future<String> uploadProfileImage({
    required XFile file,
    required String userId,
  }) async {
    return uploadFile(
      file: file,
      bucketName: 'profiles',
      pathPrefix: 'users/$userId',
    );
  }
}
