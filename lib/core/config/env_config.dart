import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class EnvConfig {
  static const _supabaseUrlDefine = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKeyDefine =
      String.fromEnvironment('SUPABASE_ANON_KEY');
  static const _cloudinaryCloudNameDefine =
      String.fromEnvironment('CLOUDINARY_CLOUD_NAME');
  static const _cloudinaryUploadPresetDefine =
      String.fromEnvironment('CLOUDINARY_UPLOAD_PRESET');

  static String get supabaseUrl => _value('SUPABASE_URL', _supabaseUrlDefine);
  static String get supabaseAnonKey =>
      _value('SUPABASE_ANON_KEY', _supabaseAnonKeyDefine);
  static String get cloudinaryCloudName =>
      _value('CLOUDINARY_CLOUD_NAME', _cloudinaryCloudNameDefine);
  static String get cloudinaryUploadPreset =>
      _value('CLOUDINARY_UPLOAD_PRESET', _cloudinaryUploadPresetDefine);

  static String _value(String key, String defineValue) {
    if (defineValue.isNotEmpty) return defineValue;
    return dotenv.env[key] ?? '';
  }
}
