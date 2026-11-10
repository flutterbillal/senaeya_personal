import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/auth_screens/login_screen/widgets/custom_button.dart';
import 'package:Senaeya/View/Screens/report_screen/controller/report_screen_controller.dart';
import 'package:Senaeya/View/Widgegts/report_card/report_card.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:Senaeya/View/Widgets/custom_dropdown.dart';
import 'package:Senaeya/View/Widgets/custom_text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Widgets/commonTextWithoutResize.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ReportScreenController controller =
        Get.find<ReportScreenController>();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: CustomAppBar(
          title: "report_screen_title".tr,
          titleColor: Colors.black,
          centerTitle: true,
          blackHomeIcon: true,
          //blueCloud: true,
        ),
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 14.0, bottom: 14),
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 10.0,
                  bottom: 10,
                  left: 4,
                  right: 4,
                ),
                child: Container(
                  width: 0.92.sw,
                  height: MediaQuery.of(context).size.height,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Report Type Selection
                          Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => ReportCard(
                                    tittle: "daily_report".tr,
                                    isSelected:
                                        controller.selectedReportType.value ==
                                            "Daily",
                                    onTap: () => controller
                                        .selectedReportType.value = "Daily",
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Obx(
                                  () => ReportCard(
                                    tittle: "weekly_report".tr,
                                    isSelected:
                                        controller.selectedReportType.value ==
                                            "Weekly",
                                    onTap: () => controller
                                        .selectedReportType.value = "Weekly",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => ReportCard(
                                    tittle: "monthly_report".tr,
                                    isSelected:
                                        controller.selectedReportType.value ==
                                            "Monthly",
                                    onTap: () => controller
                                        .selectedReportType.value = "Monthly",
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Obx(
                                  () => ReportCard(
                                    tittle: "three_month_report".tr,
                                    isSelected:
                                        controller.selectedReportType.value ==
                                            "3-month",
                                    onTap: () => controller
                                        .selectedReportType.value = "3-month",
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => ReportCard(
                                    tittle: "six_month_report".tr,
                                    isSelected:
                                        controller.selectedReportType.value ==
                                            "6-month",
                                    onTap: () => controller
                                        .selectedReportType.value = "6-month",
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Obx(
                                  () => ReportCard(
                                    tittle: "annual_report".tr,
                                    isSelected:
                                        controller.selectedReportType.value ==
                                            "Annual",
                                    onTap: () => controller
                                        .selectedReportType.value = "Annual",
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 16.h),

                          Align(
                            alignment: Alignment.center,
                            child: Commontextwithoutresize(
                              text: "report_start_date".tr,
                              color: const Color(0xFF1771B7),
                              fontWeight: FontWeight.w600,
                              fontSize: 18.sp,
                            ),
                          ),

                          SizedBox(height: 8.h),

                          // Date Selection Dropdowns
                          Row(
                            children: [
                              Expanded(
                                child: Obx(
                                  () => CustomDropdown<String>(
                                    value: controller.selectedDay.value.isEmpty
                                        ? null
                                        : controller.selectedDay.value,
                                    items: List.generate(
                                      31,
                                      (index) => (index + 1)
                                          .toString()
                                          .padLeft(2, '0'),
                                    ),
                                    hint: "day_label".tr,
                                    onChanged: (value) => controller
                                        .selectedDay.value = value ?? '',
                                    height: 40.h,
                                    width: double.infinity,
                                    borderRadius: 24.r,
                                    fillColor: Colors.grey[100],
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    hintStyle: customTextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                    ),
                                    itemStyle: customTextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Obx(
                                  () => CustomDropdown<String>(
                                    value:
                                        controller.selectedMonth.value.isEmpty
                                            ? null
                                            : controller.selectedMonth.value,
                                    items: List.generate(
                                      12,
                                      (index) => (index + 1)
                                          .toString()
                                          .padLeft(2, '0'),
                                    ),
                                    hint: "month_label".tr,
                                    onChanged: (value) => controller
                                        .selectedMonth.value = value ?? '',
                                    height: 40.h,
                                    width: double.infinity,
                                    borderRadius: 24.r,
                                    fillColor: Colors.grey[100],
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    hintStyle: customTextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                    ),
                                    itemStyle: customTextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Obx(
                                  () => CustomDropdown<String>(
                                    value: controller.selectedYear.value.isEmpty
                                        ? null
                                        : controller.selectedYear.value,
                                    items: List.generate(
                                      10,
                                      (index) =>
                                          (DateTime.now().year - 2 + index)
                                              .toString(),
                                    ),
                                    hint: "year_label".tr,
                                    onChanged: (value) => controller
                                        .selectedYear.value = value ?? '',
                                    height: 40.h,
                                    width: double.infinity,
                                    borderRadius: 24.r,
                                    fillColor: Colors.grey[100],
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8.w),
                                    hintStyle: customTextStyle(
                                      color: Colors.grey,
                                      fontSize: 10.sp,
                                    ),
                                    itemStyle: customTextStyle(fontSize: 12.sp),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),

                          // Checkboxes Section
                          Padding(
                            padding:
                                const EdgeInsets.only(left: 8.0, right: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(
                                      () => GestureDetector(
                                        // onTap: () {
                                        //   controller.includeIncome.value =
                                        //       !controller.includeIncome.value;
                                        // },
                                        child: Container(
                                          width: 20.w,
                                          height: 20.w,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: controller.includeIncome.value
                                              ? SvgPicture.asset(
                                                  AppIcon.check,
                                                  width: 16.sp,
                                                  height: 16.sp,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Commontextwithoutresize(
                                      text: "income".tr,
                                      fontSize: 14.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(
                                      () => GestureDetector(
                                        // onTap: () {
                                        //   controller.includeOutlay.value =
                                        //       !controller.includeOutlay.value;
                                        // },
                                        child: Container(
                                          width: 20.w,
                                          height: 20.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: controller.includeOutlay.value
                                              ? SvgPicture.asset(
                                                  AppIcon.check,
                                                  width: 16.sp,
                                                  height: 16.sp,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Commontextwithoutresize(
                                      text: "outlay".tr,
                                      fontSize: 14.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Obx(
                                      () => GestureDetector(
                                        // onTap: () {
                                        //   controller.includeNumberOfCars.value =
                                        //       !controller.includeNumberOfCars.value;
                                        // },
                                        child: Container(
                                          width: 20.w,
                                          height: 20.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                              width: 2,
                                            ),
                                          ),
                                          child: controller
                                                  .includeNumberOfCars.value
                                              ? SvgPicture.asset(
                                                  AppIcon.check,
                                                  width: 16.sp,
                                                  height: 16.sp,
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Commontextwithoutresize(
                                      text: "number_of_cars".tr,
                                      fontSize: 14.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      maxLines: 1,
                                      overflow: TextOverflow.visible,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Toggle for Daily Report Generation
                          // Row(
                          //   children: [
                          //     Obx(
                          //           () => Switch(
                          //         value: controller.generateDailyReport.value,
                          //         onChanged: (value) =>
                          //         controller.generateDailyReport.value = value,
                          //         activeColor: AppColors.primary,
                          //       ),
                          //     ),
                          //     SizedBox(width: 12.w),
                          //     Flexible(
                          //       child: Commontextwithoutresize(
                          //         text: "generate_daily_report_directly".tr,
                          //         fontSize: 15.sp,
                          //         textAlign: TextAlign.start,
                          //         overflow: TextOverflow.visible,
                          //         fontWeight: FontWeight.w700,
                          //       ),
                          //     ),
                          //   ],
                          // ),

                          // Language Selection
                          Row(
                            children: [
                              Commontextwithoutresize(
                                text: "report_language".tr,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              SizedBox(height: 8.sp),
                              Obx(
                                () => Radio<String>(
                                  value: "عربي",
                                  groupValue: controller.selectedLanguage.value,
                                  onChanged: (value) => controller
                                      .selectedLanguage.value = value!,
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              Commontextwithoutresize(
                                text: "عربي",
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                              ),
                              Obx(
                                () => Radio<String>(
                                  value: "English",
                                  groupValue: controller.selectedLanguage.value,
                                  onChanged: (value) => controller
                                      .selectedLanguage.value = value!,
                                  activeColor: AppColors.primary,
                                ),
                              ),
                              Commontextwithoutresize(
                                text: 'English',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ],
                          ),

                          const Spacer(),

                          Obx(
                            () => CustomButton(
                              text: controller.isLoading.value
                                  ? "Generating...".tr
                                  : "report_release".tr,
                              onPressed: controller.isLoading.value
                                  ? null
                                  : () {
                                      controller.generateReport();
                                      // if (success) {
                                      //  controller.reportSuccess();
                                      // }
                                    },
                              backgroundColor: controller.isLoading.value
                                  ? Colors.grey
                                  : null,
                            ),
                          ),
                        ],
                      ),
                      Obx(
                        () => controller.isLoading.value
                            ? Positioned(
                                top: 10,
                                left: 10,
                                right: 10,
                                bottom: 10,
                                child: Center(
                                  child: Image.asset(
                                    AppImages.loading,
                                    width: 150.w,
                                    height: 150.w,
                                  ),
                                ),
                              )
                            : const SizedBox(),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
