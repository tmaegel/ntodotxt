import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common/widget/info_dialog.dart';

class MaterialAppInfoDialog extends StatelessWidget {
  const MaterialAppInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Builder(
              builder: (BuildContext context) {
                return TextButton(
                  child: const Text('Open dialog'),
                  onPressed: () async {
                    await InfoDialog.dialog(
                      context: context,
                      title: 'Dialog title',
                      message: 'Dialog text',
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('InfoDialog', () {
    testWidgets('info', (tester) async {
      await tester.pumpWidget(const MaterialAppInfoDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Dialog title'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Dialog text'),
        ),
        findsOneWidget,
      );
    });
  });
}
