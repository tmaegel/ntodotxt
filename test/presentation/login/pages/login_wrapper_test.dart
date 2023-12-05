import 'dart:io';

import 'package:file/memory.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/main.dart' show App;
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
import 'package:ntodotxt/presentation/login/states/login_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferences prefs;
  late MemoryFileSystem fs;
  late File file;

  setUp(() async {
    // Mock shared preferences.
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();

    // Create in-memory file.
    fs = MemoryFileSystem();
    file = fs.file('todo.test');
    await file.create();
    await file.writeAsString("", flush: true); // Empty file.
  });

  group('Logout', () {
    testWidgets('show login screen if state is Logout', (tester) async {
      await tester.pumpWidget(
        LoginWrapper(
          prefs: prefs,
          todoFile: file,
          initialLoginState: const Logout(),
        ),
      );
      expect(find.byType(LoginPage), findsOneWidget);
    });
  });

  group('Login', () {
    testWidgets('show app screen if state is LoginOffline', (tester) async {
      await tester.pumpWidget(
        LoginWrapper(
          prefs: prefs,
          todoFile: file,
          initialLoginState: const LoginOffline(),
        ),
      );
      expect(find.byType(App), findsOneWidget);
    });
  });

  group('Login form validation', () {
    testWidgets('Render form', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      expect(find.byType(WebDAVLoginView), findsOneWidget);
    });
    testWidgets('Missing base url', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Missing base URL'), findsOneWidget);
    });
    testWidgets('Missing username', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Missing username'), findsOneWidget);
    });
    testWidgets('Missing password', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Missing password'), findsOneWidget);
    });
    testWidgets('Missing server address', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Missing server address'), findsOneWidget);
    });
    testWidgets('Missing protocol', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.enterText(
        find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        ),
        "localhost",
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Missing protocol'), findsOneWidget);
    });
    testWidgets('Missing server port (http)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.enterText(
        find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        ),
        "http://localhost",
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Missing server port'), findsOneWidget);
    });
    testWidgets('Missing server port (https)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.enterText(
        find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        ),
        "https://localhost",
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Missing server port'), findsOneWidget);
    });
    testWidgets('Invalid format (port is string)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.enterText(
        find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        ),
        "https://localhost:abc",
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Invalid format'), findsOneWidget);
    });
    testWidgets('Invalid format (multiple ports)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          debugShowCheckedModeBanner: false,
          home: WebDAVLoginView(),
        ),
      );
      await tester.enterText(
        find.ancestor(
          of: find.text('Server'),
          matching: find.byType(TextFormField),
        ),
        "https://localhost:80:90",
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Invalid format'), findsOneWidget);
    });
  });
}
