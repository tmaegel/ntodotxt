import 'dart:convert' show utf8;

import 'package:ntodotxt/main.dart' show log;
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebDAVClientException implements Exception {
  final String message;

  const WebDAVClientException(this.message);

  @override
  String toString() => message;
}

class WebDAVClient {
  late final webdav.Client client;

  WebDAVClient({
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
    client = webdav.newClient(
      Uri(
        scheme: schema,
        host: host,
        port: port,
        path: '$baseUrl/$username',
      ).toString(),
      user: username,
      password: password,
      debug: false,
    );
    // Set the public request headers
    client.setHeaders({'accept-charset': 'utf-8'});
    // Set the connection server timeout time in milliseconds.
    client.setConnectTimeout(8000);
    // Set send data timeout time in milliseconds.
    client.setSendTimeout(8000);
    // Set transfer data time in milliseconds.
    client.setReceiveTimeout(8000);
  }

  Future<void> ping() async {
    try {
      await client.ping();
    } on Exception catch (e) {
      log.severe(e);
      throw const WebDAVClientException('Server cannot reached');
    }
  }

  Future<bool> fileExists(String filename) async {
    if (!filename.startsWith('/')) {
      filename = '/$filename';
    }
    for (webdav.File f in await listFiles()) {
      if (f.path == filename) {
        return true;
      }
    }
    return false;
  }

  Future<List<webdav.File>> listFiles({String path = '/'}) async {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    try {
      return await client.readDir(path);
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException('Failed to list files in path $path.');
    }
  }

  Future<void> create(String filename) async {
    try {
      if (!filename.startsWith('/')) {
        filename = '/$filename';
      }
      if (await fileExists(filename) == false) {
        // Create file by writing empty string.
        await client.write(filename, utf8.encode(''));
      }
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException('Failed to create the file $filename.');
    }
  }

  Future<void> mkdir(String path) async {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    try {
      await client.mkdir(path);
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException('Failed to create the directory $path.');
    }
  }

  Future<String> download({
    required String filename,
  }) async {
    try {
      List<int> content = await client.read(filename);

      return utf8.decode(content);
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException('Failed to download the file $filename.');
    }
  }

  Future<void> upload({
    required String filename,
    required String content,
  }) async {
    try {
      await client.write(filename, utf8.encode(content));
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException('Failed to upload the file $filename.');
    }
  }
}
