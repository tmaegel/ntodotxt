import 'package:equatable/equatable.dart';

final class SettingsState extends Equatable {
  /// Todo filter.
  /// Defaults to 'all'.
  final String todoFilter;

  /// Todo order.
  /// Defaults to 'ascending'.
  final String todoOrder;

  /// Group todos by criteria.
  /// Defaults to 'none'.
  final String todoGrouping;

  const SettingsState({
    this.todoFilter = 'all',
    this.todoOrder = 'ascending',
    this.todoGrouping = 'none',
  });

  SettingsState copyWith({
    String? todoFilter,
    String? todoOrder,
    String? todoGrouping,
  }) {
    return SettingsState(
      todoFilter: todoFilter ?? this.todoFilter,
      todoOrder: todoOrder ?? this.todoOrder,
      todoGrouping: todoGrouping ?? this.todoGrouping,
    );
  }

  @override
  List<Object?> get props => [
        todoFilter,
        todoOrder,
        todoGrouping,
      ];

  @override
  String toString() => 'SettingsState { }';
}
