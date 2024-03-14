import 'package:flutter/material.dart';
import 'package:ntodotxt/presentation/login/pages/login_page.dart';
import 'package:url_launcher/url_launcher.dart';

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}

class _IntroPageState extends State<IntroPage> {
  int _currentPage = 0;

  final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> pages = [
    const IntroPageWelcome(),
    IntroPageLocal(),
    IntroPageWebDav(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (int page) {
          setState(() {
            _currentPage = page;
          });
        },
        children: pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 30,
            bottom: 20,
            child: IconButton(
              tooltip: 'Previous page',
              icon: const Icon(
                Icons.navigate_before,
                size: 40,
              ),
              onPressed: _currentPage > 0
                  ? () {
                      setState(() {
                        _currentPage -= 1;
                      });
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  : null,
            ),
          ),
          Positioned(
            bottom: 20,
            right: 30,
            child: IconButton(
              tooltip: 'Next page',
              icon: const Icon(
                Icons.navigate_next,
                size: 40,
              ),
              onPressed: _currentPage < pages.length - 1
                  ? () {
                      setState(() {
                        _currentPage += 1;
                      });
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class IntroPageWelcome extends StatelessWidget {
  const IntroPageWelcome({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          Text(
            '''This app is based on the todo.txt format.
If you don't know what this is, you can find out more about the format below.''',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            child: const Text('todo.txt format'),
            onPressed: () async {
              const String urlStr = 'https://github.com/todotxt/todo.txt';
              final Uri url = Uri.parse(urlStr);
              if (!await launchUrl(url)) {
                throw Exception('Could not open $urlStr');
              }
            },
          ),
          const SizedBox(height: 24),
          Text(
            'You can use this app in different ways. Find out more on the following pages.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}

class IntroPageLocal extends StatelessWidget {
  IntroPageLocal({super.key});

  final List<(String, TextStyle?)> content = [
    ('Use this app in ', null),
    ('local', const TextStyle(fontWeight: FontWeight.bold)),
    (' or ', null),
    ('cloudless', const TextStyle(fontWeight: FontWeight.bold)),
    (' mode.', null),
    (
      '\nIn this mode, the app manages your todos locally only. This means that the app only reads and writes your todos from and to your todo file on your device.',
      null
    ),
    (
      '\n\nUse this option if you don\'t need synchronisation across multiple devices, or if you have an external app that takes care of syncing the folder (e.g. Syncthing, Nextcloud, etc.).',
      null
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Local',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              text: '',
              children: <TextSpan>[
                for ((String, TextStyle?) item in content)
                  TextSpan(text: item.$1, style: item.$2),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            child: const Text('Use local mode'),
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => const LocalLoginView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class IntroPageWebDav extends StatelessWidget {
  IntroPageWebDav({super.key});

  final List<(String, TextStyle?)> content = [
    ('Use this app in ', null),
    ('webdav', const TextStyle(fontWeight: FontWeight.bold)),
    (' or ', null),
    ('cloud', const TextStyle(fontWeight: FontWeight.bold)),
    (' mode.', null),
    (
      '\nIn this mode, the app manages your todos with a webdav server of your choice. This means that the app reads and writes your todos from and to your todo file on your device and synchronizes this file with your backend server.',
      null
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'WebDAV',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 24),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              text: '',
              children: <TextSpan>[
                for ((String, TextStyle?) item in content)
                  TextSpan(text: item.$1, style: item.$2),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            child: const Text('Use webdav mode'),
            onPressed: () async {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => const WebDAVLoginView(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
