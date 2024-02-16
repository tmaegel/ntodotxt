import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ntodotxt/domain/settings/setting_model.dart' show Setting;
import 'package:ntodotxt/domain/settings/setting_repository.dart'
    show SettingRepository;
import 'package:ntodotxt/presentation/todo_file/todo_file_state.dart';
import 'package:path_provider/path_provider.dart';

class TodoFileCubit extends Cubit<TodoFileState> {
  final SettingRepository _repository;

  TodoFileCubit({
    required SettingRepository repository,
    TodoFileState? state,
  })  : _repository = repository,
        super(state ?? const TodoFileLoading());

  Future<void> initial() async {
    if (state is TodoFileLoading) {
      // Use app caches directory as default.
      String appCacheDir = (await getApplicationCacheDirectory()).path;
      emit(
        state.copyWith(
          localPath: (await _repository.getOrInsert(
                  key: 'localPath', defaultValue: appCacheDir))
              .value,
          remotePath: (await _repository.getOrInsert(
                  key: 'remotePath', defaultValue: '/'))
              .value,
        ),
      );
    }
  }

  Future<void> updateLocalPath(String? value) async {
    if (value != null) {
      emit(
        state.copyWith(
          localPath: value,
        ),
      );
      await _repository.updateOrInsert(
        Setting(key: 'localPath', value: value),
      );
    }
  }

  Future<void> updateRemotePath(String? value) async {
    if (value != null) {
      emit(
        state.copyWith(
          remotePath: value,
        ),
      );
      await _repository.updateOrInsert(
        Setting(key: 'remotePath', value: value),
      );
    }
  }
}
