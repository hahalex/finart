import 'package:finart_app/main.dart' as app;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app starts and shows the FinArt shell', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('FinArt'), findsWidgets);
  });
}
