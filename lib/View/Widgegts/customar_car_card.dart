import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class CustomerCarCard extends StatelessWidget {
  final String customerName;
  final String customerPhone;
  final String customerId;
  final VoidCallback onTapYes;
  final bool isWarning;

  const CustomerCarCard({
    super.key,
    required this.onTapYes,
    required this.customerName,
    required this.customerPhone,
    required this.customerId,
    required this.isWarning,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: const Color(0xFF1771B7),
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      child: Padding(
        padding: EdgeInsets.only(
          left: 16.w,
          right: 16.w,
          top: 10.h,
          bottom: 10.h,
        ),
        child: Row(
          children: [
            // Left side - Customer info and phone
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Customer name
                  CustomText(
                    text: customerName,
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: 8.h),
                  // Phone number with icon
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (customerPhone.isNotEmpty) {
                            Clipboard.setData(
                                ClipboardData(text: customerPhone));
                            showCustomSnackBar(
                                'Phone number copied to clipboard'.tr,
                                isError: false);
                          }
                        },
                        child: SvgPicture.asset(
                          AppIcon.copy,
                          height: 16.w,
                          width: 16.w,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CustomText(
                        text: customerPhone,
                        color: Colors.white,
                        fontSize: 14.sp,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      SizedBox(width: 34.w),
                      GestureDetector(
                        onTap: () {
                          CustomAlert.showConfirmation(
                            onYesPressed: onTapYes,
                            context: context,
                            noButtonText: 'no'.tr,
                            yesButtonText: 'yes'.tr,
                            message:
                                "Send a message to\nthe customer to receive the car"
                                    .tr,
                          );
                        },
                        child: SvgPicture.asset(
                          AppIcon.carRepair,
                          height: 40.w,
                        ),
                      ),
                      SizedBox(width: 40.w),
                      GestureDetector(
                        onTap: () {
                          // CustomAlert.showConfirmationColumn(
                          //   context: context,
                          //   title: "The customer has an overdue invoice".tr,
                          //   yesButtonText: "Add to the defaulters list".tr,
                          //   noButtonText: "Give the customer extra time".tr,
                          //   message:
                          //       "Do you want to place the customer\non the defaulters list?".tr,
                          // );
                        },
                        child: isWarning
                            ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: SvgPicture.asset(
                                  AppIcon.warning,
                                  height: 36.w,
                                ),
                              )
                            : SizedBox(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Right side - Action buttons
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  // Cars button
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoute.carsScreen,
                          arguments: {'id': customerId});
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        text: "Cars".tr,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.w,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // Invoices button
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoute.customerInvoiceScreen,
                          arguments: {'clientId': customerId});
                    },
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 6.h,
                        horizontal: 12.w,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: CustomText(
                        text: "invoices".tr,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 17.w,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
