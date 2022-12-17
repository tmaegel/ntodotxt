import 'package:flutter_test/flutter_test.dart';
import 'package:todotxt/storage.dart';
import 'package:mocktail/mocktail.dart';

// A Mock Cat class
class MockTasksFile extends Mock implements TasksFile {}

void main() {
  group("file path", () {
    test("Get local path", () async {
      // Create a Mock TasksFile instance.
      final mockFile = MockTasksFile();
      // Stub the 'localPath' method.
      when(() => mockFile.localPath)
          .thenAnswer((_) => Future(() => '/home/user'));
      final path = await mockFile.localPath;
      expect(path, "/home/user");
    });
    // test("Get local file", () async {
    //   // Create a Mock TasksFile instance.
    //   final mockFile = MockTasksFile();
    //   // Stub the 'localPath' method.
    //   when(() => mockFile.localPath)
    //       .thenAnswer((_) => Future(() => '/home/user'));
    //   final filePath = await mockFile.localFile;
    //   expect(filePath, "/home/user/todo.txt");
    // });
  });
  group("write file", () {
    test("file is written", () async {});
  });
}
