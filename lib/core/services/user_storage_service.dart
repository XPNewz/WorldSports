import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

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

    // Zero dummy accounts policy: No fallback to hardcoded demo accounts when starting from scratch.
    return null;
  }

  /// Wipes all accounts, active sessions, and local athlete caches from storage.
  /// Used to ensure a clean database start.
  static Future<void> wipeAllDatabaseAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyRegisteredAccounts);
      await prefs.remove(_keyCurrentUser);
      await prefs.remove(_keyIsLoggedIn);
      await prefs.remove(_keyUserId);
      await prefs.remove(_keyCachedAthletes);
      debugPrint('UserStorageService: All accounts wiped from database. Database is now 100% fresh.');
    } catch (e) {
      debugPrint('UserStorageService: Error wiping accounts from database: $e');
    }
  }

  /// Fast-check if an identifier is a demo account
  static bool isDemoAccount(String identifier) {
    final rawInput = identifier.trim().toLowerCase();
    final cleanUsername = rawInput.replaceAll('@', '');
    const demoIdentifiers = [
      'arjun@worldsports.com',
      'arjun',
      'arjun_plays',
      'priya@worldsports.com',
      'priya',
      'priya_coach',
      'vikram@worldsports.com',
      'vikram',
      'vikram_org',
      'anil@worldsports.com',
      'anil',
      'anil_umpire',
    ];
    return demoIdentifiers.contains(rawInput) ||
        demoIdentifiers.contains(cleanUsername);
  }

  /// Get predefined demo athlete passport for instant 1-tap test drive
  static UserModel getDemoUser(String identifier) {
    final rawInput = identifier.trim().toLowerCase();
    final cleanUsername = rawInput.replaceAll('@', '');

    if (cleanUsername.contains('priya')) {
      return const UserModel(
        id: 'u_demo_coach',
        userId: 'WS-COACH-102',
        name: 'Priya Patel',
        username: 'priya_coach',
        email: 'priya@worldsports.com',
        phone: '+91 98765 43211',
        role: UserRole.coach,
        sports: [SportType.cricket, SportType.football],
        primarySport: SportType.cricket,
        primaryRole: 'Head Coach & Performance Analyst',
        hasCompletedProfile: true,
      );
    } else if (cleanUsername.contains('vikram')) {
      return const UserModel(
        id: 'u_demo_org',
        userId: 'WS-ORG-103',
        name: 'Vikram Malhotra',
        username: 'vikram_org',
        email: 'vikram@worldsports.com',
        phone: '+91 98765 43212',
        role: UserRole.organiser,
        sports: [SportType.cricket, SportType.tennis],
        primarySport: SportType.cricket,
        primaryRole: 'Tournament Director',
        hasCompletedProfile: true,
      );
    } else if (cleanUsername.contains('anil')) {
      return const UserModel(
        id: 'u_demo_umpire',
        userId: 'WS-UMP-104',
        name: 'Anil Deshmukh',
        username: 'anil_umpire',
        email: 'anil@worldsports.com',
        phone: '+91 98765 43213',
        role: UserRole.umpire,
        sports: [SportType.cricket],
        primarySport: SportType.cricket,
        primaryRole: 'Senior Match Official & Umpire',
        hasCompletedProfile: true,
      );
    }

    // Default: Arjun Sharma (Athlete)
    return const UserModel(
      id: 'u_demo_athlete',
      userId: 'WS-ATH-101',
      name: 'Arjun Sharma',
      username: 'arjun_plays',
      email: 'arjun@worldsports.com',
      phone: '+91 98765 43210',
      role: UserRole.player,
      sports: [SportType.cricket, SportType.football],
      primarySport: SportType.cricket,
      primaryRole: 'Top Order Batter',
      hasCompletedProfile: true,
    );
  }

  /// Update saved user profile in registered accounts list and current session
  static Future<void> updateAccountUser(UserModel updatedUser) async {
    await saveCurrentUser(updatedUser);
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawAccounts = prefs.getString(_keyRegisteredAccounts);
      List<dynamic> list = [];
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        try {
          list = jsonDecode(rawAccounts) as List<dynamic>;
        } catch (_) {}
      }

      final cleanEmail = updatedUser.email.trim().toLowerCase();
      final cleanUsername = updatedUser.username.trim().toLowerCase().replaceAll('@', '');
      bool found = false;

      for (int i = 0; i < list.length; i++) {
        final item = list[i];
        if (item is Map) {
          final e = (item['email'] as String? ?? '').toLowerCase();
          final u = (item['username'] as String? ?? '').toLowerCase().replaceAll('@', '');
          String existingId = '';
          final existingUser = item['user'];
          if (existingUser is Map) {
            existingId = existingUser['id']?.toString() ?? '';
          }

          if ((existingId.isNotEmpty && existingId == updatedUser.id) ||
              (cleanUsername.isNotEmpty && u == cleanUsername) ||
              (cleanEmail.isNotEmpty && e == cleanEmail)) {
            list[i] = {
              ...item,
              'email': cleanEmail.isNotEmpty ? cleanEmail : e,
              'username': cleanUsername.isNotEmpty ? cleanUsername : u,
              'user': updatedUser.toMap(),
            };
            found = true;
            break;
          }
        }
      }

      if (!found) {
        list.add({
          'email': cleanEmail,
          'username': cleanUsername,
          'password': 'password',
          'user': updatedUser.toMap(),
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      await prefs.setString(_keyRegisteredAccounts, jsonEncode(list));
      debugPrint('UserStorageService: Successfully updated account for ${updatedUser.username} (${updatedUser.id})');
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
            final u = (item['username'] as String? ?? '').toLowerCase().replaceAll('@', '');
            if ((cleanEmail.isNotEmpty && e == cleanEmail) ||
                (cleanUsername.isNotEmpty && u == cleanUsername)) {
              return true;
            }
          }
        }
      }
    } catch (_) {}
    return false;
  }

  static const String _keyCachedAthletes = 'worldsports_cached_athletes';

  /// Cache remote athletes retrieved from Supabase locally for offline resilience
  static Future<void> cacheRemoteAthletes(List<MatchPlayer> athletes) async {
    if (athletes.isEmpty) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCachedAthletes);
      final Map<String, dynamic> cacheMap = {};
      if (raw != null && raw.isNotEmpty) {
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map<String, dynamic>) {
            cacheMap.addAll(decoded);
          }
        } catch (_) {}
      }

      for (final p in athletes) {
        if (p.id.isNotEmpty) {
          cacheMap[p.id] = p.toMap();
        }
      }

      await prefs.setString(_keyCachedAthletes, jsonEncode(cacheMap));
    } catch (e) {
      debugPrint('UserStorageService: Error caching remote athletes: $e');
    }
  }

  /// Load cached remote athletes
  static Future<List<MatchPlayer>> getCachedRemoteAthletes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCachedAthletes);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return decoded.values
              .whereType<Map>()
              .map((m) => MatchPlayer.fromMap(Map<String, dynamic>.from(m)))
              .where((p) => p.hasRegisteredContact)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('UserStorageService: Error loading cached remote athletes: $e');
    }
    return [];
  }

  /// Returns all registered real athlete profiles stored on the device,
  /// plus available demo profiles and cached remote athletes.
  static Future<List<UserModel>> getAllRegisteredUsers() async {
    final List<UserModel> users = [];
    final Set<String> seenIds = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final rawAccounts = prefs.getString(_keyRegisteredAccounts);
      if (rawAccounts != null && rawAccounts.isNotEmpty) {
        final list = jsonDecode(rawAccounts) as List<dynamic>;
        for (final item in list) {
          if (item is Map) {
            final userData = item['user'];
            if (userData is Map) {
              try {
                final u = UserModel.fromMap(Map<String, dynamic>.from(userData));
                if (!seenIds.contains(u.id) && u.hasRegisteredContact) {
                  seenIds.add(u.id);
                  users.add(u);
                }
              } catch (_) {}
            }
          }
        }
      }
    } catch (e) {
      debugPrint('UserStorageService: Error loading registered users: $e');
    }

    // Zero-dummy policy: return only real registered users with verified contact
    return users.where((u) => u.hasRegisteredContact).toList();
  }
}

