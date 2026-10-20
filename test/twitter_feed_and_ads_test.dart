import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:worldsports/core/models/models.dart';
import 'package:worldsports/core/services/ad_service.dart';
import 'package:worldsports/core/state/app_state.dart';
import 'package:worldsports/core/theme/app_theme.dart';
import 'package:worldsports/screens/home/home_screen.dart';
import 'package:worldsports/screens/scores/scores_screen.dart';

void main() {
  group('AdService Logic & Targeting Tests', () {
    test('AdService returns targeted and default ads correctly', () {
      final bannerCricket = AdService.getBannerAd(sport: SportType.cricket);
      expect(bannerCricket, isNotNull);
      expect(bannerCricket.headline, isNotEmpty);

      final bannerTennis = AdService.getBannerAd(sport: SportType.tennis);
      expect(bannerTennis.advertiserName, contains('Wilson'));
      expect(bannerTennis.targetSport, equals(SportType.tennis));

      final scoreboardSponsor = AdService.getScoreboardSponsor();
      expect(scoreboardSponsor.advertiserName, contains('Gatorade'));
      expect(scoreboardSponsor.type, equals(AdType.scoreboardSponsor));
      expect(scoreboardSponsor.promoCode, equals('GATOR25'));

      final promotedPosts = AdService.getPromotedPosts();
      expect(promotedPosts.length, greaterThanOrEqualTo(2));
      expect(promotedPosts.first.badgeText, contains('Promoted'));
    });

    test('AdService impression and click tracking increments correctly', () {
      final ad = AdService.getScoreboardSponsor();
      final initialImpressions = ad.impressions;
      final initialClicks = ad.clicks;

      AdService.recordImpression(ad.id);
      expect(ad.impressions, equals(initialImpressions + 1));

      AdService.recordClick(ad.id);
      expect(ad.clicks, equals(initialClicks + 1));
    });
  });

  group('Twitter Feed & In-Feed Promoted Ads Tests on HomeScreen', () {
    Widget buildTestHomeScreen(AppState appState) {
      appState.login(MockData.demoPlayer);
      return ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: HomeScreen(),
          ),
        ),
      );
    }

    testWidgets('HomeScreen renders ModernSportsBannerAd and Sports Wire Tweet Feed', (tester) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = AppState();
      await tester.pumpWidget(buildTestHomeScreen(appState));
      await tester.pump(const Duration(milliseconds: 300));

      // 1. Verify Arena Sponsor Banner is displayed
      expect(find.text('OFFICIAL ARENA PARTNER'), findsOneWidget);
      expect(find.text('TurfNation Arena'), findsOneWidget);

      // 2. Verify Sports Wire & Live Feed header
      expect(find.text('Sports Wire & Live Feed'), findsOneWidget);
      expect(find.text('Latest Posts'), findsOneWidget);

      // 3. Verify Twitter-style post elements: Author, Handle, Verified checkmark
      expect(find.text('Mumbai Cricket Association'), findsOneWidget);
      expect(find.text('@MCA_Cricket'), findsOneWidget);
      expect(find.byIcon(Icons.verified), findsWidgets);

      // 4. Verify in-feed Promoted Ad Tweet is interleaved
      expect(find.text('PROMOTED'), findsWidgets);
      expect(find.text('SS Cricket Gear'), findsOneWidget);
      expect(find.text('@SS_Cricket'), findsOneWidget);
    });

    testWidgets('Tapping like, repost and bookmark toggles Tweet interaction states', (tester) async {
      final appState = AppState();
      await tester.pumpWidget(buildTestHomeScreen(appState));
      await tester.pump(const Duration(milliseconds: 300));

      final firstPost = appState.feedPosts.first;
      final initialLikes = firstPost.likes;
      final initialReposts = firstPost.reposts;

      // 1. Test Like Toggle
      appState.togglePostLike(firstPost.id);
      await tester.pump(const Duration(milliseconds: 100));
      expect(firstPost.isLiked, isTrue);
      expect(firstPost.likes, equals(initialLikes + 1));

      appState.togglePostLike(firstPost.id);
      await tester.pump(const Duration(milliseconds: 100));
      expect(firstPost.isLiked, isFalse);
      expect(firstPost.likes, equals(initialLikes));

      // 2. Test Repost Toggle
      appState.togglePostRepost(firstPost.id);
      await tester.pump(const Duration(milliseconds: 100));
      expect(firstPost.isReposted, isTrue);
      expect(firstPost.reposts, equals(initialReposts + 1));

      // 3. Test Bookmark Toggle
      expect(firstPost.isBookmarked, isFalse);
      appState.togglePostBookmark(firstPost.id);
      await tester.pump(const Duration(milliseconds: 100));
      expect(firstPost.isBookmarked, isTrue);
    });

    testWidgets('Posts and updates render full width without left/right box borders', (tester) async {
      tester.view.physicalSize = const Size(1080, 3200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final appState = AppState();
      await tester.pumpWidget(buildTestHomeScreen(appState));
      await tester.pump(const Duration(milliseconds: 300));

      // Post text should exist
      final postTextFinder = find.text('Mumbai Cricket Association');
      expect(postTextFinder, findsOneWidget);

      // Verify that post container has no left/right margins (width spans full screen)
      final postRenderBox = tester.renderObject(postTextFinder);
      expect(postRenderBox, isNotNull);

      // Verify upcoming fixtures section displays horizontal carousel like live arena matches
      await tester.scrollUntilVisible(find.text('Upcoming Fixtures'), 500, scrollable: find.byType(Scrollable).first);
      expect(find.text('Upcoming Fixtures'), findsOneWidget);
      final upcomingHorizontalList = find.byWidgetPredicate(
        (w) => w is ListView && w.scrollDirection == Axis.horizontal,
      );
      // Both Live Arena Matches, Nearby Live Matches, and Upcoming Fixtures are horizontal ListViews
      expect(upcomingHorizontalList, findsWidgets);
    });
  });

  group('ScoresScreen Scoreboard Sponsor Ad Tests', () {
    Widget buildTestScoresScreen(AppState appState) {
      appState.login(MockData.demoPlayer);
      return ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ScoresScreen(),
        ),
      );
    }

    testWidgets('ScoresScreen renders Match Day Sponsor Ad banner', (tester) async {
      final appState = AppState();
      await tester.pumpWidget(buildTestScoresScreen(appState));
      await tester.pump(const Duration(milliseconds: 300));

      // Verify Scoreboard Sponsor Ad banner
      expect(find.text('MATCH DAY SPONSOR'), findsOneWidget);
      expect(find.textContaining('Gatorade Zero Fuel'), findsOneWidget);
      expect(find.text('CODE: GATOR25'), findsOneWidget);
    });
  });
}
