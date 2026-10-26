import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────

/// Lightweight user card used in follow lists and suggestions.
class FollowUser {
  final String id;           // auth.users UUID
  final String fullName;
  final String username;
  final String avatarUrl;
  final String primarySport;
  final int followersCount;
  final int followingCount;
  final int mutualCount;     // # of mutual follows (for BFS suggestion ranking)
  bool isFollowing;          // local state for immediate UI toggling

  FollowUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatarUrl,
    required this.primarySport,
    required this.followersCount,
    required this.followingCount,
    this.mutualCount = 0,
    this.isFollowing = false,
  });

  factory FollowUser.fromMap(Map<String, dynamic> m) => FollowUser(
        id: m['user_id']?.toString() ?? m['id']?.toString() ?? '',
        fullName: m['full_name']?.toString() ?? 'Athlete',
        username: m['username']?.toString() ?? '',
        avatarUrl: m['avatar_url']?.toString() ?? m['profile_picture_url']?.toString() ?? '',
        primarySport: m['primary_sport']?.toString() ?? 'cricket',
        followersCount: (m['followers_count'] as num?)?.toInt() ?? 0,
        followingCount: (m['following_count'] as num?)?.toInt() ?? 0,
        mutualCount: (m['mutual_count'] as num?)?.toInt() ?? 0,
      );
}

/// Community data model — mirrors the `communities` table.
class CommunityModel {
  final String id;           // UUID
  final String name;
  final String slug;
  final String description;
  final String avatarUrl;
  final String bannerUrl;
  final List<String> sportTags;
  final String location;
  final bool isVerified;
  final bool isPrivate;
  final String creatorId;
  final int membersCount;
  final int postsCount;
  final DateTime createdAt;

  // Runtime state (not in DB)
  String memberStatus; // 'active', 'pending', 'banned', '' = not member
  double jaccardScore; // suggestion ranking score

  CommunityModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
    required this.avatarUrl,
    required this.bannerUrl,
    required this.sportTags,
    required this.location,
    required this.isVerified,
    required this.isPrivate,
    required this.creatorId,
    required this.membersCount,
    required this.postsCount,
    required this.createdAt,
    this.memberStatus = '',
    this.jaccardScore = 0.0,
  });

  bool get isMember => memberStatus == 'active';
  bool get isPending => memberStatus == 'pending';

  factory CommunityModel.fromMap(Map<String, dynamic> m) => CommunityModel(
        id: m['id']?.toString() ?? m['community_id']?.toString() ?? '',
        name: m['name']?.toString() ?? '',
        slug: m['slug']?.toString() ?? '',
        description: m['description']?.toString() ?? '',
        avatarUrl: m['avatar_url']?.toString() ?? '',
        bannerUrl: m['banner_url']?.toString() ?? '',
        sportTags: (m['sport_tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        location: m['location']?.toString() ?? '',
        isVerified: m['is_verified'] as bool? ?? false,
        isPrivate: m['is_private'] as bool? ?? false,
        creatorId: m['creator_id']?.toString() ?? '',
        membersCount: (m['members_count'] as num?)?.toInt() ?? 0,
        postsCount: (m['posts_count'] as num?)?.toInt() ?? 0,
        createdAt: m['created_at'] != null
            ? DateTime.tryParse(m['created_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
        memberStatus: m['member_status']?.toString() ?? (m['is_member'] == true ? 'active' : ''),
        jaccardScore: (m['jaccard_score'] as num?)?.toDouble() ?? 0.0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// FOLLOW & COMMUNITY SERVICE
// ─────────────────────────────────────────────────────────────────────────────

/// DSA Algorithm summary for this service:
///
/// 1. follow()   / unfollow()  → O(1) via composite PK upsert on user_follows
/// 2. followers() / following() → O(log n + k) via B-Tree index scan
/// 3. isFollowing()             → O(1) via Postgres point lookup on PK
/// 4. getFollowSuggestions()    → O(V+E) BFS 2-hop social graph traversal via SQL CTE
/// 5. joinCommunity()           → O(1) via composite PK insert on community_members
/// 6. leaveCommunity()          → O(1) via composite PK delete
/// 7. getCommunities()          → O(log n) via B-Tree on members_count
/// 8. getCommunityMembers()     → O(log n + k) via B-Tree on community_id
/// 9. getCommunitySuggestions() → Jaccard set-similarity scoring via SQL function
class FollowCommunityService {
  // ── In-Memory Cache (LRU-style Set for O(1) follow lookup) ─────────────────
  // Key format: "${followerId}_${followeeId}"
  // Evicted on logout or explicit clearCache()
  static final Set<String> _followedSet = {};
  // community_id → status ('active','pending','')
  static final Map<String, String> _memberStatusCache = {};

  static String get _myId =>
      SupabaseService.currentUser?.id ?? '';

  static SupabaseClient? get _client => SupabaseService.clientOrNull;

  // ──────────────────────────────────────────────────────────────────────────
  // 1. FOLLOW / UNFOLLOW
  // O(1): composite PK insert/delete, trigger handles counter atomically
  // ──────────────────────────────────────────────────────────────────────────

  /// Follow a user. Returns true on success.
  static Future<bool> follow(String followeeId) async {
    final me = _myId;
    if (me.isEmpty || followeeId == me) return false;
    final c = _client;
    if (c == null) return false;

    try {
      await c.from('user_follows').insert({
        'follower_id': me,
        'followee_id': followeeId,
      });
      // Update in-memory cache
      _followedSet.add('${me}_$followeeId');
      debugPrint('FollowService: Followed $followeeId');
      return true;
    } catch (e) {
      // Duplicate = already following (PK conflict)
      if (e.toString().contains('23505')) {
        _followedSet.add('${me}_$followeeId');
        return true;
      }
      debugPrint('FollowService: Error following $followeeId: $e');
      return false;
    }
  }

  /// Unfollow a user. Returns true on success.
  static Future<bool> unfollow(String followeeId) async {
    final me = _myId;
    if (me.isEmpty) return false;
    final c = _client;
    if (c == null) return false;

    try {
      await c
          .from('user_follows')
          .delete()
          .eq('follower_id', me)
          .eq('followee_id', followeeId);
      _followedSet.remove('${me}_$followeeId');
      debugPrint('FollowService: Unfollowed $followeeId');
      return true;
    } catch (e) {
      debugPrint('FollowService: Error unfollowing $followeeId: $e');
      return false;
    }
  }

  /// Toggle follow state — returns new isFollowing value.
  static Future<bool> toggleFollow(String followeeId) async {
    final alreadyFollowing = await isFollowing(followeeId);
    if (alreadyFollowing) {
      final ok = await unfollow(followeeId);
      return ok ? false : true;
    } else {
      final ok = await follow(followeeId);
      return ok ? true : false;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 2. IS FOLLOWING — O(1) cache hit / O(log n) DB fallback
  // ──────────────────────────────────────────────────────────────────────────

  static Future<bool> isFollowing(String followeeId) async {
    final me = _myId;
    if (me.isEmpty) return false;

    // O(1) cache lookup first
    if (_followedSet.contains('${me}_$followeeId')) return true;

    final c = _client;
    if (c == null) return false;

    try {
      // Call Postgres function for O(1) point lookup on PK
      final res = await c.rpc('is_following', params: {
        'p_follower_id': me,
        'p_followee_id': followeeId,
      });
      final val = res as bool? ?? false;
      if (val) _followedSet.add('${me}_$followeeId');
      return val;
    } catch (e) {
      // Fallback: direct select
      try {
        final rows = await c
            .from('user_follows')
            .select('follower_id')
            .eq('follower_id', me)
            .eq('followee_id', followeeId)
            .limit(1);
        final val = (rows as List).isNotEmpty;
        if (val) _followedSet.add('${me}_$followeeId');
        return val;
      } catch (_) {
        return false;
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 3. GET FOLLOWERS / FOLLOWING — O(log n + k) via B-Tree index
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns list of users following [userId].
  static Future<List<FollowUser>> getFollowers(String userId, {int limit = 50}) async {
    final c = _client;
    if (c == null) return [];
    try {
      // Join user_follows → profiles → follow_counts in one query
      final rows = await c
          .from('user_follows')
          .select('follower_id, created_at, profiles!user_follows_follower_id_fkey(id, full_name, username, profile_picture_url, primary_sport), follow_counts!follow_counts_user_id_fkey(followers_count, following_count)')
          .eq('followee_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final me = _myId;
      return (rows as List<dynamic>).map((r) {
        final p = r['profiles'] as Map<String, dynamic>? ?? {};
        final fc = r['follow_counts'] as Map<String, dynamic>? ?? {};
        final uid = p['id']?.toString() ?? '';
        return FollowUser(
          id: uid,
          fullName: p['full_name']?.toString() ?? '',
          username: p['username']?.toString() ?? '',
          avatarUrl: p['profile_picture_url']?.toString() ?? '',
          primarySport: p['primary_sport']?.toString() ?? 'cricket',
          followersCount: (fc['followers_count'] as num?)?.toInt() ?? 0,
          followingCount: (fc['following_count'] as num?)?.toInt() ?? 0,
          isFollowing: _followedSet.contains('${me}_$uid'),
        );
      }).toList();
    } catch (e) {
      debugPrint('FollowService: getFollowers error: $e');
      return _getFollowersFallback(userId, limit: limit);
    }
  }

  /// Fallback: simpler query without joins
  static Future<List<FollowUser>> _getFollowersFallback(String userId, {int limit = 50}) async {
    final c = _client;
    if (c == null) return [];
    try {
      final rows = await c
          .from('user_follows')
          .select('follower_id')
          .eq('followee_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final ids = (rows as List).map((r) => r['follower_id'].toString()).toList();
      if (ids.isEmpty) return [];

      final profiles = await c.from('profiles').select().inFilter('id', ids);
      final me = _myId;
      return (profiles as List).map((p) {
        final uid = p['id']?.toString() ?? '';
        return FollowUser(
          id: uid,
          fullName: p['full_name']?.toString() ?? '',
          username: p['username']?.toString() ?? '',
          avatarUrl: p['profile_picture_url']?.toString() ?? '',
          primarySport: p['primary_sport']?.toString() ?? 'cricket',
          followersCount: 0,
          followingCount: 0,
          isFollowing: _followedSet.contains('${me}_$uid'),
        );
      }).toList();
    } catch (e) {
      debugPrint('FollowService: getFollowers fallback error: $e');
      return [];
    }
  }

  /// Returns list of users that [userId] follows.
  static Future<List<FollowUser>> getFollowing(String userId, {int limit = 50}) async {
    final c = _client;
    if (c == null) return [];
    try {
      final rows = await c
          .from('user_follows')
          .select('followee_id, created_at')
          .eq('follower_id', userId)
          .order('created_at', ascending: false)
          .limit(limit);

      final ids = (rows as List).map((r) => r['followee_id'].toString()).toList();
      if (ids.isEmpty) return [];

      final profiles = await c
          .from('profiles')
          .select('id, full_name, username, profile_picture_url, primary_sport')
          .inFilter('id', ids);

      final me = _myId;
      return (profiles as List).map((p) {
        final uid = p['id']?.toString() ?? '';
        return FollowUser(
          id: uid,
          fullName: p['full_name']?.toString() ?? '',
          username: p['username']?.toString() ?? '',
          avatarUrl: p['profile_picture_url']?.toString() ?? '',
          primarySport: p['primary_sport']?.toString() ?? 'cricket',
          followersCount: 0,
          followingCount: 0,
          isFollowing: _followedSet.contains('${me}_$uid') || ids.contains(uid),
        );
      }).toList();
    } catch (e) {
      debugPrint('FollowService: getFollowing error: $e');
      return [];
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 4. FOLLOW SUGGESTIONS — 2-Hop BFS O(V+E)
  // ──────────────────────────────────────────────────────────────────────────

  /// Get "Who to Follow" suggestions using 2-hop BFS social graph traversal.
  static Future<List<FollowUser>> getFollowSuggestions({int limit = 10}) async {
    final me = _myId;
    if (me.isEmpty) return [];
    final c = _client;
    if (c == null) return [];

    try {
      final rows = await c.rpc('get_follow_suggestions', params: {
        'p_user_id': me,
        'p_limit': limit,
      });
      return (rows as List<dynamic>)
          .map((r) => FollowUser.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('FollowService: getFollowSuggestions error: $e');
      // Fallback: return popular athletes user hasn't followed
      return _getPopularAthletesFallback(limit: limit);
    }
  }

  static Future<List<FollowUser>> _getPopularAthletesFallback({int limit = 10}) async {
    final c = _client;
    if (c == null) return [];
    try {
      final rows = await c
          .from('follow_counts')
          .select('user_id, followers_count, following_count, profiles!follow_counts_user_id_fkey(full_name, username, profile_picture_url, primary_sport)')
          .order('followers_count', ascending: false)
          .limit(limit);
      final me = _myId;
      return (rows as List).where((r) => r['user_id'] != me).map((r) {
        final p = r['profiles'] as Map<String, dynamic>? ?? {};
        return FollowUser(
          id: r['user_id'].toString(),
          fullName: p['full_name']?.toString() ?? '',
          username: p['username']?.toString() ?? '',
          avatarUrl: p['profile_picture_url']?.toString() ?? '',
          primarySport: p['primary_sport']?.toString() ?? 'cricket',
          followersCount: (r['followers_count'] as num?)?.toInt() ?? 0,
          followingCount: (r['following_count'] as num?)?.toInt() ?? 0,
        );
      }).toList();
    } catch (e) {
      debugPrint('FollowService: popular athletes fallback error: $e');
      return [];
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // 5. FOLLOW COUNTS — O(1) from counter cache
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns {followers_count, following_count} for [userId].
  static Future<Map<String, int>> getFollowCounts(String userId) async {
    final c = _client;
    if (c == null) return {'followers_count': 0, 'following_count': 0};
    try {
      final rows = await c
          .from('follow_counts')
          .select('followers_count, following_count')
          .eq('user_id', userId)
          .limit(1);
      if ((rows as List).isEmpty) return {'followers_count': 0, 'following_count': 0};
      return {
        'followers_count': (rows.first['followers_count'] as num?)?.toInt() ?? 0,
        'following_count': (rows.first['following_count'] as num?)?.toInt() ?? 0,
      };
    } catch (e) {
      return {'followers_count': 0, 'following_count': 0};
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // COMMUNITY — JOIN / LEAVE
  // O(1) via composite PK insert/delete, trigger updates members_count
  // ──────────────────────────────────────────────────────────────────────────

  /// Join a community. For private communities, status = 'pending'; for public, 'active'.
  static Future<String> joinCommunity(String communityId, {bool isPrivate = false}) async {
    final me = _myId;
    if (me.isEmpty) return '';
    final c = _client;
    if (c == null) return '';

    final status = isPrivate ? 'pending' : 'active';
    try {
      await c.from('community_members').insert({
        'community_id': communityId,
        'user_id': me,
        'role': 'member',
        'status': status,
      });
      _memberStatusCache[communityId] = status;
      debugPrint('FollowService: Joined community $communityId (status=$status)');
      return status;
    } catch (e) {
      if (e.toString().contains('23505')) {
        // Already a member — fetch current status
        return await getMembershipStatus(communityId);
      }
      debugPrint('FollowService: joinCommunity error: $e');
      return '';
    }
  }

  /// Leave a community.
  static Future<bool> leaveCommunity(String communityId) async {
    final me = _myId;
    if (me.isEmpty) return false;
    final c = _client;
    if (c == null) return false;

    try {
      await c
          .from('community_members')
          .delete()
          .eq('community_id', communityId)
          .eq('user_id', me);
      _memberStatusCache.remove(communityId);
      debugPrint('FollowService: Left community $communityId');
      return true;
    } catch (e) {
      debugPrint('FollowService: leaveCommunity error: $e');
      return false;
    }
  }

  /// Get current user's membership status for a community. O(1) cache / O(log n) DB.
  static Future<String> getMembershipStatus(String communityId) async {
    if (_memberStatusCache.containsKey(communityId)) {
      return _memberStatusCache[communityId]!;
    }
    final me = _myId;
    if (me.isEmpty) return '';
    final c = _client;
    if (c == null) return '';

    try {
      final res = await c.rpc('is_community_member', params: {
        'p_user_id': me,
        'p_community_id': communityId,
      });
      final status = res?.toString() ?? '';
      _memberStatusCache[communityId] = status;
      return status;
    } catch (e) {
      // Fallback
      try {
        final rows = await c
            .from('community_members')
            .select('status')
            .eq('community_id', communityId)
            .eq('user_id', me)
            .limit(1);
        final status = (rows as List).isNotEmpty
            ? rows.first['status']?.toString() ?? ''
            : '';
        _memberStatusCache[communityId] = status;
        return status;
      } catch (_) {
        return '';
      }
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // GET COMMUNITIES
  // ──────────────────────────────────────────────────────────────────────────

  /// Fetch all communities ordered by members_count DESC. O(log n) B-Tree scan.
  static Future<List<CommunityModel>> getCommunities({
    String? sportFilter,
    String? searchQuery,
    int limit = 50,
  }) async {
    final c = _client;
    if (c == null) return [];

    try {
      var query = c.from('communities').select();

      if (sportFilter != null && sportFilter.isNotEmpty) {
        query = query.contains('sport_tags', [sportFilter]);
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('name', '%$searchQuery%');
      }

      final rows = await query.order('members_count', ascending: false).limit(limit);
      final me = _myId;
      final communities = (rows as List<dynamic>)
          .map((r) => CommunityModel.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList();

      // Batch resolve membership status from cache
      if (me.isNotEmpty) {
        for (final comm in communities) {
          if (_memberStatusCache.containsKey(comm.id)) {
            comm.memberStatus = _memberStatusCache[comm.id]!;
          }
        }
      }
      return communities;
    } catch (e) {
      debugPrint('FollowService: getCommunities error: $e');
      return [];
    }
  }

  /// Get communities the current user has joined.
  static Future<List<CommunityModel>> getMyCommunities({int limit = 50}) async {
    final me = _myId;
    if (me.isEmpty) return [];
    final c = _client;
    if (c == null) return [];

    try {
      final rows = await c
          .from('community_members')
          .select('community_id, status, role, joined_at, communities(*)')
          .eq('user_id', me)
          .eq('status', 'active')
          .order('joined_at', ascending: false)
          .limit(limit);

      return (rows as List<dynamic>).map((r) {
        final commData = r['communities'] as Map<String, dynamic>? ?? {};
        final comm = CommunityModel.fromMap(commData);
        comm.memberStatus = r['status']?.toString() ?? 'active';
        _memberStatusCache[comm.id] = comm.memberStatus;
        return comm;
      }).toList();
    } catch (e) {
      debugPrint('FollowService: getMyCommunities error: $e');
      return [];
    }
  }

  /// Get community suggestions using Jaccard sport-tag similarity.
  static Future<List<CommunityModel>> getCommunitySuggestions({int limit = 10}) async {
    final me = _myId;
    if (me.isEmpty) return [];
    final c = _client;
    if (c == null) return [];

    try {
      final rows = await c.rpc('get_community_suggestions', params: {
        'p_user_id': me,
        'p_limit': limit,
      });
      return (rows as List<dynamic>)
          .map((r) => CommunityModel.fromMap(Map<String, dynamic>.from(r as Map)))
          .toList();
    } catch (e) {
      debugPrint('FollowService: getCommunitySuggestions error: $e');
      return getCommunities(limit: limit);
    }
  }

  /// Get members of a community. O(log n + k) via B-Tree index.
  static Future<List<FollowUser>> getCommunityMembers(
    String communityId, {
    int limit = 50,
  }) async {
    final c = _client;
    if (c == null) return [];

    try {
      final rows = await c
          .from('community_members')
          .select('user_id, role, status, joined_at, profiles(full_name, username, profile_picture_url, primary_sport)')
          .eq('community_id', communityId)
          .eq('status', 'active')
          .order('joined_at', ascending: false)
          .limit(limit);

      final me = _myId;
      return (rows as List<dynamic>).map((r) {
        final p = r['profiles'] as Map<String, dynamic>? ?? {};
        final uid = r['user_id']?.toString() ?? '';
        return FollowUser(
          id: uid,
          fullName: p['full_name']?.toString() ?? '',
          username: p['username']?.toString() ?? '',
          avatarUrl: p['profile_picture_url']?.toString() ?? '',
          primarySport: p['primary_sport']?.toString() ?? 'cricket',
          followersCount: 0,
          followingCount: 0,
          isFollowing: _followedSet.contains('${me}_$uid'),
        );
      }).toList();
    } catch (e) {
      debugPrint('FollowService: getCommunityMembers error: $e');
      return [];
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // REALTIME SUBSCRIPTION
  // ──────────────────────────────────────────────────────────────────────────

  /// Subscribe to follow events for the current user (realtime).
  static RealtimeChannel? subscribeToFollowEvents({
    required void Function(String followerId) onNewFollower,
    required void Function(String followerId) onUnfollowed,
  }) {
    final c = _client;
    if (c == null) return null;
    final me = _myId;
    if (me.isEmpty) return null;

    try {
      final channel = c.channel('follow_events_$me');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'user_follows',
        callback: (payload) {
          final rec = payload.newRecord;
          if (rec['followee_id']?.toString() == me) {
            final followerId = rec['follower_id']?.toString() ?? '';
            if (followerId.isNotEmpty) onNewFollower(followerId);
          }
        },
      );
      channel.onPostgresChanges(
        event: PostgresChangeEvent.delete,
        schema: 'public',
        table: 'user_follows',
        callback: (payload) {
          final rec = payload.oldRecord;
          if (rec['followee_id']?.toString() == me) {
            final followerId = rec['follower_id']?.toString() ?? '';
            if (followerId.isNotEmpty) onUnfollowed(followerId);
          }
        },
      );
      channel.subscribe();
      return channel;
    } catch (e) {
      debugPrint('FollowService: subscribeToFollowEvents error: $e');
      return null;
    }
  }

  /// Subscribe to community member changes for a specific community.
  static RealtimeChannel? subscribeToCommunityMembers({
    required String communityId,
    required void Function(String userId, String status) onMemberChanged,
  }) {
    final c = _client;
    if (c == null) return null;

    try {
      final channel = c.channel('community_members_$communityId');
      channel.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'community_members',
        callback: (payload) {
          final rec = payload.newRecord.isNotEmpty ? payload.newRecord : payload.oldRecord;
          if (rec['community_id']?.toString() != communityId) return;
          final userId = rec['user_id']?.toString() ?? '';
          final status = rec['status']?.toString() ?? '';
          if (userId.isNotEmpty) onMemberChanged(userId, status);
        },
      );
      channel.subscribe();
      return channel;
    } catch (e) {
      debugPrint('FollowService: subscribeToCommunityMembers error: $e');
      return null;
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // CACHE MANAGEMENT
  // ──────────────────────────────────────────────────────────────────────────

  /// Call on logout to clear all in-memory caches.
  static void clearCache() {
    _followedSet.clear();
    _memberStatusCache.clear();
  }

  /// Pre-warm the follow cache for a list of user IDs (batch load into O(1) set).
  /// Call this on app start or profile screen open for snappy UI.
  static Future<void> preWarmFollowCache(List<String> userIds) async {
    final me = _myId;
    if (me.isEmpty || userIds.isEmpty) return;
    final c = _client;
    if (c == null) return;

    try {
      final rows = await c
          .from('user_follows')
          .select('followee_id')
          .eq('follower_id', me)
          .inFilter('followee_id', userIds);
      for (final r in rows as List) {
        final uid = r['followee_id']?.toString() ?? '';
        if (uid.isNotEmpty) _followedSet.add('${me}_$uid');
      }
    } catch (e) {
      debugPrint('FollowService: preWarmFollowCache error: $e');
    }
  }
}
