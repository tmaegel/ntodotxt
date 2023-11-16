import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ntodotxt/common_widgets/app_bar.dart';
import 'package:ntodotxt/oss_licenses.dart';

class LicenceListPage extends StatelessWidget {
  const LicenceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MainAppBar(
        title: "Licenses",
        leadingAction: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: const LicenseListView(),
    );
  }
}

class LicenseListView extends StatelessWidget {
  const LicenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: ossLicenses.length,
      itemBuilder: (BuildContext context, int index) {
        Package package = ossLicenses[index];
        return ListTile(
          title: Text(package.name),
          subtitle: Text(
            package.repository ?? (package.homepage ?? ''),
            style: const TextStyle(color: Colors.grey),
          ),
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
      appBar: MainAppBar(
        title: title,
        leadingAction: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
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
