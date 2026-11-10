import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/auth_screens/repo/auth_repo.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ForgotScreenController extends GetxController {
  TextEditingController phoneController = TextEditingController();
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  Future<void> onTapForget() async {
    // final phone = phoneController.text.trim();
    // if (!_validatePhone(phone)) {
    //   errorMessage.value = 'forgot_password_invalid_phone'.tr;
    //   return;
    // }
    isLoading.value = true;
    Response response =
        await AuthRepo().forgotPassword(password: phoneController.text.trim());
    isLoading.value = false;
    if (response.statusCode == 200) {
      CustomAlert.showInfo(
        context: Get.context!,
        message: "The new password has\n been sent via WhatsApp".tr,
        onPressed: () {
          Navigator.pop(Get.context!);
        },
      );
    } else {
      errorMessage.value = response.statusText ?? "Error";
      showCustomSnackBar(errorMessage.value, isError: true);
    }
  }

  bool validatePhone(String phone) {
    // Basic Saudi phone validation: starts with 05, 9 digits
    final normalized =
        phone.replaceAll('+9665', '').replaceAll(RegExp(r'[^0-9]'), '');
    return normalized.length == 9 && normalized.startsWith('5');
  }

  void initial() {
    phoneController = TextEditingController();
  }

  @override
  void onInit() {
    initial();
    super.onInit();
  }

  @override
  void onClose() {
    phoneController.clear();
    super.onClose();
  }
}
