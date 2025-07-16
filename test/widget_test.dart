// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';

import '../lib/main.dart';

void main() {
  group('FlashCompositionApp', () {
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
    });

    testWidgets('App initializes without Firebase errors', (WidgetTester tester) async {
      // Build our app
      await tester.pumpWidget(const FlashCompositionApp());

      // Wait for initial frame
      await tester.pump();

      // Verify that the basic widget structure is present
      expect(find.byType(FlashCompositionApp), findsOneWidget);
    });
  });
}
