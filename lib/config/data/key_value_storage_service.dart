abstract class KeyValueStorageService {
  // Future<void> setKeyValue<T>(String key, T value);

  // Future<bool> removeKeyValue(String key);

  // Future<T?> getValue<T>(String key);

  Future<void> saveId<T>(T value);
  Future<void> saveRole<T>(T value);
  Future<void> saveToken<T>(T value);
  Future<void> saveUserName<T>(T value);
  Future<void> saveAuthType<T>(T value);
  Future<void> saveEmail<T>(T value);

  Future<int> getId();
  Future<String> getRole();
  Future<String> getToken();
  Future<String> getUserName();
  Future<String> getAuthType();
  Future<String> getEmail();

  Future<bool> removeId();
  Future<bool> removeRole();
  Future<bool> removeToken();
  Future<bool> removeUserName();
  Future<bool> removeAuthType();
  Future<bool> removeEmail();

  Future<void> saveGoogleIdToken<T>(T value);
  Future<String> getGoogleIdToken();
  Future<bool> removeGoogleIdToken();
}
