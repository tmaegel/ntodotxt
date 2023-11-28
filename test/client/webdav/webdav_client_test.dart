import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/client/webdav_client.dart';

void main() {
  const String host = 'localhost';
  const int port = 8080;
  const String baseUrl = '/remote.php/dav/files';
  const String username = 'test';
  const String password = 'test';
  setUp(() async {});

  group("WebDAVClient", () {
    group("upload()", () {
      test("successful file upload", () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: password);
        try {
          client.upload(
            content: 'abc',
            targetFilename: 'test.txt',
          );
        } catch (e) {
          fail('An exception was thrown.');
        }
      });
      test("exception while file upload", () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: 'wrong');
        expectLater(
          () async => await client.upload(
            content: 'abc',
            targetFilename: 'test.txt',
          ),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });
    group("download()", () {
      test("successful file download", () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: password);
        try {
          await client.download(targetFilename: 'test.txt');
        } catch (e) {
          fail('An exception was thrown.');
        }
      });
      test("exception while file download", () async {
        WebDAVClient client = WebDAVClient(
            host: host,
            port: port,
            baseUrl: baseUrl,
            username: username,
            password: 'wrong');
        expectLater(
          () async => await client.download(targetFilename: 'test.txt'),
          throwsA(
            isA<WebDAVClientException>(),
          ),
        );
      });
    });
  });
}
