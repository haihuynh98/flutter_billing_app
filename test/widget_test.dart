import 'package:flutter_test/flutter_test.dart';

import 'package:billing_app/core/data/hive_database.dart';
import 'package:billing_app/core/service_locator.dart' as di;
import 'package:billing_app/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await HiveDatabase.initForTests();
    await di.init();
  });

  testWidgets('App smoke test — home loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Danh sách trống'), findsOneWidget);
  });
}
