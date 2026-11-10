import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Senaeya/Utils/AppIcons/app_icons.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import '../../../Utils/AppImg/app_img.dart';
import '../../../utils/AppColors/app_colors.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    this.onTap,
    this.favourTab,
    required this.courseName,
    required this.mentors,
    required this.date,
    required this.time,
    required this.price,
    required this.lecture,
    required this.isFavourite,
    required this.iconVisible,
    this.home = false,
  });
  final void Function()? onTap;
  final void Function()? favourTab;
  final bool home;
  final String courseName;
  final String mentors;
  final String date;
  final String time;
  final String lecture;
  final String price;
  final bool isFavourite;
  final bool iconVisible;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 290.h,
        width: home == false ? double.maxFinite : 300.w,
        margin: EdgeInsets.symmetric(horizontal: 5.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.black200.withOpacity(0.5), // Shadow color
              spreadRadius: 0.5, // Spread of shadow
              blurRadius: 7, // Blur radius
              offset: const Offset(0, 0), // Offset in x and y direction
            ),
          ],
          borderRadius: BorderRadius.circular(16.r),
          color: AppColors.white50,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///<=================== This is image section ===========================>
            Container(
              height: 180.h,
              width: 319.w,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  image: const DecorationImage(
                      fit: BoxFit.contain,
                      image: AssetImage(
                        AppImages.newCustomCards,
                      ))),
              child: iconVisible == true
                  ? Padding(
                      padding: EdgeInsets.only(top: 16.h, right: 10.w),
                      child: Align(
                        alignment: AlignmentDirectional.topEnd,
                        child: Container(
                          //margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 19.w),
                          padding: EdgeInsets.all(1.r),
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.white500),
                          child: IconButton(
                              onPressed: favourTab,
                              icon: isFavourite == true
                                  ? const Icon(
                                      size: 16,
                                      Icons.favorite_outlined,
                                      color: AppColors.red,
                                    )
                                  : const Icon(
                                      Icons.favorite_border,
                                      color: AppColors.red,
                                    )),
                        ),
                      ),
                    )
                  : SizedBox(),
            ),

            SizedBox(
              height: 5.h,
            ),

            ///<================Course Name =========================================>

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  maxLines: 1,
                  text: courseName,
                  color: AppColors.black300,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  // right: 50.w,
                ),
                CustomText(
                  text: "\$ ${price}",
                  color: AppColors.golden600,
                  fontWeight: FontWeight.w500,
                  fontSize: 24,
                ),
              ],
            ),

            ///<=================== Mentors Name ===================================>

            SizedBox(
              width: 150.w,
              child: CustomText(
                textAlign: TextAlign.left,
                maxLines: 1,
                text: mentors,
                fontWeight: FontWeight.w400,
                fontSize: 12,
                color: AppColors.black200,
                right: 8.w,
              ),
            ),

            SizedBox(
              height: 8.h,
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ///<========================= This is the date section ================>
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.calender,
                      height: 24.h,
                      width: 24.w,
                    ),
                    CustomText(
                      text: date,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.navy300,
                    ),
                  ],
                ),

                SizedBox(
                  width: 8.w,
                ),

                ///<========================= This is the time section ================>
                Row(
                  children: [
                    SvgPicture.asset(
                      AppIcons.time,
                      height: 24.h,
                      width: 24.w,
                    ),
                    CustomText(
                      text: time,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.navy300,
                    ),
                  ],
                ),

                SizedBox(
                  width: 8.w,
                ),

                ///<========================= This is the lecture section ================>
                Expanded(
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        AppIcons.lecture,
                        height: 24.h,
                        width: 24.w,
                      ),
                      Expanded(
                        child: CustomText(
                          overflow: TextOverflow.ellipsis,
                          text: "${lecture} Lectures",
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.navy300,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
