import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env_config.dart';

bool get hasSupabaseConfig =>
    EnvConfig.supabaseUrl.isNotEmpty && EnvConfig.supabaseAnonKey.isNotEmpty;

SupabaseClient? supabaseOrNull() {
  if (!hasSupabaseConfig) return null;
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}
