import 'package:flutter/material.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/oss_licenses.dart';

class LicenceListPage extends StatelessWidget {
  const LicenceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MainAppBar(title: 'Licenses'),
      body: LicenseListView(),
    );
  }
}

class LicenseListView extends StatelessWidget {
  const LicenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      itemCount: ossLicenses.length,
      itemBuilder: (BuildContext context, int index) {
        Package package = ossLicenses[index];
        return ListTile(
          title: Text(package.name),
          subtitle: Text(package.repository ?? (package.homepage ?? '')),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return LicenceDetailPage(
                    title: package.name,
                    licence: package.license ?? package.description,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}

class LicenceDetailPage extends StatelessWidget {
  final String title;
  final String licence;

  const LicenceDetailPage({
    super.key,
    required this.title,
    required this.licence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(title: title),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                Text(licence),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
