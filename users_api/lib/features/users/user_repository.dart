import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

/// Screens ask for models and get models, or an [ApiException].
class UserRepository {
  UserRepository(this._api);

  final ApiClient _api;

  Future<List<User>> getAll() async {
    final body = await _api.getJson('/users');
    return _parse(
      'users',
      () => (body as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Future<User> getById(int id) async {
    final body = await _api.getJson('/users/$id');
    return _parse(
      'users/$id',
      () => User.fromJson(body as Map<String, dynamic>),
    );
  }

  /// POST /users, expects 201. The server adds the id (11 on this API).
  Future<User> create(User draft) async {
    final json = draft.toJson()..remove('id');
    final body = await _api.postJson('/users', json);
    return _parse(
      'users (create)',
      () => User.fromJson(body as Map<String, dynamic>),
    );
  }

  /// A failed cast in fromJson is a TypeError; double.parse throws
  /// FormatException. Both become one of our exceptions.
  T _parse<T>(String what, T Function() build) {
    try {
      return build();
    } on TypeError catch (e) {
      throw BadResponseException('$what: $e');
    } on FormatException catch (e) {
      throw BadResponseException('$what: $e');
    }
  }
}
