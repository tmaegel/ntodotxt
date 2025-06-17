import 'package:flutter/material.dart';

class ScollToTopView extends StatefulWidget {
  const ScollToTopView({super.key});

  @override
  State<ScollToTopView> createState() => ScollToTopViewState();
}

class ScollToTopViewState<T extends ScollToTopView> extends State<T> {
  bool scrolledDown = false;
  late ScrollController scrollController;

  @override
  void initState() {
    scrollController = ScrollController()
      ..addListener(
        () {
          setState(() {
            if (scrollController.offset >= 50) {
              scrolledDown = true;
            } else {
              scrolledDown = false;
            }
          });
        },
      );
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToTop() {
    scrollController.animateTo(0,
        duration: const Duration(milliseconds: 250), curve: Curves.linear);
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
