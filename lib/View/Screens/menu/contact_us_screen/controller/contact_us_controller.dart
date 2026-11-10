import 'package:Senaeya/Service/api_client.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Helper/shared_prefe/shared_prefe.dart';
import '../../../../Widgegts/custom_alert_dialog/custom_alert_dialog.dart';

class ContactUsController extends GetxController {
  RxBool isLoading = false.obs;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  String phoneNumber = "";
  final messageController = TextEditingController();

  Future<void> contactUs({required VoidCallback onTapOk}) async {
    try {
      isLoading(true);
      String workShopId = await SharePrefsHelper.getString(
        SharedPreferenceValue.workshopId,
      );
      print("==================${phoneController.text}");
      Map<String, dynamic> body = {
        "providerWorkShopId": workShopId,
        "name": nameController.text,
        "contact": phoneNumber,
        "message": messageController.text,
      };

      Response response = await ApiClient.postData(
        "${ApiConstant.message}/public",
        body: body,
      );

      if (response.statusCode == 200) {
        debugPrint("""✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅
response: ${response.body}
✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅""");
        onSendSuccess(onTap: onTapOk);
        nameController.clear();
        phoneController.clear();
        messageController.clear();
        isLoading(false);
      } else {
        isLoading(false);
        showCustomSnackBar("Error in contacting");
      }
    } catch (e) {
      showCustomSnackBar("Error in contacting : ${e.toString()}");
    }
  }

  void onSendSuccess({required VoidCallback onTap}) {
    CustomAlert.showInfo(
        context: Get.context!,
        message: 'your_message_has_been_send_successfully'.tr,
        onPressed: onTap);
  }
}
