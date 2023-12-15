import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';

void main() {
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
        'localhost',
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
        'http://localhost',
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
        'https://localhost',
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
        'https://localhost:abc',
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
        'https://localhost:80:90',
      );
      await tester.tap(find.text('Login'));
      await tester.pump();
      expect(find.text('Invalid format'), findsOneWidget);
    });
  });
}
