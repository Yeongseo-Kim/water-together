// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:water_together/main.dart';

void main() {
  testWidgets('Water Together app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const WaterTogetherApp());

    // Verify that our app shows the main screen
    expect(find.text('물먹자 투게더'), findsOneWidget);
    expect(find.text('홈'), findsOneWidget);
  });
}
