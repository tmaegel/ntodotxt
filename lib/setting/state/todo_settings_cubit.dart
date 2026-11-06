import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/setting/model/setting_model.dart';
import 'package:ntodotxt/setting/repository/setting_repository.dart';
import 'package:ntodotxt/setting/state/todo_settings_state.dart';

class TodoSettingsCubit extends Cubit<TodoSettingsState> {
  final SettingRepository repository;

  TodoSettingsCubit({
    required this.repository,
  }) : super(
         TodoSettingsLoading(
           autoCreationDateEnabled: false,
         ),
       );

  bool parseBoolOrFalse(String? value) {
    return value?.trim().toLowerCase() == 'true';
  }

  Future<void> load() async {
    try {
      if (state is TodoSettingsLoading) {
        emit(
          state.save(
            autoCreationDateEnabled: parseBoolOrFalse(
              (await repository.get(key: 'autoCreationDateEnabled'))?.value,
            ),
          ),
        );
      }
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }

  Future<void> setAutoCreationDateEnabled(bool value) async {
    try {
      emit(state.save(autoCreationDateEnabled: value));
      await repository.updateOrInsert(
        Setting(key: 'autoCreationDateEnabled', value: value.toString()),
      );
    } on Exception catch (e) {
      emit(state.error(message: e.toString()));
    }
  }
}
