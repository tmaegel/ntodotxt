import 'package:equatable/equatable.dart';

sealed class TodoSettingsState extends Equatable {
  final bool autoCreationDateEnabled;

  const TodoSettingsState({
    required this.autoCreationDateEnabled,
  });

  TodoSettingsLoading loading({
    bool? autoCreationDateEnabled,
  }) {
    return TodoSettingsLoading(
      autoCreationDateEnabled:
          autoCreationDateEnabled ?? this.autoCreationDateEnabled,
    );
  }

  TodoSettingsSaved save({
    bool? autoCreationDateEnabled,
  }) {
    return TodoSettingsSaved(
      autoCreationDateEnabled:
          autoCreationDateEnabled ?? this.autoCreationDateEnabled,
    );
  }

  TodoSettingsError error({
    required String message,
    bool? autoCreationDateEnabled,
  }) {
    return TodoSettingsError(
      message: message,
      autoCreationDateEnabled:
          autoCreationDateEnabled ?? this.autoCreationDateEnabled,
    );
  }

  @override
  List<Object?> get props => [
    autoCreationDateEnabled,
  ];

  @override
  String toString() =>
      'TodoSettingsState { autoCreationDateEnabled: $autoCreationDateEnabled }';
}

final class TodoSettingsLoading extends TodoSettingsState {
  const TodoSettingsLoading({
    required super.autoCreationDateEnabled,
  });

  TodoSettingsLoading copyWith({
    bool? autoCreationDateEnabled,
  }) => super.loading(
    autoCreationDateEnabled:
        autoCreationDateEnabled ?? this.autoCreationDateEnabled,
  );

  @override
  String toString() =>
      'TodoSettingsLoading { autoCreationDateEnabled: $autoCreationDateEnabled }';
}

final class TodoSettingsSaved extends TodoSettingsState {
  const TodoSettingsSaved({
    required super.autoCreationDateEnabled,
  });

  TodoSettingsSaved copyWith({
    bool? autoCreationDateEnabled,
  }) => super.save(
    autoCreationDateEnabled:
        autoCreationDateEnabled ?? this.autoCreationDateEnabled,
  );

  @override
  String toString() =>
      'TodoSettingsSaved { autoCreationDateEnabled: $autoCreationDateEnabled }';
}

final class TodoSettingsError extends TodoSettingsState {
  final String message;

  const TodoSettingsError({
    required this.message,
    required super.autoCreationDateEnabled,
  });

  TodoSettingsError copyWith({
    String? message,
    bool? autoCreationDateEnabled,
  }) => super.error(
    message: message ?? this.message,
    autoCreationDateEnabled:
        autoCreationDateEnabled ?? this.autoCreationDateEnabled,
  );

  @override
  List<Object?> get props => [
    message,
    autoCreationDateEnabled,
  ];

  @override
  String toString() =>
      'TodoSettingsError { message: $message, autoCreationDateEnabled: $autoCreationDateEnabled }';
}
