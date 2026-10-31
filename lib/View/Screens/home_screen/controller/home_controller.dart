import 'dart:io';

import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/home_screen/model/country_list_model.dart';
import 'package:Senaeya/View/Screens/home_screen/repo/get_cars_repo.dart';
import 'package:Senaeya/View/Widgets/common_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../Service/api_client.dart';
import '../../../Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import '../../edit_profile_screen/models/profile_screen_model.dart';
import '../../edit_workshop_screen/repo/edit_workshop_screen_repo.dart';
import '../../nav_screen/controller/navigation_controller.dart';

class HomeController extends GetxController {
  RxList<CommonItemModel> countryList = <CommonItemModel>[].obs;
  RxList<CommonItemModel> workshopList = <CommonItemModel>[].obs;
  RxList<WorkItem> workShopWorkList = <WorkItem>[].obs;
  RxList<CommonItemModel> selectedCountries = <CommonItemModel>[].obs;
  RxList<CommonItemModel> selectedWorks = <CommonItemModel>[].obs;
  RxList<WorkItem> selectedWorkShopWork = <WorkItem>[].obs;
  RxBool carsIsLoading = false.obs;
  var businessName = "John's Auto Service Center".obs;
  final String _prefsKey = 'selected_country_ids';
  final String _prefsKeyWorkShop = 'selected_workshopwork_ids';
  Rxn<ProfileModel> profileData = Rxn<ProfileModel>();
  RxString profileImageUrl = "".obs;
  RxString profileName = "".obs;
  RxBool isLoading = false.obs;
  String workShopId = "";
  String token = "";
  bool init = false;
  RxBool workShopWorkIsLoading = false.obs;
  RxString workShopName = "".obs;

