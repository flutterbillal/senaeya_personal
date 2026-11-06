import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:Senaeya/Service/api_client.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/Utils/AppLog/error_log.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../Core/AppRoute/app_route.dart';
import '../../../../Widgegts/custom_alert_verification_dialog/custom_alert_verification_dialog.dart';

class SignupScreenController extends GetxController {
  RxBool enableUser = false.obs; // Default to disabled
  // Main user fields
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final confirmEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  String workshopPhoneNumber = '';
  void setWorkShopPhone(String phone) {
    workshopPhoneNumber = phone;

    update();
  }

  // Additional user fields (for dynamic user addition)
  var additionalUsers = <Map<String, TextEditingController>>[].obs;

  // Terms agreement
  var isTermsAgreed = false.obs;
  var isVerifiedNumber = false.obs;
  var isVerified = false.obs;
  var isOtpVerified = false.obs;
  var isMainPhoneVerified = false.obs;
  var isCreatingAccount = false.obs;

  // Track verification status for additional users
  Map<int, bool> additionalUserPhoneVerified = {};

  // Validation error flags
  var isNameValid = true.obs;
  var isPhoneValid = true.obs;
  var isEmailValid = true.obs;
  var isUsernameValid = true.obs;
  var isPasswordValid = true.obs;
  var isConfirmPasswordValid = true.obs;

