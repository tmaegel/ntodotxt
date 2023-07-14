import 'package:flutter/material.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(title: 'Settings', showToolBar: false),
      body: Center(
        child: Text('Settings page'),
      ),
    );
  }
}
