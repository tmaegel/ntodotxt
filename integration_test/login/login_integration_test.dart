import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ntodotxt/main.dart';
import 'package:ntodotxt/presentation/intro/page/intro_page.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
  );

  final String appCacheDir = (await getApplicationCacheDirectory()).path;

  group('login', () {
    group('initial', () {
      testWidgets('screen is visible', (tester) async {
        await tester.pumpWidget(
          App(appCacheDir: appCacheDir),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));
        expect(find.byType(IntroPage), findsOneWidget);
      });
    });

    group('local', () {
      testWidgets('default local path', (tester) async {
        await tester.pumpWidget(
          App(appCacheDir: appCacheDir),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));
        expect(find.byType(IntroPage), findsOneWidget);
        await tester.tap(find.text('Local'));
        await tester.pumpAndSettle();
        expect(find.byType(LocalLoginView), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                widget.title is Text &&
                (widget.title as Text).data == 'Local path' &&
                widget.subtitle != null &&
                (widget.subtitle as Text).data == appCacheDir,
          ),
          findsOneWidget,
        );
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();
        expect(find.byType(App), findsOneWidget);

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();
        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('Reset and logout'), 500);
        await tester.tap(find.text('Reset and logout'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Logout'),
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));
        expect(find.byType(IntroPage), findsOneWidget);
      });
    });

    group('webdav', () {
      testWidgets('default local path', (tester) async {
        await tester.pumpWidget(
          App(appCacheDir: appCacheDir),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));
        expect(find.byType(IntroPage), findsOneWidget);
        await tester.tap(find.text('WebDAV'));
        await tester.pumpAndSettle();
        expect(find.byType(WebDAVLoginView), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (Widget widget) =>
                widget is ListTile &&
                widget.title is Text &&
                (widget.title as Text).data == 'Local path' &&
                widget.subtitle != null &&
                (widget.subtitle as Text).data == appCacheDir,
          ),
          findsOneWidget,
        );

        await tester.enterText(
          find.ancestor(
            of: find.text('Server'),
            matching: find.byType(TextFormField),
          ),
          'http://10.0.2.2',
        );
        await tester.enterText(
          find.ancestor(
            of: find.text('Base URL'),
            matching: find.byType(TextFormField),
          ),
          '/remote.php/dav/files',
        );
        await tester.enterText(
          find.ancestor(
            of: find.text('Username'),
            matching: find.byType(TextFormField),
          ),
          'test',
        );
        await tester.enterText(
          find.ancestor(
            of: find.text('Password'),
            matching: find.byType(TextFormField),
          ),
          'test',
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(AppBar));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Login'));
        await tester.pumpAndSettle();
        expect(find.byType(App), findsOneWidget);

        await tester.tap(find.byTooltip('Open drawer'));
        await tester.pumpAndSettle();
        await tester.drag(
            find.byType(DraggableScrollableSheet), const Offset(0, -500));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(find.text('Reset and logout'), 500);
        await tester.tap(find.text('Reset and logout'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.text('Logout'),
          ),
        );
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));
        expect(find.byType(IntroPage), findsOneWidget);
      });
    });
  });
}
