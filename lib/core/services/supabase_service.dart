import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  // Paste your keys here
  static const String supabaseUrl = 'https://ofqzfplizvyxlcndzamr.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9mcXpmcGxpenZ5eGxjbmR6YW1yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTI0MTI4MDYsImV4cCI6MjEwNzk4ODgwNn0.ceFrpl_sOyP0nVjF8SwlMARZj01ygZYmMGKs6U2Ae04';

  static SupabaseClient? get clientOrNull {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: supabaseUrl,
      publishableKey: supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
    );
  }

  // ─── 1. SIGN UP (Captures full athlete passport) ───────────────────────────
  static Future<AuthResponse?> signUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
    required String phone,
    required String primarySport,
    required String primaryRole,
    String? profilePictureUrl,
  }) async {
    final c = clientOrNull;
    if (c == null) return null;
    final res = await c.auth.signUp(
      email: email.trim(),
      password: password,
      data: {
        'full_name': fullName.trim(),
        'username': username.trim().replaceAll('@', ''),
        'phone': phone.trim(),
        'primary_sport': primarySport,
        'primary_role': primaryRole,
        'profile_picture_url': profilePictureUrl ?? '',
      },
    );

    if (res.user != null) {
      try {
        await c.from('profiles').upsert({
          'id': res.user!.id,
          'user_id': 'WS-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}',
          'full_name': fullName.trim(),
          'username': username.trim().replaceAll('@', ''),
          'phone': phone.trim(),
          'primary_sport': primarySport,
          'primary_role': primaryRole,
          'is_verified': false,
        });
      } catch (e) {
        debugPrint('Supabase profiles initial row upsert note: $e');
      }
    }

    return res;
  }

  // ─── 2. DIRECT LOGIN ───────────────────────────────────────────────────────
  static Future<AuthResponse?> signIn({
    required String email,
    required String password,
  }) async {
    final c = clientOrNull;
    if (c == null) return null;
    return await c.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  // ─── 3. GOOGLE SIGN-IN ─────────────────────────────────────────────────────
  static Future<bool> signInWithGoogle() async {
    final c = clientOrNull;
    if (c == null) return false;
    return await c.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'worldsports://login-callback',
    );
  }

  // ─── 4. FACEBOOK SIGN-IN ───────────────────────────────────────────────────
  static Future<bool> signInWithFacebook() async {
    final c = clientOrNull;
    if (c == null) return false;
    return await c.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: kIsWeb ? null : 'worldsports://login-callback',
    );
  }

  // ─── 5. FETCH PLAYER PROFILE BY USER ID OR USERNAME ────────────────────────
  static Future<Map<String, dynamic>?> fetchPlayerProfile(
    String identifier,
  ) async {
    final cleanId = identifier.trim().replaceAll('@', '');
    if (cleanId.isEmpty) return null;
    try {
      final c = clientOrNull;
      if (c == null) return null;
      final res = await c
          .from('profiles')
          .select('*, player_sport_stats(*)')
          .or('user_id.ilike.$cleanId,username.ilike.$cleanId')
          .maybeSingle();
      return res;
    } catch (e) {
      debugPrint('Error fetching player profile from Supabase: $e');
      return null;
    }
  }

  // ─── 6. LOGOUT ─────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    final c = clientOrNull;
    if (c != null) {
      await c.auth.signOut();
    }
  }

  // ─── 7. UPDATE ATHLETE SPECIALIZATION SPECS ────────────────────────────────
  static Future<bool> updateAthleteSpecs({
    required String userId,
    required String sport,
    required Map<String, dynamic> specs,
  }) async {
    try {
      final c = clientOrNull;
      if (c == null) return false;
      await c.from('profiles').update({
        'primary_sport': sport,
        'primary_role': specs['primary_role'] ?? 'Athlete',
        'is_verified': true,
      }).eq('id', userId);

      await c.from('player_sport_stats').upsert({
        'user_id': userId,
        'sport': sport,
        'stats_data': specs,
      });
      return true;
    } catch (e) {
      debugPrint('Error updating athlete specs in Supabase: $e');
      return false;
    }
  }

  static User? get currentUser => clientOrNull?.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
}
