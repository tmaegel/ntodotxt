import 'package:flutter/material.dart';

class BottomSheetPage<T> extends Page<T> {
  final Widget child;

  const BottomSheetPage({
    required this.child,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
        context: context,
        settings: this,
        builder: (context) => BottomSheet(
          enableDrag: false,
          showDragHandle: false,
          onClosing: () {},
          builder: (context) {
            return Container(
              // width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.9,
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: child,
              ),
            );
          },
        ),
      );
}

class DialogPage<T> extends Page<T> {
  final Widget child;

  const DialogPage({
    required this.child,
    super.key,
  });

  @override
  Route<T> createRoute(BuildContext context) => DialogRoute<T>(
        context: context,
        settings: this,
        builder: (context) => Dialog(
          child: Container(
            // width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.9,
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: child,
            ),
          ),
        ),
      );
}
