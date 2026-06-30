import 'package:flutter_test/flutter_test.dart';
import 'package:karisma_pos/main.dart';

void main() {
  testWidgets('OMScan smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const OMScanApp());
    expect(find.text('OMScan'), findsWidgets);
  });
}
