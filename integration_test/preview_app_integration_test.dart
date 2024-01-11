import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

class AppPreview extends StatelessWidget {
  final String image;
  final String message;
  final Color foregroundColor = Colors.white;
  final Color backgroundColor = Colors.lightBlue[100]!;
  final Color deviceFrameColor = Colors.blueGrey;

  AppPreview({
    required this.image,
    required this.message,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: backgroundColor,
        body: Container(
          padding: const EdgeInsets.only(bottom: 24.0),
          child: Column(
            children: [
              Flexible(
                flex: 1,
                child: Center(
                  child: Text(
                    message,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ),
              Flexible(
                flex: 6,
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: deviceFrameColor,
                        border: Border.all(
                          width: 12,
                          color: deviceFrameColor,
                        ),
                        borderRadius: BorderRadius.circular(34),
                      ),
                      child: Stack(
                        alignment: Alignment.topLeft,
                        children: [
                          Stack(
                            alignment: Alignment.topRight,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  image,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.signal_wifi_4_bar,
                                      color: foregroundColor,
                                      size: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize,
                                    ),
                                    Icon(
                                      Icons.signal_cellular_4_bar,
                                      color: foregroundColor,
                                      size: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize,
                                    ),
                                    const SizedBox(width: 2.0),
                                    Icon(
                                      Icons.battery_full,
                                      color: foregroundColor,
                                      size: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.fontSize,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 8.0),
                            child: Text(
                              '12:00',
                              style: TextStyle(
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.fontSize,
                                color: foregroundColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() async {
  const String repoUrl =
      'https://raw.githubusercontent.com/tmaegel/ntodotxt/HEAD/';
  final IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  // Hide android status bar.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

  group('dark mode', () {
    group('create app store preview screenshots', () {
      testWidgets('of todo list (default)', (tester) async {
        await tester.pumpWidget(
          AppPreview(
            message: 'Compact overview of all todos',
            image: '$repoUrl/screenshots/phone/1.png',
          ),
        );
        // Ensure the image is loaded/displayed.
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('preview/1');
      });
      testWidgets('of todo list (with open drawer)', (tester) async {
        await tester.pumpWidget(
          AppPreview(
            message: 'Custom filters',
            image: '$repoUrl/screenshots/phone/2.png',
          ),
        );
        // Ensure the image is loaded/displayed.
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('preview/2');
      });
      testWidgets('of todo edit page', (tester) async {
        await tester.pumpWidget(
          AppPreview(
            message: 'Edit and create todos',
            image: '$repoUrl/screenshots/phone/3.png',
          ),
        );
        // Ensure the image is loaded/displayed.
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('preview/3');
      });
      testWidgets('of filter list (default)', (tester) async {
        await tester.pumpWidget(
          AppPreview(
            message: 'Compact overview of all filters',
            image: '$repoUrl/screenshots/phone/4.png',
          ),
        );
        // Ensure the image is loaded/displayed.
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('preview/4');
      });
      testWidgets('of filter edit page', (tester) async {
        await tester.pumpWidget(
          AppPreview(
            message: 'Edit and create filters',
            image: '$repoUrl/screenshots/phone/5.png',
          ),
        );
        // Ensure the image is loaded/displayed.
        await tester.pumpAndSettle(const Duration(milliseconds: 5000));

        await binding.convertFlutterSurfaceToImage();
        await tester.pumpAndSettle();
        await binding.takeScreenshot('preview/5');
      });
    });
  });
}
