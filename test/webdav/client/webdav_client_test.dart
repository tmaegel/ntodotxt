import 'package:flutter_test/flutter_test.dart';
import 'package:ntodotxt/webdav/client/webdav_client.dart';

void main() {
  setUp(() {});

  group('scheme', () {
    test('http', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.scheme, 'http');
    });
    test('https', () {
      WebDAVClient client = WebDAVClient(
        server: 'https://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.scheme, 'https');
    });
    test('undefined', () {
      expect(
        () => WebDAVClient(
          server: 'example.org',
          path: '/',
          username: 'test',
          password: 'test',
        ),
        throwsA(isA<FormatException>()),
      );
    });
    test('http', () {
      expect(
        () => WebDAVClient(
          server: 'httpx://example.org',
          path: '/',
          username: 'test',
          password: 'test',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('host', () {
    test('valid 1', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.host, 'example.org');
    });
    test('valid 2', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example-local',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.host, 'example-local');
    });
    test('undefined', () {
      expect(
        () => WebDAVClient(
          server: 'httpx://',
          path: '/',
          username: 'test',
          password: 'test',
        ),
        throwsA(isA<FormatException>()),
      );
    });
    test('invalid', () {
      expect(
        () => WebDAVClient(
          server: 'httpx://example_test.org',
          path: '/',
          username: 'test',
          password: 'test',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('port', () {
    test('valid 1', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org:80',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.port, 80);
    });
    test('valid 2', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org:8443',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.port, 8443);
    });
    test('undefined', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.port, null);
    });
    test('invalid', () {
      expect(
        () => WebDAVClient(
          server: 'httpx://example.org:abc',
          path: '/',
          username: 'test',
          password: 'test',
        ),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('path', () {
    test('valid 1', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '',
        username: 'test',
        password: 'test',
      );
      expect(client.path, '');
    });
    test('valid 2', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.path, '/');
    });
    test('valid 3', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/test',
        username: 'test',
        password: 'test',
      );
      expect(client.path, '/test');
    });
    test('valid 4', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/test/',
        username: 'test',
        password: 'test',
      );
      expect(client.path, '/test');
    });
  });

  group('username', () {
    test('valid', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.username, 'test');
    });
  });

  group('password', () {
    test('valid', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.password, 'test');
    });
  });

  group('acceptUntrustedCert', () {
    test('true', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
        acceptUntrustedCert: true,
      );
      expect(client.acceptUntrustedCert, true);
    });
    test('false', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
        acceptUntrustedCert: false,
      );
      expect(client.acceptUntrustedCert, false);
    });
    test('undefined', () {
      WebDAVClient client = WebDAVClient(
        server: 'http://example.org',
        path: '/',
        username: 'test',
        password: 'test',
      );
      expect(client.acceptUntrustedCert, false);
    });
  });
}
