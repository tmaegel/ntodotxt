import 'package:equatable/equatable.dart';

sealed class InteractionSettingsState extends Equatable {
  final bool swipeLeftActionEnabled;
  final bool swipeRightActionEnabled;

  const InteractionSettingsState({
    required this.swipeLeftActionEnabled,
    required this.swipeRightActionEnabled,
  });

  InteractionSettingsLoading loading({
    bool? swipeLeftActionEnabled,
    bool? swipeRightActionEnabled,
  }) {
    return InteractionSettingsLoading(
      swipeLeftActionEnabled:
          swipeLeftActionEnabled ?? this.swipeLeftActionEnabled,
      swipeRightActionEnabled:
          swipeRightActionEnabled ?? this.swipeRightActionEnabled,
    );
  }

  InteractionSettingsSaved save({
    bool? swipeLeftActionEnabled,
    bool? swipeRightActionEnabled,
  }) {
    return InteractionSettingsSaved(
      swipeLeftActionEnabled:
          swipeLeftActionEnabled ?? this.swipeLeftActionEnabled,
      swipeRightActionEnabled:
          swipeRightActionEnabled ?? this.swipeRightActionEnabled,
    );
  }

  InteractionSettingsError error({
    required String message,
    bool? swipeLeftActionEnabled,
    bool? swipeRightActionEnabled,
  }) {
    return InteractionSettingsError(
      message: message,
      swipeLeftActionEnabled:
          swipeLeftActionEnabled ?? this.swipeLeftActionEnabled,
      swipeRightActionEnabled:
          swipeRightActionEnabled ?? this.swipeRightActionEnabled,
    );
  }

  @override
  List<Object?> get props => [
        swipeLeftActionEnabled,
        swipeRightActionEnabled,
      ];

  @override
  String toString() =>
      'InteractionSettingsState { swipeLeftActionEnabled: $swipeLeftActionEnabled, swipeRightActionEnabled: $swipeRightActionEnabled }';
}

final class InteractionSettingsLoading extends InteractionSettingsState {
  const InteractionSettingsLoading({
    required super.swipeLeftActionEnabled,
    required super.swipeRightActionEnabled,
  });

  InteractionSettingsLoading copyWith({
    bool? swipeLeftActionEnabled,
    bool? swipeRightActionEnabled,
  }) =>
      super.loading(
        swipeLeftActionEnabled:
            swipeLeftActionEnabled ?? this.swipeLeftActionEnabled,
        swipeRightActionEnabled:
            swipeRightActionEnabled ?? this.swipeRightActionEnabled,
      );

  @override
  String toString() =>
      'InteractionSettingsLoading { swipeLeftActionEnabled: $swipeLeftActionEnabled, swipeRightActionEnabled: $swipeRightActionEnabled }';
}

final class InteractionSettingsSaved extends InteractionSettingsState {
  const InteractionSettingsSaved({
    required super.swipeLeftActionEnabled,
    required super.swipeRightActionEnabled,
  });

  InteractionSettingsSaved copyWith({
    bool? swipeLeftActionEnabled,
    bool? swipeRightActionEnabled,
  }) =>
      super.save(
        swipeLeftActionEnabled:
            swipeLeftActionEnabled ?? this.swipeLeftActionEnabled,
        swipeRightActionEnabled:
            swipeRightActionEnabled ?? this.swipeRightActionEnabled,
      );

  @override
  String toString() =>
      'InteractionSettingsSaved { swipeLeftActionEnabled: $swipeLeftActionEnabled, swipeRightActionEnabled: $swipeRightActionEnabled }';
}

final class InteractionSettingsError extends InteractionSettingsState {
  final String message;

  const InteractionSettingsError({
    required this.message,
    required super.swipeLeftActionEnabled,
    required super.swipeRightActionEnabled,
  });

  InteractionSettingsError copyWith({
    String? message,
    bool? swipeLeftActionEnabled,
    bool? swipeRightActionEnabled,
  }) =>
      super.error(
          message: message ?? this.message,
          swipeLeftActionEnabled:
              swipeLeftActionEnabled ?? this.swipeLeftActionEnabled,
          swipeRightActionEnabled:
              swipeRightActionEnabled ?? this.swipeRightActionEnabled);

  @override
  List<Object?> get props => [
        message,
        swipeLeftActionEnabled,
        swipeRightActionEnabled,
      ];

  @override
  String toString() =>
      'InteractionSettingsError { message: $message, swipeLeftActionEnabled: $swipeLeftActionEnabled, swipeRightActionEnabled: $swipeRightActionEnabled }';
}
