import 'package:flutter/material.dart';
import 'package:ntodotxt/common/widget/app_bar.dart';
import 'package:ntodotxt/oss_licenses.dart';

class LicenceListPage extends StatelessWidget {
  const LicenceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: CustomScrollView(
        slivers: [
          MainSliverAppBar(title: 'Licenses'),
          LicenseListView(),
        ],
      ),
    );
  }
}

class LicenseListView extends StatelessWidget {
  const LicenseListView({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          Package package = allDependencies[index];
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
      ),
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
      body: CustomScrollView(
        slivers: [
          MainSliverAppBar(title: title),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Text(licence),
            ),
          ),
        ],
      ),
    );
  }
}
