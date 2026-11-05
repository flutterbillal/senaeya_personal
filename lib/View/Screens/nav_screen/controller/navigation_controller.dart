import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:Senaeya/Service/socket_service.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../Core/AppRoute/app_route.dart';
import '../../../Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import '../../home_screen/controller/home_controller.dart';
import '../../notification_screen/controller/notification_controller.dart';

class NavigationController extends GetxController {
  // 0: Home, 1: Works & Cars, 2: Language, 3: Contact, 4: Profile
  var currentIndex = 0.obs;
  var isInitializing = true.obs;
  String workShopId = '';
  String userId = '';
  String role = '';
  String token = '';

  void showLoginAlertDialog(){
    CustomAlert.showInfo(
      context: Get.context!,
      message: 'You must log in to continue...'.tr,
      onPressed: () {
        Get.offAllNamed(AppRoute.loginScreen);
      },
    );
  }
  RxString appVersion = ''.obs;
  Future<String> getAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    return info.version; // This will read version from pubspec.yaml
  }

  void restrictedForOwner(){
    CustomAlert.showInfo(
      context: Get.context!,
      message: 'Sorry... this service is restricted to the workshop manager only,'.tr,
      onPressed: () {
        Navigator.pop(Get.context!);
      },
    );
  }


  @override
  Future<void> onInit() async {
    super.onInit();
    appVersion.value = await getAppVersion();
    update();
    if(!Get.isRegistered<HomeController>()){
      Get.put(HomeController());
    }
    token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
    workShopId = await SharePrefsHelper.getString(SharedPreferenceValue.workshopId);
    userId = await SharePrefsHelper.getString(SharedPreferenceValue.userId);
    role = await SharePrefsHelper.getString(SharedPreferenceValue.role);
    // print("role==========================$role");
    if(workShopId.isNotEmpty){
      // Initialize socket connection and register event listener for notifications
      try {
        AppSocketAllOperation.instance.initializeSocket();

        // Notification events are handled inside NotificationController.registerSocket(userId).
        // Previously there was a duplicate readEvent here — removed to avoid duplicate handling.

        // Initialize NotificationController and register socket listener there as well
        try {

            final notifCtrl = Get.find<NotificationController>();
            notifCtrl.registerSocket(userId);
        } catch (e) {
          appLog('Error initializing NotificationController: $e');
        }

      } catch (e) {
        appLog('Error initializing socket in NavigationController: $e');
      }
    }
    initializeHomeController();
  }

  /// Initialize HomeController and wait for initial data load
  Future<void> initializeHomeController() async {
    try {
      isInitializing(true);
      if (!Get.isRegistered<HomeController>()) {
        Get.put(HomeController());
      }
      isInitializing(false);
    } catch (e) {
      isInitializing(false);
    }
  }

  void changeIndex(int index) {
    currentIndex.value = index;
  }
}