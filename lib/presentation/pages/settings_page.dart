import 'package:flutter/material.dart';
import 'package:todotxt/constants/screen.dart';
import 'package:todotxt/presentation/widgets/app_bar.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: screenWidth < maxScreenWidthCompact
          ? const MainAppBar(title: 'Settings', showToolBar: false)
          : null,
      body: const Center(
        child: Text('Settings page'),
      ),
    );
  }
}
