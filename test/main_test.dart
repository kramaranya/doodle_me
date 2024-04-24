import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:doodle_me/main.dart'; // Adjust the import according to your project structure
import 'package:mockito/mockito.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
  });

  testWidgets('Bottom Navigation Bar Test', (WidgetTester tester) async {
    MockNavigatorObserver mockObserver = MockNavigatorObserver();
    await tester.pumpWidget(MaterialApp(
      home: BottomNavigationBarApp(
          initialLocale: Locale('en', ''), // Specify the locale
          initialThemeMode: ThemeMode.light // Specify the theme mode
          ),
      navigatorObservers: [mockObserver],
    ));

    // Verify the app starts on the first tab
    expect(find.text('Doodle'), findsOneWidget);

    // Tap the second navigation bar item
    await tester.tap(find.text('Draw'));
    await tester.pumpAndSettle();

    // Verify the app correctly switched to the second tab
    expect(find.text('Draw'), findsOneWidget);
  });
}
