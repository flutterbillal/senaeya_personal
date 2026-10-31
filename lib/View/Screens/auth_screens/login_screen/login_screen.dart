import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/auth_screens/login_screen/widgets/custom_button.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'controller/login_screen_controller.dart';
import 'widgets/custom_text_field.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
    // Force LTR direction for the login screen
    return Directionality(
      textDirection: TextDirection.ltr,
      child: GetBuilder<LoginScreenController>(
        init: LoginScreenController(),
        builder: (controller) {
          return Scaffold(
            appBar: CustomAppBar(
              title: 'sign_in'.tr,
              titleColor: Colors.black,
              // //blueCloud: true,
              blackHomeIcon: true,
            ),
            backgroundColor: const Color(0xFF1766A0),
            body: Stack(
              children: [
                SingleChildScrollView(
                  child: SafeArea(
                    child: Form(
                      key: controller.formKey,
                      child: Column(
                        children: [
                          SizedBox(height: 16.h),
                          CustomText(
                            text: 'welcome_back'.tr,
                            color: Colors.white,
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 4.h),
                          CustomText(
                            text: 'log_in'.tr,
                            color: Colors.white,
                            fontSize: 16.sp,
                            textAlign: TextAlign.left,
                          ),
                          SizedBox(height: 24.h),
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 16.w,
                            ),
                            child: Container(
                              padding: EdgeInsetsDirectional.symmetric(
                                horizontal: 16.w,
                                vertical: 24.h,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                children: [
                                  CustomTextFormField(
                                    controller: controller.phoneController,
                                    hintText: 'xxxxxxxx'.tr,
                                    icon: AppIcon.phone,
                                    keyboardType: TextInputType.phone,
                                    prefix: '+9665', // Add non-editable prefix
                                    maxDigits: 13,
                                  ),
                                  CustomTextFormField(
                                    controller: controller.passwordController,
                                    hintText: '*************'.tr,
                                    icon: AppIcon.lock,
                                    obscureText: true,
                                  ),
                                  SizedBox(height: 16.h),
                                  Obx(
                                    () => CustomButton(
                                      onPressed: controller.login,
                                      text: 'login'.tr,
                                      isLoading: controller.isLoading.value,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Obx(
                                        () => Checkbox(
                                          value: controller.rememberMe.value,
                                          onChanged:
                                              controller.toggleRememberMe,
                                          activeColor: const Color(0xFF1766A0),
                                        ),
                                      ),
                                      CustomText(
                                        text: 'remember_me'.tr,
                                        fontSize: 14.sp,
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 12.h),
                                  Obx(
                                    () => controller.biometricAvailable.value &&
                                            !controller.isLoading.value
                                        ? Column(
                                            children: [
                                              CustomText(
                                                text:
                                                    'use_fingerprint_login'.tr,
                                                fontSize: 16.sp,
                                                color: Colors.black,
                                                textAlign: TextAlign.left,
                                              ),
                                              SizedBox(height: 22.h),
                                              GestureDetector(
                                                onTap:
                                                    controller.fingerprintLogin,
                                                child: SvgPicture.asset(
                                                  AppIcon.fingurePrint,
                                                  height: 71.w,
                                                  width: 53.w,
                                                ),
                                              ),
                                            ],
                                          )
                                        : const SizedBox(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          Padding(
                            padding: EdgeInsetsDirectional.symmetric(
                              horizontal: 16.w,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      controller.forgotPassword();
                                    },
                                    child: CustomText(
                                      text: 'forgot_password'.tr,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14.sp,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Flexible(
                                  child: TextButton(
                                    onPressed: () {
                                      Get.toNamed(AppRoute.signupScreen);
                                      // Get.toNamed(
                                      // AppRoute.signupWorkshopScreen);
                                    },
                                    child: CustomText(
                                      maxLines: 2,
                                      text: 'create_new_account'.tr,
                                      color: Colors.white,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w700,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(() => controller.isLoading.value
                    ? Positioned(
                        top: 0,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Image.asset(
                            AppImages.loading,
                            width: 200.sp,
                            height: 200.sp,
                          ),
                        ),
                      )
                    : const SizedBox())
              ],
            ),
          );
        },
      ),
    );
  }
}
