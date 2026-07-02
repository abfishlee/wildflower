import 'package:flutter_test/flutter_test.dart';
import 'package:semikkot_app/main.dart';

void main() {
  testWidgets('SemikkotApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SemikkotApp());

    // Verify that our app title or tab exists.
    expect(find.text('🌸 세미꽃'), findsOneWidget);
    expect(find.text('나의 수첩'), findsOneWidget);
  });
}
