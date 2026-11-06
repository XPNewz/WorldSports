import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../../core/models/models.dart';
import '../../core/services/search_service.dart';
import '../../core/services/supabase_service.dart';
import '../../widgets/common_widgets.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final SearchCategory initialCategory;
  final SportType? initialSport;
  final String? initialLocation;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.initialCategory = SearchCategory.all,
    this.initialSport,
    this.initialLocation,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _searchController;
  late SearchCategory _selectedCategory;
  late SportType? _selectedSport;
  late String _selectedLocation;

  SearchSortStrategy _selectedSort = SearchSortStrategy.relevance;
  List<String> _recentSearches = [];
  List<AutocompleteSuggestion> _autocompleteSuggestions = [];
  String? _spellingCorrection;
  ParsedQueryIntent? _parsedIntent;

  void initStateDatabase() {
    _searchController = TextEditingController(text: widget.initialQuery ?? '');
    _selectedCategory = widget.initialCategory;
    _selectedSport = widget.initialSport;
    _selectedLocation = widget.initialLocation ?? 'All Locations';
  }

  @override
  void initState() {
    super.initState();
    initStateDatabase();
    _loadRecentSearches();
    SearchCatalogService.syncDynamicAthletesFromStorage().then((_) {
      if (mounted) setState(() {});
    });
  }

  void _loadRecentSearches() async {
    final history = await SearchHistoryService.getRecentSearches();
    if (mounted) {
      setState(() {
        _recentSearches = history;
      });
    }
  }

  void _onQueryChanged(String val) {
    setState(() {
      _autocompleteSuggestions = SearchCatalogService.getAutocompleteSuggestions(val);
      _spellingCorrection = SearchCatalogService.getSpellCheckCorrection(val);
      _parsedIntent = SearchCatalogService.parseQueryIntent(val);
    });
    _performLiveAthleteSearch(val);
  }

  void _performLiveAthleteSearch(String query) async {
    final clean = query.trim().replaceAll('@', '');
    if (clean.length < 2) return;
    try {
      final remote = await SupabaseService.searchAthletes(clean);
      if (remote.isNotEmpty && mounted) {
        for (final p in remote) {
          SearchCatalogService.registerDynamicAthlete(p);
        }
        setState(() {});
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetAllFilters() {
    setState(() {
      _searchController.clear();
      _selectedCategory = SearchCategory.all;
      _selectedSport = null;
      _selectedLocation = 'All Locations';
      _autocompleteSuggestions = [];
      _spellingCorrection = null;
      _parsedIntent = null;
    });
  }

  bool get _hasActiveFilters {
    return _searchController.text.trim().isNotEmpty ||
        _selectedCategory != SearchCategory.all ||
        _selectedSport != null ||
        _selectedLocation != 'All Locations';
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final matches = SearchCatalogService.advancedSearch(
      query: query,
      category: _selectedCategory,
      location: _selectedLocation,
      sport: _selectedSport,
      sortStrategy: _selectedSort,
    );

    final categoryCounts = SearchCatalogService.getCategoryCounts(
      query: query,
      location: _selectedLocation,
      sport: _selectedSport,
    );

    final activeFiltersCount = (_selectedSport != null ? 1 : 0) +
        (_selectedLocation != 'All Locations' ? 1 : 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            // ── TOP APP BAR & MODERN SEARCH BAR WITH FILTER BUTTON ───────────
            _buildSearchBarHeader(activeFiltersCount),

            // ── PREDICTIVE TYPEAHEAD AUTOCOMPLETE STRIP ───────────────────────
            if (_autocompleteSuggestions.isNotEmpty && _searchController.text.trim().isNotEmpty)
              _buildAutocompleteStrip(),

            // ── "DID YOU MEAN?" SPELL CORRECTION BANNER ────────────────────────
            if (_spellingCorrection != null &&
                _spellingCorrection!.toLowerCase() != _searchController.text.trim().toLowerCase())
              _buildSpellCorrectionBanner(),

            // ── SEMANTIC INTENT CLASSIFICATION CHIPS ─────────────────────────
            if (_parsedIntent != null && _parsedIntent!.hasExtractedFacets)
              _buildDetectedIntentBar(),

            // ── "WHAT TO SEARCH" CATEGORY BAR ──────────────────────────────
            _buildCategoryBar(categoryCounts),

            // ── ACTIVE APPLIED FILTERS CHIPS (SPORT / LOCATION) ─────────────
            if (activeFiltersCount > 0)
              _buildActiveFilterChips(),

            // ── RESULTS HEADER / SUMMARY ────────────────────────────────────
            _buildResultsSummaryBar(matches.length),

            // ── SEARCH RESULTS LIST / EMPTY STATE ───────────────────────────
            Expanded(
              child: matches.isEmpty
                  ? _buildEmptyState()
                  : ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                      itemCount: matches.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (ctx, index) {
                        final match = matches[index];
                        return _buildResultCard(match, query);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 1. Top Search Header with Modern Floating Pill & Filter Button ─────────
  Widget _buildSearchBarHeader(int activeFiltersCount) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          BouncingTap(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF0F172A),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Modern Pill Search Input Field
          Expanded(
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(23),
                border: Border.all(
                  color: _searchController.text.isNotEmpty
                      ? AppColors.primary
                      : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 21,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      autofocus: true,
                      onChanged: _onQueryChanged,
                      onSubmitted: (term) {
                        if (term.trim().isNotEmpty) {
                          SearchHistoryService.addQuery(term.trim());
                          _loadRecentSearches();
                        }
                      },
                      style: GoogleFonts.outfit(
                        color: const Color(0xFF0F172A),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search players, grounds, clubs, teams...',
                        hintStyle: GoogleFonts.outfit(
                          color: const Color(0xFF94A3B8),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    BouncingTap(
                      onTap: () {
                        setState(() {
                          _searchController.clear();
                          _autocompleteSuggestions = [];
                          _spellingCorrection = null;
                          _parsedIntent = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE2E8F0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: Color(0xFF64748B),
                          size: 14,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Filter Button with Active Filter Indicator Badge
          BouncingTap(
            key: const Key('search_filter_button'),
            onTap: () => _openFilterModal(context),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: activeFiltersCount > 0
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: activeFiltersCount > 0
                          ? AppColors.primary
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.tune_rounded,
                    color: activeFiltersCount > 0
                        ? AppColors.primary
                        : const Color(0xFF334155),
                    size: 20,
                  ),
                ),
                if (activeFiltersCount > 0)
                  Positioned(
                    top: -3,
                    right: -3,
                    child: Container(
                      width: 19,
                      height: 19,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$activeFiltersCount',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── 1b. Predictive Typeahead Autocomplete Strip ────────────────────────────
  Widget _buildAutocompleteStrip() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flash_on_rounded, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                'PREDICTIVE SUGGESTIONS',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF64748B),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _autocompleteSuggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (ctx, i) {
                final sug = _autocompleteSuggestions[i];
                return BouncingTap(
                  onTap: () {
                    setState(() {
                      _searchController.text = sug.text;
                      _autocompleteSuggestions = [];
                    });
                    SearchHistoryService.addQuery(sug.text);
                    _loadRecentSearches();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.north_west_rounded, size: 10, color: Color(0xFF64748B)),
                        const SizedBox(width: 5),
                        Text(
                          sug.text,
                          style: GoogleFonts.outfit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          sug.category.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 8.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 1c. "Did You Mean?" Spell Correction Banner ────────────────────────────
  Widget _buildSpellCorrectionBanner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_fix_high_rounded, size: 16, color: Color(0xFF2563EB)),
          const SizedBox(width: 8),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  'Did you mean: ',
                  style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF1E293B)),
                ),
                Text(
                  _spellingCorrection!,
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF2563EB),
                    decoration: TextDecoration.underline,
                  ),
                ),
                Text(
                  '?',
                  style: GoogleFonts.outfit(fontSize: 12.5, color: const Color(0xFF1E293B)),
                ),
              ],
            ),
          ),
          BouncingTap(
            onTap: () {
              setState(() {
                _searchController.text = _spellingCorrection!;
                _spellingCorrection = null;
              });
              SearchHistoryService.addQuery(_searchController.text);
              _loadRecentSearches();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'APPLY',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 1d. Semantic Intent Classification Chips ───────────────────────────────
  Widget _buildDetectedIntentBar() {
    final intent = _parsedIntent;
    if (intent == null) return const SizedBox.shrink();

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const Icon(Icons.psychology_rounded, size: 13, color: Color(0xFF64748B)),
            const SizedBox(width: 4),
            Text(
              'INTENT: ',
              style: GoogleFonts.outfit(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            if (intent.detectedCategory != null) ...[
              _buildIntentPill(
                label: intent.detectedCategory!.label.toUpperCase(),
                color: AppColors.primary,
              ),
              const SizedBox(width: 5),
            ],
            if (intent.detectedSport != null) ...[
              _buildIntentPill(
                label: intent.detectedSport!.name.toUpperCase(),
                color: const Color(0xFF10B981),
              ),
              const SizedBox(width: 5),
            ],
            if (intent.detectedLocation != null) ...[
              _buildIntentPill(
                label: intent.detectedLocation!.toUpperCase(),
                color: const Color(0xFF0F172A),
              ),
              const SizedBox(width: 5),
            ],
            if (intent.maxPrice != null) ...[
              _buildIntentPill(
                label: '<= ₹${intent.maxPrice}',
                color: const Color(0xFFD97706),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIntentPill({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  // ── 2. "What to Search" Category Chip Bar ──────────────────────────────────
  Widget _buildCategoryBar(Map<SearchCategory, int> categoryCounts) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'WHAT TO SEARCH',
                  style: GoogleFonts.outfit(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                if (_hasActiveFilters)
                  BouncingTap(
                    onTap: _resetAllFilters,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.restart_alt_rounded,
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'RESET ALL',
                          style: GoogleFonts.outfit(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: SearchCategory.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (ctx, index) {
                final cat = SearchCategory.values[index];
                final isSelected = _selectedCategory == cat;
                final count = categoryCounts[cat] ?? 0;

                return BouncingTap(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 11),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : const Color(0xFFE2E8F0),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      children: [
                        Icon(
                          cat.icon,
                          size: 15,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          cat.label,
                          style: GoogleFonts.outfit(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.white.withValues(alpha: 0.25)
                                : const Color(0xFFE2E8F0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '$count',
                            style: GoogleFonts.outfit(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── 3. Active Applied Filter Chips (Sport & Location) ──────────────────────
  Widget _buildActiveFilterChips() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          const Icon(Icons.filter_alt_outlined, size: 14, color: AppColors.primary),
          const SizedBox(width: 6),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  if (_selectedSport != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _selectedSport!.name.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 4),
                          BouncingTap(
                            onTap: () => setState(() => _selectedSport = null),
                            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  if (_selectedLocation != 'All Locations') ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on_rounded, size: 12, color: Color(0xFF0F172A)),
                          const SizedBox(width: 3),
                          Text(
                            _selectedLocation,
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 4),
                          BouncingTap(
                            onTap: () => setState(() => _selectedLocation = 'All Locations'),
                            child: const Icon(Icons.close_rounded, size: 14, color: Color(0xFF0F172A)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  BouncingTap(
                    onTap: () => _openFilterModal(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.edit_rounded, size: 12, color: Color(0xFF64748B)),
                          const SizedBox(width: 3),
                          Text(
                            'Edit Filters',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── 4. Dedicated Filter Modal for Sports and Location ──────────────────────
  void _openFilterModal(BuildContext context) {
    SportType? tempSport = _selectedSport;
    String tempLocation = _selectedLocation;
    final locations = SearchCatalogService.getAvailableLocations();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final activeCount = (tempSport != null ? 1 : 0) +
                (tempLocation != 'All Locations' ? 1 : 0);

            return Container(
              height: MediaQuery.of(sheetContext).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Drag Handle
                  const SizedBox(height: 12),
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.tune_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'FILTERS',
                              style: GoogleFonts.outfit(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Refine by sports & location',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (activeCount > 0)
                          BouncingTap(
                            onTap: () {
                              setModalState(() {
                                tempSport = null;
                                tempLocation = 'All Locations';
                              });
                            },
                            child: Text(
                              'RESET',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                          onPressed: () => Navigator.of(sheetContext).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),

                  // Scrollable Filter Sections
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // SECTION 1: BY SPORTS
                          Row(
                            children: [
                              Text(
                                'BY SPORTS',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const Spacer(),
                              if (tempSport != null)
                                BouncingTap(
                                  onTap: () => setModalState(() => tempSport = null),
                                  child: Text(
                                    'Clear Sport',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildModalSportOption(
                                label: 'All Sports',
                                isSelected: tempSport == null,
                                icon: Icons.public_rounded,
                                color: AppColors.primary,
                                onTap: () => setModalState(() => tempSport = null),
                              ),
                              _buildModalSportOption(
                                label: 'Cricket',
                                isSelected: tempSport == SportType.cricket,
                                icon: Icons.sports_cricket_rounded,
                                color: AppColors.cricket,
                                onTap: () => setModalState(() => tempSport = SportType.cricket),
                              ),
                              _buildModalSportOption(
                                label: 'Football',
                                isSelected: tempSport == SportType.football,
                                icon: Icons.sports_soccer_rounded,
                                color: AppColors.football,
                                onTap: () => setModalState(() => tempSport = SportType.football),
                              ),
                              _buildModalSportOption(
                                label: 'Basketball',
                                isSelected: tempSport == SportType.basketball,
                                icon: Icons.sports_basketball_rounded,
                                color: AppColors.basketball,
                                onTap: () => setModalState(() => tempSport = SportType.basketball),
                              ),
                              _buildModalSportOption(
                                label: 'Tennis',
                                isSelected: tempSport == SportType.tennis,
                                icon: Icons.sports_tennis_rounded,
                                color: AppColors.tennis,
                                onTap: () => setModalState(() => tempSport = SportType.tennis),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // SECTION 2: LOCATION
                          Row(
                            children: [
                              Text(
                                'LOCATION',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const Spacer(),
                              if (tempLocation != 'All Locations')
                                BouncingTap(
                                  onTap: () => setModalState(() => tempLocation = 'All Locations'),
                                  child: Text(
                                    'Clear Location',
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: locations.map((loc) {
                              final isSelected = tempLocation == loc;
                              return BouncingTap(
                                onTap: () => setModalState(() => tempLocation = loc),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? const Color(0xFF0F172A)
                                        : const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF0F172A)
                                          : const Color(0xFFE2E8F0),
                                      width: 1.2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 13,
                                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        loc,
                                        style: GoogleFonts.outfit(
                                          fontSize: 12.5,
                                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                          color: isSelected ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Action Bar: APPLY FILTERS
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        if (activeCount > 0) ...[
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              setModalState(() {
                                tempSport = null;
                                tempLocation = 'All Locations';
                              });
                            },
                            child: Text(
                              'CLEAR',
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                        Expanded(
                          child: BouncingTap(
                            onTap: () {
                              setState(() {
                                _selectedSport = tempSport;
                                _selectedLocation = tempLocation;
                              });
                              Navigator.of(sheetContext).pop();
                            },
                            child: Container(
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                activeCount > 0
                                    ? 'APPLY FILTERS ($activeCount)'
                                    : 'APPLY FILTERS',
                                style: GoogleFonts.outfit(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildModalSportOption({
    required String label,
    required bool isSelected,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return BouncingTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.25),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 12.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_rounded,
                size: 14,
                color: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── 3. Results Summary Bar ─────────────────────────────────────────────────
  Widget _buildResultsSummaryBar(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFFF1F5F9),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.format_list_bulleted_rounded,
            size: 14,
            color: Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Text(
            '$count match${count == 1 ? '' : 'es'} found',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          if (_selectedLocation != 'All Locations') ...[
            Text(
              ' • in $_selectedLocation',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
          if (_selectedSport != null) ...[
            Text(
              ' • ${_selectedSport!.name.toUpperCase()}',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
          const Spacer(),
          // AI Sorting Strategy Menu
          PopupMenuButton<SearchSortStrategy>(
            key: const Key('sort_strategy_btn'),
            initialValue: _selectedSort,
            tooltip: 'Sort Results',
            onSelected: (strategy) {
              setState(() {
                _selectedSort = strategy;
              });
            },
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text(
                    _selectedSort == SearchSortStrategy.relevance
                        ? 'AI Relevance'
                        : _selectedSort.label,
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.arrow_drop_down_rounded, size: 16, color: Color(0xFF64748B)),
                ],
              ),
            ),
            itemBuilder: (ctx) => SearchSortStrategy.values.map((strat) {
              return PopupMenuItem<SearchSortStrategy>(
                value: strat,
                child: Row(
                  children: [
                    Icon(
                      _selectedSort == strat ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                      size: 15,
                      color: _selectedSort == strat ? AppColors.primary : const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strat.label,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          fontWeight: _selectedSort == strat ? FontWeight.w800 : FontWeight.w600,
                          color: _selectedSort == strat ? AppColors.primary : const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 4. Result Card with High-End Category Badges & Action Buttons ───────────
  Widget _buildResultCard(dynamic result, String currentQuery) {
    final SearchResultItem item = result is SearchResultMatch ? result.item : (result as SearchResultItem);
    final SearchResultMatch? match = result is SearchResultMatch ? result : null;

    return BouncingTap(
      onTap: () => _openEntityDetailsModal(context, item),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Card Row: Icon/Avatar + Title + Badges
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category / Entity Avatar Container
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: item.accentColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: item.accentColor.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(item.icon, color: item.accentColor, size: 24),
                  ),
                  const SizedBox(width: 12),

                  // Name & Subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                item.title,
                                style: GoogleFonts.outfit(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (match?.isVerifiedPro == true)
                              const Padding(
                                padding: EdgeInsets.only(left: 4),
                                child: Icon(Icons.verified_rounded, size: 15, color: Color(0xFF0284C7)),
                              ),
                            const SizedBox(width: 6),
                            // Category Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category.label.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF475569),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            // Algorithmic Match Percentage Badge
                            if (match != null && currentQuery.trim().isNotEmpty) ...[
                              const SizedBox(width: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: match.matchPercentage >= 90
                                      ? const Color(0xFF10B981).withValues(alpha: 0.12)
                                      : const Color(0xFF0284C7).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: match.matchPercentage >= 90
                                        ? const Color(0xFF10B981).withValues(alpha: 0.3)
                                        : const Color(0xFF0284C7).withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  '${match.matchPercentage}% MATCH',
                                  style: GoogleFonts.outfit(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: match.matchPercentage >= 90
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF0284C7),
                                    letterSpacing: 0.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Location Pin Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: Color(0xFF64748B),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          item.location.split(',').first.trim(),
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Description Body (Matches query directly)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: _buildHighlightedDescription(
                match?.contextualSnippet.isNotEmpty == true
                    ? match!.contextualSnippet
                    : item.description,
                currentQuery,
              ),
            ),

            const SizedBox(height: 10),

            // Footer Attributes & Action Button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(
                  top: BorderSide(color: Color(0xFFF1F5F9), width: 1),
                ),
              ),
              child: Row(
                children: [
                  // Sport Tags
                  Wrap(
                    spacing: 5,
                    children: [
                      if (item.sport != null)
                        _buildMiniTag(
                          label: item.sport!.name.toUpperCase(),
                          color: item.accentColor,
                        )
                      else if (item.sports.isNotEmpty)
                        _buildMiniTag(
                          label: '${item.sports.length} SPORTS',
                          color: AppColors.primary,
                        )
                      else
                        _buildMiniTag(
                          label: 'MULTI-SPORT',
                          color: AppColors.primary,
                        ),
                      if (item.metadata.containsKey('price'))
                        _buildMiniTag(
                          label: '${item.metadata['price']}',
                          color: const Color(0xFF0F172A),
                        ),
                      if (item.metadata.containsKey('members'))
                        _buildMiniTag(
                          label: '${item.metadata['members']} Members',
                          color: const Color(0xFF475569),
                        ),
                      if (item.metadata.containsKey('rating'))
                        _buildMiniTag(
                          label: '★ ${item.metadata['rating']}',
                          color: AppColors.gold,
                        ),
                    ],
                  ),
                  const Spacer(),
                  // Action CTA
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getCategoryCtaLabel(item.category),
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniTag({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 0.8),
      ),
      child: Text(
        label,
        style: GoogleFonts.outfit(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  String _getCategoryCtaLabel(SearchCategory cat) {
    switch (cat) {
      case SearchCategory.all:
        return 'DETAILS';
      case SearchCategory.players:
        return 'VIEW PROFILE';
      case SearchCategory.teams:
        return 'VIEW SQUAD';
      case SearchCategory.grounds:
        return 'BOOK GROUND';
      case SearchCategory.communities:
        return 'JOIN HUB';
      case SearchCategory.clubs:
        return 'CLUB SPECS';
      case SearchCategory.associations:
        return 'VIEW BYLAWS';
    }
  }

  /// Highlights search query inside description for clear feedback to the user.
  Widget _buildHighlightedDescription(String description, String query) {
    final cleanQ = query.trim().toLowerCase();
    if (cleanQ.isEmpty || !description.toLowerCase().contains(cleanQ)) {
      return Text(
        description,
        style: GoogleFonts.outfit(
          fontSize: 12.5,
          color: const Color(0xFF475569),
          height: 1.4,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      );
    }

    final lowerDesc = description.toLowerCase();
    final matchIndex = lowerDesc.indexOf(cleanQ);
    final before = description.substring(0, matchIndex);
    final match = description.substring(matchIndex, matchIndex + cleanQ.length);
    final after = description.substring(matchIndex + cleanQ.length);

    return RichText(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        style: GoogleFonts.outfit(
          fontSize: 12.5,
          color: const Color(0xFF475569),
          height: 1.4,
        ),
        children: [
          TextSpan(text: before),
          TextSpan(
            text: match,
            style: GoogleFonts.outfit(
              backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(text: after),
        ],
      ),
    );
  }

  // ── 5. Empty State & Trending Suggestions ──────────────────────────────────
  Widget _buildEmptyState() {
    final popularKeywords = SearchCatalogService.getPopularKeywords();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: Color(0xFF94A3B8),
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Matches Found',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'We couldn\'t find any entities matching your current query or filter combination.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: const Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          BouncingTap(
            onTap: _resetAllFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restart_alt_rounded, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'RESET ALL FILTERS',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: 28),
            Row(
              children: [
                const Icon(Icons.history_rounded, size: 14, color: Color(0xFF64748B)),
                const SizedBox(width: 5),
                Text(
                  'RECENT SEARCHES',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                BouncingTap(
                  onTap: () async {
                    await SearchHistoryService.clearAll();
                    _loadRecentSearches();
                  },
                  child: Text(
                    'CLEAR',
                    style: GoogleFonts.outfit(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _recentSearches.map((term) {
                return Container(
                  padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BouncingTap(
                        onTap: () {
                          setState(() {
                            _searchController.text = term;
                          });
                          _onQueryChanged(term);
                        },
                        child: Text(
                          term,
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      BouncingTap(
                        onTap: () async {
                          await SearchHistoryService.removeQuery(term);
                          _loadRecentSearches();
                        },
                        child: const Icon(Icons.close_rounded, size: 13, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 36),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'POPULAR SEARCHES & TRENDING TERMS',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF64748B),
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: popularKeywords.map((term) {
              return BouncingTap(
                onTap: () {
                  setState(() {
                    _searchController.text = term;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        term,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ── 6. Entity Details Modal ────────────────────────────────────────────────
  void _openEntityDetailsModal(BuildContext context, SearchResultItem item) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        height: MediaQuery.of(ctx).size.height * 0.82,
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row: Avatar, Title, Category Badge, Close
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: item.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: item.accentColor.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(item.icon, color: item.accentColor, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                  splashRadius: 20,
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Metadata Chips
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildModalBadge(
                  icon: Icons.category_rounded,
                  label: item.category.label.toUpperCase(),
                  color: item.accentColor,
                ),
                _buildModalBadge(
                  icon: Icons.location_on_rounded,
                  label: item.location,
                  color: const Color(0xFF0F172A),
                ),
                if (item.sport != null)
                  _buildModalBadge(
                    icon: Icons.sports_rounded,
                    label: item.sport!.name.toUpperCase(),
                    color: item.accentColor,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            const SizedBox(height: 14),

            // Description Body
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'OVERVIEW & SPECIFICATIONS',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: const Color(0xFF334155),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Metadata details grid
                    if (item.metadata.isNotEmpty) ...[
                      Text(
                        'KEY INFORMATION',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: item.metadata.entries.map((e) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    '${e.value}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Actions: Primary CTA + Share
            Row(
              children: [
                Expanded(
                  child: BouncingTap(
                    onTap: () {
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: item.accentColor,
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                            'Action confirmed for ${item.title}!',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: item.accentColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _getCategoryCtaLabel(item.category),
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                BouncingTap(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: const Color(0xFF0F172A),
                        behavior: SnackBarBehavior.floating,
                        content: Text(
                          'Link copied for ${item.title}',
                          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: const Icon(
                      Icons.share_outlined,
                      color: Color(0xFF0F172A),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModalBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
