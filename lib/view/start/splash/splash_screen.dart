import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../util/size_extension.dart';
import '../../../theme/theme_manager.dart';
import 'splash_vm.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<SplashVM>().startSplash(context);
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
            width: 40.w, // bada logo
            child: SvgPicture.asset(
              "assets/svgs/splash1.svg",
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
