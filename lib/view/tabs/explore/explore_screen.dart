import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../util/color_resources.dart';
import '../../../util/size_extension.dart';
import '../../../helper/sb_helper.dart';
import '../../../theme/theme_manager.dart';
import '../../../widgets/coming_soon_dialog.dart';
import 'explore_vm.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // No automatic browser opening - let users choose from search results
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ExploreVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: () => ComingSoonDialog.show(
          context,
          title: "Add dApp",
          description:
          "Connect and interact with decentralized applications from the blockchain ecosystem.",
          iconPath: "assets/svgs/wallet_home/explore.svg",
        ),
        backgroundColor:
        themeManager.currentTheme.floatingActionButtonTheme.backgroundColor,
        child: Icon(
          Icons.add,
          color:
          themeManager.currentTheme.floatingActionButtonTheme.foregroundColor,
          size: 6.w,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SB.h(2.h),

                // ✅ Fixed Search Bar
                _buildSearchBar(context, themeManager),

                SB.h(3.h),

                // ✅ If searching, show results, else default content
                if (vm.isSearching)
                  _buildSearchResults(context, vm, themeManager)
                else ...[
                  _buildQuestCard(context),
                  SB.h(3.h),
                  _buildDAppSection(context, "Top dApp", vm.topDApps, themeManager),
                  SB.h(3.h),
                  _buildDAppSection(
                      context, "Latest dApp", vm.latestDApps, themeManager),
                  SB.h(3.h),
                  _buildTopDAppWithFilters(
                      context, vm.topDApps, themeManager),
                ],

                SB.h(4.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// ✅ Fixed Search Bar
  Widget _buildSearchBar(BuildContext context, ThemeManager themeManager) {
    final vm = context.watch<ExploreVM>();

    return Container(
      height: 6.h,
      child: TextField(
        controller: vm.searchController,
        style: themeManager.currentTheme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: "Search dApps...",
          hintStyle: themeManager.currentTheme.textTheme.bodyLarge?.copyWith(
            color: themeManager.currentTheme.hintColor,
          ),
          filled: true,
          fillColor: themeManager.currentTheme.colorScheme.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          prefixIcon: Icon(Icons.search, color: AppColors.primary, size: 5.w),
          suffixIcon: vm.searchQuery.isNotEmpty
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.public,
                      color: AppColors.primary.withOpacity(0.7),
                      size: 4.5.w,
                    ),
                    SizedBox(width: 1.w),
                    IconButton(
                      icon: Icon(Icons.clear, color: AppColors.primary, size: 5.w),
                      onPressed: vm.clearSearch,
                    ),
                  ],
                )
              : Icon(
                  Icons.public,
                  color: AppColors.primary.withOpacity(0.7),
                  size: 4.5.w,
                ),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildQuestCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "In-app Quest",
            style: TextStyle(
              fontSize: 3.2.sp,
              color: Colors.white70,
              fontFamily: "Rubik",
            ),
          ),
          SB.h(1.5.h),
          Row(
            children: [
              Container(
                width: 14.w,
                height: 14.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.3),
                ),
                child: Center(
                  child: Image.asset(
                    "assets/svgs/wallet_home/hero_section/binance.png",
                    width: 9.w,
                    height: 9.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              SB.w(3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Earn Trust Points and unlock future rewards",
                      style: TextStyle(
                        fontSize: 3.8.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: "Rubik",
                        height: 1.1,
                      ),
                    ),
                    SB.h(1.2.h),
                    Container(
                      padding:
                      EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 0.6.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.card_giftcard,
                              color: Colors.white, size: 2.8.w),
                          SB.w(1.2.w),
                          Flexible(
                            child: Text(
                              "Up to 100 Trust Points daily",
                              style: TextStyle(
                                fontSize: 2.4.sp,
                                color: Colors.white,
                                fontFamily: "Rubik",
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SB.w(2.w),
              GestureDetector(
                onTap: () => ComingSoonDialog.show(
                  context,
                  title: "In-App Quest",
                  description:
                  "Complete quests to earn Trust Points and unlock future rewards. This feature will be available soon.",
                  iconPath: "assets/svgs/wallet_home/explore.svg",
                ),
                child: Container(
                  padding:
                  EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.2.h),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    "Start →",
                    style: TextStyle(
                      fontSize: 3.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: "Rubik",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDAppSection(BuildContext context, String title,
      List<DAppItem> dApps, ThemeManager themeManager) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                fontSize: 4.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _openAllDAppsInBrowser(context),
              child: Text(
                "View all",
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 3.sp,
                  color: themeManager.currentTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SB.h(2.h),
        SizedBox(
          height: 11.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dApps.length,
            separatorBuilder: (_, __) => SizedBox(width: 2.5.w),
            itemBuilder: (context, index) {
              final dapp = dApps[index];
              return GestureDetector(
                onTap: () => _openDAppInBrowser(context, dapp),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 38.w,
                    height: 11.h,
                    color: Colors.white,
                    child: Image.asset(
                      dapp.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTopDAppWithFilters(BuildContext context, List<DAppItem> dApps,
      ThemeManager themeManager) {
    final vm = context.watch<ExploreVM>();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Top dApp",
              style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                fontSize: 4.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => _openAllDAppsInBrowser(context),
              child: Text(
                "View all",
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 3.sp,
                  color: themeManager.currentTheme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
        SB.h(2.h),
        Row(
          children: [
            _buildFilterButton(context, "Trending dApp", vm.selectedFilter == "Trending dApp", themeManager),
            SB.w(2.w),
            _buildFilterButton(context, "Latest dApp", vm.selectedFilter == "Latest dApp", themeManager),
            SB.w(2.w),
            _buildFilterButton(context, "New dApp", vm.selectedFilter == "New dApp", themeManager),
          ],
        ),
        SB.h(2.h),
        SizedBox(
          height: 11.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: vm.getFilteredDApps().length,
            separatorBuilder: (_, __) => SizedBox(width: 2.5.w),
            itemBuilder: (context, index) {
              final dapp = vm.getFilteredDApps()[index];
              return GestureDetector(
                onTap: () => _openDAppInBrowser(context, dapp),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 38.w,
                    height: 11.h,
                    color: Colors.white,
                    child: Image.asset(
                      dapp.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton(BuildContext context, String text, bool isSelected,
      ThemeManager themeManager) {
    final vm = context.watch<ExploreVM>();
    
    return GestureDetector(
      onTap: () {
        vm.selectFilter(text);
        // Add haptic feedback for better UX
        // HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : themeManager.currentTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : themeManager.currentTheme.dividerTheme.color ?? AppColors.borderColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 2.5.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : themeManager.currentTheme.colorScheme.onSurface,
            fontFamily: "Rubik",
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(
      BuildContext context, ExploreVM vm, ThemeManager themeManager) {
    if (vm.searchResults.isEmpty) {
      return _buildNoSearchResults(context, themeManager);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Search Suggestions",
              style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                fontSize: 4.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Text(
              "${vm.searchResults.length} options",
              style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                fontSize: 3.sp,
                color:
                themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        SB.h(2.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: vm.searchResults.length,
          separatorBuilder: (_, __) => SizedBox(height: 1.h),
          itemBuilder: (context, index) {
            final dapp = vm.searchResults[index];
            return _buildSearchSuggestionCard(context, dapp, themeManager);
          },
        ),
      ],
    );
  }

  Widget _buildSearchSuggestionCard(
      BuildContext context, DAppItem dapp, ThemeManager themeManager) {
    return GestureDetector(
      onTap: () => _openDAppInBrowser(context, dapp),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: themeManager.currentTheme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: themeManager.currentTheme.dividerTheme.color ??
                Colors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: dapp.isUrl 
                    ? AppColors.primary.withOpacity(0.1)
                    : dapp.isSearch 
                        ? Colors.blue.withOpacity(0.1)
                        : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: dapp.isUrl || dapp.isSearch
                  ? Icon(
                      dapp.isUrl ? Icons.language : Icons.search,
                      color: dapp.isUrl ? AppColors.primary : Colors.blue,
                      size: 5.w,
                    )
                  : Image.asset(
                      dapp.image,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.apps, color: Colors.grey[400], size: 4.w);
                      },
                    ),
            ),
            SB.w(3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dapp.name,
                    style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
                      fontSize: 3.5.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SB.h(0.5.h),
                  Text(
                    dapp.isUrl 
                        ? "Visit website"
                        : dapp.isSearch 
                            ? "Search on Google"
                            : "dApp",
                    style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                      fontSize: 2.8.sp,
                      color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 3.5.w,
              color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildNoSearchResults(
      BuildContext context, ThemeManager themeManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search,
              size: 15.w,
              color: themeManager.currentTheme.colorScheme.onSurface
                  .withOpacity(0.5)),
          SB.h(2.h),
          Text(
            "Start typing to search",
            style: themeManager.currentTheme.textTheme.titleMedium?.copyWith(
              fontSize: 4.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SB.h(1.h),
          Text(
            "Search for dApps, websites, or anything on the web",
            style: themeManager.currentTheme.textTheme.bodyMedium?.copyWith(
              fontSize: 3.sp,
              color: themeManager.currentTheme.colorScheme.onSurface
                  .withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _openDAppInBrowser(BuildContext context, DAppItem dapp) {
    Navigator.pushNamed(
      context,
      '/browser',
      arguments: {
        'url': dapp.url,
        'title': dapp.name,
      },
    );
  }

  void _openAllDAppsInBrowser(BuildContext context) {
    Navigator.pushNamed(
      context,
      '/browser',
      arguments: {
        'url': 'https://app.uniswap.org/?chain=sepolia',
        'title': 'DeFi Hub',
      },
    );
  }
}