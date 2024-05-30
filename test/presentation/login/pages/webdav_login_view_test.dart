import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/data/settings/setting_controller.dart';
import 'package:ntodotxt/domain/settings/setting_repository.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_cubit.dart';
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class MaterialAppWebDAVLoginView extends StatelessWidget {
  final String databasePath;

  const MaterialAppWebDAVLoginView({
    this.databasePath = inMemoryDatabasePath,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<SettingRepository>(
          create: (BuildContext context) => SettingRepository(
            SettingController(databasePath),
          ),
        ),
      ],
      child: BlocProvider(
        create: (BuildContext context) => TodoFileCubit(
          repository: context.read<SettingRepository>(),
          state: const TodoFileReady(),
        )..load(),
        child: Builder(
          builder: (BuildContext context) {
            return const MaterialApp(
              debugShowCheckedModeBanner: false,
              home: WebDAVLoginView(),
            );
          },
        ),
      ),
    );
  }
}

void main() {
  group('Login form validation', () {
    group('success', () {
      testWidgets('Render form', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        expect(find.byType(WebDAVLoginView), findsOneWidget);
      });
      testWidgets('Server address with http', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'http://localhost');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsNothing,
        );
      });
      testWidgets('Server address with https', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'https://localhost');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsNothing,
        );
      });
      testWidgets('Server address with port', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'http://localhost:80');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsNothing,
        );
      });
      testWidgets('Server address with dots', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'http://localhost.local');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsNothing,
        );
      });
    });

    group('failed', () {
      testWidgets('Missing base url', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(find.text('Missing base URL'), findsOneWidget);
      });
      testWidgets('Missing username', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(find.text('Missing username'), findsOneWidget);
      });
      testWidgets('Missing password', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(find.text('Missing password'), findsOneWidget);
      });
      testWidgets('Missing server address', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(find.text('Missing server address'), findsOneWidget);
      });
      testWidgets('Missing protocol', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'localhost');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Missing protocol'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('Missing server port (http)', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'http://localhost:');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('Missing server port (https)', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'https://localhost:');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('Invalid format (port is string)', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(
          formField,
          'https://localhost:abc',
        );
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('Invalid format (multiple ports)', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(
          formField,
          'https://localhost:80:90',
        );
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsOneWidget,
        );
      });
      testWidgets('Invalid format (invalid host)', (tester) async {
        await tester.pumpWidget(const MaterialAppWebDAVLoginView());
        Finder formField = find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        );
        await tester.enterText(formField, 'https://local host:80');
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(
          find.descendant(
            of: formField,
            matching: find.text('Invalid format'),
          ),
          findsOneWidget,
        );
      });
    });
  });
}
