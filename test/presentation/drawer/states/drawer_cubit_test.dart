import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/presentation/drawer/states/drawer_cubit.dart';

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
      expect(cubit.state, const DrawerState(index: 9, prevIndices: [0]));
    });
    test('call two times next()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      expect(cubit.state, const DrawerState(index: 2, prevIndices: [0, 9]));
    });
  });

  group('back()', () {
    test('call two times next() and one time back()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      cubit.back();
      expect(cubit.state, const DrawerState(index: 9, prevIndices: [0]));
    });
    test('call two times next() and two time back()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      cubit.back();
      cubit.back();
      expect(cubit.state, const DrawerState(index: 0, prevIndices: []));
    });
  });

  group('reset()', () {
    test('call two times next() and one time reset()', () {
      final DrawerCubit cubit = DrawerCubit();
      cubit.next(9);
      cubit.next(2);
      cubit.reset();
      expect(cubit.state, const DrawerState(index: 0, prevIndices: []));
    });
  });

  group('copyWith()', () {
    test('empty index', () {
      const DrawerState state = DrawerState(index: 99);
      expect(state.copyWith().index, 99);
    });
    test('non empty index', () {
      const DrawerState state = DrawerState(index: 99);
      expect(state.copyWith(index: 42).index, 42);
    });
    test('empty prevIndices', () {
      const DrawerState state = DrawerState(index: 0, prevIndices: [1, 2, 3]);
      expect(state.copyWith().prevIndices, [1, 2, 3]);
    });
    test('non empty index', () {
      const DrawerState state = DrawerState(index: 0, prevIndices: [1, 2, 3]);
      expect(state.copyWith(prevIndices: [3, 2, 1]).prevIndices, [3, 2, 1]);
    });
  });

  group('toString()', () {
    test('default', () {
      const DrawerState state = DrawerState(index: 99, prevIndices: [1, 2, 3]);
      expect(
        state.toString(),
        'DrawerState { index: 99 prevIndices: [1, 2, 3] }',
      );
    });
  });
}
