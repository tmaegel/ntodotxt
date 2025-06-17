import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common/constants/app.dart';
import 'package:ntodotxt/common/widget/app_bar.dart';
import 'package:url_launcher/url_launcher.dart';

class AppInfoPage extends StatelessWidget {
  const AppInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(title: 'About'),
      body: AppInfoView(),
    );
  }
}

class AppInfoView extends StatelessWidget {
  static const String repoUrl = 'https://github.com/tmaegel/ntodotxt';

  const AppInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: const Icon(Icons.update),
          title: const Text('Version'),
          subtitle: const Text('v$version'),
          onTap: () => _openUrl('$repoUrl/blob/main/CHANGELOG.md'),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: const Icon(Icons.code),
          title: const Text('Source code'),
          subtitle: const Text(repoUrl),
          onTap: () => _openUrl(repoUrl),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: const Icon(Icons.bug_report_outlined),
          title: const Text('Issue tracker'),
          subtitle: const Text('$repoUrl/issues'),
          onTap: () => _openUrl('$repoUrl/issues'),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: const Icon(Icons.email_outlined),
          title: const Text('Contact me'),
          subtitle: const Text('tnmgl@posteo.de'),
          onTap: () => _openUrl('mailto:tnmgl@posteo.de'),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: const Icon(Icons.volunteer_activism),
          title: const Text('Donation'),
          subtitle: const Text('Support this app'),
          onTap: () => _openUrl('https://ko-fi.com/tnmgl'),
        ),
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
          leading: const Icon(Icons.shield_outlined),
          title: const Text('Licence'),
          subtitle: const Text('MIT License'),
          onTap: () => context.pushNamed('licenses'),
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
