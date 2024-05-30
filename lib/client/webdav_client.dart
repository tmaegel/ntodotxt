import 'dart:convert' show utf8;

import 'package:dio/dio.dart';
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
    int? port,
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
        path: baseUrl,
      ).toString(),
      user: username,
      password: password,
      debug: false,
    );
    // Set the public request headers
    client.setHeaders({'accept-charset': 'utf-8'});
    // Set the connection server timeout time in milliseconds.
    client.setConnectTimeout(15000);
    // Set send data timeout time in milliseconds.
    client.setSendTimeout(15000);
    // Set transfer data time in milliseconds.
    client.setReceiveTimeout(15000);
  }

  (String, String) _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ('Timeout', 'Timeout occurred while sending or receiving');
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return (
                'Bad Request',
                'Something went wrong',
              );
            case 401:
              return (
                'Unauthorized',
                'It seems that the credentials are incorrect',
              );
            case 403:
              return (
                'Forbidden',
                'The request was rejected by the server',
              );
            case 404:
              return (
                'Not Found',
                'The requested resource could not be found',
              );
            case 405:
              return (
                'Method Not Allowed',
                'The request method is not supported for the requested resource',
              );
            case 409:
              return (
                'Conflict',
                'The request could not be processed because of conflict in the current state of the resource',
              );
            case 500:
              return (
                'Internal Server Error',
                'An unexpected error was encountered',
              );
          }
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.unknown:
        return (
          'Unknown Error',
          'Server cannot be reached',
        );
      case DioExceptionType.badCertificate:
        return (
          'Internal Server Error',
          'The certificate is invalid',
        );
      case DioExceptionType.connectionError:
        return (
          'Connection Error',
          'Server cannot be reached',
        );
      default:
        return (
          'Unknown Error',
          'Something went wrong',
        );
    }

    return (
      'Unknown Error',
      'Something went wrong',
    );
  }

  Future<void> ping() async {
    try {
      log.fine('Ping');
      await client.ping();
    } on DioException catch (e) {
      log.severe(e);
      final (String, String) error = _handleDioError(e);
      throw WebDAVClientException('${error.$1}: ${error.$2}');
    } on Exception catch (e) {
      log.severe(e);
      throw const WebDAVClientException('Unknown Error: Something went wrong');
    }
  }

  Future<bool> _exists({
    required String path,
    required String target,
  }) async {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    if (!path.endsWith('/')) {
      path = '$path/';
    }
    for (webdav.File f in await listFiles(path: path)) {
      if (f.path == '$path$target') {
        return true;
      }
    }
    return false;
  }

  Future<bool> fileExists({
    String path = '',
    required String filename,
  }) async {
    if (filename.startsWith('/')) {
      filename = filename.substring(1);
    }
    if (filename.endsWith('/')) {
      filename = filename.substring(0, filename.length - 1);
    }
    log.fine(
      'Check if file $filename in path ${path.isEmpty ? "/" : path} exists',
    );
    return await _exists(path: path, target: filename);
  }

  Future<bool> directoryExists({
    String path = '',
    required String directory,
  }) async {
    if (directory.startsWith('/')) {
      directory = directory.substring(1);
    }
    if (!directory.endsWith('/')) {
      directory = '$directory/';
    }
    log.fine(
      'Check if directory $directory in path ${path.isEmpty ? "/" : path} exists',
    );
    return await _exists(path: path, target: directory);
  }

  Future<List<webdav.File>> listFiles({
    String path = '',
  }) async {
    try {
      log.fine('List files and directories of ${path.isEmpty ? "/" : path}');
      return await client.readDir(path);
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException(
        'Failed to list files in directory ${path.isEmpty ? "/" : path} on remote ${client.uri}',
      );
    }
  }

  Future<void> create(String filename) async {
    try {
      if (filename.startsWith('/')) {
        filename = filename.substring(1);
      }
      if (await fileExists(filename: filename) == false) {
        // Create file by writing empty string.
        log.fine('Create file $filename');
        await client.write(filename, utf8.encode(''));
      } else {
        log.fine('Skip file creation. File $filename already exists');
      }
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException(
        'Failed to create file $filename on remote ${client.uri}',
      );
    }
  }

  Future<void> mkdir(
      {required String directory, bool recursive = false}) async {
    if (directory.startsWith('/')) {
      directory = directory.substring(1);
    }
    if (directory.endsWith('/')) {
      directory = directory.substring(0, directory.length - 1);
    }
    try {
      log.fine('Create directory $directory');
      if (recursive) {
        await client.mkdirAll(directory);
      } else {
        await client.mkdir(directory);
      }
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException(
        'Failed to create directory $directory on remote ${client.uri}',
      );
    }
  }

  Future<String> download({
    required String filename,
  }) async {
    try {
      log.fine('Download content of file $filename');
      List<int> content = await client.read(filename);
      return utf8.decode(content);
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException(
        'Failed to download file $filename from remote ${client.uri}',
      );
    }
  }

  Future<void> upload({
    required String filename,
    required String content,
  }) async {
    try {
      log.fine('Upload content to file $filename');
      await client.write(filename, utf8.encode(content));
    } on Exception catch (e) {
      log.severe(e);
      throw WebDAVClientException(
        'Failed to upload file $filename to remote ${client.uri}',
      );
    }
  }
}
