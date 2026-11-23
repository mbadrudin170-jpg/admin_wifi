// path: lib/main.dart
import 'package:admin_wifi/app.dart';
import 'package:admin_wifi/db/supabase/supabase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:network_tools_flutter/network_tools_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_global_saya/core_shared.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

void main() async {
  debugPrint('MAIN START');
  WidgetsFlutterBinding.ensureInitialized();

  // Muat konfigurasi dari berkas .env (dotenv) sebelum inisialisasi layanan.
  await dotenv.load();
  debugPrint('DOTENV LOADED');

  // SQLite di Web berjalan lewat sqflite_common_ffi_web (IndexedDB).
  // Factory wajib diset sebelum database pertama dibuka (dokumen resmi).
  if (kIsWeb) {
    databaseFactory = databaseFactoryFfiWeb;
  }

  await SharedPrefService.init();
  debugPrint('SHAREDPREF INIT');

  // Inisialisasi klien Supabase (idempoten) sebelum runApp; konfigurasi
  // diambil dari .env, bukan hardcode (skill supabase).
  await SupabaseKlien.instance.inisialisasi(
    url: dotenv.get('SUPABASE_URL'),
    publishableKey: dotenv.get('SUPABASE_PUBLISHABLE_KEY'),
  );
  debugPrint('SUPABASE INIT');

  final container = ProviderContainer();
  L.init(container);

  if (!kIsWeb) {
    try {
      final direktoriAplikasi = await getApplicationSupportDirectory();
      await configureNetworkToolsFlutter(
        direktoriAplikasi.path,
        enableDebugging: false,
      );
      L.i('direktoriAplikasi=${direktoriAplikasi.path}');
    } catch (e, s) {
      L.e('Gagal inisialisasi network_tools_flutter: $e $s');
    }
  }

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: PengelolaOverlayLogDebugRoot(child: AppMaterial()),
    ),
  );
  debugPrint('RUNAPP DONE');
}
