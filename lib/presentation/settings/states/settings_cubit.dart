import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/settings/states/settings_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  SettingsCubit({required this.prefs}) : super(const SettingsState()) {
    loadPrefs();
  }

  void loadPrefs() {
    emit(
      state.copyWith(
        todoFilename: prefs.getString('todoFilename'),
        doneFilename: prefs.getString('doneFilename'),
        autoArchive: prefs.getBool('autoArchive'),
      ),
    );
  }

  void updateTodoFilename(String? value) async {
    if (value != null) {
      if (value.isNotEmpty) {
        await prefs.setString('todoFilename', value);
        emit(state.copyWith(todoFilename: value));
      }
    }
  }

  void updateDoneFilename(String? value) async {
    if (value != null) {
      if (value.isNotEmpty) {
        await prefs.setString('doneFilename', value);
        emit(state.copyWith(doneFilename: value));
      }
    }
  }

  void toggleAutoArchive(bool value) async {
    await prefs.setBool('autoArchive', value);
    emit(state.copyWith(autoArchive: value));
  }
}
