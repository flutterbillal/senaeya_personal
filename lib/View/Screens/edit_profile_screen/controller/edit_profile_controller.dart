import 'dart:convert';

import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Service/api_client.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/home_screen/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import '../../../Widgegts/custom_alert_verification_dialog/custom_alert_verification_dialog.dart';
import '../models/profile_screen_model.dart';

class EditProfileController extends GetxController {
  // Get HomeController instance
  final HomeController _homeController = Get.find<HomeController>();
  // Main user fields
  RxBool enableUser = false.obs;
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Rxn<ProfileModel> profilemodelData = Rxn<ProfileModel>();

  // Additional user fields (for dynamic user addition)
  var additionalUsers = <Map<String, TextEditingController>>[].obs;

  var isLoading = false.obs;
  var isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> sendPhoneNumber(String phoneNumber) async {
    try {
      Response response = await ApiClient.postData(
        ApiConstant.chekPhoneNumber,
        body: {"phoneNumber": phoneNumber},
      );
      if (response.statusCode == 200) {
        showCustomSnackBar("OTP sent successfully".tr, isError: false);
      } else {
        showCustomSnackBar("Failed to send OTP".tr);
      }
    } catch (e) {
      showCustomSnackBar("Error sending OTP: ${e.toString()}");
    }
  }

  Future<bool> verifyPhoneNumber(String phoneNumber, int otp) async {
    try {
      Response response = await ApiClient.postData(
        "${ApiConstant.chekPhoneNumber}/$phoneNumber",
        body: {"otp": otp},
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        showCustomSnackBar("Invalid OTP");
        return false;
      }
    } catch (e) {
      showCustomSnackBar("Error verifying OTP: ${e.toString()}");
      return false;
    }
  }

  void verifiedPhone(String phone, {int? userIndex}) async {
    if (phone.isEmpty) {
      showCustomSnackBar("Please enter phone number".tr);
      return;
    }

    // Send OTP
    await sendPhoneNumber(phone);

    CustomAlert.showInfo(
      context: Get.context!,
      message: 'otp_sent_customer_message'.tr,
      onPressed: () {
        Navigator.pop(Get.context!);
        Get.dialog(
          CustomAlertVerificationDialog(
            phoneNumber: phone,
            onVerificationComplete: (code) async {
              // Verify OTP
              bool verified = await verifyPhoneNumber(
                phone,
                int.parse(code),
              );
              if (verified) {
                if (userIndex != null) {
                  additionalUserPhoneVerified[userIndex] = true;
                }
                Navigator.pop(Get.context!);
                CustomAlert.showInfo(
                  context: Get.context!,
                  message: 'Activation Successful'.tr,
                );
              }
            },
            onResendCode: () async {
              // Resend OTP
              await sendPhoneNumber(phone);
              CustomAlert.showInfo(
                context: Get.context!,
                message: 'otp_sent_user_message'.tr,
              );
            },
          ),
        );
      },
    );
  }

  // Track if helper user already exists (has ID)
  var hasExistingHelper = false.obs;
  var existingHelperUserCount = 0.obs;
  var additionalUserPhoneVerified = <int, bool>{}.obs;

