import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/common/widget/input_dialog.dart';

class MaterialAppInputDialog extends StatefulWidget {
  const MaterialAppInputDialog({super.key});

  @override
  State<MaterialAppInputDialog> createState() => _MaterialAppInputDialogState();
}

class _MaterialAppInputDialogState extends State<MaterialAppInputDialog> {
  String _value = 'default';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Text(_value),
            Builder(
              builder: (BuildContext context) {
                return TextButton(
                  child: const Text('Open dialog'),
                  onPressed: () async {
                    final String? value = await InputDialog.dialog(
                      context: context,
                      title: 'Dialog',
                      label: 'Enter value',
                    );

                    setState(() {
                      _value = value ?? 'cancel';
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

  group('InputDialog', () {
    testWidgets('ok', (tester) async {
      await tester.pumpWidget(const MaterialAppInputDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'enter some text');
      await tester.tap(find.text('Ok'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'enter some text',
        ),
        findsOneWidget,
      );
    });
    testWidgets('cancel', (tester) async {
      await tester.pumpWidget(const MaterialAppInputDialog());
      await tester.pump();

      await tester.tap(find.text('Open dialog'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'enter some text');
      await tester.tap(find.text('Cancel'));
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (Widget widget) => widget is Text && widget.data == 'cancel',
        ),
        findsOneWidget,
      );
    });
  });
}
