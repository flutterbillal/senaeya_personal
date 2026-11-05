import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/auth_screens/login_screen/widgets/custom_text_field.dart';
import 'package:Senaeya/View/Screens/edit_profile_screen/controller/edit_profile_controller.dart';
import 'package:Senaeya/View/Widgegts/custom_button/custom_button.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:Senaeya/View/Widgets/custom_phone_text_filed/custom_phone_text_filed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

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
              onBack: () => Get.offAllNamed(AppRoute.navScreen),
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
                                  enabled: false,
                                  onButtonTap: () {},
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
                                  controller: controller.confirmPasswordController,
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
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomText(
                                      text: 'Additional User'.tr,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    Obx(() {
                                      final count = controller.additionalUsersList.length;
                                      final canAdd = count < 2;
                                      return GestureDetector(
                                        onTap: canAdd
                                            ? () {
                                                controller.showAddUserForm.value =
                                                    !controller.showAddUserForm.value;
                                              }
                                            : () {
                                                showCustomSnackBar(
                                                  "you_can_only_add_one_additional_user".tr,
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
                                            borderRadius: BorderRadius.circular(20.r),
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
                                                text: controller.showAddUserForm.value
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
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        CustomText(
                                          text: 'New Additional User'.tr,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                        SizedBox(height: 8.h),
                                        CustomTextFieldWithButton(
                                          controller: controller.newHelperPhoneController,
                                          hintText: '+966 5xxxxxxxxx',
                                          prefix: '+9665',
                                          keyboardType: TextInputType.phone,
                                          onButtonTap: () {
                                            controller.verifiedPhone(
                                              controller.newHelperPhoneController.text.trim(),
                                            );
                                          },
                                        ),
                                        CustomTextFormField(
                                          controller: controller.newHelperPasswordController,
                                          hintText: 'new_password'.tr,
                                          icon: AppIcon.lock,
                                          obscureText: true,
                                        ),
                                        CustomTextFormField(
                                          controller: controller.newHelperConfirmPasswordController,
                                          hintText: 'confirm_password'.tr,
                                          icon: AppIcon.lock,
                                          obscureText: true,
                                        ),
                                        SizedBox(height: 12.h),
                                        Center(
                                          child: Obx(
                                            () => controller.isAddingAdditionalUser.value
                                                ? const CircularProgressIndicator()
                                                : CustomButtonPrev(
                                                    title: 'Add User'.tr,
                                                    height: 44.h,
                                                    width: double.infinity,
                                                    onTap: controller.addAdditionalUser,
                                                    fillColor: const Color(0xFF0C5CA8),
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
                                  if (controller.isFetchingAdditionalUsers.value) {
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
                                      padding: EdgeInsets.symmetric(vertical: 12.h),
                                      child: Center(
                                        child: CustomText(
                                          text: 'No additional user added yet'.tr,
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
                                        final user = controller.additionalUsersList[index];
                                        final bool isActive = (user.status ?? 'active').toLowerCase() == 'active';

                                        return Container(
                                          margin: EdgeInsets.only(bottom: 12.h),
                                          padding: EdgeInsets.all(12.w),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(12.r),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 20.r,
                                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                                child: Icon(
                                                  Icons.person,
                                                  color: AppColors.primary,
                                                  size: 22.sp,
                                                ),
                                              ),
                                              SizedBox(width: 12.w),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    CustomText(
                                                      text: user.contact ?? user.name ?? 'Additional User'.tr,
                                                      fontSize: 14.sp,
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                    SizedBox(height: 2.h),
                                                    CustomText(
                                                      text: isActive ? 'Active'.tr : 'Blocked'.tr,
                                                      fontSize: 11.sp,
                                                      color: isActive ? Colors.green : Colors.red,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              // Status Switch (enable/disable)
                                              Transform.scale(
                                                scale: 0.8,
                                                child: Switch(
                                                  value: isActive,
                                                  activeThumbColor: Colors.white,
                                                  activeTrackColor: AppColors.primary,
                                                  onChanged: (val) {
                                                    if (user.sId != null) {
                                                      controller.enableDesableAdditionalUser(
                                                        id: user.sId!,
                                                        status: val,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),
                                              // Delete Button
                                              IconButton(
                                                icon: const Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  if (user.sId != null) {
                                                    Get.defaultDialog(
                                                      title: 'delete'.tr,
                                                      middleText: 'Are you sure you want to delete this user?'.tr,
                                                      textConfirm: 'yes'.tr,
                                                      textCancel: 'no'.tr,
                                                      confirmTextColor: Colors.white,
                                                      buttonColor: Colors.red,
                                                      onConfirm: () {
                                                        Get.back();
                                                        controller.deleteAdditionalUser(id: user.sId!);
                                                      },
                                                    );
                                                  }
                                                },
                                              ),
                                            ],
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