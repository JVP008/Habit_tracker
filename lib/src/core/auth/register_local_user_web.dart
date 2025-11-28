// Platform-specific implementation for web
class RegisterLocalUserPlatform {
  static const String platform = 'web';
  
  Future<bool> register(String email, String password) async {
    // Web-specific implementation
    return true;
  }
}
