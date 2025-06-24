import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/drawer/state/drawer_cubit.dart';
import 'package:ntodotxt/drawer/state/drawer_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {});

  group('initial', () {
    test('initial state', () {
      final DrawerCubit cubit = DrawerCubit();
      expect(cubit.state, const DrawerState(index: 0));
    });
  });

  group('next()', () {
    test('call one time next()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      expect(cubit.state, const DrawerState(index: 9, prevIndex: 0));
    });
    test('call two times next()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      expect(cubit.state, const DrawerState(index: 2, prevIndex: 9));
    });
  });

  group('back()', () {
    test('call two times next() and one time back()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      cubit.back();
      expect(cubit.state, const DrawerState(index: 9, prevIndex: null));
    });
    test('call two times next() and two time back()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      cubit.back();
      cubit.back();
      expect(cubit.state, const DrawerState(index: 0, prevIndex: null));
    });
  });

  group('reset()', () {
    test('call two times next() and one time reset()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      cubit.reset();
      expect(cubit.state, const DrawerState(index: 0, prevIndex: null));
    });
  });

  group('toString()', () {
    test('default', () {
      const DrawerState state = DrawerState(index: 99, prevIndex: 0);
      expect(
        state.toString(),
        'DrawerState { index: 99 prevIndex: 0 }',
      );
    });
  });
}
