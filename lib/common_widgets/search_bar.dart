import 'package:flutter/material.dart';

class GenericSearchBar extends StatelessWidget {
  const GenericSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(8.0),
      child: SearchBar(),
    );
  }
}
