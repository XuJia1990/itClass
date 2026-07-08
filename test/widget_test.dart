import 'package:flutter_test/flutter_test.dart';
import 'package:it_class/main.dart';

void main() {
  testWidgets('shows supported platforms', (tester) async {
    await tester.pumpWidget(const ItClassApp());

    expect(find.text('itClass'), findsOneWidget);
    expect(find.text('Web'), findsOneWidget);
    expect(find.text('Android'), findsOneWidget);
    expect(find.text('iOS'), findsOneWidget);
  });
}
