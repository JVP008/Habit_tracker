// Platform-specific implementation for mobile/desktop
class RegisterLocalUserPlatform {
  static const String platform = 'io';
  
  Future<bool> register(String email, String password) async {
    // IO-specific implementation
    return true;
  }
}
