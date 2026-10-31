import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/edit_profile_screen/controller/edit_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../Widgegts/custom_button/custom_button.dart';
import '../../Widgegts/custom_text/custom_text.dart';
import '../../Widgets/custom_app_bar.dart';
import '../../Widgets/custom_phone_text_filed/custom_phone_text_filed.dart';
import '../auth_screens/login_screen/widgets/custom_text_field.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: SafeArea(
            child: Scaffold(
              appBar: CustomAppBar(
                title: 'edit_profile'.tr,
                titleColor: Colors.black,
                //blueCloud: true,
                onBack: () => Navigator.pop(context),
              ),
              backgroundColor: const Color(0xFF0C5CA8),
              body: Obx(
                () => controller.isLoading.value
                    ? Center(
                        child: Center(
                          child: Image.asset(
                            AppImages.loading,
                            width: 150.w,
                            height: 150.w,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
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
                                  CustomTextFormField(
                                    controller: controller.nameController,
                                    hintText: 'name_hint'.tr,
                                    icon: AppIcon.profile,
                                    showOneStar: true,
                                  ),
                                  // Phone (Read-only, no check button)
                                  CustomTextFieldWithButton(
                                    controller: controller.phoneController,
                                    hintText: '+966 5xxxxxxxxx',
                                    prefix: '+9665',
                                    keyboardType: TextInputType.phone,
                                    onButtonTap: () {
                                      controller.verifiedPhone(
                                        controller.phoneController.text,
                                      );
                                    },
                                  ),
                                  // Email
                                  CustomTextFormField(
                                    controller: controller.emailController,
                                    hintText: 'email_hint'.tr,
                                    icon: AppIcon.blueMail,
                                    showOneStar: false,
                                  ),
                                  // Password (optional for update)
                                  CustomTextFormField(
                                    controller: controller.passwordController,
                                    hintText: 'new_password'.tr,
                                    icon: AppIcon.lock,
                                    obscureText: true,
                                  ),
                                  CustomTextFormField(
                                    controller:
                                        controller.confirmPasswordController,
                                    hintText: 'confirm_password'.tr,
                                    icon: AppIcon.lock,
                                    obscureText: true,
                                  ),
                                  // Add a user section
                                  // Padding(
                                  //   padding: const EdgeInsets.all(8.0),
                                  //   child: Row(
                                  //     mainAxisAlignment:
                                  //         MainAxisAlignment.spaceBetween,
                                  //     children: [
                                  //       Flexible(
                                  //         child: Obx(
                                  //           () => GestureDetector(
                                  //             onTap: controller.enableUser.value
                                  //                 ? controller.addUser
                                  //                 : null,
                                  //             child: Row(
                                  //               children: [
                                  //                 Icon(
                                  //                   Icons.add,
                                  //                   color:
                                  //                       controller.enableUser.value
                                  //                       ? const Color(0xFF0C5CA8)
                                  //                       : Colors.grey,
                                  //                 ),
                                  //                 SizedBox(width: 4.w),
                                  //                 Flexible(
                                  //                   child: CustomText(
                                  //                     text: 'add_user'.tr,
                                  //                     color:
                                  //                         controller.enableUser.value
                                  //                         ? Colors.black
                                  //                         : Colors.grey,
                                  //                     maxLines: 2,
                                  //
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ),
                                  //       SizedBox(width: 8.w),
                                  //       Flexible(
                                  //         child: Column(
                                  //           children: [
                                  //             Obx(
                                  //               () => Transform.scale(
                                  //                 scale: 0.8,
                                  //                 child: Switch(
                                  //                   value:
                                  //                       controller.enableUser.value,
                                  //                   onChanged:
                                  //                       controller
                                  //                           .hasExistingHelper
                                  //                           .value
                                  //                       ? null // Disable switch if helper exists
                                  //                       : (val) {
                                  //                           controller
                                  //                                   .enableUser
                                  //                                   .value =
                                  //                               val;
                                  //                           if (!val) {
                                  //                             // Clear additional users when disabled
                                  //                             controller
                                  //                                 .additionalUsers
                                  //                                 .clear();
                                  //                           }
                                  //                         },
                                  //                   activeThumbColor: Colors.white,
                                  //                   activeTrackColor:
                                  //                       AppColors.primary,
                                  //                 ),
                                  //               ),
                                  //             ),
                                  //             CustomText(
                                  //               maxLines: 2,
                                  //               text: "Enable/Disable User".tr,
                                  //               fontSize: 10.sp,
                                  //               textAlign: TextAlign.center,
                                  //             ),
                                  //           ],
                                  //         ),
                                  //       ),
                                  //     ],
                                  //   ),
                                  // ),
                                  // SizedBox(height: 12.h),
                                  // Additional user (single user only)
                                  // Obx(
                                  //   () => controller.additionalUsers.isNotEmpty
                                  //       ? Column(
                                  //           children: [
                                  //             SizedBox(height: 8.h),
                                  //             Row(
                                  //               mainAxisAlignment:
                                  //                   MainAxisAlignment
                                  //                       .spaceBetween,
                                  //               children: [
                                  //                 CustomText(
                                  //                   text: 'Additional User',
                                  //                   fontSize: 14.w,
                                  //                   fontWeight: FontWeight.bold,
                                  //                 ),
                                  //                 // Only show delete button if helper doesn't exist yet
                                  //                 if (!controller
                                  //                     .hasExistingHelper
                                  //                     .value)
                                  //                   IconButton(
                                  //                     icon: const Icon(
                                  //                       Icons.delete,
                                  //                       color: Colors.red,
                                  //                     ),
                                  //                     onPressed: () => controller
                                  //                         .removeUser(0),
                                  //                   ),
                                  //               ],
                                  //             ),
                                  //             CustomTextFieldWithButton(
                                  //               controller: controller
                                  //                   .additionalUsers[0]['phone']!,
                                  //               hintText: '+966 5xxxxxxxxx',
                                  //               prefix: '+9665',
                                  //               keyboardType: TextInputType.phone,
                                  //               onButtonTap: () {
                                  //                 controller.verifiedPhone(
                                  //                   controller
                                  //                       .additionalUsers[0]['phone']
                                  //                       ?.text ??
                                  //                       '',
                                  //                 );
                                  //               },
                                  //             ),
                                  //
                                  //             CustomTextFormField(
                                  //               controller: controller
                                  //                   .additionalUsers[0]['password']!,
                                  //               hintText:
                                  //                   'new_password'.tr,
                                  //               icon: AppIcon.lock,
                                  //               obscureText: true,
                                  //             ),
                                  //             CustomTextFormField(
                                  //               controller: controller
                                  //                   .additionalUsers[0]['confirmPassword']!,
                                  //               hintText: 'confirm_password'.tr,
                                  //               icon: AppIcon.lock,
                                  //               obscureText: true,
                                  //             ),
                                  //           ],
                                  //         )
                                  //       : const SizedBox.shrink(),
                                  // ),
                                  // SizedBox(height: 40.h),
                                  Center(
                                    child: Obx(
                                      () => controller.isSaving.value
                                          ? const CircularProgressIndicator()
                                          : CustomButtonPrev(
                                              title: 'save'.tr,
                                              height: 48.h,
                                              width: double.infinity,
                                              onTap: controller.submit,
                                              fillColor: AppColors.primary,
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
          ),
        );
      },
    );
  }
}
