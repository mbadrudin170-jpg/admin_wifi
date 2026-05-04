// test/widget_test.dart
// diubah: Mengganti tes default dengan tes yang relevan untuk aplikasi ini.
// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:admin_wifi/main.dart';

void main() {
  testWidgets('App starts with SplashScreen and navigates to HalamanUtama', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that SplashScreen is shown with its content.
    expect(find.text('Admin WiFi'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Wait for all animations and async tasks to complete,
    // which includes the navigation from SplashScreen to HalamanUtama.
    // The duration is added to handle longer async operations during initialization.
    await tester.pumpAndSettle(const Duration(seconds: 5));

    // Verify that HalamanUtama is now visible by checking for BottomNavigationBar items.
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('Dompet'), findsOneWidget);
    expect(find.text('Transaksi'), findsOneWidget);
    expect(find.text('Lainnya'), findsOneWidget);
  });
}
