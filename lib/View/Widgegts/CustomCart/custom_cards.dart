import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomCards extends StatelessWidget {
  const CustomCards({super.key, required this.children});
  final Widget children;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: 20.w, vertical: 16.h), // Set your desired height
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        color: const Color(0xFFFAFAFA), // Background color
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05), // 5% opacity of black
            offset: const Offset(0, 0), // X and Y offset are both 0
            blurRadius: 7, // Blur radius
            spreadRadius: 0.5, // Spread radius
          ),
        ],
      ),
      child: children,
    );
  }
}
