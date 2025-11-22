import 'package:flutter/material.dart';
import '../../util/color_resources.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;
  final bool isEnabled;

  const AppButton({
    super.key, 
    required this.text, 
    required this.onTap,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppColors.primary : AppColors.primary.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        onPressed: isEnabled ? onTap : null,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: "Rubik",
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: isEnabled ? Colors.white : Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}
