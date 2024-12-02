import 'dart:convert' show utf8;
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:ntodotxt/main.dart' show log;
import 'package:webdav_client/webdav_client.dart' as webdav;

class WebDAVClientException implements Exception {
  final String message;

  const WebDAVClientException(this.message);

  @override
  String toString() => message;
}

class WebDAVClient {
  webdav.Client? _client; // Singleton pattern

  late final String scheme;
  late final String host;
  late final int? port;
  late final String path;
  final String username;
  final String password;
  final bool acceptUntrustedCert;

  static const int idleTimeout = 15000;
  static const int connectionTimeout = 15000;
  static const int sendTimeout = 15000;
  static const int receiveTimeout = 15000;

  WebDAVClient({
    required String server,
    required String path,
    required this.username,
    required this.password,
    this.acceptUntrustedCert = false,
  }) {
    final RegExp exp = RegExp(
        r'(?<scheme>^(http|https)):\/\/(?<host>[a-zA-Z0-9.-]+)(:(?<port>\d+)){0,1}$');
    final RegExpMatch? match = exp.firstMatch(server);
    if (match != null) {
      scheme = match.namedGroup('scheme')!;
      host = match.namedGroup('host')!;
      port = match.namedGroup('port') != null
          ? int.parse(match.namedGroup('port')!)
          : null;
    } else {
      throw const FormatException('Invalid server format');
    }

    if (path == '/') {
      this.path = path;
    } else {
      if (path.endsWith('/')) {
        this.path = path.substring(0, path.length - 1);
      } else {
        this.path = path;
      }
    }
  }

  Future<webdav.Client> get connection async {
    if (_client != null) {
      return _client!;
    } else {
      _client = await _open();
      return _client!;
    }
  }

  Future<webdav.Client> _open() async {
    // Handle untrusted certificates.
    webdav.WdDio dio = webdav.WdDio(debug: false);
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        // Don't trust any certificate just because their root cert is trusted.
        final HttpClient httpClient =
            HttpClient(context: SecurityContext(withTrustedRoots: false));
        httpClient.idleTimeout = const Duration(
          milliseconds: idleTimeout,
        );
        httpClient.connectionTimeout = const Duration(
          milliseconds: connectionTimeout,
        );
        // You can test the intermediate / root cert here. We just ignore it.
        httpClient.badCertificateCallback =
            (cert, host, port) => acceptUntrustedCert;
        return httpClient;
      },
      validateCertificate: (cert, host, port) => acceptUntrustedCert,
    );

    webdav.Client client = webdav.Client(
      uri: Uri(
        scheme: scheme,
        host: host,
        port: port,
        path: path,
      ).toString(),
      c: dio,
      auth: webdav.BasicAuth(user: username, pwd: password),
      debug: false,
    );
    client.setHeaders({'accept-charset': 'utf-8'});
    client.setConnectTimeout(connectionTimeout);
    client.setSendTimeout(sendTimeout);
    client.setReceiveTimeout(receiveTimeout);

    return client;
  }

  (String, String) _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return (
          'TIMEOUT',
          'Timeout occurred while sending or receiving',
        );
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        if (statusCode != null) {
          switch (statusCode) {
            case 400:
              return (
                'BAD REQUEST',
                'Something went wrong',
              );
            case 401:
              return (
                'UNAUTHORIZED',
                'It seems that the credentials are incorrect',
              );
            case 403:
              return (
                'FORBIDDEN',
                'The request was rejected by the server',
              );
            case 404:
              return (
                'NOT FOUND',
                'The requested resource could not be found',
              );
            case 405:
              return (
                'METHOD NOT ALLOWED',
                'The request method is not supported for the requested resource',
              );
            case 409:
              return (
                'CONFLICT',
                'The request could not be processed because of conflict in the current state of the resource',
              );
            case 500:
              return (
                'INTERNAL SERVER ERROR',
                'An unexpected error was encountered on server side',
              );
            default:
              return (
                'INTERNAL SERVER ERROR ($statusCode)',
                'An unexpected error was encountered on server side',
              );
          }
        }
        break;
      case DioExceptionType.cancel:
        break;
      case DioExceptionType.badCertificate:
        return (
          'INVALID SSL CERTIFICATE',
          'The certificate is invalid',
        );
      case DioExceptionType.connectionError:
        return (
          'CONNECTION ERROR',
          'Server cannot be reached',
        );
      case DioExceptionType.unknown:
        return (
          'UNKNOWN ERROR',
          'Possible cause may be a connection problem or an invalid SSL certificate',
        );
      default:
        return (
          'UNKNOWN ERROR',
          'Possible cause may be a connection problem or an invalid SSL certificate',
        );
    }

    return (
      'UNKNOWN ERROR',
      'Something unexpected went wrong',
    );
  }

  Future<void> ping() async {
    try {
      log.fine('Ping');
      webdav.Client client = await connection;
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
    webdav.Client client = await connection;
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
    webdav.Client client = await connection;
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
    webdav.Client client = await connection;
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
    webdav.Client client = await connection;
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
    webdav.Client client = await connection;
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