  @override
  void onInit() async {
    init ? null : initial();
    init = true;
    super.onInit();
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

  Future<void> fetchLatestVersion() async {
    String latestVersionNumber = "1.0.5";
    String iosLatestVersion = "1.0.5";
    Response response = await ApiClient.getData(ApiConstant.appVersion);
    if (response.statusCode == 200) {
      latestVersionNumber = response.body['data']['androidVersion'] ?? "1.0.5";
      iosLatestVersion = response.body['data']['iosVersion'] ?? "1.0.5";
    }

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String currentVersionNumber = packageInfo.version;

    if (Platform.isAndroid) {
      if (latestVersionNumber != currentVersionNumber) {
        showAppUpdateDialog();
      }
    } else if (Platform.isIOS) {
      if (iosLatestVersion != currentVersionNumber) {
        showAppUpdateDialog();
      }
    }
  }

  showAppUpdateDialog() {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: CustomAlertDialog(
          message:
              'A new app update is available. Please update the app to continue.'
                  .tr,
          buttonText: 'Update'.tr,
          onPressed: () async {
            //playstore
            //https://play.google.com/store/apps/details?id=com.fahadalfayez.senaeya
            //huwawei
            //https://appgallery.huawei.com/app/C116338049
            //gelaxy
            //https://galaxystore.samsung.com/detail/com.fahadalfayez.senaeya
            if (Platform.isAndroid) {
              await launchUrl(
                Uri.parse(
                    "https://play.google.com/store/apps/details?id=com.fahadalfayez.senaeya"),
                mode: LaunchMode.externalApplication,
              );
            } else if (Platform.isIOS) {
              await launchUrl(
                Uri.parse("https://apps.apple.com/us/app/id6756404472"),
                mode: LaunchMode.externalApplication,
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> initial() async {
    // fetchLatestVersion();
    token = await SharePrefsHelper.getString(SharedPreferenceValue.token);
    workShopId = await SharePrefsHelper.getString(
      SharedPreferenceValue.workshopId,
    );
    // print("=========================$token");
    // print("=========================$workShopId");
    if (workShopId.isNotEmpty) {
      final response = await EditWorkshopScreenRepo().getWorkshopData();
      if (response.statusCode == 200 && response.body['data'] != null) {
        final data = response.body['data'];

        workShopName.value = data['workshopNameEnglish'] ?? '';
      }
    }
    if (token.isNotEmpty) {
      await fetchProfile();
    }
  }

  /// Fetch profile data from API
  Future<void> fetchProfile() async {
    try {
      //TODO: show loading indicator
      isLoading(false);
      Response response = await ApiClient.getData(ApiConstant.getProfile);

      if (response.statusCode == 200) {
        profileData.value = ProfileModel.fromJson(response.body);

        // Set profile name
        if (profileData.value?.data?.name != null) {
          profileName.value = profileData.value!.data!.name!;
        }

        // Set profile image URL if available
        if (profileData.value?.data?.image != null &&
            profileData.value!.data!.image!.isNotEmpty) {
          String imagePath = profileData.value!.data!.image!;
          // If the image path doesn't start with http, prepend the image base URL
          if (!imagePath.startsWith('http')) {
            profileImageUrl.value = ApiConstant.imageBaseUrl + imagePath;
          } else {
            profileImageUrl.value = imagePath;
          }
        }
      }
      isLoading(false);
    } catch (e) {
      isLoading(false);
      debugPrint('Error loading profile: ${e.toString()}');
    }
  }

  ///Countries
  Future<void> getCountries() async {
    carsIsLoading.value = true;

    Response response = await GetCarsRepo().getApi(
      getUrl: ApiConstant.getCountries,
    );
    carsIsLoading.value = false;

    if (response.statusCode == 200) {
      CommonListModel countryListModel = CommonListModel.fromJson(
        response.body,
      );
      countryList.clear();
      countryList.addAll(countryListModel.data ?? []);
      // After loading countries, apply any saved selection (by id)
      await _applySavedSelection();
    } else {
      showCustomSnackBar(response.statusText ?? "Country List Will Not Load");
    }
  }

  // Toggle selection for a country item (multi-select)
  Future<void> toggleSelection(CommonItemModel item) async {
    if (item.sId == null) return;

    final exists = selectedCountries.any((c) => c.sId == item.sId);
    if (exists) {
      selectedCountries.removeWhere((c) => c.sId == item.sId);
    } else {
      selectedCountries.add(item);
    }

    // Persist selection ids
    await _saveSelectedIds();
    update();
  }

  // Helper to check if an id is selected
  bool isSelectedById(String? id) {
    if (id == null) return false;
    return selectedCountries.any((c) => c.sId == id);
  }

  Future<void> _applySavedSelection() async {
    try {
      List<String> saved = await SharePrefsHelper.getLisOfString(_prefsKey);
      if (saved.isEmpty) return;

      selectedCountries.clear();
      for (var item in countryList) {
        if (item.sId != null && saved.contains(item.sId)) {
          selectedCountries.add(item);
        }
      }
      update();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveSelectedIds() async {
    try {
      final ids =
          selectedCountries.map((e) => e.sId).whereType<String>().toList();
      await SharePrefsHelper.setListOfString(_prefsKey, ids);
    } catch (e) {
      // ignore
    }
  }

  /// workShop Work
  Future<void> getWorkShopWork() async {
    workShopWorkIsLoading.value = true;

    Response response = await GetCarsRepo().getApi(
      getUrl: ApiConstant.workShopWork,
    );
    workShopWorkIsLoading.value = false;

    if (response.statusCode == 200) {
      WorkshopWorksModel commonListModel =
          WorkshopWorksModel.fromJson(response.body);
      workShopWorkList.clear();
      workShopWorkList.addAll(commonListModel.worksList ?? []);
      // After loading countries, apply any saved selection (by id)
      await _applySavedSelectionWorkShop();
    } else {
      showCustomSnackBar(response.statusText ?? "Country List Will Not Load");
    }
  }

  // Toggle selection for a workshop-work item (multi-select)
  Future<void> toggleWorkShopSelection(WorkItem item) async {
    if (item.sId == null) return;

    final exists = selectedWorkShopWork
        .any((c) => c.workCategoryName == item.workCategoryName);
    if (exists) {
      selectedWorkShopWork
          .removeWhere((c) => c.workCategoryName == item.workCategoryName);
    } else {
      selectedWorkShopWork.add(item);
    }

    await _saveSelectedWorkShopIds();
    update();
  }

  bool isWorkShopSelectedById(String? id) {
    if (id == null) return false;
    return selectedWorkShopWork.any((c) => c.sId == id);
  }

  Future<void> _applySavedSelectionWorkShop() async {
    try {
      List<String> saved = await SharePrefsHelper.getLisOfString(
        _prefsKeyWorkShop,
      );
      if (saved.isEmpty) return;

      selectedWorkShopWork.clear();
      workshopList.clear();
      for (var item in workShopWorkList) {
        if (item.workCategoryName != null &&
            saved.contains(item.workCategoryName)) {
          selectedWorkShopWork.add(item);
        }
      }
      // print("==================selectedWorkShopWork length: ${selectedWorkShopWork.length}" );
      update();
    } catch (e) {
      // ignore
    }
  }

  Future<void> _saveSelectedWorkShopIds() async {
    try {
      final ids = selectedWorkShopWork
          .map((e) => e.workCategoryName)
          .whereType<String>()
          .toList();
      await SharePrefsHelper.setListOfString(_prefsKeyWorkShop, ids);
    } catch (e) {
      // ignore
    }
  }

  Future<void> ensureCountriesLoaded() async {
    if (countryList.isEmpty) {
      await getCountries();
    } else if (selectedCountries.isEmpty) {
      await _applySavedSelection();
      await _applySavedSelectionWorkShop();
    }
  }

  // Card tap handlers
  void onAddCustomer() {
    // Ensure countries are loaded and selection is restored before navigating
    if (workShopId.isEmpty) {
      CommonAlertDialog.showRegisterWorkshopDialog();
      return;
    }

    Get.toNamed(
      AppRoute.addCustomerScreen,
      arguments: {
        "fromNewInvoice": false,
      },
    );
  }

  void onNewInvoice() {
    Get.toNamed(
      AppRoute.addCustomerScreen,
      arguments: {
        "fromNewInvoice": true,
      },
    );
    // Get.toNamed(
    //   AppRoute.addWorksScreen,
    // );
  }

  void needSubscriptionDialog() {
    CustomAlert.showInfo(
      context: Get.context!,
      message:
          "Your free trial period has ended We invite you to subscribe to the app's services"
              .tr,
      onPressed: () {
        Navigator.pop(Get.context!);
        Get.find<NavigationController>().changeIndex(4);
      },
    );
  }

  void onTapAddInvoice() {
    token.isNotEmpty
        ? workShopId.isEmpty
            ? CommonAlertDialog.showRegisterWorkshopDialog()
            : onNewInvoice()
        : showLoginAlertDialog();
  }

  void onTapReport() {
    token.isEmpty
        ? showLoginAlertDialog()
        : workShopId.isEmpty
            ? CommonAlertDialog.showRegisterWorkshopDialog()
            : onReports();
  }

  RxBool checkingAuthorization = false.obs;
  Future<bool> checkAuthorization({bool popOnUnAuthorized = false}) async {
    bool isAuthorized = false;
    try {
      checkingAuthorization = true.obs;
      Response response = await GetCarsRepo().getAuthorized();
      checkingAuthorization = false.obs;
      if (response.statusCode == 200) {
        isAuthorized = true;
      } else {
        isAuthorized = false;
        if (popOnUnAuthorized) {
          Get.back(closeOverlays: true);
        }
        needSubscriptionDialog();
      }
    } catch (e) {
      isAuthorized = false;
      showCustomSnackBar("Error: ${e.toString()}");
      return isAuthorized;
    }
    return isAuthorized;
  }

  void onCustomers() {
    Get.toNamed(AppRoute.customersScreen);
  }

  void onPreviousInvoices() {
    Get.toNamed(AppRoute.previousInvoicesScreen);
  }

  void onReports() {
    Get.toNamed(AppRoute.reportScreen);
  }

  void onExpenses() {
    Get.toNamed(AppRoute.expensesScreen);
  }
}
