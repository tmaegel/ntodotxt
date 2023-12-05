import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/presentation/settings/states/settings_state.dart';
import 'package:ntodotxt/presentation/todo/states/todo_list_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsCubit extends Cubit<SettingsState> {
  final SharedPreferences prefs;

  SettingsCubit({
    required this.prefs,
  }) : super(const SettingsState()) {
    loadPrefs();
  }

  void loadPrefs() {
    emit(
      state.copyWith(
        // Display
        todoFilter: prefs.getString('todoFilter'),
        todoOrder: prefs.getString('todoOrder'),
        todoGrouping: prefs.getString('todoGrouping'),
      ),
    );
  }

  void resetSettings() {
    final List<String> settings = [
      'todoFilter',
      'todoOrder',
      'todoGrouping',
    ];
    for (var setting in settings) {
      prefs.remove(setting);
    }
    emit(const SettingsState());
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
