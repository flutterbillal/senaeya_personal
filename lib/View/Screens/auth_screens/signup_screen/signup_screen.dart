import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Widgegts/custom_text/custom_text.dart';
import '../../../Widgets/custom_app_bar.dart';
import '../../../Widgegts/custom_button/custom_button.dart';
import '../../../Widgets/custom_phone_field_with_button.dart';
import '../../../Widgets/custom_phone_text_filed/custom_phone_text_filed.dart';
import '../login_screen/widgets/custom_text_field.dart';
import 'controller/signup_screen_controller.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupScreenController>(
      init: SignupScreenController(),
      builder: (controller) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title: 'workshop_manager_reg'.tr,
                titleColor: Colors.black,
                // //blueCloud: true,
                onBack: () => Navigator.pop(context),
              ),
              backgroundColor: const Color(0xFF0C5CA8),
              body: SingleChildScrollView(
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Center(
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name
                          _managerInfo(controller),
                          // Add a user
                          // Padding(
                          //   padding: const EdgeInsets.all(8.0),
                          //   child: Row(
                          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //     children: [
                          //       Obx(
                          //         () => GestureDetector(
                          //           onTap: controller.enableUser.value
                          //               ? controller.addUser
                          //               : null,
                          //           child: Row(
                          //             children: [
                          //               Icon(
                          //                 Icons.add,
                          //                 color: controller.enableUser.value
                          //                     ? const Color(0xFF0C5CA8)
                          //                     : Colors.grey,
                          //               ),
                          //               CustomText(
                          //                 text: 'add_user'.tr,
                          //                 color: controller.enableUser.value
                          //                     ? Colors.black
                          //                     : Colors.grey,
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //       Row(
                          //         children: [
                          //           Obx(
                          //             () => Transform.scale(
                          //               scale: 0.8,
                          //               child: Switch(
                          //                 value: controller.enableUser.value,
                          //                 onChanged: (val) {
                          //                   controller.enableUser.value = val;
                          //                   if (!val) {
                          //                     // Clear additional users when disabled
                          //                     controller.additionalUsers
                          //                         .clear();
                          //                     controller
                          //                         .additionalUserPhoneVerified
                          //                         .clear();
                          //                   }
                          //                 },
                          //                 activeColor: Colors.white,
                          //                 activeTrackColor: AppColors.primary,
                          //               ),
                          //             ),
                          //           ),
                          //           CustomText(
                          //             text: "Enable/Disable User".tr,
                          //             fontSize: 13.w,
                          //           ),
                          //         ],
                          //       ),
                          //     ],
                          //   ),
                          // ),
                          // SizedBox(height: 12.h),
                          // // Additional user (single user only)
                          // Obx(
                          //   () => controller.additionalUsers.isNotEmpty
                          //       ? Column(
                          //           children: [
                          //             Row(
                          //               children: [
                          //                 Expanded(
                          //                   child: CustomTextFieldWithButton(
                          //                     controller: controller
                          //                         .additionalUsers[0]['phone']!,
                          //                     hintText: '+966 5xxxxxxxxx',
                          //                     prefix: '+9665',
                          //                     keyboardType: TextInputType.phone,
                          //                     onButtonTap: () {
                          //                       controller.checkPhone(
                          //                         controller
                          //                             .additionalUsers[0]
                          //                                 ['phone']!
                          //                             .text
                          //                             .trim(),
                          //                         userIndex: 0,
                          //                       );
                          //                     },
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //             // Show verification status for additional user
                          //             (controller.additionalUserPhoneVerified[
                          //                         0] ==
                          //                     true)
                          //                 ? Padding(
                          //                     padding: EdgeInsets.only(
                          //                       left: 16.w,
                          //                       bottom: 8.h,
                          //                     ),
                          //                     child: Row(
                          //                       children: [
                          //                         Icon(
                          //                           Icons.check_circle,
                          //                           color: Colors.green,
                          //                           size: 16.w,
                          //                         ),
                          //                         SizedBox(width: 4.w),
                          //                         CustomText(
                          //                           text: 'Phone verified',
                          //                           color: Colors.green,
                          //                           fontSize: 12.w,
                          //                         ),
                          //                       ],
                          //                     ),
                          //                   )
                          //                 : const SizedBox.shrink(),
                          //             Row(
                          //               children: [
                          //                 Expanded(
                          //                   child: CustomTextFormField(
                          //                     controller:
                          //                         controller.additionalUsers[0]
                          //                             ['password']!,
                          //                     hintText: 'password_hint'.tr,
                          //                     icon: AppIcon.lock,
                          //                     obscureText: true,
                          //                     showOneStar: true,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //             Row(
                          //               children: [
                          //                 Expanded(
                          //                   child: CustomTextFormField(
                          //                     controller:
                          //                         controller.additionalUsers[0]
                          //                             ['confirmPassword']!,
                          //                     hintText: 'password_hint'.tr,
                          //                     icon: AppIcon.lock,
                          //                     showOneStar: true,
                          //                     obscureText: true,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ],
                          //         )
                          //       : const SizedBox.shrink(),
                          // ),
                          // Terms and conditions
                          Row(
                            children: [
                              Obx(
                                () => Checkbox(
                                  value: controller.isTermsAgreed.value,
                                  onChanged: (val) => controller
                                      .isTermsAgreed.value = val ?? false,
                                  activeColor: const Color(0xFF0C5CA8),
                                ),
                              ),
                              CustomText(text: 'agree_to'.tr, fontSize: 15.w),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(AppRoute.termsAndCondition);
                                },
                                child: CustomText(
                                  text: 'terms_and_conditions'.tr,
                                  color: const Color(0xFF0C5CA8),
                                  decoration: TextDecoration.underline,
                                  fontSize: 15.w,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              const Text(
                                '*',
                                style: TextStyle(color: AppColors.red),
                              ),
                            ],
                          ),
                          Center(
                            child: Obx(
                              () => controller.isCreatingAccount.value
                                  ? const CircularProgressIndicator()
                                  : CustomButtonPrev(
                                      title: 'create_new_account'.tr,
                                      height: 48.h,
                                      width: double.infinity,
                                      onTap: controller.isFormValid
                                          ? controller.submit
                                          : () {}, // Disabled if not valid
                                      fillColor: controller.isFormValid
                                          ? const Color(0xFF0C5CA8)
                                          : Colors.grey,
                                      textColor: Colors.white,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Form _managerInfo(SignupScreenController controller) {
    return Form(
      key: controller.formKey,
      child: Column(
        children: [
          CustomTextFormField(
            controller: controller.nameController,
            hintText: 'name_hint'.tr,
            icon: AppIcon.profile,
            showOneStar: true,
            onChanged: (_) => controller.validateFields(),
          ),
          // Phone with Check
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: controller.phoneController,
                  hintText: 'xxxxxxxx'.tr,
                  icon: AppIcon.phone,
                  keyboardType: TextInputType.phone,
                  prefix: '+9665', // Add non-editable prefix
                  maxDigits: 13,
                  showCheckButton: true,
                  onTapCheck: () =>
                      controller.checkPhone(controller.workshopPhoneNumber),
                  onChanged: (phone) => controller.setWorkShopPhone(phone),
                ),
              ),
            ],
          ),
          // Show verification status
          Obx(
            () => controller.isMainPhoneVerified.value
                ? Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      bottom: 8.h,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 16.w,
                        ),
                        SizedBox(width: 4.w),
                        CustomText(
                          text: 'Phone verified'.tr,
                          color: Colors.green,
                          fontSize: 12.w,
                        ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Username
          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextFormField(
          //         controller: controller.emailController,
          //         hintText: 'email_hint'.tr,
          //         icon: AppIcon.blueMail,
          //         showOneStar: true,
          //         onChanged: (_) => controller.validateFields(),
          //       ),
          //     ),
          //   ],
          // ),

          // Row(
          //   children: [
          //     Expanded(
          //       child: CustomTextFormField(
          //         controller: controller.confirmEmailController,
          //         hintText: 'confirm_email_hint'.tr,
          //         icon: AppIcon.blueMail,
          //         showOneStar: true,
          //         onChanged: (_) => controller.validateFields(),
          //       ),
          //     ),
          //   ],
          // ),
          // Password
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: controller.passwordController,
                  hintText: 'password_hint'.tr,
                  icon: AppIcon.lock,
                  obscureText: true,
                  showOneStar: true,
                  onChanged: (_) => controller.validateFields(),
                ),
              ),
            ],
          ),
          // Confirm Password
          Row(
            children: [
              Expanded(
                child: CustomTextFormField(
                  controller: controller.confirmPasswordController,
                  hintText: 'confirm_password_hint'.tr,
                  icon: AppIcon.lock,
                  obscureText: true,
                  showOneStar: true,
                  onChanged: (_) => controller.validateFields(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