  // Check phone logic
  void checkPhone(String phoneNumber, {int? userIndex}) async {
    if (phoneNumber.isEmpty) {
      showCustomSnackBar("please_enter_phone_number_signup".tr);
      return;
    }

    // Send OTP
    await sendPhoneNumber(phoneNumber);

    CustomAlert.showInfo(
      context: Get.context!,
      message: 'otp_sent_customer_message'.tr,
      onPressed: () {
        Navigator.pop(Get.context!);
        Get.dialog(
          CustomAlertVerificationDialog(
            otpContrller: TextEditingController(),
            phoneNumber: phoneNumber,
            onVerificationComplete: (code) async {
              // Verify OTP
              bool verified = await verifyPhoneNumber(
                phoneNumber,
                int.parse(code),
              );
              appLog("verified===============$verified");
              if (verified) {
                // Check if this is for additional user or main user
                if (userIndex != null) {
                  // Additional user verification
                  additionalUserPhoneVerified[userIndex] = true;
                  update(); // Trigger UI update
                } else {
                  // Main user verification
                  isMainPhoneVerified.value = true;
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
              await sendPhoneNumber(phoneNumber);
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

  Future<void> sendPhoneNumber(String phoneNumber) async {
    try {
      isVerified(true);
      Response response = await ApiClient.postData(
        ApiConstant.chekPhoneNumber,
        body: {"phoneNumber": phoneNumber},
      );
      if (response.statusCode == 200) {
        appLog(response.body.toString());
        showCustomSnackBar("OTP sent successfully".tr, isError: false);
      } else {
        showCustomSnackBar("failed_to_send_otp".tr);
      }
      isVerified(false);
    } catch (e) {
      isVerified(false);
      showCustomSnackBar("error_sending_otp".tr);
    }
  }

  Future<bool> verifyPhoneNumber(String phoneNumber, int otp) async {
    try {
      isOtpVerified(true);
      Response response = await ApiClient.postData(
        "${ApiConstant.chekPhoneNumber}/$phoneNumber",
        body: {"otp": otp},
      );

      if (response.statusCode == 200) {
        appLog(response.body.toString());
        isOtpVerified(false);
        return true;
      } else {
        showCustomSnackBar("invalid_otp".tr);
        isOtpVerified(false);
        return false;
      }
    } catch (e) {
      isOtpVerified(false);
      showCustomSnackBar("error_verifying_otp".tr);
      return false;
    }
  }

  // Add another user
  void addUser() {
    if (!enableUser.value) {
      showCustomSnackBar("please_enable_user_option_first".tr);
      return;
    }

    if (additionalUsers.isNotEmpty) {
      showCustomSnackBar("you_can_only_add_one_additional_user".tr);
      return;
    }

    additionalUsers.add({
      'phone': TextEditingController(),
      'password': TextEditingController(),
      'confirmPassword': TextEditingController(),
    });
    update(); // Trigger UI update
  }

  // Remove user
  void removeUser(int index) {
    if (index < additionalUsers.length) {
      additionalUsers[index]['phone']?.dispose();
      additionalUsers[index]['password']?.dispose();
      additionalUsers[index]['confirmPassword']?.dispose();
      additionalUsers.removeAt(index);
      additionalUserPhoneVerified.remove(index);
      update(); // Trigger UI update
    }
  }

  // Validate form
  bool validateForm() {
    if (nameController.text.isEmpty) {
      showCustomSnackBar("please_enter_your_name".tr);
      return false;
    }

    if (phoneController.text.isEmpty) {
      showCustomSnackBar("please_enter_your_phone_number".tr);
      return false;
    }

    if (!isMainPhoneVerified.value) {
      showCustomSnackBar("please_verify_your_phone_number".tr);
      return false;
    }

    // if (emailController.text.isEmpty) {
    //   showCustomSnackBar("please_enter_your_email".tr);
    //   return false;
    // }

    if (passwordController.text.isEmpty) {
      showCustomSnackBar("please_enter_password".tr);
      return false;
    }

    if (passwordController.text.length < 8) {
      showCustomSnackBar("password_must_be_at_least_8_characters".tr);
      return false;
    }

    if (passwordController.text != confirmPasswordController.text) {
      showCustomSnackBar("passwords_do_not_match".tr);
      return false;
    }

    // Only validate helper user if the feature is enabled AND user was added
    if (enableUser.value && additionalUsers.isNotEmpty) {
      for (int i = 0; i < additionalUsers.length; i++) {
        final user = additionalUsers[i];

        if (user['phone']!.text.isEmpty) {
          showCustomSnackBar("please_enter_phone_for_helper_user".tr);
          return false;
        }

        if (additionalUserPhoneVerified[i] != true) {
          showCustomSnackBar("please_verify_phone_for_helper_user".tr);
          return false;
        }

        if (user['password']!.text.isEmpty) {
          showCustomSnackBar("please_enter_password_for_helper_user".tr);
          return false;
        }

        if (user['password']!.text.length < 8) {
          showCustomSnackBar(
            "helper_user_password_must_be_at_least_8_characters".tr,
          );
          return false;
        }

        if (user['password']!.text != user['confirmPassword']!.text) {
          showCustomSnackBar("helper_user_passwords_do_not_match".tr);
          return false;
        }
      }
    }

    if (!isTermsAgreed.value) {
      showCustomSnackBar("please_agree_to_terms_and_conditions".tr);
      return false;
    }

    return true;
  }

  // Create user account
  // Replace the createAccount() method in signup_screen_controller.dart

  Future<void> createAccount() async {
    if (!validateForm()) return;

    try {
      isCreatingAccount(true);

      // Validate email format
      // final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      // if (!emailRegex.hasMatch(emailController.text.trim())) {
      //   isCreatingAccount(false);
      //   showCustomSnackBar("please_enter_a_valid_email_address".tr);
      //   return;
      // }

      // Build base body
      Map<String, dynamic> body = {
        // "email": emailController.text.trim(),
        "password": passwordController.text,
        "contact": workshopPhoneNumber.trim(),
        "name": nameController.text.trim(),
        "role": "WORKSHOP_OWNER",
      };

      // ONLY add helperUserId if:
      // 1. The feature is enabled
      // 2. A helper user has been added
      // 3. The helper user phone is verified
      if (enableUser.value &&
          additionalUsers.isNotEmpty &&
          additionalUserPhoneVerified[0] == true) {
        final helperUser = additionalUsers[0];

        // Add helper user data
        body["helperUserId"] = {
          "password": helperUser['password']!.text.trim(),
          "contact": helperUser['phone']!.text.trim(),
        };

        appLog("Creating account WITH helper user");
        appLog("Helper contact: ${helperUser['phone']!.text.trim()}");
      } else {
        appLog("Creating account WITHOUT helper user");
        appLog("enableUser: ${enableUser.value}");
        appLog("additionalUsers.isNotEmpty: ${additionalUsers.isNotEmpty}");
        if (additionalUsers.isNotEmpty) {
          appLog(
            "additionalUserPhoneVerified[0]: ${additionalUserPhoneVerified[0]}",
          );
        }
      }

      appLog("Final request body: ${body.toString()}");

      Response response = await ApiClient.postData(
        ApiConstant.createUser,
        body: body,
      );

      appLog(
        "API Response: [${response.statusCode}] ${ApiConstant.createUser}",
      );
      appLog("Response body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        appLog("Account created successfully: ${response.body}");
        isCreatingAccount(false);

        String value = response.body['data']['accessToken'];
        await SharePrefsHelper.setString(SharedPreferenceValue.token, value);
        await SharePrefsHelper.setString(
            SharedPreferenceValue.role, "WORKSHOP_OWNER");
        appLog("Token saved: $value");

        // Show success dialog
        CustomAlert.showConfirmationColumn(
          context: Get.context!,
          message1: 'account_created_successfully'.tr,
          message: 'workshop_data_must_be_registered'.tr,
          yesButtonText: 'register_now'.tr,
          noButtonText: 'register_later'.tr,
          onYesPressed: () {
            Get.back();
            Get.toNamed(AppRoute.signupWorkshopScreen);
          },
          onNoPressed: () {
            Get.offAllNamed(AppRoute.navScreen);
          },
        );
      } else {
        isCreatingAccount(false);
        String errorMessage = "failed_to_create_account".tr;

        // Try to extract error message from response
        if (response.body != null && response.body is Map) {
          if (response.body['message'] != null) {
            errorMessage = response.body['message'];
          } else if (response.body['error'] != null) {
            if (response.body['error'] is List &&
                response.body['error'].isNotEmpty) {
              errorMessage =
                  response.body['error'][0]['message'] ?? errorMessage;
            } else if (response.body['error'] is String) {
              errorMessage = response.body['error'];
            }
          }
        }

        appLog("Error response: ${response.body}");
        showCustomSnackBar(errorMessage);
      }
    } catch (e) {
      isCreatingAccount(false);
      errorLog("Error creating account", e.toString());
      showCustomSnackBar("error_creating_account".tr);
    }
  }

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Password validation: at least 8 chars, one letter, one number
  bool isPasswordValidFunc(String password) {
    final hasMinLength = password.length >= 8;
    final hasLetter = password.contains(RegExp(r'[A-Za-z]'));
    final hasNumber = password.contains(RegExp(r'[0-9]'));
    return hasMinLength && hasLetter && hasNumber;
  }

  // Overall form validation
  bool get isFormValid {
    return nameController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        // emailController.text.trim().isNotEmpty &&
        // confirmEmailController.text.trim().isNotEmpty &&
        // emailController.text.trim() == confirmEmailController.text.trim() &&
        passwordController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty &&
        // passwordController.text == confirmPasswordController.text &&
        // isPasswordValidFunc(passwordController.text) &&
        isTermsAgreed.value;
  }

  // Call this on field change
  void validateFields() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
    isPhoneValid.value =
        workshopPhoneNumber.isNotEmpty && isMainPhoneVerified.value;
    isEmailValid.value = emailController.text.trim().isNotEmpty &&
        confirmEmailController.text.trim().isNotEmpty &&
        emailController.text.trim() == confirmEmailController.text.trim();
    isPasswordValid.value = isPasswordValidFunc(passwordController.text);
    isConfirmPasswordValid.value =
        passwordController.text == confirmPasswordController.text &&
            confirmPasswordController.text.isNotEmpty;
    update();
  }

  // Submit registration
  void submit() {
    // if(!formKey.currentState!.validate()){
    //   return;
    // }
    // print("object");
    // if (confirmEmailController.text != emailController.text) {
    //   showCustomSnackBar("Email and Confirm Email do not match".tr);
    //   return;
    // }
    // else
    if (confirmPasswordController.text != passwordController.text) {
      showCustomSnackBar("Password and Confirm Password do not match".tr);
      return;
    } else if (!isPasswordValidFunc(passwordController.text)) {
      showCustomSnackBar(
          "Password must be at least 8 characters long and include at least one letter and one number"
              .tr);
      return;
    }
    createAccount();
  }

  @override
  void onClose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    confirmEmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    for (var user in additionalUsers) {
      user['phone']?.dispose();
      user['password']?.dispose();
      user['confirmPassword']?.dispose();
    }
    super.onClose();
  }
}
