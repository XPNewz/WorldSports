import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/theme/app_theme.dart';

class AdService {
  static final List<AdModel> _allAds = [
    AdModel(
      id: 'ad_001',
      advertiserName: 'SS Cricket Gear',
      advertiserHandle: '@SS_Cricket',
      isVerified: true,
      badgeText: 'Promoted',
      headline: 'Pro-Grade English Willow Bats & Tournament Kits',
      bodyText:
          'Elevate your innings with ICC-approved mastercraft bats hand-picked for explosive stroke play. Flat 35% off on tournament kits! Use code WORLD35 at checkout. #CricketGear #ProAthlete #MatchWinner',
      ctaText: 'Shop Now',
      ctaUrl: 'https://sscricket.com/pro-willow',
      promoCode: 'WORLD35',
      discountTag: '35% OFF',
      targetSport: SportType.cricket,
      type: AdType.promotedPost,
      rating: 4.9,
      reviewsCount: 2840,
    ),
    AdModel(
      id: 'ad_002',
      advertiserName: 'TurfNation Arena',
      advertiserHandle: '@TurfNation_In',
      isVerified: true,
      badgeText: 'Promoted • Sponsored',
      headline: 'Book FIFA & ICC Standard Floodlit Turfs Near You',
      bodyText:
          'Instant slot confirmation for Box Cricket and 7v7 Football across 25+ city venues. Olympic turf quality, pro LED floodlights, locker rooms & free parking. #TurfBooking #WeekendMatch #NightTournament',
      ctaText: 'Book Ground',
      ctaUrl: 'https://turfnation.in/book',
      promoCode: 'NIGHT20',
      discountTag: '20% CASHBACK',
      targetSport: SportType.football,
      type: AdType.promotedPost,
      rating: 4.8,
      reviewsCount: 1650,
    ),
    AdModel(
      id: 'ad_003',
      advertiserName: 'Gatorade Zero Fuel',
      advertiserHandle: '@Gatorade_India',
      isVerified: true,
      badgeText: 'Official Partner',
      headline: 'Official Match Day Electrolyte & Rapid Rehydration',
      bodyText:
          'Replenish essential electrolytes lost during high-intensity athletic scrambles. Scientifically calibrated to prevent muscular cramps and fatigue. Trusted by champions worldwide. #FuelYourGame',
      ctaText: 'Order Pack',
      ctaUrl: 'https://gatorade.com/zero',
      promoCode: 'GATOR25',
      discountTag: 'PARTNER PERK',
      targetSport: null,
      type: AdType.scoreboardSponsor,
      rating: 4.95,
      reviewsCount: 5120,
    ),
    AdModel(
      id: 'ad_004',
      advertiserName: 'Wilson Pro Tennis',
      advertiserHandle: '@WilsonTennis',
      isVerified: true,
      badgeText: 'Promoted',
      headline: 'Wilson Pro Staff & Blade Racquet Championship Series',
      bodyText:
          'Precision string tension, aerodynamic graphite beam, and tournament-grade balance. Complimentary dampeners and overgrip bundle with every pre-order. #WilsonTennis #GrandSlamReady',
      ctaText: 'Claim Deal',
      ctaUrl: 'https://wilson.com/tennis',
      promoCode: 'WILSON15',
      discountTag: '15% OFF',
      targetSport: SportType.tennis,
      type: AdType.banner,
      rating: 4.88,
      reviewsCount: 920,
    ),
    AdModel(
      id: 'ad_005',
      advertiserName: 'Spalding All-Court',
      advertiserHandle: '@SpaldingHoops',
      isVerified: true,
      badgeText: 'Promoted',
      headline: 'Official FIBA Standard Composite Leather Game Balls',
      bodyText:
          'Superior pebble grain grip and true-bounce response engineered for outdoor blacktop and indoor hardwood tournament courts. #BallIsLife #SpaldingHoops',
      ctaText: 'Explore Gear',
      ctaUrl: 'https://spalding.com/hoops',
      promoCode: 'HOOPS20',
      discountTag: 'TOP RATED',
      targetSport: SportType.basketball,
      type: AdType.banner,
      rating: 4.92,
      reviewsCount: 1430,
    ),
  ];

  static List<AdModel> getPromotedPosts({SportType? sport}) {
    if (sport == null) {
      return _allAds
          .where((ad) => ad.type == AdType.promotedPost || ad.targetSport == null)
          .toList();
    }
    final filtered = _allAds
        .where((ad) =>
            ad.targetSport == sport ||
            (ad.type == AdType.promotedPost && ad.targetSport == null))
        .toList();
    return filtered.isNotEmpty
        ? filtered
        : _allAds.where((ad) => ad.type == AdType.promotedPost).toList();
  }

  static AdModel getBannerAd({SportType? sport}) {
    if (sport != null) {
      final match = _allAds.firstWhere(
        (ad) => ad.targetSport == sport && ad.type == AdType.banner,
        orElse: () => _allAds.firstWhere(
          (ad) => ad.targetSport == sport,
          orElse: () => _allAds[1],
        ),
      );
      return match;
    }
    return _allAds[1]; // TurfNation Arena by default
  }

  static AdModel getScoreboardSponsor({SportType? sport}) {
    final sponsor = _allAds.firstWhere(
      (ad) => ad.type == AdType.scoreboardSponsor,
      orElse: () => _allAds[2],
    );
    return sponsor;
  }

  static void recordImpression(String adId) {
    try {
      final ad = _allAds.firstWhere((a) => a.id == adId);
      ad.impressions++;
    } catch (_) {}
  }

  static void recordClick(String adId) {
    try {
      final ad = _allAds.firstWhere((a) => a.id == adId);
      ad.clicks++;
    } catch (_) {}
  }

  static void showAdDetailsModal(BuildContext context, AdModel ad) {
    recordClick(ad.id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cellBorderColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Header: Brand avatar + Name + Verified + Badge
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.7),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      ad.advertiserName.substring(0, 1).toUpperCase(),
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              ad.advertiserName,
                              style: GoogleFonts.outfit(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            if (ad.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified_rounded,
                                color: Color(0xFF1D9BF0),
                                size: 16,
                              ),
                            ],
                          ],
                        ),
                        Text(
                          ad.advertiserHandle,
                          style: GoogleFonts.outfit(
                            color: AppColors.textMuted,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.campaign_rounded,
                          color: AppColors.primary,
                          size: 13,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ad.badgeText,
                          style: GoogleFonts.outfit(
                            color: AppColors.primary,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Headline & Description
              Text(
                ad.headline,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ad.bodyText,
                style: GoogleFonts.outfit(
                  color: AppColors.textSecondary,
                  fontSize: 13.5,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Coupon code box if present
              if (ad.promoCode != null) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.discount_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SPECIAL PROMO CODE',
                            style: GoogleFonts.outfit(
                              color: AppColors.textMuted,
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Text(
                            ad.promoCode!,
                            style: GoogleFonts.outfit(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      ElevatedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: ad.promoCode!));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.white,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF10B981)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Promo code ${ad.promoCode} copied!',
                                    style: GoogleFonts.outfit(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: Text(
                          'COPY',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryLight,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // CTA Action Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.white,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        content: Row(
                          children: [
                            const Icon(Icons.open_in_new_rounded,
                                color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Redirecting to ${ad.advertiserName} (${ad.ctaUrl})...',
                                style: GoogleFonts.outfit(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ad.ctaText,
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
