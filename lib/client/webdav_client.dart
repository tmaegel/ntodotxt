import 'dart:convert' show utf8, base64;
import 'dart:io'
    show
        ContentType,
        HttpClient,
        HttpClientRequest,
        HttpClientResponse,
        HttpHeaders;

import 'package:ntodotxt/main.dart' show log;
import 'package:xml/xml.dart'
    show XmlDocument, XmlException, XmlStringExtension;

class WebDAVClientException implements Exception {
  final String message;

  const WebDAVClientException(this.message);

  @override
  String toString() => message;
}

class WebDAVClient {
  final String schema;
  final String host;
  final int port;
  final String baseUrl;
  final String username;
  final String password;

  WebDAVClient._({
    required this.schema,
    required this.host,
    required this.port,
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  factory WebDAVClient({
    String schema = 'http',
    required String host,
    required int port,
    required String baseUrl,
    required String username,
    required String password,
  }) {
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    return WebDAVClient._(
      schema: schema,
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

  Uri serverUri(String filename) {
    return Uri(
      scheme: schema,
      host: host,
      port: port,
      path: path(filename),
    );
  }

  String path(String filename) {
    return '$baseUrl/$username/$filename';
  }

  Future<String> download({
    String targetFilename = 'todo.txt',
  }) async {
    final HttpClient client = HttpClient();
    final Uri url = serverUri(targetFilename);
    log.info('Download from server $url');

    try {
      HttpClientRequest request = await client.getUrl(url);
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

  Future<void> upload({
    required String content,
    String targetFilename = 'todo.txt',
  }) async {
    final HttpClient client = HttpClient();
    final Uri url = serverUri(targetFilename);
    log.info('Upload to server $url');

    try {
      HttpClientRequest request = await client.putUrl(url);
      request.headers.contentType =
          ContentType('text', 'plain', charset: 'utf-8');
      request.headers.set(HttpHeaders.authorizationHeader, 'Basic $token');
      request.write(content);

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
