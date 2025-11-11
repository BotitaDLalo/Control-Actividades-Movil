import 'package:aprende_mas/config/data/key_value_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aprende_mas/config/utils/catalog_names.dart';

class KeyValueStorageServiceImpl implements KeyValueStorageService {
  final cn = CatalogNames();

  Future<SharedPreferences> getSharedPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<void> _setKeyValue<T>(String key, T value) async {
    final prefs = await getSharedPrefs();
    if (value is int) {
      await prefs.setInt(key, value as int);
    } else if (value is String) {
      await prefs.setString(key, value as String);
    } else if (value is Enum) {
      await prefs.setString(key, value.toString());
    } else {
      throw UnimplementedError('Set not implemented for type ${T.runtimeType}');
    }
  }

  Future<bool> _removeKeyValue(String key) async {
    try {
      final prefs = await getSharedPrefs();
      final valueRemoved = await prefs.remove(key);
      return valueRemoved;
    } catch (e) {
      return false;
    }
  }

  Future<T?> _getValue<T>(String key) async {
    final prefs = await getSharedPrefs();
    switch (T) {
      case const (int):
        return prefs.getInt(key) as T?;
      case const (String):
        return prefs.getString(key) as T?;

      default:
        throw UnimplementedError(
            'Set not implemented for type ${T.runtimeType}');
    }
  }

  @override
  Future<void> saveAuthType<T>(T value) async {
    await _setKeyValue(cn.getKeyAuthTypeName, value);
  }

  @override
  Future<void> saveEmail<T>(T value) async {
    await _setKeyValue(cn.getKeyEmailName, value);
  }

  @override
  Future<void> saveId<T>(T value) async {
    await _setKeyValue(cn.getKeyIdName, value);
  }

  @override
  Future<void> saveRole<T>(T value) async {
    await _setKeyValue(cn.getKeyRoleName, value);
  }

  @override
  Future<void> saveToken<T>(T value) async {
    await _setKeyValue(cn.getKeyTokenName, value);
  }

  @override
  Future<void> saveUserName<T>(T value) async {
    await _setKeyValue(cn.getKeyUserName, value);
  }

  @override
  Future<int> getId() async {
    return await _getValue<int>(cn.getKeyIdName) ?? -1;
  }

  @override
  Future<String> getRole() async {
    return await _getValue<String>(cn.getKeyRoleName) ?? "";
  }

  @override
  Future<String> getToken() async {
    return await _getValue<String>(cn.getKeyTokenName) ?? "";
  }

  @override
  Future<String> getUserName() async {
    return await _getValue<String>(cn.getKeyUserName) ?? "";
  }

  @override
  Future<String> getAuthType() async {
    return await _getValue<String>(cn.getKeyAuthTypeName) ?? "";
  }

  @override
  Future<String> getEmail() async {
    return await _getValue<String>(cn.getKeyEmailName) ?? "";
  }

  @override
  Future<bool> removeAuthType() async {
    return await _removeKeyValue(cn.getKeyAuthTypeName);
  }

  @override
  Future<bool> removeEmail() async {
    return await _removeKeyValue(cn.getKeyEmailName);
  }

  @override
  Future<bool> removeId() {
    return _removeKeyValue(cn.getKeyIdName);
  }

  @override
  Future<bool> removeRole() async {
    return await _removeKeyValue(cn.getKeyRoleName);
  }

  @override
  Future<bool> removeToken() async {
    return await _removeKeyValue(cn.getKeyTokenName);
  }

  @override
  Future<bool> removeUserName() async {
    return await _removeKeyValue(cn.getKeyUserName);
  }


}
