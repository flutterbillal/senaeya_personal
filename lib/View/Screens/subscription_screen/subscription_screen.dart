import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/auth_screens/login_screen/widgets/custom_button.dart';
import 'package:Senaeya/View/Screens/subscription_screen/controller/subscription_screen_controller.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../Widgegts/custom_text/custom_text.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SubscriptionScreenController controller =
        Get.find<SubscriptionScreenController>();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Color(0xFF1771B7),
          appBar: CustomAppBar(
            title: 'subscription'.tr,
            titleColor: Colors.black,
            //blueCloud: true,
            onBack: Get.back,
            centerTitle: true,
          ),
          body: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                    width: 0.92.sw,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 8)
                      ],
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final subscription =
                          controller.subscriptionsList.isNotEmpty
                              ? controller.subscriptionsList[0]
                              : null;

                      if (subscription == null) {
                        return Center(
                          child: CustomText(
                            text: 'No subscription available'.tr,
                            fontSize: 16.sp,
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            // Main subscription card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFFE49894),
                                borderRadius: BorderRadius.circular(20.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 22.h),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(AppIcon.riyalWhite,
                                          width: 28.w, height: 28.w),
                                      SizedBox(width: 6.w),
                                      CustomText(
                                        text:
                                            '${subscription.monthlyBasePrice}',
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 6.w),
                                      CustomText(
                                        text: 'monthly'.tr,
                                        fontSize: 32.sp,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 6.h),
                                  CustomText(
                                    text: 'payment_annually'.tr,
                                    fontSize: 20.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  SizedBox(height: 18.h),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 26.0, right: 26),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(AppIcon.riyalWhite,
                                                width: 24.w, height: 24.w),
                                            SizedBox(width: 4.w),
                                            CustomText(
                                              text: '${subscription.price}',
                                              fontSize: 33.sp,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.white,
                                            ),
                                          ],
                                        ),
                                        Text.rich(
                                          TextSpan(
                                            text:
                                                "${controller.subscriptionsList[0].cutOffprice ?? 0}",
                                            style: TextStyle(
                                              fontSize: 33.sp,
                                              color: Colors.white,
                                              decoration:
                                                  TextDecoration.lineThrough,
                                              decorationColor: AppColors.red,
                                              fontWeight: FontWeight.w700,
                                              decorationThickness: 2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  CustomText(
                                    text: subscription.title ?? '',
                                    fontSize: 18.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                    overflow: TextOverflow.visible,
                                  ),
                                  // RichText(
                                  //   text: TextSpan(
                                  //     children: [
                                  //       TextSpan(text: 'months_12'.tr + ' ', style: customTextStyle(fontSize: 18.sp, color:AppColors.primary, fontWeight: FontWeight.bold)),
                                  //       TextSpan(text: '+ ', style: TextStyle(fontSize: 18.sp, color:AppColors.primary, fontWeight: FontWeight.bold)),
                                  //       TextSpan(text: 'months_6_free'.tr, style: customTextStyle(fontSize: 18.sp, color: AppColors.primary, fontWeight: FontWeight.bold,)),
                                  //     ],
                                  //   ),
                                  // ),
                                  SizedBox(height: 10.h),

                                  // Render features: model defines features as List<String>?, so treat it as such
                                  Builder(builder: (_) {
                                    final List<String>? features =
                                        subscription.features;
                                    if (features == null || features.isEmpty)
                                      return SizedBox.shrink();

                                    return Column(
                                      children: features
                                          .map<Widget>((f) => Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 4.h),
                                                child: CustomText(
                                                  text: f.tr,
                                                  fontSize: 15.sp,
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ))
                                          .toList(),
                                    );
                                  }),
                                ],
                              ),
                            ),
                            SizedBox(height: 18.h),
                            Align(
                                alignment: Alignment.topLeft,
                                child: CustomText(
                                  text: "Discount Code".tr,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                            // Discount code input
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onTapOutside: (_) {
                                      FocusScope.of(Get.key.currentContext!)
                                          .unfocus();
                                    },
                                    controller: controller.cuponCodeController,
                                    decoration: InputDecoration(
                                      hintText: 'discount_code_hint'.tr,
                                      hintStyle: TextStyle(
                                          color: Colors.grey, fontSize: 14.sp),
                                      border: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.r),
                                      ),
                                      contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 12.h),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10.w),
                                ElevatedButton(
                                  onPressed: () {
                                    controller.onTapCuponCheck();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28.r),
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 18.w, vertical: 10.h),
                                  ),
                                  child: Obx(
                                    () => CustomText(
                                      text: controller.cuponLoading.value
                                          ? 'checking...'.tr
                                          : 'check'.tr,
                                      fontSize: 18.sp,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height: 18.h),

                            // Summary card
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Color(0xFFF7F7F7),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 14.h),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(AppIcon.riyal,
                                              width: 20.w, height: 20.w),
                                          SizedBox(width: 4.w),
                                          CustomText(
                                            text:
                                                "${subscription.price} = ${subscription.monthlyBasePrice} x 12",
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          CustomText(
                                            text: 'annual'.tr,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          CustomText(
                                            text: 'subscription_amount'.tr,
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Row(
                                    children: [
                                      CustomText(
                                        text:
                                            "${controller.cuponDiscount.value.toStringAsFixed(0)}%",
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      const Spacer(),
                                      CustomText(
                                        text: 'discount'.tr,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                  Divider(),
                                  SizedBox(height: 8.h),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                              'assets/icons/riyal.svg',
                                              width: 20.w,
                                              height: 20.w),
                                          SizedBox(width: 4.w),
                                          CustomText(
                                            text:
                                                "${(subscription.price - (subscription.price * controller.cuponDiscount.value / 100)).toStringAsFixed(2)}",
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ],
                                      ),
                                      CustomText(
                                        text: 'total_amount_including_tax'.tr,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 28.h),
                            // Go to checkout button
                            Obx(() => CustomButton(
                                  isLoading: controller.checkoutLoading.value,
                                  text: 'go_to_checkout'.tr,
                                  onPressed: () {
                                    controller
                                        .onTapCheckout(subscription.sId ?? '');
                                  },
                                ))
                          ],
                        ),
                      );
                    })),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
