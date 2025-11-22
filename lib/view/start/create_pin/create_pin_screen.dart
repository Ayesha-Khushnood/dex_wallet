import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:dex/util/size_extension.dart';
import 'package:dex/helper/sb_helper.dart';
import 'package:dex/widgets/app_button.dart';
import 'package:dex/theme/theme_manager.dart';
import 'create_pin_vm.dart';

class CreatePinScreen extends StatefulWidget {
  const CreatePinScreen({super.key});

  @override
  State<CreatePinScreen> createState() => _CreatePinScreenState();
}

class _CreatePinScreenState extends State<CreatePinScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CreatePinVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: Icon(
                    Icons.arrow_back, 
                    color: themeManager.currentTheme.colorScheme.primary,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              SB.h(2.h),

              Text(
                "Create a Pin",
                style: themeManager.currentTheme.textTheme.headlineMedium?.copyWith(
                  fontSize: 6.sp,
                  fontWeight: FontWeight.bold,
                  color: themeManager.currentTheme.colorScheme.onSurface,
                ),
              ),

              SB.h(3.h),

              GestureDetector(
                onTap: () => FocusScope.of(context).requestFocus(vm.pinFocusNode),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final filled = index < vm.pin.length;
                    final display = filled ? vm.pin[index] : "";
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2.w),
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: filled 
                            ? themeManager.currentTheme.colorScheme.primary
                            : themeManager.currentTheme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: filled
                            ? null
                            : Border.all(
                                color: themeManager.currentTheme.colorScheme.outline.withOpacity(0.5),
                              ),
                      ),
                      child: Center(
                        child: Text(
                          display,
                          style: TextStyle(
                            fontSize: 6.sp,
                            fontWeight: FontWeight.bold,
                            color: filled 
                                ? themeManager.currentTheme.colorScheme.onPrimary
                                : Colors.transparent,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              // hidden input field
              Opacity(
                opacity: 0,
                child: TextField(
                  focusNode: vm.pinFocusNode,
                  controller: vm.pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: const InputDecoration(counterText: "", border: InputBorder.none),
                  onChanged: (v) => vm.setPin(v),
                ),
              ),

              SB.h(4.h),

              SvgPicture.asset(
                "assets/svgs/create_pin.svg",
                height: 12.h,
              ),

              SB.h(4.h),

              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: vm.isLoading ? "Setting up..." : "Continue",
                  onTap: () => vm.continueWithPin(context),
                  isEnabled: !vm.isLoading,
                ),
              ),

              SB.h(2.h),
            ],
          ),
        ),
      ),
    );
  }
}
