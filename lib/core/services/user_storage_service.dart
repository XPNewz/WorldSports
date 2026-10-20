import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../state/app_state.dart';

/// Service responsible for storing and retrieving user data and account credentials
/// in persistent local storage (SharedPreferences) with fallback support for demo accounts.
class UserStorageService {
  static const String _keyCurrentUser = 'current_user_data';
  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserId = 'user_id';
  static const String _keyRegisteredAccounts = 'registered_user_accounts';

  /// Save currently logged-in user profile to persistent local storage
  static Future<void> saveCurrentUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyCurrentUser, user.toJson());
      await prefs.setBool(_keyIsLoggedIn, true);
      await prefs.setString(_keyUserId, user.id);
      debugPrint('UserStorageService: Saved current user ${user.username} (${user.id})');
    } catch (e) {
      debugPrint('UserStorageService: Error saving current user: $e');
    }
  }

  /// Load currently logged-in user from persistent storage
  static Future<UserModel?> loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
      if (!isLoggedIn) return null;

      final jsonStr = prefs.getString(_keyCurrentUser);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return UserModel.fromJson(jsonStr);
      }
    } catch (e) {
      debugPrint('UserStorageService: Error loading current user: $e');
    }
    return null;
  }

  /// Clear current user session on logout
  static Future<void> clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyCurrentUser);
      await prefs.setBool(_keyIsLoggedIn, false);
      await prefs.remove(_keyUserId);
      debugPrint('UserStorageService: Cleared current user session');
    } catch (e) {
      debugPrint('UserStorageService: Error clearing current user: $e');
    }
  }

  /// Register or store an account with credentials locally so it can always be logged into
  static Future<void> registerAccount({
    required String email,
    required String username,
    required String password,
    required UserModel user,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawAccounts = prefs.getString(_keyRegisteredAccounts);
      List<dynamic> list = [];
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        try {
          list = jsonDecode(rawAccounts) as List<dynamic>;
        } catch (_) {}
      }

      final cleanEmail = email.trim().toLowerCase();
      final cleanUsername = username.trim().toLowerCase().replaceAll('@', '');

      // Remove any prior entry with matching email or username to prevent duplicates
      list.removeWhere((item) {
        if (item is Map) {
          final e = (item['email'] as String? ?? '').toLowerCase();
          final u = (item['username'] as String? ?? '').toLowerCase();
          return e == cleanEmail || u == cleanUsername;
        }
        return false;
      });

      list.add({
        'email': cleanEmail,
        'username': cleanUsername,
        'password': password,
        'user': user.toMap(),
        'created_at': DateTime.now().toIso8601String(),
      });

      await prefs.setString(_keyRegisteredAccounts, jsonEncode(list));
      debugPrint('UserStorageService: Registered account for $cleanUsername ($cleanEmail)');
    } catch (e) {
      debugPrint('UserStorageService: Error registering account locally: $e');
    }
  }

  /// Authenticate credentials against locally saved accounts or demo accounts
  static Future<UserModel?> authenticateLocal({
    required String emailOrUsername,
    required String password,
  }) async {
    final rawInput = emailOrUsername.trim().toLowerCase();
    final cleanUsername = rawInput.replaceAll('@', '');
    if (rawInput.isEmpty || password.isEmpty) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawAccounts = prefs.getString(_keyRegisteredAccounts);
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        final list = jsonDecode(rawAccounts) as List<dynamic>;
        for (final item in list) {
          if (item is Map) {
            final e = (item['email'] as String? ?? '').toLowerCase();
            final u = (item['username'] as String? ?? '').toLowerCase();
            final p = item['password'] as String? ?? '';

            if ((e == rawInput || u == cleanUsername || u == rawInput) && p == password) {
              final userData = item['user'];
              if (userData is Map<String, dynamic>) {
                return UserModel.fromMap(userData);
              } else if (userData is Map) {
                return UserModel.fromMap(Map<String, dynamic>.from(userData));
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('UserStorageService: Error during local auth lookup: $e');
    }

    // Check demo accounts fallback
    final demoUsers = [
      {'email': 'arjun@worldsports.com', 'username': 'arjun', 'user': MockData.demoPlayer},
      {'email': 'priya@worldsports.com', 'username': 'priya', 'user': MockData.demoCoach},
      {'email': 'vikram@worldsports.com', 'username': 'vikram', 'user': MockData.demoOrganiser},
      {'email': 'anil@worldsports.com', 'username': 'anil', 'user': MockData.demoUmpire},
    ];

    for (final demo in demoUsers) {
      final dEmail = (demo['email'] as String).toLowerCase();
      final dUser = (demo['username'] as String).toLowerCase();
      if ((dEmail == rawInput || dUser == cleanUsername || dUser == rawInput) &&
          (password == 'password' || password.isNotEmpty)) {
        return demo['user'] as UserModel;
      }
    }

    return null;
  }

  /// Update saved user profile in registered accounts list and current session
  static Future<void> updateAccountUser(UserModel updatedUser) async {
    await saveCurrentUser(updatedUser);
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawAccounts = prefs.getString(_keyRegisteredAccounts);
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        final list = jsonDecode(rawAccounts) as List<dynamic>;
        for (int i = 0; i < list.length; i++) {
          final item = list[i];
          if (item is Map) {
            final e = (item['email'] as String? ?? '').toLowerCase();
            final u = (item['username'] as String? ?? '').toLowerCase();
            if (e == updatedUser.email.toLowerCase() || u == updatedUser.username.toLowerCase()) {
              list[i] = {
                ...item,
                'user': updatedUser.toMap(),
              };
              break;
            }
          }
        }
        await prefs.setString(_keyRegisteredAccounts, jsonEncode(list));
      }
    } catch (e) {
      debugPrint('UserStorageService: Error updating account user: $e');
    }
  }

  /// Check if account already exists with given email or username
  static Future<bool> accountExists({
    required String email,
    required String username,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanUsername = username.trim().toLowerCase().replaceAll('@', '');

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawAccounts = prefs.getString(_keyRegisteredAccounts);
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        final list = jsonDecode(rawAccounts) as List<dynamic>;
        for (final item in list) {
          if (item is Map) {
            final e = (item['email'] as String? ?? '').toLowerCase();
            final u = (item['username'] as String? ?? '').toLowerCase();
            if (e == cleanEmail || u == cleanUsername) {
              return true;
            }
          }
        }
      }
    } catch (_) {}
    return false;
  }
}
