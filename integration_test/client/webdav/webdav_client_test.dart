import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ntodotxt/client/webdav_client.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  const String host = 'localhost';
  const int port = 8080;
  const String baseUrl = '/remote.php/dav/files';
  const String username = 'test';
  const String password = 'test';
  const String filename = 'test.txt';
  setUp(() async {});

  group('WebDAVClient', () {
    group('ping()', () {
      test('successful ping', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: password);
        try {
          await client.ping();
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('failed ping', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: 9999,
            baseUrl: baseUrl,
            username: username,
            password: password);
        expectLater(
          () async => await client.ping(),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });

    group('fileExists()', () {
      test('file exists', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: password);
        try {
          expectLater(
            await client.fileExists(filename),
            true,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
      test('file not exists', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: password);
        try {
          expectLater(
            await client.fileExists('abc.xyz'),
            false,
          );
        } catch (e) {
          fail('An exception was thrown: $e');
        }
      });
    });

    group('upload()', () {
      test('successful file upload', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: password);
        try {
          await client.upload(content: 'abc', filename: filename);
        } catch (e) {
          fail('An exception was thrown.');
        }
      });
      test('exception while file upload', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: 'wrong');
        expectLater(
          () async => await client.upload(content: 'abc', filename: filename),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });
    group('download()', () {
      test('successful file download', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: password);
        try {
          await client.download(filename: filename);
        } catch (e) {
          fail('An exception was thrown.');
        }
      });
      test('exception while file download', () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: 'wrong');
        expectLater(
          () async => await client.download(filename: filename),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });
  });
}
