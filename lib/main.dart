import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) {
    // Permite abrir builds sin asset .env; la app mostrara estado sin Supabase.
  }

  final supabaseUrl = EnvConfig.supabaseUrl;
  final supabaseAnonKey = EnvConfig.supabaseAnonKey;

  if (supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty) {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
  }

  runApp(const ProviderScope(child: FonoClinicApp()));
}
