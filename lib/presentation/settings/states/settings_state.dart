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

  const SettingsState({
    this.todoFilename = 'todo.txt',
    this.doneFilename = 'done.txt',
    this.autoArchive = false,
  });

  SettingsState copyWith({
    String? todoFilename,
    String? doneFilename,
    bool? autoArchive,
  }) {
    return SettingsState(
      todoFilename: todoFilename ?? this.todoFilename,
      doneFilename: doneFilename ?? this.doneFilename,
      autoArchive: autoArchive ?? this.autoArchive,
    );
  }

  @override
  List<Object?> get props => [
        todoFilename,
        doneFilename,
        autoArchive,
      ];

  @override
  String toString() => 'SettingsState { }';
}
