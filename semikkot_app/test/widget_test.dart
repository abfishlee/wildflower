import 'package:flutter_test/flutter_test.dart';
import 'package:semikkot_app/main.dart';

void main() {
  testWidgets('SemikkotApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SemikkotApp());

    // Verify that the redesigned top-level navigation exists.
    expect(find.text('세미꽃'), findsOneWidget);
    expect(find.text('야생화 수집'), findsWidgets);
    expect(find.text('나의 정원'), findsOneWidget);
    expect(find.text('꽃밭'), findsOneWidget);
  });
}
