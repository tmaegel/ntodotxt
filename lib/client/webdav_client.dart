import 'dart:convert' show utf8, base64;
import 'dart:io'
    show
        ContentType,
        HttpClient,
        HttpClientRequest,
        HttpClientResponse,
        HttpHeaders;

import 'package:xml/xml.dart'
    show XmlDocument, XmlException, XmlStringExtension;

class WebDAVClientException implements Exception {
  final String message;

  const WebDAVClientException(this.message);

  @override
  String toString() => message;
}

class WebDAVClient {
  final String host;
  final int port;
  final String username;
  final String password;
  final String baseUrl;

  late final HttpClient client;

  WebDAVClient._({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    required this.baseUrl,
  }) {
    client = HttpClient();
  }

  factory WebDAVClient({
    required String host,
    required int port,
    required String username,
    required String password,
    String baseUrl = '/remote.php/dav/files',
  }) {
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    return WebDAVClient._(
      host: host,
      port: port,
      username: username,
      password: password,
      baseUrl: baseUrl,
    );
  }

  String get token => base64.encode(
        utf8.encode('$username:$password'),
      );

  String fullPath(String filename) {
    return '$baseUrl/$username/$filename';
  }

  Future<String> download(String filename) async {
    try {
      HttpClientRequest request =
          await client.get(host, port, fullPath(filename));
      request.headers.contentType =
          ContentType('text', 'plain', charset: 'utf-8');
      request.headers.set(HttpHeaders.authorizationHeader, 'Basic $token');

      HttpClientResponse response = await request.close();

      final String data = await response.transform(utf8.decoder).join();
      try {
        final document = XmlDocument.parse(data);
        final error = document.getElement('d:error');
        if (error != null) {
          final messageTag = error.getElement('s:message');
          if (messageTag != null) {
            throw WebDAVClientException(messageTag.innerText);
          } else {
            throw const WebDAVClientException(
                'Something went wrong while performing http request.');
          }
        }
      } on XmlException {
        // If the xml couldn't parse the response isn't xml.
      }

      return data;
    } finally {
      client.close();
    }
  }

  Future<void> upload(String filename) async {
    try {
      HttpClientRequest request =
          await client.put(host, port, fullPath(filename));
      request.headers.contentType =
          ContentType('text', 'plain', charset: 'utf-8');
      request.headers.set(HttpHeaders.authorizationHeader, 'Basic $token');
      request.write('testabc111');

      HttpClientResponse response = await request.close();

      final String data = await response.transform(utf8.decoder).join();
      try {
        final document = XmlDocument.parse(data);
        final error = document.getElement('d:error');
        if (error != null) {
          final messageTag = error.getElement('s:message');
          if (messageTag != null) {
            throw WebDAVClientException(messageTag.innerText);
          } else {
            throw const WebDAVClientException(
                'Something went wrong while performing http request.');
          }
        }
      } on XmlException {
        // If the xml couldn't parse the response isn't xml.
      }
    } finally {
      client.close();
    }
  }
}
