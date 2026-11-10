import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

import '../../Utils/AppColors/app_colors.dart';
import '../../Utils/AppImg/app_img.dart';

class CustomDropdownField extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final ValueChanged<String?>? onChanged;
  final bool isRequired;
  final bool enabled;
  final double? iconSize;

  const CustomDropdownField({
    super.key,
    this.value,
    required this.items,
    this.iconSize,
    required this.hintText,
    this.onChanged,
    this.isRequired = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    // Remove duplicates from items list to prevent dropdown errors
    final uniqueItems = items.toSet().toList();

    // Ensure the value is in the unique items list, otherwise set to null
    final safeValue =
        (value?.isEmpty == true || !uniqueItems.contains(value)) ? null : value;

    return Stack(
      children: [
        DropdownButtonFormField<String>(
          isExpanded: true, // Add this line - critical for preventing overflow
          dropdownColor: AppColors.textFiledColor,
          value: safeValue,
          items: uniqueItems
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Center(
                    child: Text(
                      e,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis, // Handle long text
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          icon: SvgPicture.asset(
            AppIcon.dropDown,
            height: 10.w,
            width: 10.w,
          ),
          iconSize: iconSize ?? 24,
          decoration: InputDecoration(
            hintText: hintText,
            filled: true,
            fillColor: enabled ? const Color(0xffF4F5F7) : Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24.r),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
        ),
        if (isRequired)
          const Positioned(
            top: 4,
            left: 10,
            child: Text(
              "*",
              style: TextStyle(color: AppColors.red),
            ),
          ),
      ],
    );
  }
}
