import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import '../../../util/color_resources.dart';
import '../../../theme/theme_manager.dart';
import 'widgets/swap_tab.dart';
import 'widgets/hot_tokens_tab.dart';

class SwapScreen extends StatefulWidget {
  const SwapScreen({super.key});

  @override
  State<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends State<SwapScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 6.h,
              child: TabBar(
                controller: _tabController,
                labelColor: themeManager.currentTheme.colorScheme.onSurface,
                unselectedLabelColor: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(
                    fontSize: 4.5.sp, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: "Swap"),
                  Tab(text: "Hot tokens"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [
                  SwapTab(),
                  HotTokensTab(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
