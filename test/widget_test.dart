// This is a basic Flutter widget test.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:nyaya_mithra/main.dart';
import 'package:nyaya_mithra/providers/app_provider.dart';

void main() {
  testWidgets('App should render splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NyayaMithraApp());

    // Verify that splash screen elements are present
    expect(find.text('NyayaMithra'), findsOneWidget);
    expect(find.text('Your Legal & Civic Companion'), findsOneWidget);
  });
}
