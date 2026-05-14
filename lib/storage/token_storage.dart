import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _usernameKey = 'username';
  static const _fullNameKey = 'fullName';
  static const _targetKey = 'target';
  static const _imageKey = 'imagetoShow';
  static const _entityIdKey = 'entityId';

  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _usernameKey, value: username);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  static Future<void> saveFullName(String fullName) async {
    await _storage.write(key: _fullNameKey, value: fullName);
  }

  static Future<String?> getFullName() async {
    return await _storage.read(key: _fullNameKey);
  }

  static Future<void> saveTarget(String target) async {
    await _storage.write(key: _targetKey, value: target);
  }

  static Future<String?> getTarget() async {
    return await _storage.read(key: _targetKey);
  }

  static Future<void> saveImage(String? image) async {
    await _storage.write(key: _imageKey, value: image);
  }

  static Future<String?> getImage() async {
    return await _storage.read(key: _imageKey);
  }

  static Future<void> saveEntityId(int id) async {
    await _storage.write(key: _entityIdKey, value: id.toString());
  }

  static Future<int?> getEntityId() async {
    final value = await _storage.read(key: _entityIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _fullNameKey);
    await _storage.delete(key: _targetKey);
    await _storage.delete(key: _imageKey);
    await _storage.delete(key: _entityIdKey);
  }
}