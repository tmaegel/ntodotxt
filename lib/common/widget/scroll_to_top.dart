import 'package:flutter/material.dart';

class ScollToTopView extends StatefulWidget {
  const ScollToTopView({super.key});

  @override
  State<ScollToTopView> createState() => ScollToTopViewState();
}

class ScollToTopViewState<T extends ScollToTopView> extends State<T> {
  bool scrolledDown = false;
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController()..addListener(_onScroll);
  }

  @override
  void dispose() {
    scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShow = scrollController.offset >= 50;
    if (scrolledDown != shouldShow) {
      setState(() {
        scrolledDown = shouldShow;
      });
    }
  }

  void scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
