import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:roommate_app/app/app.dart';
import 'package:roommate_app/core/constants/app_strings.dart';

void main() {
  testWidgets('App boots and shows registration title', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RoommateApp()));
    expect(find.text(AppStrings.registerTitle), findsOneWidget);
  });
}
