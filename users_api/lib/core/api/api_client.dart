import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

/// Knows http. Everything above it gets decoded JSON or an [ApiException].
class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  static const _timeout = Duration(seconds: 10);

  /// Headers in one place.
  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<dynamic> getJson(String path, {Map<String, String>? query}) async {
    final r = await _send(
      () => _client.get(Uri.https(host, path, query), headers: _headers),
    );
    _check(r);
    return _decode(r);
  }

  Future<dynamic> postJson(
    String path,
    Object body, {
    int expectStatus = 201,
  }) async {
    final r = await _send(
      () => _client.post(
        Uri.https(host, path),
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ),
    );
    _check(r);
    if (r.statusCode != expectStatus) {
      throw BadResponseException(
        'POST $path: expected $expectStatus, got ${r.statusCode}',
      );
    }
    return _decode(r);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final r = await call().timeout(_timeout);
      if (kDebugMode) {
        log(
          '${r.request?.method} ${r.request?.url} -> ${r.statusCode}',
          name: 'api',
        );
      }
      return r;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      // package:http often wraps SocketException ("Failed host lookup")
      // into ClientException, so the typo-host test needs this arm.
      throw const NoConnectionException();
    }
  }

  /// Status first, body second: a 404 never reaches fromJson.
  void _check(http.Response r) {
    final s = r.statusCode;
    if (s == 401) throw const UnauthorizedException();
    if (s == 404) throw const NotFoundException();
    if (s >= 500) throw ServerException(s);
    if (s < 200 || s >= 300) throw BadResponseException('HTTP $s');
  }

  dynamic _decode(http.Response r) {
    try {
      return jsonDecode(utf8.decode(r.bodyBytes));
    } on FormatException catch (e) {
      throw BadResponseException(e.message);
    }
  }
}
