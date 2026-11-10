import 'dart:io';

import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/View/Screens/edit_profile_screen/models/profile_screen_model.dart';
import 'package:Senaeya/View/Screens/home_screen/controller/home_controller.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgets/common_alert_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart' as UrlLauncher;

import '../../../../../Utils/AppColors/app_colors.dart';
import '../../../../Widgegts/custom_alert_dialog/custom_alert_dialog.dart';

class MenuController extends GetxController {
  // Get HomeController instance

  late HomeController _homeController;
  // Use getters to directly access HomeController's reactive values
  RxString profileImageUrl = ''.obs;
  RxString get profileName => _homeController.profileName;
  Rxn<ProfileModel> get profileData => _homeController.profileData;
  RxBool get isLoading => _homeController.isLoading;
  RxString token = ''.obs;
  @override
  Future<void> onInit() async {
    _homeController = Get.find<HomeController>();
    print("=====================${_homeController.profileImageUrl}");
    profileImageUrl = _homeController.profileImageUrl;
    token.value = await SharePrefsHelper.getString(SharedPreferenceValue.token);
    super.onInit();
    // No need to load separately - we're directly using HomeController's observables
  }

  void showLoginAlertDialog() {
    CustomAlert.showInfo(
      context: Get.context!,
      message: 'You must log in to continue...'.tr,
      onPressed: () {
        Get.offAllNamed(AppRoute.loginScreen);
      },
    );
  }

  // Example navigation methods
  void goToHome() => Get.back();
  void goToAddWorks() => token.isEmpty
      ? showLoginAlertDialog()
      : _homeController.workShopId.isEmpty
          ? CommonAlertDialog.showRegisterWorkshopDialog()
          : Get.toNamed(AppRoute.addWorksItem);
  void goToAppExplain() => Get.toNamed(
        AppRoute.appExplainScreen,
      );
  void goToTerms() => Get.toNamed(AppRoute.termsAndCondition);
  void goToAboutUs() =>
      Get.toNamed(AppRoute.aboutUsScreen, arguments: {'from': 'aboutUs'});
  void goToAppRating() {
    const androidUrl =
        'https://play.google.com/store/apps/details?id=com.fahadalfayez.senaeya';

    const hueaweiUrl = 'https://appgallery.huawei.com/app/C116338049';
    const gelaxyUrl =
        'https://galaxystore.samsung.com/detail/com.fahadalfayez.senaeya';

    const iosUrl = 'https://apps.apple.com/app/senaeya-الصناعية/id6756404472';

    final String storeUrl = Platform.isAndroid ? gelaxyUrl : iosUrl;
    launchUrl(storeUrl);
  }

  void goToAppSharing() {
    const String message = 'https://senaeya.net';

    SharePlus.instance.share(
      ShareParams(
        text: message,
        sharePositionOrigin: const Rect.fromLTWH(10, 10, 50, 50),
      ),
    );
  }

  void onTapFacebook({required String facebookUrl}) {
    launchUrl(facebookUrl);
  }

  void onTapYoutube({required String youtubeUrl}) {
    launchUrl(youtubeUrl);
  }

  void onTapTiktok({required String tiktokUrl}) {
    launchUrl(tiktokUrl);
  }

  void launchUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      appLog('Attempting to launch URL: $url');

      // Check if the URL can be launched
      bool canLaunch = await UrlLauncher.canLaunchUrl(uri);
      appLog('Can launch URL: $canLaunch');

      if (canLaunch) {
        bool launched = await UrlLauncher.launchUrl(
          uri,
          mode: UrlLauncher.LaunchMode.externalApplication,
        );

        if (!launched) {
          appLog('Failed to launch URL even though canLaunchUrl returned true');
          _showErrorSnackbar('Failed to open the link. Please try again.');
        }
      } else {
        appLog('Cannot launch URL: $url');
        _showErrorSnackbar(
            'Cannot open this link. Please check if you have the app installed.');
      }
    } catch (e) {
      appLog('Exception launching URL: $e');
      _showErrorSnackbar('An error occurred while opening the link: $e');
    }
  }

  void _showErrorSnackbar(String message) {
    if (Get.context != null) {
      Get.snackbar(
        'Error'.tr,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void exitApp() {
    _showLogoutDialog(Get.context!);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: CustomText(
                      text: 'logout_confirm'.tr,
                      fontSize: 18.w,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xffFAECEC),
                            foregroundColor: AppColors.red,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: CustomText(
                            text: 'no'.tr,
                            fontWeight: FontWeight.bold,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1766A0),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),
                          onPressed: () {
                            onLogOut();
                          },
                          child: CustomText(
                            text: 'yes'.tr,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Contact actions
  void openContact(String type) {
    // Implement launch logic for social/contact icons
  }

  Future<void> onLogOut() async {
    Get.delete<HomeController>();
    Get.deleteAll();
    await SharePrefsHelper.clearData();
    Navigator.pop(Get.context!);
    Get.offAllNamed(AppRoute.navScreen);
  }
}
