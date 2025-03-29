import 'dart:io' show Platform;
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ntodotxt/client/webdav_client.dart';
import 'package:webdav_client/webdav_client.dart';

const String scheme = 'https';
const int port = 8443;
final String host = Platform.isAndroid ? '10.0.2.2' : 'localhost';

WebDAVClient createWebDAVClient({
  String? server,
  String? path,
  String? username,
  String? password,
}) {
  return WebDAVClient(
    server: server ?? '$scheme://$host:$port',
    path: path ?? '/remote.php/dav/files/test',
    username: username ?? 'test',
    password: password ?? 'test',
    acceptUntrustedCert: true,
  );
}

String randomString({int len = 8}) {
  final Random r = Random();
  const chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('WebDAVClient', () {
    group('ping()', () {
      test('correct connection', () async {
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.ping();
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('wrong host', () async {
        final WebDAVClient client =
            createWebDAVClient(server: '$scheme://webdav:$port');
        expectLater(
          () async => await client.ping(),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
      test('wrong port', () async {
        final WebDAVClient client =
            createWebDAVClient(server: '$scheme://$host:9999');
        expectLater(
          () async => await client.ping(),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });

    group('listFiles()', () {
      test('list', () async {
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.listFiles(path: '/');
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
    });

    group('file create() & fileExists()', () {
      test('file does exist (1)', () async {
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.create(filename);
          expectLater(
            await client.fileExists(filename: filename),
            true,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('file does exist (2)', () async {
        final String directory = randomString();
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.mkdir(directory: directory);
          await client.create('$directory/$filename');
          expectLater(
            await client.fileExists(filename: '$directory/$filename'),
            true,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('file doesn\'t exist (1)', () async {
        final WebDAVClient client = createWebDAVClient();
        try {
          expectLater(
            await client.fileExists(filename: 'abc.xyz'),
            false,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('file doesn\'t exist (2)', () async {
        final String directory = randomString();
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.mkdir(directory: directory);
          expectLater(
            await client.fileExists(filename: '/$directory/abc.xyz'),
            false,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('directory/file doesn\'t exist in this path', () async {
        final String directory = randomString();
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.mkdir(directory: directory);
          await client.create(filename);
          expectLater(
            await client.fileExists(filename: '$directory/$filename'),
            false,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
    });

    group('upload()', () {
      test('file upload', () async {
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.upload(content: 'abc', filename: filename);
          expectLater(await client.fileExists(filename: filename), true);
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('file upload within already existing directory', () async {
        final String directory = randomString();
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.mkdir(directory: directory);
          await client.upload(content: 'abc', filename: '$directory/$filename');
          expectLater(
            await client.fileExists(filename: '$directory/$filename'),
            true,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('file upload within non existing directory', () async {
        final String directory = randomString();
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.upload(content: 'abc', filename: '$directory/$filename');
          expectLater(
            await client.fileExists(filename: '$directory/$filename'),
            true,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('exception', () async {
        final WebDAVClient client = createWebDAVClient(password: 'wrong');
        expectLater(
          () async => await client.upload(content: 'abc', filename: 'todo.txt'),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });

    group('download()', () {
      test('file download', () async {
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.upload(content: 'abc', filename: filename);
          expectLater(await client.download(filename: filename), 'abc');
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('file download within directory', () async {
        final String directory = randomString();
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.upload(content: 'abc', filename: '$directory/$filename');
          expectLater(
            await client.download(filename: '$directory/$filename'),
            'abc',
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('exception', () async {
        final WebDAVClient client = createWebDAVClient(password: 'wrong');
        expectLater(
          () async => await client.download(filename: 'todo.txt'),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });

    group('getFile()', () {
      test('valid', () async {
        final String filename = '${randomString()}.txt';
        final WebDAVClient client = createWebDAVClient();
        try {
          await client.upload(content: 'abc', filename: filename);
          File f = await client.getFile(filename: filename);
          expect(f.mTime is DateTime, true);
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('exception', () async {
        final WebDAVClient client = createWebDAVClient();
        expectLater(
          () async => await client.getFile(filename: 'unknown.txt'),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });
  });
}
