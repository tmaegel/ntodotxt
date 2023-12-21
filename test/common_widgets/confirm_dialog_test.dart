import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common_widgets/confirm_dialog.dart';

class MaterialAppConfirmationDialog extends StatefulWidget {
  const MaterialAppConfirmationDialog({super.key});

  @override
  State<MaterialAppConfirmationDialog> createState() =>
      _MaterialAppConfirmationDialogState();
}

class _MaterialAppConfirmationDialogState
    extends State<MaterialAppConfirmationDialog> {
  int _value = -1;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text('$_value'),
            Builder(
              builder: (BuildContext context) {
                return TextButton(
                  child: const Text('Open dialog'),
                  onPressed: () async {
                    bool confirm = await ConfirmationDialog.dialog(
                      context: context,
                      title: 'Dialog',
                      message: 'Question?',
                      actionLabel: 'Ok',
                    );

                    setState(() {
                      _value = confirm == true ? 1 : 0;
                    });
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

  group('ConfirmationDialog', () {
    testWidgets('confirm', (tester) async {
      await tester.pumpWidget(const MaterialAppConfirmationDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Ok'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == '1',
        ),
        findsOneWidget,
      );
    });
    testWidgets('confirm', (tester) async {
      await tester.pumpWidget(const MaterialAppConfirmationDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == '0',
        ),
        findsOneWidget,
      );
    });
  });
}
