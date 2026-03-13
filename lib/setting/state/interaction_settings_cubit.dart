import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/setting/model/setting_model.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:ntodotxt/setting/state/interaction_settings_state.dart';

class InteractionSettingsCubit extends Cubit<InteractionSettingsState> {
  final SettingRepository repository;

  InteractionSettingsCubit({
    required this.repository,
  }) : super(
          InteractionSettingsLoading(
            swipeLeftActionEnabled: false,
            swipeRightActionEnabled: false,
          ),
        );

  bool parseBoolOrFalse(String? value) {
    return value?.trim().toLowerCase() == 'true';
  }

  Future<void> load() async {
    try {
      if (state is InteractionSettingsLoading) {
        emit(
          state.save(
            swipeLeftActionEnabled: parseBoolOrFalse(
                (await repository.get(key: 'swipeLeftActionEnabled'))?.value),
            swipeRightActionEnabled: parseBoolOrFalse(
                (await repository.get(key: 'swipeRightActionEnabled'))?.value),
          ),
        );
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> setSwipeLeftActionEnabled(bool value) async {
    try {
      emit(state.save(swipeLeftActionEnabled: value));
      await repository.updateOrInsert(
        Setting(key: 'swipeLeftActionEnabled', value: value.toString()),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> setSwipeRightActionEnabled(bool value) async {
    try {
      emit(state.save(swipeRightActionEnabled: value));
      await repository.updateOrInsert(
        Setting(key: 'swipeRightActionEnabled', value: value.toString()),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
