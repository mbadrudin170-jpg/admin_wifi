// path: lib/main_prod.dart
import 'package:admin_wifi/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_global_saya/core_shared.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPrefService.init();

  final container = ProviderContainer();
  L.init(container);

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            // PengelolaOverlayLogDebug menyisipkan ikon/panel ke Overlay.maybeOf(context);
            // Overlay dibuat di root agar pemanggilannya menemukan ancestor (rootOverlay).
            builder: (context) =>
                const PengelolaOverlayLogDebug(child: MyApp()),
          ),
        ],
      ),
    ),
  );
}
