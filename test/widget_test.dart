// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:chat_app/core/app_strings.dart';
import 'package:chat_app/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App loads splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    // Verify that the splash screen loads with app name
    expect(find.text(AppStrings.appName), findsOneWidget);
  });
}

