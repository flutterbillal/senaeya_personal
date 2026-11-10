import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/utils/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InvoiceCard extends StatelessWidget {
  final String title;
  final String rightText;
  final String? vatText;
  final Color? borderColor;
  final String icon;
  final Color? backgroundColor;
  final Color highlightColor;
  final Color tittleColor;
  final double fontSize;
  final FontWeight fontWeight;
  final bool? extraPadding;
  final FontWeight tittleFontWeight;

  const InvoiceCard({
    super.key,
    required this.title,
    required this.rightText,
    this.extraPadding = false,
    this.borderColor = Colors.grey,
    this.backgroundColor,
    this.tittleFontWeight = FontWeight.w400,
    this.highlightColor = AppColors.primary,
    this.vatText,
    required this.icon,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w400,
    this.tittleColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? AppColors.textFiledColor,
            border: Border.all(color: borderColor ?? Colors.grey),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        icon,
                        height: 16.w,
                        width: 16.w,
                      ),
                      Padding(
                        padding: extraPadding != false
                            ? const EdgeInsets.all(4.0)
                            : EdgeInsets.zero,
                        child: CustomText(
                            color: tittleColor,
                            text: title,
                            overflow: TextOverflow.visible,
                            fontWeight: tittleFontWeight,
                            fontSize: 14.w),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: extraPadding != true
                          ? BorderSide(color: Colors.grey, width: 1)
                          : BorderSide(color: Colors.grey, width: 1),
                    ),
                  ),
                  child: Padding(
                    padding: extraPadding != false
                        ? const EdgeInsets.all(4.0)
                        : EdgeInsets.zero,
                    child: CustomText(
                      text: rightText,
                      fontSize: 13.w,
                      fontWeight: fontWeight,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        vatText != null
            ? Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: EdgeInsets.only(left: 4.w),
                    child: CustomText(text: vatText!, fontSize: 13.w),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
