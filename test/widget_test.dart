import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmaharab/main.dart';

void main() {
  testWidgets('TaskFlowApp initialization smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: TaskFlowApp(),
      ),
    );

    // Let splash screen timer and animations complete
    await tester.pump(const Duration(seconds: 2));

    expect(find.byType(TaskFlowApp), findsOneWidget);
  });
}
