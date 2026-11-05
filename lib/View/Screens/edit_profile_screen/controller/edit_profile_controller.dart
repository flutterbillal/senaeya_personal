import 'dart:convert';

import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Service/api_client.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/edit_profile_screen/models/additional_user_model.dart';
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
  final confirmPasswordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  Rxn<ProfileModel> profilemodelData = Rxn<ProfileModel>();

  // Additional user controllers for adding new user
  final newHelperPhoneController = TextEditingController();
  final newHelperPasswordController = TextEditingController();
  final newHelperConfirmPasswordController = TextEditingController();
  var isNewHelperPhoneVerified = false.obs;
  var verifiedHelperPhoneNumber = ''.obs;

  // Controllers for changing specific additional user password
  final changeHelperPasswordController = TextEditingController();
  final changeHelperConfirmPasswordController = TextEditingController();
  var isChangingHelperPassword = false.obs;

  // Additional user list fetched from backend
  var additionalUsersList = <AdditionalUserModel>[].obs;
  var isFetchingAdditionalUsers = false.obs;
  var isAddingAdditionalUser = false.obs;
  var isDeletingUser = false.obs;

  // Toggle for showing the "Add User" form
  var showAddUserForm = false.obs;

  var isLoading = false.obs;
  var isSaving = false.obs;
  RxString profileImageUrl = "".obs;

  @override
  void onInit() {
    super.onInit();
    getAdditionalUser();
    fetchProfile();
  }

  // ==================== ADDITIONAL USER APIS ====================

  /// Change password for a specific additional user
  Future<bool> chagePasswordSpecifiqAdditionalUser({
    required String newPassword,
    required String confirmPassword,
    required String id,
  }) async {
    if (newPassword.isEmpty) {
      showCustomSnackBar("please_enter_password_for_helper_user".tr);
      return false;
    }
    if (newPassword.length < 8) {
      showCustomSnackBar("helper_user_password_must_be_at_least_8_characters".tr);
      return false;
    }
    if (newPassword != confirmPassword) {
      showCustomSnackBar("helper_user_passwords_do_not_match".tr);
      return false;
    }

    try {
      isChangingHelperPassword(true);
      Response response = await ApiClient.patchData(
        "${ApiConstant.additionalUser}/change-password/$id",
        body: {
          "password": newPassword,
          "confirmPassword": confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Password Changed Successfully".tr, isError: false);
        changeHelperPasswordController.clear();
        changeHelperConfirmPasswordController.clear();
        return true;
      } else {
        Map<String, dynamic>? resBody;
        if (response.body is Map) {
          resBody = response.body;
        } else if (response.body is String) {
          try {
            resBody = jsonDecode(response.body);
          } catch (_) {}
        }
        showCustomSnackBar(
          resBody?['message'] ?? response.statusText ?? "Something went wrong",
        );
        return false;
      }
    } catch (e) {
      showCustomSnackBar("Error changing password: ${e.toString()}");
      return false;
    } finally {
      isChangingHelperPassword(false);
    }
  }

  /// Fetch additional / helper users
  Future<void> getAdditionalUser() async {
    try {
      isFetchingAdditionalUsers(true);
      Response response = await ApiClient.getData(ApiConstant.additionalUser);
      if (response.statusCode == 200) {
        additionalUsersList.clear();
        final List<dynamic> data = response.body["data"] ?? [];
        final List<AdditionalUserModel> list = data
            .map((e) =>
                AdditionalUserModel.fromJson(Map<String, dynamic>.from(e)))
            .toList()
            .cast<AdditionalUserModel>();
        additionalUsersList.assignAll(list);
        appLog("Additional user list count: ${additionalUsersList.length}");
        update();
      } else {
        showCustomSnackBar(response.statusText ?? "Something went wrong");
      }
    } catch (e) {
      appLog("Error fetching additional users: $e");
    } finally {
      isFetchingAdditionalUsers(false);
    }
  }

  /// Add new additional user
  Future<void> addAdditionalUser() async {
    String phone = newHelperPhoneController.text.trim();
    String password = newHelperPasswordController.text;
    String confirmPassword = newHelperConfirmPasswordController.text;

    if (phone.isEmpty) {
      showCustomSnackBar("Please enter phone number".tr);
      return;
    }

    if (!isNewHelperPhoneVerified.value || verifiedHelperPhoneNumber.value != phone) {
      showCustomSnackBar("please_verify_phone_for_helper_user".tr);
      return;
    }

    if (password.isEmpty) {
      showCustomSnackBar("please_enter_password_for_helper_user".tr);
      return;
    }

    if (password.length < 8) {
      showCustomSnackBar("helper_user_password_must_be_at_least_8_characters".tr);
      return;
    }

    if (password != confirmPassword) {
      showCustomSnackBar("helper_user_passwords_do_not_match".tr);
      return;
    }

    try {
      isAddingAdditionalUser(true);
      Response response = await ApiClient.postData(
        ApiConstant.additionalUser,
        body: {
          "contact": phone,
          "password": password,
          "confirmPassword": confirmPassword,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        showCustomSnackBar("Additional user added successfully".tr, isError: false);
        // Clear input controllers
        newHelperPhoneController.clear();
        newHelperPasswordController.clear();
        newHelperConfirmPasswordController.clear();
        isNewHelperPhoneVerified.value = false;
        verifiedHelperPhoneNumber.value = '';
        showAddUserForm.value = false;

        // Refresh additional user list
        await getAdditionalUser();
      } else {
        Map<String, dynamic>? resBody;
        if (response.body is Map) {
          resBody = response.body;
        } else if (response.body is String) {
          try {
            resBody = jsonDecode(response.body);
          } catch (_) {}
        }
        showCustomSnackBar(
          resBody?['message'] ?? response.statusText ?? "Something went wrong",
        );
      }
    } catch (e) {
      showCustomSnackBar("Error adding additional user: ${e.toString()}");
    } finally {
      isAddingAdditionalUser(false);
    }
  }

  /// Enable / Disable an additional user with optimistic UI and undo on error
  Future<void> enableDesableAdditionalUser({
    required String id,
    required bool status,
  }) async {
    final index = additionalUsersList.indexWhere((u) => u.sId == id);
    if (index == -1) return;

    final String originalStatus = additionalUsersList[index].status ?? 'active';
    final String newStatus = status ? "active" : "blocked";

    // Optimistically update UI
    additionalUsersList[index].status = newStatus;
    additionalUsersList.refresh();

    try {
      Response response = await ApiClient.patchData(
        "${ApiConstant.additionalUser}/status/$id",
        body: {"status": newStatus},
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        // Rollback UI change
        additionalUsersList[index].status = originalStatus;
        additionalUsersList.refresh();
        showCustomSnackBar(response.statusText ?? "Failed to update user status");
      }
    } catch (e) {
      // Rollback UI change
      additionalUsersList[index].status = originalStatus;
      additionalUsersList.refresh();
      showCustomSnackBar("Error updating user status: ${e.toString()}");
    }
  }

  /// Delete an additional user
  Future<void> deleteAdditionalUser({required String id}) async {
    final index = additionalUsersList.indexWhere((u) => u.sId == id);
    if (index == -1) return;

    final removedUser = additionalUsersList[index];

    // Optimistically remove from UI
    additionalUsersList.removeAt(index);

    try {
      Response response = await ApiClient.deleteData(
        "${ApiConstant.additionalUser}/$id",
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        showCustomSnackBar("Additional user deleted successfully".tr, isError: false);
      } else {
        // Rollback UI
        additionalUsersList.insert(index, removedUser);
        showCustomSnackBar(response.statusText ?? "Something went wrong");
      }
    } catch (e) {
      additionalUsersList.insert(index, removedUser);
      showCustomSnackBar("Error deleting user: ${e.toString()}");
    }
  }

  // ==================== PHONE OTP VERIFICATION ====================

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

  void verifiedPhone(String phone) async {
    if (phone.isEmpty) {
      showCustomSnackBar("Please enter phone number".tr);
      return;
    }

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
              bool verified = await verifyPhoneNumber(
                phone,
                int.parse(code),
              );
              if (verified) {
                isNewHelperPhoneVerified.value = true;
                verifiedHelperPhoneNumber.value = phone;
                Navigator.pop(Get.context!);
                CustomAlert.showInfo(
                  context: Get.context!,
                  message: 'Activation Successful'.tr,
                );
              }
            },
            onResendCode: () async {
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

  // ==================== PROFILE FETCH & UPDATE ====================

  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      Response response = await ApiClient.getData(ApiConstant.getProfile);
      if (response.statusCode == 200) {
        profilemodelData.value = ProfileModel.fromJson(response.body);

        final data = profilemodelData.value?.data;
        if (data != null) {
          nameController.text = data.name ?? '';
          phoneController.text = data.contact ?? '';
          emailController.text = data.email ?? '';

          if (data.image != null && data.image!.isNotEmpty) {
            String imagePath = data.image!;
            if (!imagePath.startsWith('http')) {
              profileImageUrl.value = ApiConstant.imageBaseUrl + imagePath;
            } else {
              profileImageUrl.value = imagePath;
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

  bool validateForm() {
    if (nameController.text.isEmpty) {
      showCustomSnackBar("Please enter your name");
      return false;
    }

    if (emailController.text.isEmpty) {
      showCustomSnackBar("Please enter your email");
      return false;
    }

    if (passwordController.text.isNotEmpty) {
      if (passwordController.text.length < 8) {
        showCustomSnackBar("Password must be at least 8 characters");
        return false;
      }
    }

    return true;
  }

  /// Update main workshop owner profile ONLY (additional users are managed independently via their own APIs)
  Future<void> updateProfile() async {
    if (!validateForm()) return;

    try {
      isSaving(true);

      Map<String, dynamic> profileData = {
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "contact": phoneController.text.trim(),
      };

      if (passwordController.text.isNotEmpty) {
        profileData["password"] = passwordController.text;
      }

      Map<String, String> body = {"data": jsonEncode(profileData)};

      Response response = await ApiClient.patchMultipartData(
        ApiConstant.updateProfile,
        body,
        multipartBody: [],
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
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

  Future<void> _syncProfileToHomeController() async {
    try {
      Response response = await ApiClient.getData(ApiConstant.getProfile);
      if (response.statusCode == 200) {
        ProfileModel updatedProfile = ProfileModel.fromJson(response.body);
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

  void submit() {
    updateProfile();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    newHelperPhoneController.dispose();
    newHelperPasswordController.dispose();
    newHelperConfirmPasswordController.dispose();
    changeHelperPasswordController.dispose();
    changeHelperConfirmPasswordController.dispose();
    super.onClose();
  }
}