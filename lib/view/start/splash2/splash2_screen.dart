import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../util/size_extension.dart';
import '../../../util/color_resources.dart';
import '../../../theme/theme_manager.dart';
import 'splash2_vm.dart';

class Splash2Screen extends StatefulWidget {
  const Splash2Screen({super.key});

  @override
  State<Splash2Screen> createState() => _Splash2ScreenState();
}

class _Splash2ScreenState extends State<Splash2Screen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<Splash2VM>().startSplash(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    
    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        body: Center(
          child: SizedBox(
            width: 40.w,
            child: SvgPicture.asset(
              "assets/svgs/splash2.svg",
              fit: BoxFit.contain,
              colorFilter: themeManager.isDarkMode 
                ? null // Use original colors in dark theme
                : ColorFilter.mode(
                    AppColors.primary, // Use primary color in light theme
                    BlendMode.srcIn,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}
