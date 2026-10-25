import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  // Supabase Configuration
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
    final cleanUsername = username.trim().replaceAll('@', '');
    final cleanEmail = email.trim();

    final res = await c.auth.signUp(
      email: cleanEmail,
      password: password,
      data: {
        'full_name': fullName.trim(),
        'username': cleanUsername,
        'phone': phone.trim(),
        'primary_sport': primarySport,
        'primary_role': primaryRole,
        'profile_picture_url': profilePictureUrl ?? '',
      },
    );

    // If session is null (e.g. unconfirmed or unauthenticated response), try signing in to acquire session
    if (res.session == null) {
      try {
        await c.auth.signInWithPassword(
          email: cleanEmail,
          password: password,
        );
      } catch (_) {}
    }

    if (res.user != null) {
      try {
        await c.from('profiles').upsert({
          'id': res.user!.id,
          'user_id': 'WS-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}',
          'full_name': fullName.trim(),
          'username': cleanUsername,
          'email': cleanEmail,
          'phone': phone.trim(),
          'primary_sport': primarySport,
          'primary_role': primaryRole,
          'is_verified': false,
        });

        await c.from('player_sport_stats').upsert({
          'user_id': res.user!.id,
          'sport': primarySport,
          'stats_data': {
            'matches_played': 0,
            'wins': 0,
            'rating': 1000,
            'created_at': DateTime.now().toIso8601String(),
          },
        });
      } catch (e) {
        debugPrint(
            'Supabase profiles initial row upsert note: $e (Run supabase_schema.sql to enable RLS public access)');
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
    final redirectUrl = kIsWeb ? Uri.base.origin : 'worldsports://login-callback';
    return await c.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: redirectUrl,
    );
  }

  // ─── 4. FACEBOOK SIGN-IN ───────────────────────────────────────────────────
  static Future<bool> signInWithFacebook() async {
    final c = clientOrNull;
    if (c == null) return false;
    final redirectUrl = kIsWeb ? Uri.base.origin : 'worldsports://login-callback';
    return await c.auth.signInWithOAuth(
      OAuthProvider.facebook,
      redirectTo: redirectUrl,
    );
  }

  static final _uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');

  // ─── 5. FETCH PLAYER PROFILE BY AUTH ID, USER ID, USERNAME OR FULL NAME ─────
  static Future<Map<String, dynamic>?> fetchPlayerProfile(
    String identifier,
  ) async {
    final cleanId = identifier.trim().replaceAll('@', '');
    if (cleanId.isEmpty) return null;
    try {
      final c = clientOrNull;
      if (c == null) return null;

      final isUuid = _uuidRegex.hasMatch(cleanId);

      // Attempt 1: With player_sport_stats joined
      try {
        final query = isUuid
            ? c.from('profiles').select('*, player_sport_stats(*)').eq('id', cleanId)
            : c
                .from('profiles')
                .select('*, player_sport_stats(*)')
                .or('username.ilike.%$cleanId%,full_name.ilike.%$cleanId%,user_id.ilike.%$cleanId%');

        final rows = await query.limit(1);
        if (rows.isNotEmpty) {
          return Map<String, dynamic>.from(rows.first);
        }
      } catch (joinErr) {
        debugPrint('Supabase profile join query note: $joinErr; falling back to direct profiles select');
        // Attempt 2: Direct profiles table select without join
        final fallbackQuery = isUuid
            ? c.from('profiles').select().eq('id', cleanId)
            : c
                .from('profiles')
                .select()
                .or('username.ilike.%$cleanId%,full_name.ilike.%$cleanId%,user_id.ilike.%$cleanId%');

        final fallbackRows = await fallbackQuery.limit(1);
        if (fallbackRows.isNotEmpty) {
          return Map<String, dynamic>.from(fallbackRows.first);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching player profile from Supabase: $e');
      return null;
    }
  }

  // ─── 6. SEARCH ATHLETES BY USERNAME, NAME, EMAIL OR ID ───────────────────
  static Future<List<MatchPlayer>> searchAthletes(
    String query, {
    SportType? sport,
  }) async {
    final clean = query.trim().replaceAll('@', '');
    if (clean.isEmpty) return [];

    try {
      final c = clientOrNull;
      if (c == null) return [];

      List<dynamic> rows = [];
      try {
        final q = c.from('profiles').select('*, player_sport_stats(*)').or(
              'username.ilike.%$clean%,full_name.ilike.%$clean%,email.ilike.%$clean%,user_id.ilike.%$clean%',
            );
        rows = await q.limit(50);
      } catch (_) {
        final fallbackQ = c.from('profiles').select().or(
              'username.ilike.%$clean%,full_name.ilike.%$clean%,email.ilike.%$clean%,user_id.ilike.%$clean%',
            );
        rows = await fallbackQ.limit(50);
      }

      return rows
          .map((r) => profileMapToMatchPlayer(Map<String, dynamic>.from(r)))
          .where((p) => p.hasRegisteredContact)
          .toList();
    } catch (e) {
      debugPrint('Error searching athletes in Supabase: $e');
      return [];
    }
  }

  // ─── 7. FETCH ALL ATHLETE PROFILES FROM SUPABASE ───────────────────────────
  static Future<List<MatchPlayer>> fetchAllAthletes({
    SportType? sport,
  }) async {
    try {
      final c = clientOrNull;
      if (c == null) return [];

      List<dynamic> rows = [];
      try {
        final q = c.from('profiles').select('*, player_sport_stats(*)');
        rows = await q.limit(100);
      } catch (_) {
        final fallbackQ = c.from('profiles').select();
        rows = await fallbackQ.limit(100);
      }

      return rows
          .map((r) => profileMapToMatchPlayer(Map<String, dynamic>.from(r)))
          .where((p) => p.hasRegisteredContact)
          .toList();
    } catch (e) {
      debugPrint('Error fetching all athletes from Supabase: $e');
      return [];
    }
  }

  // ─── 8. SYNC USER PROFILE TO SUPABASE ──────────────────────────────────────
  static Future<bool> syncUserProfile(UserModel user) async {
    try {
      final c = clientOrNull;
      if (c == null) return false;

      final cleanUsername = user.username.trim().replaceAll('@', '');
      final cleanEmail = user.email.trim();
      final userId =
          user.userId.isNotEmpty ? user.userId : 'WS-${cleanUsername.toUpperCase()}';

      await c.from('profiles').upsert({
        'id': user.id,
        'user_id': userId,
        'full_name': user.name.trim(),
        'username': cleanUsername,
        'email': cleanEmail,
        'phone': user.phone.trim(),
        'primary_sport': user.primarySport.name,
        'primary_role': user.primaryRole,
        'is_verified': user.hasCompletedProfile,
        'updated_at': DateTime.now().toIso8601String(),
      });

      await c.from('player_sport_stats').upsert({
        'user_id': user.id,
        'sport': user.primarySport.name,
        'stats_data': {
          'matches_played': 0,
          'wins': 0,
          'rating': 1000,
          'specs': user.getSpecsSummaryForSport(user.primarySport),
          'updated_at': DateTime.now().toIso8601String(),
        },
      });

      debugPrint('SupabaseService: Successfully synced user profile for $cleanUsername');
      return true;
    } catch (e) {
      debugPrint(
          'SupabaseService: Note while syncing user profile: $e. If RLS 42501, execute supabase_schema.sql in Supabase SQL editor.');
      return false;
    }
  }

  // ─── 9. CONVERT SUPABASE PROFILE ROW TO MATCHPLAYER ────────────────────────
  static MatchPlayer profileMapToMatchPlayer(Map<String, dynamic> data) {
    final statsList = data['player_sport_stats'] as List<dynamic>?;
    String specsStr = '';
    if (statsList != null && statsList.isNotEmpty) {
      final s = statsList.first['stats_data'] as Map<String, dynamic>?;
      if (s != null) {
        specsStr = s.entries.map((e) => '${e.value}').join(' • ');
      }
    }

    final rawUsername = data['username']?.toString() ?? '';
    final cleanUsername = rawUsername.replaceAll('@', '');
    final fullName = data['full_name']?.toString() ?? cleanUsername;
    final userId = data['user_id']?.toString() ??
        'WS-${cleanUsername.isNotEmpty ? cleanUsername.toUpperCase() : "ATHLETE"}';

    final email = data['email']?.toString() ?? '';
    final phone = data['phone']?.toString() ?? '';

    return MatchPlayer(
      id: data['id']?.toString() ?? 'sp_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      username: cleanUsername.isNotEmpty ? '@$cleanUsername' : '@athlete',
      name: fullName.isNotEmpty ? fullName : 'Verified Athlete',
      jerseyNumber: int.tryParse(data['jersey_number']?.toString() ?? '') ?? 10,
      role: (data['primary_role']?.toString() ?? 'Athlete').toUpperCase(),
      specsSummary: specsStr.isNotEmpty ? specsStr : 'Verified Profile',
      avatar: data['profile_picture_url']?.toString() ?? '',
      email: email,
      phone: phone,
    );
  }

  // ─── 10. LOGOUT ────────────────────────────────────────────────────────────
  static Future<void> signOut() async {
    final c = clientOrNull;
    if (c != null) {
      await c.auth.signOut();
    }
  }

  // ─── 11. UPDATE ATHLETE SPECIALIZATION SPECS ───────────────────────────────
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

  // ─── 12. SAVE / UPSERT MATCH TO SUPABASE ──────────────────────────────────
  static Future<bool> saveMatch(MatchModel match) async {
    try {
      final c = clientOrNull;
      if (c == null) return false;

      // Extract all participant IDs, usernames, and names
      final Set<String> participantIds = {};

      void addParticipant(String? val) {
        if (val == null) return;
        final clean = val.trim().toLowerCase();
        if (clean.isNotEmpty) {
          participantIds.add(clean);
          final noAt = clean.replaceAll('@', '');
          if (noAt.isNotEmpty) participantIds.add(noAt);
        }
      }

      addParticipant(match.creatorId);
      addParticipant(match.scorerId);
      addParticipant(match.umpire1Id);
      addParticipant(match.umpire2Id);

      for (final p in [...match.team1Players, ...match.team2Players]) {
        addParticipant(p.id);
        addParticipant(p.userId);
        addParticipant(p.username);
        addParticipant(p.name);
      }

      final data = {
        'id': match.id,
        'sport': match.sport.name,
        'team1_id': match.team1Id,
        'team2_id': match.team2Id,
        'team1_name': match.team1Name,
        'team2_name': match.team2Name,
        'team1_short': match.team1Short,
        'team2_short': match.team2Short,
        'date_time': match.dateTime.toIso8601String(),
        'venue': match.venue,
        'tournament_id': match.tournamentId,
        'status': match.status.name,
        'score_data': match.scoreData ?? {},
        'format': match.format,
        'team1_players': match.team1Players.map((p) => p.toMap()).toList(),
        'team2_players': match.team2Players.map((p) => p.toMap()).toList(),
        'participant_ids': participantIds.toList(),
        'toss_winner': match.tossWinner,
        'toss_decision': match.tossDecision,
        'result_text': match.resultText,
        'creator_id': match.creatorId,
        'scorer_id': match.scorerId,
        'scorer_name': match.scorerName,
        'umpire1_id': match.umpire1Id,
        'umpire1_name': match.umpire1Name,
        'umpire2_id': match.umpire2Id,
        'umpire2_name': match.umpire2Name,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await c.from('matches').upsert(data);
      debugPrint('SupabaseService: Successfully saved match ${match.id} to Supabase');
      return true;
    } catch (e) {
      debugPrint('SupabaseService: Note while saving match to Supabase: $e');
      return false;
    }
  }

  // ─── 13. UPDATE LIVE MATCH SCORE IN SUPABASE ─────────────────────────────
  static Future<bool> updateMatchScore(
    String matchId,
    dynamic scoreData, {
    MatchStatus? status,
    String? resultText,
  }) async {
    try {
      final c = clientOrNull;
      if (c == null) return false;

      final updateMap = <String, dynamic>{
        'score_data': scoreData,
        'updated_at': DateTime.now().toIso8601String(),
      };
      if (status != null) {
        updateMap['status'] = status.name;
      }
      if (resultText != null) {
        updateMap['result_text'] = resultText;
      }

      await c.from('matches').update(updateMap).eq('id', matchId);
      return true;
    } catch (e) {
      debugPrint('SupabaseService: Note while updating match score in Supabase: $e');
      return false;
    }
  }

  // ─── 14. FETCH ALL MATCHES FROM SUPABASE ─────────────────────────────────
  static Future<List<MatchModel>> fetchMatches({int limit = 100}) async {
    try {
      final c = clientOrNull;
      if (c == null) return [];

      final rows = await c
          .from('matches')
          .select()
          .order('updated_at', ascending: false)
          .limit(limit);

      return (rows as List<dynamic>)
          .map((r) => MatchModel.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService: Note while fetching matches from Supabase: $e');
      return [];
    }
  }

  // ─── 15. SAVE PREVIOUS MATCH TO SUPABASE ─────────────────────────────────
  static Future<bool> savePreviousMatch(
    PreviousMatchModel prevMatch, {
    required String userId,
  }) async {
    try {
      final c = clientOrNull;
      if (c == null) return false;

      final cleanUserId = userId.trim().toLowerCase().replaceAll('@', '');
      if (cleanUserId.isEmpty) return false;

      final data = {
        'id': prevMatch.id,
        'user_id': cleanUserId,
        'sport': prevMatch.sport.name,
        'team1_name': prevMatch.team1Name,
        'team2_name': prevMatch.team2Name,
        'team1_short': prevMatch.team1Short,
        'team2_short': prevMatch.team2Short,
        'team1_score': prevMatch.team1Score,
        'team2_score': prevMatch.team2Score,
        'result_text': prevMatch.resultText,
        'is_win': prevMatch.isWin,
        'date': prevMatch.date.toIso8601String(),
        'venue': prevMatch.venue,
        'my_performance': prevMatch.myPerformance,
        'mvp_player': prevMatch.mvpPlayer,
        'raw_score_data': prevMatch.rawScoreData ?? {},
        'format': prevMatch.format,
      };

      await c.from('user_previous_matches').upsert(data);
      debugPrint('SupabaseService: Successfully saved user_previous_match for user $cleanUserId');
      return true;
    } catch (e) {
      debugPrint('SupabaseService: Note while saving previous match to Supabase: $e');
      return false;
    }
  }

  // ─── 16. FETCH USER PREVIOUS MATCHES FROM SUPABASE ───────────────────────
  static Future<List<PreviousMatchModel>> fetchUserPreviousMatches(UserModel user) async {
    try {
      final c = clientOrNull;
      if (c == null) return [];

      final Set<String> userIds = {};
      if (user.id.isNotEmpty) userIds.add(user.id.toLowerCase().trim());
      if (user.userId.isNotEmpty) userIds.add(user.userId.toLowerCase().trim());
      final uname = user.username.replaceAll('@', '').toLowerCase().trim();
      if (uname.isNotEmpty) userIds.add(uname);

      if (userIds.isEmpty) return [];

      final rows = await c
          .from('user_previous_matches')
          .select()
          .filter('user_id', 'in', userIds.toList())
          .order('date', ascending: false)
          .limit(100);

      return (rows as List<dynamic>)
          .map((r) => PreviousMatchModel.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('SupabaseService: Note while fetching user previous matches: $e');
      return [];
    }
  }

  // ─── 17. SUBSCRIBE TO REALTIME MATCH CHANGES ─────────────────────────────
  static RealtimeChannel? subscribeToMatches({
    required void Function(MatchModel match) onMatchUpserted,
    void Function(String matchId)? onMatchDeleted,
  }) {
    final c = clientOrNull;
    if (c == null) return null;

    try {
      final channel = c.channel('public:matches');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'matches',
        callback: (payload) {
          try {
            if (payload.eventType == PostgresChangeEvent.delete) {
              final oldRec = payload.oldRecord;
              final id = oldRec['id']?.toString();
              if (id != null && onMatchDeleted != null) {
                onMatchDeleted(id);
              }
            } else {
              final newRec = payload.newRecord;
              if (newRec.isNotEmpty) {
                final match = MatchModel.fromMap(Map<String, dynamic>.from(newRec));
                onMatchUpserted(match);
              }
            }
          } catch (e) {
            debugPrint('Error processing match realtime change: $e');
          }
        },
      );
      channel.subscribe();
      debugPrint('SupabaseService: Realtime subscription active for public:matches');
      return channel;
    } catch (e) {
      debugPrint('Error setting up Supabase Realtime channel for matches: $e');
      return null;
    }
  }

  static User? get currentUser => clientOrNull?.auth.currentUser;
  static bool get isLoggedIn => currentUser != null;
}

