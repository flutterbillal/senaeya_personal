import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/auth_screens/login_screen/widgets/custom_text_field.dart';
import 'package:Senaeya/View/Screens/edit_profile_screen/controller/edit_profile_controller.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:Senaeya/View/Widgegts/custom_button/custom_button.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:Senaeya/View/Widgets/custom_phone_text_filed/custom_phone_text_filed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  /// Bottom sheet dialog to change password for a specific additional user
  void _showChangePasswordDialog(
    BuildContext context,
    EditProfileController controller, {
    required String userId,
    required String userContact,
  }) {
    controller.changeHelperPasswordController.clear();
    controller.changeHelperConfirmPasswordController.clear();

    Get.bottomSheet(
      SafeArea(
        child: Container(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 20.h,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20.h,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: 'Change Password'.tr,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        SizedBox(height: 2.h),
                        CustomText(
                          text: userContact,
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Get.back(),
                    ),
                  ],
                ),
                const Divider(),
                SizedBox(height: 12.h),
                CustomTextFormField(
                  controller: controller.changeHelperPasswordController,
                  hintText: 'new_password'.tr,
                  icon: AppIcon.lock,
                  obscureText: true,
                ),
                CustomTextFormField(
                  controller: controller.changeHelperConfirmPasswordController,
                  hintText: 'confirm_password'.tr,
                  icon: AppIcon.lock,
                  obscureText: true,
                ),
                SizedBox(height: 16.h),
                Center(
                  child: Obx(
                    () => controller.isChangingHelperPassword.value
                        ? const CircularProgressIndicator()
                        : CustomButtonPrev(
                            title: 'save'.tr,
                            height: 44.h,
                            width: double.infinity,
                            onTap: () async {
                              final success = await controller
                                  .chagePasswordSpecifiqAdditionalUser(
                                id: userId,
                                newPassword: controller
                                    .changeHelperPasswordController.text,
                                confirmPassword: controller
                                    .changeHelperConfirmPasswordController.text,
                              );
                              if (success) {
                                Get.back();
                              }
                            },
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
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      init: EditProfileController(),
      builder: (controller) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'edit_profile'.tr,
              titleColor: Colors.black,
              onBack: () => Get.back(),
            ),
            backgroundColor: const Color(0xFF0C5CA8),
            body: SafeArea(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Workshop Name
                                CustomTextFormField(
                                  controller: controller.nameController,
                                  hintText: 'workshop_name'.tr,
                                  showOneStar: true,
                                ),
                                // Email
                                CustomTextFormField(
                                  controller: controller.emailController,
                                  hintText: 'email'.tr,
                                  showOneStar: true,
                                ),
                                // Phone (Read-only)
                                CustomTextFieldWithButton(
                                  controller: controller.phoneController,
                                  hintText: '+966 5xxxxxxxxx',
                                  prefix: '+9665',
                                  keyboardType: TextInputType.phone,
                                  enabled: true,
                                  onButtonTap: () {
                                    controller.verifiedPhone(
                                      controller.phoneController.text,
                                    );
                                  },
                                ),
                                // Password
                                CustomTextFormField(
                                  controller: controller.passwordController,
                                  hintText: 'new_password'.tr,
                                  icon: AppIcon.lock,
                                  obscureText: true,
                                ),
                                // Confirm Password
                                CustomTextFormField(
                                  controller:
                                      controller.confirmPasswordController,
                                  hintText: 'confirm_password'.tr,
                                  icon: AppIcon.lock,
                                  obscureText: true,
                                ),

                                SizedBox(height: 24.h),

                                // ===== MAIN SAVE BUTTON (Only updates workshop owner profile) =====
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

                                SizedBox(height: 32.h),
                                const Divider(),
                                SizedBox(height: 16.h),

                                // ===== ADDITIONAL USERS SECTION =====
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: 'Additional User'.tr,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Obx(() {
                                      final count =
                                          controller.additionalUsersList.length;
                                      final canAdd = count < 2;
                                      return GestureDetector(
                                        onTap: canAdd
                                            ? () {
                                                controller
                                                        .showAddUserForm.value =
                                                    !controller
                                                        .showAddUserForm.value;
                                              }
                                            : () {
                                                showCustomSnackBar(
                                                  "you_can_only_add_one_additional_user"
                                                      .tr,
                                                );
                                              },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 12.w,
                                            vertical: 6.h,
                                          ),
                                          decoration: BoxDecoration(
                                            color: canAdd
                                                ? AppColors.primary
                                                : Colors.grey.shade400,
                                            borderRadius:
                                                BorderRadius.circular(20.r),
                                          ),
                                          child: Row(
                                            children: [
                                              Icon(
                                                controller.showAddUserForm.value
                                                    ? Icons.close
                                                    : Icons.add,
                                                color: Colors.white,
                                                size: 16.sp,
                                              ),
                                              SizedBox(width: 4.w),
                                              CustomText(
                                                text: controller
                                                        .showAddUserForm.value
                                                    ? 'Cancel'.tr
                                                    : 'add_user'.tr,
                                                color: Colors.white,
                                                fontSize: 12.sp,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                ),

                                SizedBox(height: 12.h),

                                // Form to ADD a new additional user
                                Obx(() {
                                  if (!controller.showAddUserForm.value) {
                                    return const SizedBox.shrink();
                                  }
                                  return Container(
                                    margin: EdgeInsets.only(bottom: 16.h),
                                    padding: EdgeInsets.all(12.w),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade50,
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'New Additional User'.tr,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(height: 8.h),
                                        CustomTextFieldWithButton(
                                          controller: controller
                                              .newHelperPhoneController,
                                          hintText: '+966 5xxxxxxxxx',
                                          prefix: '+9665',
                                          keyboardType: TextInputType.phone,
                                          onTextChanged: (_) {
                                            if (controller
                                                    .isNewHelperPhoneVerified
                                                    .value &&
                                                controller
                                                        .verifiedHelperPhoneNumber
                                                        .value !=
                                                    controller
                                                        .newHelperPhoneController
                                                        .text
                                                        .trim()) {
                                              controller
                                                  .isNewHelperPhoneVerified
                                                  .value = false;
                                              controller
                                                  .verifiedHelperPhoneNumber
                                                  .value = '';
                                            }
                                          },
                                          onButtonTap: () {
                                            controller.verifiedPhone(
                                              controller
                                                  .newHelperPhoneController.text
                                                  .trim(),
                                            );
                                          },
                                        ),
                                        Obx(
                                          () => (controller
                                                      .isNewHelperPhoneVerified
                                                      .value &&
                                                  controller
                                                          .verifiedHelperPhoneNumber
                                                          .value ==
                                                      controller
                                                          .newHelperPhoneController
                                                          .text
                                                          .trim())
                                              ? Padding(
                                                  padding: EdgeInsets.only(
                                                    left: 12.w,
                                                    bottom: 8.h,
                                                    top: 2.h,
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.check_circle,
                                                        color: Colors.green,
                                                        size: 16.sp,
                                                      ),
                                                      SizedBox(width: 4.w),
                                                      CustomText(
                                                        text:
                                                            'Phone verified'.tr,
                                                        color: Colors.green,
                                                        fontSize: 12.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox.shrink(),
                                        ),
                                        CustomTextFormField(
                                          controller: controller
                                              .newHelperPasswordController,
                                          hintText: 'new_password'.tr,
                                          icon: AppIcon.lock,
                                          obscureText: true,
                                        ),
                                        CustomTextFormField(
                                          controller: controller
                                              .newHelperConfirmPasswordController,
                                          hintText: 'confirm_password'.tr,
                                          icon: AppIcon.lock,
                                          obscureText: true,
                                        ),
                                        SizedBox(height: 12.h),
                                        Center(
                                          child: Obx(
                                            () => controller
                                                    .isAddingAdditionalUser
                                                    .value
                                                ? const CircularProgressIndicator()
                                                : CustomButtonPrev(
                                                    title: 'Add User'.tr,
                                                    height: 44.h,
                                                    width: double.infinity,
                                                    onTap: controller
                                                        .addAdditionalUser,
                                                    fillColor:
                                                        const Color(0xFF0C5CA8),
                                                    textColor: Colors.white,
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                // Existing Additional Users List
                                Obx(() {
                                  if (controller
                                      .isFetchingAdditionalUsers.value) {
                                    return const Center(
                                      child: Padding(
                                        padding: EdgeInsets.all(16.0),
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }

                                  if (controller.additionalUsersList.isEmpty &&
                                      !controller.showAddUserForm.value) {
                                    return Padding(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12.h),
                                      child: Center(
                                        child: CustomText(
                                          text:
                                              'No additional user added yet'.tr,
                                          color: Colors.grey,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    );
                                  }

                                  return Column(
                                    children: List.generate(
                                      controller.additionalUsersList.length,
                                      (index) {
                                        final user = controller
                                            .additionalUsersList[index];
                                        final bool isActive =
                                            (user.status ?? 'active')
                                                    .toLowerCase() ==
                                                'active';

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12.h),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10.w, vertical: 8.h),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius:
                                                BorderRadius.circular(12.r),
                                            border: Border.all(
                                                color: Colors.grey.shade200),
                                          ),
                                          child: Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 16.r,
                                                  backgroundColor: AppColors
                                                      .primary
                                                      .withValues(alpha: 0.1),
                                                  child: Icon(
                                                    Icons.person,
                                                    color: AppColors.primary,
                                                    size: 18.sp,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                Expanded(
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      CustomText(
                                                        text: user.contact ??
                                                            user.name ??
                                                            'Additional User'
                                                                .tr,
                                                        fontSize: 13.sp,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        textAlign:
                                                            TextAlign.start,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      SizedBox(height: 2.h),
                                                      CustomText(
                                                        text: isActive
                                                            ? 'Active'.tr
                                                            : 'Blocked'.tr,
                                                        fontSize: 11.sp,
                                                        color: isActive
                                                            ? Colors.green
                                                            : Colors.red,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        textAlign:
                                                            TextAlign.start,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                // Action buttons group (strictly right aligned & close together)
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    // Change Password Button
                                                    InkWell(
                                                      onTap: () {
                                                        if (user.sId != null) {
                                                          _showChangePasswordDialog(
                                                            context,
                                                            controller,
                                                            userId: user.sId!,
                                                            userContact:
                                                                user.contact ??
                                                                    user.name ??
                                                                    '',
                                                          );
                                                        }
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14.r),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(2.w),
                                                        child: Icon(
                                                          Icons.lock_reset,
                                                          color: const Color(
                                                              0xFF0C5CA8),
                                                          size: 23.sp,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    // Status Switch (enable/disable)
                                                    SizedBox(
                                                      width: 32.w,
                                                      height: 23.h,
                                                      child: FittedBox(
                                                        fit: BoxFit.contain,
                                                        child: Switch(
                                                          value: isActive,
                                                          activeThumbColor:
                                                              Colors.white,
                                                          activeTrackColor:
                                                              AppColors.primary,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                          onChanged: (val) {
                                                            if (user.sId !=
                                                                null) {
                                                              controller
                                                                  .enableDesableAdditionalUser(
                                                                id: user.sId!,
                                                                status: val,
                                                              );
                                                            }
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 8.w),
                                                    // Delete Button
                                                    InkWell(
                                                      onTap: () {
                                                        if (user.sId != null) {
                                                          CustomAlert
                                                              .showConfirmation(
                                                            context: context,
                                                            title: 'delete'.tr,
                                                            message:
                                                                'are_you_sure_delete_additional_user'
                                                                    .tr,
                                                            yesButtonText:
                                                                'yes'.tr,
                                                            noButtonText:
                                                                'no'.tr,
                                                            titleBackgroundColor:
                                                                Colors.red,
                                                            onYesPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                              controller
                                                                  .deleteAdditionalUser(
                                                                      id: user
                                                                          .sId!);
                                                            },
                                                            onNoPressed: () {
                                                              Navigator.of(
                                                                      context)
                                                                  .pop();
                                                            },
                                                          );
                                                        }
                                                      },
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              14.r),
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(2.w),
                                                        child: Icon(
                                                          Icons.delete,
                                                          color: Colors.red,
                                                          size: 23.sp,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  );
                                }),
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
}
