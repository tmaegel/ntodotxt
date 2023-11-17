import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/settings/states/settings_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  SettingsCubit({required this.prefs}) : super(const SettingsState()) {
    loadPrefs();
  }

  void loadPrefs() {
    emit(
      state.copyWith(
        // Todo
        todoFilename: prefs.getString('todoFilename'),
        doneFilename: prefs.getString('doneFilename'),
        autoArchive: prefs.getBool('autoArchive'),
        // Display
        todoFilter: prefs.getString('todoFilter'),
        todoOrder: prefs.getString('todoOrder'),
        todoGrouping: prefs.getString('todoGrouping'),
      ),
    );
  }

  void resetSettings() {
    final List<String> settings = [
      'todoFilename',
      'doneFilename',
      'autoArchive',
      'todoFilter',
      'todoOrder',
      'todoGrouping',
    ];
    for (var setting in settings) {
      prefs.remove(setting);
    }
    emit(const SettingsState());
  }

  void updateTodoFilename(String? value) {
    if (value != null) {
      if (value.isNotEmpty) {
        prefs.setString('todoFilename', value);
        emit(state.copyWith(todoFilename: value));
      }
    }
  }

  void updateDoneFilename(String? value) {
    if (value != null) {
      if (value.isNotEmpty) {
        prefs.setString('doneFilename', value);
        emit(state.copyWith(doneFilename: value));
      }
    }
  }

  void toggleAutoArchive(bool value) {
    prefs.setBool('autoArchive', value);
    emit(state.copyWith(autoArchive: value));
  }

  void updateTodoFilter(TodoListFilter? value) {
    if (value != null) {
      prefs.setString('todoFilter', value.name);
      emit(state.copyWith(todoFilter: value.name));
    }
  }

  void updateTodoOrder(TodoListOrder? value) {
    if (value != null) {
      prefs.setString('todoOrder', value.name);
      emit(state.copyWith(todoOrder: value.name));
    }
  }

  void updateTodoGrouping(TodoListGroupBy? value) {
    if (value != null) {
      prefs.setString('todoGrouping', value.name);
      emit(state.copyWith(todoGrouping: value.name));
    }
  }
}
