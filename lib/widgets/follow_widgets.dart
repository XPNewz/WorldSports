import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_theme.dart';
import '../core/services/follow_community_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE FOLLOW BUTTON
// Drop this anywhere — profile pages, athlete cards, search results.
//
// DSA note: uses FollowCommunityService's in-memory Set for O(1) state reads
// and optimistic UI updates for instant feedback before server confirms.
// ─────────────────────────────────────────────────────────────────────────────

class FollowButton extends StatefulWidget {
  /// The auth UUID of the user to follow/unfollow.
  final String targetUserId;

  /// Initial state — if known, pass true/false to skip a network call.
  /// If null, the button will auto-resolve on first build.
  final bool? initialIsFollowing;

  /// Callback fired after state changes. Receives new isFollowing value.
  final ValueChanged<bool>? onChanged;

  /// Compact = icon-only pill; full = text + icon.
  final bool compact;

  const FollowButton({
    super.key,
    required this.targetUserId,
    this.initialIsFollowing,
    this.onChanged,
    this.compact = false,
  });

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton>
    with SingleTickerProviderStateMixin {
  bool _isFollowing = false;
  bool _loading = true;
  late AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.92,
      upperBound: 1.0,
      value: 1.0,
    );

    if (widget.initialIsFollowing != null) {
      _isFollowing = widget.initialIsFollowing!;
      _loading = false;
    } else {
      _resolveFollowState();
    }
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Future<void> _resolveFollowState() async {
    final state = await FollowCommunityService.isFollowing(widget.targetUserId);
    if (mounted) setState(() { _isFollowing = state; _loading = false; });
  }

  Future<void> _toggle() async {
    // Optimistic update + micro-animation
    _bounce.reverse().then((_) => _bounce.forward());
    final prev = _isFollowing;
    setState(() { _isFollowing = !_isFollowing; _loading = false; });

    final newState = await FollowCommunityService.toggleFollow(widget.targetUserId);
    if (!mounted) return;
    if (newState != !prev) {
      // Server disagreed — revert
      setState(() => _isFollowing = newState);
    }
    widget.onChanged?.call(newState);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(
        width: widget.compact ? 36 : 90,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(30),
        ),
        child: const Center(
          child: SizedBox(
            width: 14, height: 14,
            child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
          ),
        ),
      );
    }

    return ScaleTransition(
      scale: _bounce,
      child: GestureDetector(
        onTap: _toggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(
            horizontal: widget.compact ? 10 : 16,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            gradient: _isFollowing ? null : AppColors.primaryGradient,
            color: _isFollowing ? const Color(0xFFF1F5F9) : null,
            borderRadius: BorderRadius.circular(30),
            border: _isFollowing
                ? Border.all(color: const Color(0xFFE2E8F0), width: 1.5)
                : null,
            boxShadow: _isFollowing
                ? null
                : [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _isFollowing ? Icons.check_rounded : Icons.person_add_rounded,
                size: 15,
                color: _isFollowing ? AppColors.textSecondary : Colors.white,
              ),
              if (!widget.compact) ...[
                const SizedBox(width: 5),
                Text(
                  _isFollowing ? 'Following' : 'Follow',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: _isFollowing ? AppColors.textSecondary : Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FOLLOW COUNT DISPLAY
// Shows "X followers · Y following" with live-update capability.
// ─────────────────────────────────────────────────────────────────────────────

class FollowCountRow extends StatefulWidget {
  /// Auth UUID of the user to show counts for.
  final String userId;

  /// Pre-loaded counts — if provided, no network call on init.
  final int? initialFollowers;
  final int? initialFollowing;

  const FollowCountRow({
    super.key,
    required this.userId,
    this.initialFollowers,
    this.initialFollowing,
  });

  @override
  State<FollowCountRow> createState() => _FollowCountRowState();
}

class _FollowCountRowState extends State<FollowCountRow> {
  int _followers = 0;
  int _following = 0;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFollowers != null && widget.initialFollowing != null) {
      _followers = widget.initialFollowers!;
      _following = widget.initialFollowing!;
      _loaded = true;
    } else {
      _loadCounts();
    }
  }

  Future<void> _loadCounts() async {
    final counts = await FollowCommunityService.getFollowCounts(widget.userId);
    if (mounted) {
      setState(() {
        _followers = counts['followers_count'] ?? 0;
        _following = counts['following_count'] ?? 0;
        _loaded = true;
      });
    }
  }

  String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SizedBox(
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CountStat(label: 'Followers', value: _fmt(_followers)),
        Container(width: 1, height: 24, color: const Color(0xFFE5E5E5),
            margin: const EdgeInsets.symmetric(horizontal: 16)),
        _CountStat(label: 'Following', value: _fmt(_following)),
      ],
    );
  }
}

class _CountStat extends StatelessWidget {
  final String label;
  final String value;
  const _CountStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY JOIN BUTTON
// Drop-in button for community cards anywhere in the app.
// ─────────────────────────────────────────────────────────────────────────────

class CommunityJoinButton extends StatefulWidget {
  final String communityId;
  final bool isPrivate;
  final String? initialStatus; // 'active', 'pending', ''
  final ValueChanged<String>? onChanged; // passes new status

  const CommunityJoinButton({
    super.key,
    required this.communityId,
    this.isPrivate = false,
    this.initialStatus,
    this.onChanged,
  });

  @override
  State<CommunityJoinButton> createState() => _CommunityJoinButtonState();
}

class _CommunityJoinButtonState extends State<CommunityJoinButton> {
  String _status = '';
  bool _loading = true;

  bool get _isMember => _status == 'active';
  bool get _isPending => _status == 'pending';

  @override
  void initState() {
    super.initState();
    if (widget.initialStatus != null) {
      _status = widget.initialStatus!;
      _loading = false;
    } else {
      _resolveStatus();
    }
  }

  Future<void> _resolveStatus() async {
    final s = await FollowCommunityService.getMembershipStatus(widget.communityId);
    if (mounted) setState(() { _status = s; _loading = false; });
  }

  Future<void> _toggle() async {
    setState(() => _loading = true);
    if (_isMember || _isPending) {
      final ok = await FollowCommunityService.leaveCommunity(widget.communityId);
      if (mounted) {
        setState(() { _status = ok ? '' : _status; _loading = false; });
        if (ok) widget.onChanged?.call('');
      }
    } else {
      final s = await FollowCommunityService.joinCommunity(
        widget.communityId,
        isPrivate: widget.isPrivate,
      );
      if (mounted) {
        setState(() { _status = s; _loading = false; });
        widget.onChanged?.call(s);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _loading ? null : _toggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
        decoration: BoxDecoration(
          gradient: _isMember || _isPending ? null : AppColors.primaryGradient,
          color: _isMember ? const Color(0xFFF1F5F9) : (_isPending ? AppColors.primaryLight : null),
          borderRadius: BorderRadius.circular(30),
          border: (_isMember || _isPending)
              ? Border.all(color: const Color(0xFFE2E8F0), width: 1.5)
              : null,
        ),
        child: _loading
            ? SizedBox(
                width: 16, height: 16,
                child: CircularProgressIndicator(
                  color: _isMember ? AppColors.textMuted : Colors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                _isMember
                    ? 'Joined'
                    : (_isPending
                        ? 'Pending'
                        : (widget.isPrivate ? 'Request to Join' : 'Join')),
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _isMember
                      ? AppColors.textSecondary
                      : (_isPending ? AppColors.primary : Colors.white),
                ),
              ),
      ),
    );
  }
}
