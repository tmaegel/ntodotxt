import 'package:equatable/equatable.dart';

final class SettingsState extends Equatable {
  /// Todo filter.
  /// Defaults to 'all'.
  final String todoFilter;

  /// Todo order.
  /// Defaults to 'ascending'.
  final String todoOrder;

  /// Group todos by criteria.
  /// Defaults to 'upcoming'.
  final String todoGrouping;

  /// File name  of file in which todos are stored.
  /// Defaults to 'todo.txt'.
  final String todoFilename;

  /// File name  of file in which archived/completed todos are stored.
  /// Defaults to 'done.txt'.
  final String doneFilename;

  /// Automatically archive completed todos to the done.txt file.
  /// Defaults to false.
  final bool autoArchive;

  const SettingsState({
    this.todoFilter = 'all',
    this.todoOrder = 'ascending',
    this.todoGrouping = 'upcoming',
    this.todoFilename = 'todo.txt',
    this.doneFilename = 'done.txt',
    this.autoArchive = false,
  });

  SettingsState copyWith({
    String? todoFilter,
    String? todoOrder,
    String? todoGrouping,
    String? todoFilename,
    String? doneFilename,
    bool? autoArchive,
  }) {
    return SettingsState(
      todoFilter: todoFilter ?? this.todoFilter,
      todoOrder: todoOrder ?? this.todoOrder,
      todoGrouping: todoGrouping ?? this.todoGrouping,
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      autoArchive: autoArchive ?? this.autoArchive,
    );
  }

  @override
  List<Object?> get props => [
        todoFilter,
        todoOrder,
        todoGrouping,
        todoFilename,
        doneFilename,
        autoArchive,
      ];

  @override
  String toString() => 'SettingsState { }';
}
