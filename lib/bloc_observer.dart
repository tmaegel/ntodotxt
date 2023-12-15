// coverage:ignore-file

import 'package:flutter_bloc/flutter_bloc.dart'
    show Bloc, BlocBase, BlocObserver, Change, Transition;
import 'package:ntodotxt/main.dart' show log;

class GenericBlocObserver extends BlocObserver {
  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    log.fine(
        'STATE CHANGE: ${change.currentState.runtimeType} > ${change.nextState.runtimeType}');
    log.finer('${bloc.runtimeType} $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    log.finest('${bloc.runtimeType} $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    log.fine('${bloc.runtimeType} $error $stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
