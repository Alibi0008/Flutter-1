import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:users_api/core/api/api_client.dart';
import 'package:users_api/core/api/api_exception.dart';
import 'package:users_api/features/users/user.dart';
import 'package:users_api/features/users/user_repository.dart';

const _user1 = r'''
{"id":1,"name":"Leanne Graham","username":"Bret","email":"Sincere@april.biz",
"address":{"street":"Kulas Light","suite":"Apt. 556","city":"Gwenborough",
"zipcode":"92998-3874","geo":{"lat":"-37.3159","lng":"81.1496"}},
"phone":"1-770-736-8031 x56442","website":"hildegard.org",
"company":{"name":"Romaguera-Crona","catchPhrase":"Multi-layered client-server neural-net","bs":"harness real-time e-markets"}}
''';

UserRepository _repo(MockClientHandler h) =>
    UserRepository(ApiClient(MockClient(h)));

http.Response _json(String body, [int status = 200]) => http.Response(
  body,
  status,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  group('User', () {
    test('fromJson / toJson round-trip', () {
      final u = User.fromJson(jsonDecode(_user1) as Map<String, dynamic>);
      expect(u.address.geo.lat, -37.3159);
      expect(
        u.phoneDigits,
        '17707368031'
        '56442',
      );
      expect(u.company.name, 'Romaguera-Crona');
      expect(User.fromJson(u.toJson()), u);
      expect(u.toJson()['address']['geo']['lat'], '-37.3159');
    });

    test('website is nullable', () {
      final m = jsonDecode(_user1) as Map<String, dynamic>..['website'] = null;
      expect(User.fromJson(m).website, isNull);
    });

    test('id as a string throws a TypeError', () {
      final m = jsonDecode(_user1) as Map<String, dynamic>..['id'] = '1';
      expect(() => User.fromJson(m), throwsA(isA<TypeError>()));
    });
  });

  group('UserRepository', () {
    test('getAll parses a list', () async {
      final repo = _repo((_) async => _json('[$_user1,$_user1]'));
      expect((await repo.getAll()).length, 2);
    });

    test('404 -> NotFoundException before the body is read', () async {
      final repo = _repo((_) async => _json('{}', 404));
      expect(repo.getById(999), throwsA(isA<NotFoundException>()));
    });

    test('401 -> UnauthorizedException', () async {
      final repo = _repo((_) async => _json('{}', 401));
      expect(repo.getAll(), throwsA(isA<UnauthorizedException>()));
    });

    test('503 -> ServerException(503)', () async {
      final repo = _repo((_) async => _json('', 503));
      expect(
        repo.getAll(),
        throwsA(isA<ServerException>().having((e) => e.status, 'status', 503)),
      );
    });

    test('bad JSON -> BadResponseException', () async {
      final repo = _repo((_) async => _json('<html>'));
      expect(repo.getAll(), throwsA(isA<BadResponseException>()));
    });

    test('wrong type inside JSON -> BadResponseException', () async {
      final bad = _user1.replaceFirst('"id":1', '"id":"1"');
      final repo = _repo((_) async => _json('[$bad]'));
      expect(repo.getAll(), throwsA(isA<BadResponseException>()));
    });

    test(
      'SocketException and ClientException -> NoConnectionException',
      () async {
        final a = _repo((_) async => throw const SocketException('x'));
        final b = _repo((_) async => throw http.ClientException('x'));
        expect(a.getAll(), throwsA(isA<NoConnectionException>()));
        expect(b.getAll(), throwsA(isA<NoConnectionException>()));
      },
    );

    test('create POSTs JSON and expects 201', () async {
      late http.Request seen;
      final repo = _repo((req) async {
        seen = req;
        final body = jsonDecode(req.body) as Map<String, dynamic>;
        return _json(jsonEncode({...body, 'id': 11}), 201);
      });
      final u = await repo.create(
        User.draft(name: 'Ali', username: 'ali', email: 'a@b.kz'),
      );
      expect(u.id, 11);
      expect(seen.method, 'POST');
      expect(seen.headers['Content-Type'], startsWith('application/json'));
      expect(seen.url.host, 'jsonplaceholder.typicode.com');
    });

    test('create with 200 instead of 201 -> BadResponseException', () async {
      final repo = _repo((_) async => _json(_user1));
      expect(
        repo.create(User.draft(name: 'Ali', username: 'ali', email: 'a@b.kz')),
        throwsA(isA<BadResponseException>()),
      );
    });
  });
}
