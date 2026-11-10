import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../Service/api_client.dart';
import '../../../../../Service/api_url.dart';
import '../../../../../Utils/ToastMsg/toast_message.dart';
import '../../terms_and_condition/model/terms_and_condition_model.dart';

class AboutUsController extends GetxController {
  RxBool isloading = false.obs;
  Rxn<TermsandConditionModel> aboutusData = Rxn<TermsandConditionModel>();

  @override
  void onInit() {
    super.onInit();
    fetchTermsandCondition();
  }

  Future<void> fetchTermsandCondition() async {
    try {
      isloading(true);

      Response response = await ApiClient.getData(ApiConstant.aboutUs);
      isloading(false);
      if (response.statusCode == 200) {
        debugPrint("""✅✅✅✅✅✅✅✅✅✅✅✅✅
        ${response.body.toString()}
        ✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅✅""");

        aboutusData.value = TermsandConditionModel.fromJson(
          response.body,
        );
      } else {
        showCustomSnackBar("Error in Fetching the Terms and Condition");
      }
    } catch (e) {
      showCustomSnackBar("Error in Fetching the Terms and Condition");
    }
  }
}
