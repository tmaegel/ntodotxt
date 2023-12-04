import 'package:equatable/equatable.dart';

final class SettingsState extends Equatable {
  /// File name  of file in which todos are stored.
  /// Defaults to 'todo.txt'.
  final String todoFilename;

  /// File name  of file in which archived/completed todos are stored.
  /// Defaults to 'done.txt'.
  final String doneFilename;

  /// Automatically archive completed todos to the done.txt file.
  /// Defaults to false.
  final bool autoArchive;

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
    this.todoFilename = 'todo.txt',
    this.doneFilename = 'done.txt',
    this.autoArchive = false,
    this.todoFilter = 'all',
    this.todoOrder = 'ascending',
    this.todoGrouping = 'none',
  });

  SettingsState copyWith({
    String? todoFilename,
    String? doneFilename,
    bool? autoArchive,
    String? todoFilter,
    String? todoOrder,
    String? todoGrouping,
  }) {
    return SettingsState(
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      autoArchive: autoArchive ?? this.autoArchive,
      todoFilter: todoFilter ?? this.todoFilter,
      todoOrder: todoOrder ?? this.todoOrder,
      todoGrouping: todoGrouping ?? this.todoGrouping,
    );
  }

  @override
  List<Object?> get props => [
        todoFilename,
        doneFilename,
        autoArchive,
        todoFilter,
        todoOrder,
        todoGrouping,
      ];

  @override
  String toString() => 'SettingsState { }';
}
