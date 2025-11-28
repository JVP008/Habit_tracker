import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../features/auth/data/models/user_model.dart';
import '../database/daos/user_dao.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  final SharedPreferences _prefs;
  final UserDao _userDao = UserDao();

  AuthProvider(this._prefs);

  UserModel? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize auth state from shared preferences and local DB
  Future<void> initialize() async {
    final userId = _prefs.getString('logged_in_user_id');
    if (userId != null) {
      try {
        _user = await _userDao.getById(userId);
        if (_user != null) {
           await _userDao.updateLastActive(_user!.id!);
        } else {
           // User ID in prefs but not in DB? Anomalous state.
           await _prefs.remove('logged_in_user_id');
        }
        notifyListeners();
      } catch (e) {
        debugPrint('Error initializing user: $e');
        _error = 'Failed to restore session';
      }
    }
  }

  // Login with email and password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Simulate network delay for "security check"
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      // 1. Check if user exists in local DB
      final existingUser = await _userDao.getUserByEmail(email);

      if (existingUser != null) {
        _user = existingUser;
        await _userDao.updateLastActive(_user!.id!);
        // Persist session
        await _prefs.setString('logged_in_user_id', _user!.id!);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // For this local-first app, we can treat "Login" as "Register if not exists" 
        // OR enforce strict registration. Let's enforce strict registration to be "real".
        throw Exception('User not found. Please sign up.');
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Sign up with name, email, and password
  Future<bool> signup(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields are required');
      }

      if (password.length < 6) {
        throw Exception('Password must be at least 6 characters');
      }

      // Check if user already exists
      final exists = await _userDao.userExists(email);
      if (exists) {
        throw Exception('User with this email already exists');
      }

      // Create new user
      final newUser = UserModel(
        id: const Uuid().v4(),
        displayName: name,
        email: email,
        lastActive: DateTime.now(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Insert into DB
      await _userDao.insert(newUser);

      _user = newUser;
      // Persist session
      await _prefs.setString('logged_in_user_id', _user!.id!);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _prefs.remove('logged_in_user_id');
      _user = null;
    } catch (e) {
      debugPrint('Error during logout: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    String? bio,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        displayName: displayName ?? _user!.displayName,
        photoUrl: photoUrl ?? _user!.photoUrl,
        bio: bio ?? _user!.bio,
        updatedAt: DateTime.now(),
      );

      await _userDao.update(updatedUser, updatedUser.id!);
      _user = updatedUser;
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}