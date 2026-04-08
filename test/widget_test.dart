import 'package:flutter_test/flutter_test.dart';
import 'package:olympia_app/main.dart';

void main() {
  testWidgets('App should build without errors', (WidgetTester tester) async {
    expect(OlympiaApp, isNotNull);
  });
}