  RxString profileImageUrl = "".obs;

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      Response response = await ApiClient.getData(ApiConstant.getProfile);
      if (response.statusCode == 200) {
        profilemodelData.value = ProfileModel.fromJson(response.body);

        // Populate fields with existing data
        final data = profilemodelData.value?.data;
        if (data != null) {
          nameController.text = data.name ?? '';
          phoneController.text = data.contact ?? '';
          emailController.text = data.email ?? '';

          // Set profile image URL if available
          if (data.image != null && data.image!.isNotEmpty) {
            String imagePath = data.image!;
            // If the image path doesn't start with http, prepend the image base URL
            if (!imagePath.startsWith('http')) {
              profileImageUrl.value = ApiConstant.imageBaseUrl + imagePath;
            } else {
              profileImageUrl.value = imagePath;
            }
          }

          // Check if helper users exist and populate up to 2
          final helpers = data.helperUserList;
          if (helpers.isNotEmpty) {
            hasExistingHelper.value = true;
            existingHelperUserCount.value = helpers.length;
            enableUser.value = true;
            additionalUsers.clear();
            for (var helper in helpers) {
              additionalUsers.add({
                'phone': TextEditingController(
                  text: helper.contact ?? '',
                ),
                'password': TextEditingController(),
                'confirmPassword': TextEditingController(),
              });
            }
          }
        }
      } else {
        showCustomSnackBar(
          "Error in fetching Profile : ${response.statusCode}",
          isError: true,
        );
      }
      isLoading(false);
    } catch (e) {
      isLoading(false);
      showCustomSnackBar(
        "Error in fetching Profile : ${e.toString()}",
        isError: true,
      );
    }
  }

  // Add another user (max 2 additional users allowed)
  void addUser() {
    if (!enableUser.value) {
      showCustomSnackBar("Please enable user option first");
      return;
    }

    if (additionalUsers.length >= 2) {
      showCustomSnackBar("you_can_only_add_one_additional_user".tr);
      return;
    }

    additionalUsers.add({
      'phone': TextEditingController(),
      'password': TextEditingController(),
      'confirmPassword': TextEditingController(),
    });
  }

  // Remove user
  void removeUser(int index) {
    if (index < additionalUsers.length) {
      additionalUsers[index]['phone']?.dispose();
      additionalUsers[index]['password']?.dispose();
      additionalUsers[index]['confirmPassword']?.dispose();
      additionalUsers.removeAt(index);
      additionalUserPhoneVerified.remove(index);
    }
  }

  // Validate form
  bool validateForm() {
    if (nameController.text.isEmpty) {
      showCustomSnackBar("Please enter your name");
      return false;
    }

    if (emailController.text.isEmpty) {
      showCustomSnackBar("Please enter your email");
      return false;
    }

    // Only validate password if it's being changed
    if (passwordController.text.isNotEmpty) {
      if (passwordController.text.length < 8) {
        showCustomSnackBar("Password must be at least 8 characters");
        return false;
      }
    }

    // Validate additional user if enabled
    if (enableUser.value && additionalUsers.isNotEmpty) {
      for (int i = 0; i < additionalUsers.length; i++) {
        final user = additionalUsers[i];

        // if (user['phone']!.text.isEmpty) {
        //   showCustomSnackBar("Please enter phone for additional user");
        //   return false;
        // }

        // Only validate password if it's being changed
        if (user['password']!.text.isNotEmpty) {
          if (user['password']!.text.length < 8) {
            showCustomSnackBar(
              "Additional user password must be at least 8 characters",
            );
            return false;
          }

          if (user['password']!.text != user['confirmPassword']!.text) {
            showCustomSnackBar("Additional user passwords do not match");
            return false;
          }
        }
      }
    }

    return true;
  }

  // Update profile
  Future<void> updateProfile() async {
    if (!validateForm()) return;

    try {
      isSaving(true);

      Map<String, dynamic> profileData = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "contact": phoneController.text.trim(),
      };

      // Only include password if it's being changed
      if (passwordController.text.isNotEmpty) {
        profileData["password"] = passwordController.text;
      }

      // Add helper user(s) if enabled and exists (supporting single or multiple helper users)
      if (enableUser.value && additionalUsers.isNotEmpty) {
        List<Map<String, dynamic>> helpersList = [];
        for (var helperUser in additionalUsers) {
          Map<String, dynamic> helperData = {
            "contact": helperUser['phone']!.text.trim(),
          };
          if (helperUser['password']!.text.isNotEmpty) {
            helperData["password"] = helperUser['password']!.text;
          }
          helpersList.add(helperData);
        }

        // Send primary helper in helperUserId and all in helperUserIds for compatibility
        profileData["helperUserId"] = helpersList.first;
        profileData["helperUserIds"] = helpersList;
      }

      // Send as form-data with a single "data" field containing JSON string
      Map<String, String> body = {"data": jsonEncode(profileData)};

      Response response = await ApiClient.patchMultipartData(
        ApiConstant.updateProfile,
        body,
        multipartBody: [],
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Update HomeController with new profile data
        await _syncProfileToHomeController();

        showCustomSnackBar("Profile updated successfully", isError: false);
        Get.offAllNamed(AppRoute.navScreen);
      } else {
        Map<String, dynamic> body1 = jsonDecode(response.body);
        appLog('Profile update failed: ${body1['message']}');
        showCustomSnackBar(
          "Failed to update profile: ${body1['message'] ?? response.statusText}",
          isError: true,
        );
      }
      isSaving(false);
    } catch (e) {
      isSaving(false);
      showCustomSnackBar(
        "Error updating profile: ${e.toString()}",
        isError: true,
      );
    }
  }

  // Sync profile data to HomeController
  Future<void> _syncProfileToHomeController() async {
    try {
      // Fetch fresh profile data
      Response response = await ApiClient.getData(ApiConstant.getProfile);
      if (response.statusCode == 200) {
        ProfileModel updatedProfile = ProfileModel.fromJson(response.body);

        // Update HomeController with fresh data
        _homeController.profileData.value = updatedProfile;

        if (updatedProfile.data?.name != null) {
          _homeController.profileName.value = updatedProfile.data!.name!;
        }

        if (updatedProfile.data?.image != null &&
            updatedProfile.data!.image!.isNotEmpty) {
          String imagePath = updatedProfile.data!.image!;
          if (!imagePath.startsWith('http')) {
            _homeController.profileImageUrl.value =
                ApiConstant.imageBaseUrl + imagePath;
          } else {
            _homeController.profileImageUrl.value = imagePath;
          }
        }
      }
    } catch (e) {
      debugPrint('Error syncing profile to HomeController: ${e.toString()}');
    }
  }

  // Submit
  void submit() {
    updateProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    for (var user in additionalUsers) {
      user['phone']?.dispose();
      user['password']?.dispose();
      user['confirmPassword']?.dispose();
    }
    super.onClose();
  }
}
