import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';

import 'package:url_launcher/url_launcher.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "About",
        leadingAction: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _cancelAction(context),
        ),
      ),
      body: const AppInfoView(),
    );
  }

  void _cancelAction(BuildContext context) => context.pop();
}

class AppInfoView extends StatelessWidget {
  static const String repoUrl = "https://github.com/tmaegel/ntodo-txt";

  const AppInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.update),
          title: const Text('ntodotxt'),
          subtitle: const Text('Version 0.0.1'),
          onTap: () => _openUrl('$repoUrl/blob/main/CHANGELOG.md'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('Source code'),
          subtitle: const Text(repoUrl),
          onTap: () => _openUrl(repoUrl),
        ),
        ListTile(
          leading: const Icon(Icons.bug_report),
          title: const Text('Issue tracker'),
          subtitle: const Text('$repoUrl/issues'),
          onTap: () => _openUrl('$repoUrl/issues'),
        ),
        ListTile(
          leading: const Icon(Icons.email),
          title: const Text('Contact me'),
          subtitle: const Text('mail@tonimaegel.de'),
          onTap: () => _openUrl('mailto:mail@tonimaegel.de'),
        ),
        ListTile(
          leading: const Icon(Icons.policy),
          title: const Text('Licence'),
          subtitle: const Text('MIT License'),
          onTap: () => _openUrl('$repoUrl/blob/main/LICENSE'),
        ),
      ],
    );
  }

  Future<void> _openUrl(String urlStr) async {
    final Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url)) {
      throw Exception('Could not open $urlStr');
    }
  }
}
