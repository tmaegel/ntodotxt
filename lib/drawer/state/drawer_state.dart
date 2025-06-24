import 'package:equatable/equatable.dart';

final class DrawerState extends Equatable {
  final int index;
  final int? prevIndex;

  const DrawerState({
    required this.index,
    this.prevIndex,
  });

  @override
  List<Object?> get props => [
        index,
        prevIndex,
      ];

  @override
  String toString() => 'DrawerState { index: $index prevIndex: $prevIndex }';
}
