import 'dart:developer';

import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:get/get.dart';

class SplashScreenController extends GetxController {
  RxDouble animation = 0.0.obs;
  RxDouble animation2 = 0.0.obs;

  @override
  void onInit() async {
    String token = await SharePrefsHelper.getString(
      SharedPreferenceValue.token,
    );

    log("""
✅✅✅✅✅✅✅✅✅✅✅✅✅

$token

✅✅✅✅✅✅✅✅✅✅✅✅✅
""");
    Future.delayed(const Duration(milliseconds: 500), () {
      animation.value = 1.0;
      animation2.value = 1.0;
    });
    Future.delayed(const Duration(seconds: 2), () {
      if (token.isEmpty) {
        Get.offAllNamed(AppRoute.navScreen, arguments: {"from": "splash"});
      } else {
        Get.offAllNamed(AppRoute.navScreen);
      }
    });
    super.onInit();
  }
}
