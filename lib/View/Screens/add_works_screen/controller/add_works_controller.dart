import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/add_works_screen/model/work_list_response_model.dart';
import 'package:Senaeya/View/Screens/add_works_screen/repo/add_works_repo.dart';
import 'package:Senaeya/View/Screens/home_screen/controller/home_controller.dart';
import 'package:Senaeya/View/Screens/home_screen/model/country_list_model.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgegts/custom_text_field/custom_text_field.dart';
import 'package:Senaeya/View/Widgets/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../Utils/AppColors/app_colors.dart';

class CommonWorkItem {
  final String code;
  final String name;
  final int qty;
  final double price;
  bool selected;

  CommonWorkItem({
    required this.code,
    required this.name,
    required this.qty,
    required this.price,
    this.selected = false,
  });

  double get total => qty * price;

  CommonWorkItem copyWith({
    String? code,
    String? name,
    int? qty,
    double? price,
    bool? selected,
  }) {
    return CommonWorkItem(
      code: code ?? this.code,
      name: name ?? this.name,
      qty: qty ?? this.qty,
      price: price ?? this.price,
      selected: selected ?? this.selected,
    );
  }
}

class AddWorksController extends GetxController {
  // Form fields
  var selectedCode = ''.obs;
  var selectedWorkId = ''.obs; // Store the work ID instead of just name
  var workName = ''.obs;
  var qty = 0.obs;
  var price = 0.0.obs;
  var searchQuery = ''.obs;
  String clientId = '';
  String clientCarId = '';

  // Text editing controllers
  final TextEditingController priceController = TextEditingController();

  // Lists
  var works = <CommonWorkItem>[].obs;
  var filteredWorks = <CommonWorkItem>[].obs;

  // Selection
  var selectedIndex = (-1).obs;

  // Calculations
  var discount = RxDouble(0.0);

  double get totalBeforeTax {
    double total = works.fold(0.0, (sum, item) => sum + item.total);
    return total;
  }

  double get tax => isTaxAvailable.value
      ? ((totalBeforeTax - discount.value) * 0.15)
      : 0; // 15% VAT

  double get totalIncludingTax => totalBeforeTax - discount.value + tax;

  ///from works screen value

  String brandName = '';
  String carModel = '';
  String carYear = '';
  String brandId = '';
  String carModelId = '';
  String clientName = '';
  String clientPhone = '';
  String carPlateNumberForInternational = '';
  String carPlateNumberForSaudi = '';
  String carSymbolForSaudi = '';
  String saudiPlateEnglishText = '';
  String saudiPlateArabicText = '';
  String inputEnglishPlateNumber = '';
  String inputArabicPlateNumber = '';
  String symbolImageForSaudi = '';
  String internationalPlateNumber = '';
  String brandImage = '';
  RxBool isTaxAvailable = false.obs;

  RxList<WorkItem> selectedWorkModel = <WorkItem>[].obs;
  RxList<String> selectedWorkIds = <String>[].obs;

  // Key to match HomeController's saved workshop works
  final String _prefsKeyWorkShop = 'selected_workshopwork_ids';
  RxList<String> savedWorkShopIds = <String>[].obs;

  @override
  void onInit() async {
    super.onInit();

    // Get arguments
    HomeController homeController = Get.find<HomeController>();
    selectedWorkModel = homeController.selectedWorkShopWork;
    // print("selected workshop work===============${selectedWorkModel.length}");
    final arguments = Get.arguments ?? {};
    isTaxAvailable.value = arguments['isTaxAvailable'] ?? false;
    clientId = arguments['clientId'] ?? '';
    clientCarId = arguments['clientCarId'] ?? '';
    brandName = arguments['brandName'] ?? '';
    carModelId = arguments['modelId'] ?? '';
    carModel = arguments['modelName'] ?? '';
    carYear = arguments['year'] ?? '';
    brandImage = arguments['brandImage'] ?? '';
    clientName = arguments['clientName'] ?? '';
    clientPhone = arguments['clientPhone'] ?? '';

    // Saudi plate information
    saudiPlateEnglishText = arguments['saudiPlateEnglishText'] ?? '';
    saudiPlateArabicText = arguments['saudiPlateArabicText'] ?? '';
    inputEnglishPlateNumber = arguments['inputEnglishPlateNumber'] ?? '';
    inputArabicPlateNumber = arguments['inputArabicPlateNumber'] ?? '';
    symbolImageForSaudi = arguments['symbolImageForSaudi'] ?? '';

    // International plate information
    internationalPlateNumber = arguments['internationalPlateNumber'] ?? '';

    filteredWorks.addAll(works);
    // selectedWorkModel=Get.arguments['works'];

    // Load saved workshop work IDs from shared preferences
    await loadSavedWorkShopIds();

    getWorks();
    // Listen to search query changes
    ever(searchQuery, (_) => filterWorks());
  }

  RxList<WorksModel> worksList = <WorksModel>[].obs;
  RxBool isLoading = false.obs;

  /// Load saved workshop work IDs from shared preferences
  Future<void> loadSavedWorkShopIds() async {
    try {
      List<String> saved =
          await SharePrefsHelper.getLisOfString(_prefsKeyWorkShop);
      savedWorkShopIds.clear();
      //TODO: Check if saved contains duplicates before adding
      savedWorkShopIds.addAll(saved);

      print(
          "================ Loaded saved workshop work IDs: ${savedWorkShopIds.length}");
      print("================ Workshop work IDs: $savedWorkShopIds");

      update();
    } catch (e) {
      print("================ Error loading saved workshop work IDs: $e");
    }
  }

  /// Check if a workshop work ID is in the saved list
  bool isWorkShopWorkSaved(String? id) {
    if (id == null) return false;
    return savedWorkShopIds.contains(id);
  }

  // Dynamic computed lists based on API data
  List<String> get availableCodes {
    return worksList
        .map((work) => work.code ?? '')
        .where((code) => code.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> get availableWorks {
    String currentLocale = Get.locale?.languageCode ?? 'en';
    return worksList
        .map((work) => work.getLocalizedTitle(currentLocale))
        .where((title) => title.isNotEmpty)
        .toList();
  }

  // Get work model by localized name
  WorksModel? getWorkByLocalizedName(String localizedName) {
    String currentLocale = Get.locale?.languageCode ?? 'en';
    for (var work in worksList) {
      if (work.getLocalizedTitle(currentLocale) == localizedName) {
        return work;
      }
    }
    return null;
  }

  // Get work model by code
  WorksModel? getWorkByCode(String code) {
    for (var work in worksList) {
      if (work.code == code) {
        return work;
      }
    }
    return null;
  }

  /// Fetch works from the repository
  Future<void> getWorks() async {
    // Build query string using saved workshop work IDs
    String queryString = '';
    if (savedWorkShopIds.isNotEmpty) {
      queryString =
          savedWorkShopIds.map((id) => 'workCategoryName=$id').join('&');
    }

    String url = '/works?${queryString.isNotEmpty ? queryString : ''}';

    print("================ Fetching works with URL: $url");

    isLoading.value = true;
    Response response = await AddWorksRepo().getWorks(url: url);
    isLoading.value = false;
    if (response.statusCode == 200) {
      WorksListResponse worksListResponse =
          WorksListResponse.fromJson(response.body);
      worksList.clear();
      worksList.addAll(worksListResponse.data?.workList ?? []);

      print("================ Loaded works count: ${worksList.length}");
    } else {
      showCustomSnackBar("${response.statusText}");
    }
  }

  void addWork() {
    if (selectedCode.value.isEmpty ||
        workName.value.isEmpty ||
        qty.value <= 0 ||
        price.value <= 0.0) {
      showCustomSnackBar('please_fill_all_required_fields'.tr, isError: true);
      return;
    }

    final newWork = CommonWorkItem(
      code: selectedCode.value,
      name: workName.value,
      qty: qty.value,
      price: price.value,
    );

    works.add(newWork);
    filterWorks();
    clearForm();
    update();
    showCustomSnackBar('work_item_added_successfully'.tr, isError: false);
  }

  void editWork(int index) {
    if (index < 0 || index >= works.length) return;

    final work = works[index];
    selectedCode.value = work.code;
    workName.value = work.name;
    qty.value = work.qty;
    price.value = work.price;
  }

  void updateWork(int index) {
    if (index < 0 || index >= works.length) return;

    works[index] = CommonWorkItem(
      code: selectedCode.value,
      name: workName.value,
      qty: qty.value,
      price: price.value,
    );
    filterWorks();
    clearForm();
    selectedIndex.value = -1;
    update();
    showCustomSnackBar('work_item_updated_successfully'.tr, isError: false);
  }

  void onTapNext() {
    // Create a list of work items with work ID, quantity, and price
    List<Map<String, dynamic>> workItems = works.map((workItem) {
      // Find the work model to get the ID
      WorksModel? workModel = getWorkByCode(workItem.code);

      return {
        "work": workModel?.id ?? '', // Use the work ID from the model
        "quantity": workItem.qty,
        "cost": workItem.price,
        // "code": workItem.code,
      };
    }).toList();

    ///Navigate
    // print("========================$totalIncludingTax");
    Get.toNamed(AppRoute.addSparePartScreen, arguments: {
      'workItems': workItems,
      'clientId': clientId,
      'clientCarId': clientCarId,
      'discount': discount.value,
      'brandName': brandName,
      'brandId': brandId,
      'modelId': carModelId,
      'modelName': carModel,
      'year': carYear,
      'brandImage': brandImage,
      'clientName': clientName,
      'clientPhone': clientPhone,
      // Saudi plate information
      'saudiPlateEnglishText': saudiPlateEnglishText,
      'saudiPlateArabicText': saudiPlateArabicText,
      'inputEnglishPlateNumber': inputEnglishPlateNumber,
      'inputArabicPlateNumber': inputArabicPlateNumber,
      'symbolImageForSaudi': symbolImageForSaudi,
      // International plate information
      'internationalPlateNumber': internationalPlateNumber,
      'costOfWorks': totalIncludingTax,
    });
  }

  void editWorkWithValues(
    int index,
    String code,
    String name,
    int qty,
    double price,
  ) {
    if (index < 0 || index >= works.length) return;
    works[index] = CommonWorkItem(
      code: code,
      name: name,
      qty: qty,
      price: price,
      selected: works[index].selected,
    );
    filterWorks();
    works.refresh();
    filteredWorks.refresh();
    selectedIndex.value = -1;
    update();
    showCustomSnackBar('work_item_updated_successfully'.tr, isError: false);
  }

  void deleteWork(int index) {
    if (index < 0 || index >= works.length) return;

    CustomAlert.showConfirmation(
        context: Get.context!,
        message: 'are_you_sure_delete_work_item'.tr,
        onYesPressed: () {
          works.removeAt(index);
          filterWorks();
          selectedIndex.value = -1;
          Navigator.pop(Get.context!);
          showCustomSnackBar('work_item_deleted_successfully'.tr,
              isError: false);
        },
        onNoPressed: () {
          Navigator.pop(Get.context!);
        },
        yesButtonText: "delete".tr,
        noButtonText: "cancel".tr);
    update();

    // Get.dialog(
    //   AlertDialog(
    //     title: CustomText(text: 'confirm_delete'.tr),
    //     content: CustomText(text: 'are_you_sure_delete_work_item'.tr),
    //     actions: [
    //       TextButton(onPressed: () => Navigator.pop(context), child: Text('cancel'.tr)),
    //       TextButton(
    //         onPressed: () {
    //           works.removeAt(index);
    //           filterWorks();
    //           selectedIndex.value = -1;
    //           Get.back();
    //           Get.snackbar('success'.tr, 'work_item_deleted_successfully'.tr);
    //         },
    //         child: CustomText(text: 'delete'.tr, color: Colors.red),
    //       ),
    //     ],
    //   ),
    // );
  }

  void selectWork(int index) {
    // Deselect all works first
    for (int i = 0; i < works.length; i++) {
      works[i].selected = false;
    }

    // Select the clicked work
    if (index >= 0 && index < works.length) {
      works[index].selected = true;
      selectedIndex.value = index;
    } else {
      selectedIndex.value = -1;
    }
    works.refresh();
    filteredWorks.refresh();
    update();
  }

  void filterWorks() {
    if (searchQuery.value.isEmpty) {
      filteredWorks.assignAll(works);
    } else {
      filteredWorks.assignAll(
        works
            .where(
              (work) =>
                  work.code.toLowerCase().contains(
                        searchQuery.value.toLowerCase(),
                      ) ||
                  work.name.toLowerCase().contains(
                        searchQuery.value.toLowerCase(),
                      ),
            )
            .toList(),
      );
    }
    update();
  }

  void clearForm() {
    selectedCode.value = '';
    workName.value = '';
    qty.value = 1;
    price.value = 0.0;
    priceController.clear();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void onCodeChanged(String? value) {
    selectedCode.value = value ?? '';

    // Auto-fill work name and price from API data when code is selected
    if (selectedCode.value.isNotEmpty) {
      WorksModel? work = getWorkByCode(selectedCode.value);
      if (work != null) {
        String currentLocale = Get.locale?.languageCode ?? 'en';
        workName.value = work.getLocalizedTitle(currentLocale);
        // price.value = work.cost?.toDouble() ?? 0.0;
        // priceController.text = price.value.toString();
      }
    }
  }

  void onWorkNameChanged(String value) {
    workName.value = value;

    // Auto-fill code and price from API data when work name is selected
    if (workName.value.isNotEmpty) {
      WorksModel? work = getWorkByLocalizedName(workName.value);
      if (work != null) {
        selectedCode.value = work.code ?? '';
        // price.value = work.cost?.toDouble() ?? 0.0;
        // priceController.text = price.value.toString();
      }
    }
  }

  void onQtyChanged(String value) {
    qty.value = int.tryParse(value) ?? 1;
  }

  void onPriceChanged(String value) {
    price.value = double.tryParse(value) ?? 0.0;
  }

  void onDiscountChanged(String value) {
    discount.value = double.tryParse(value) ?? 0.0;
  }

  void showDiscountDialog(BuildContext context) {
    TextEditingController discountController = TextEditingController(
      text: discount.value == 0.0 ? '' : discount.value.toString(),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: CustomText(text: 'discount'.tr),
          content: CustomTextField(
            textAlign: TextAlign.center,
            controller: discountController,
            hintText: 'discount'.tr,
            keyboardType: TextInputType.number,
            height: 45,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.redTextFiled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: CustomText(
                      text: 'cancel'.tr,
                      color: AppColors.red,
                      fontSize: 16.sp,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                    ),
                    onPressed: () {
                      discount.value =
                          double.tryParse(discountController.text) ?? 0.0;
                      Navigator.of(context).pop();
                      showCustomSnackBar('discount_updated_successfully'.tr,
                          isError: false);
                    },
                    child: CustomText(
                      text: 'save'.tr,
                      color: Colors.white,
                      fontSize: 16.sp,
                      overflow: TextOverflow.visible,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void showEditDialog(BuildContext context, int index) {
    if (index < 0 || index >= works.length) return;

    editWork(index);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.85,
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                CustomText(
                  text: 'edit_work'.tr,
                  fontSize: 18.sp,
                ),
                SizedBox(height: 16.h),
                // Content
                Obx(
                  () => CustomDropdown<String>(
                    value: selectedCode.value.isEmpty
                        ? null
                        : selectedCode.value,
                    items: availableCodes,
                    hint: 'code'.tr,
                    onChanged: onCodeChanged,
                    height: 45,
                    width: double.infinity,
                    borderRadius: 24,
                    iconSize: 20,
                    icon: null,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    hintStyle: const TextStyle(color: Colors.grey),
                    itemStyle: const TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => CustomDropdown<String>(
                    value: workName.value.isNotEmpty &&
                            availableWorks.toSet().contains(workName.value)
                        ? workName.value
                        : null,
                    items: availableWorks.toSet().toList(),
                    hint: 'works'.tr,
                    onChanged: (val) {
                      if (val != null && availableWorks.contains(val)) {
                        onWorkNameChanged(val);
                      } else {
                        onWorkNameChanged('');
                      }
                    },
                    height: 45,
                    width: double.infinity,
                    borderRadius: 24,
                    icon: null,
                    iconSize: 20,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    hintStyle: const TextStyle(color: Colors.grey),
                    itemStyle: const TextStyle(fontSize: 14),
                  ),
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  textAlign: TextAlign.center,
                  initialValue: qty.value.toString(),
                  hintText: 'qty'.tr,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => qty.value = int.tryParse(val) ?? 1,
                  height: 45,
                ),
                SizedBox(height: 8.h),
                CustomTextField(
                  textAlign: TextAlign.center,
                  initialValue: price.value.toString(),
                  hintText: 'price'.tr,
                  keyboardType: TextInputType.number,
                  onChanged: (val) =>
                      price.value = double.tryParse(val) ?? 0.0,
                  height: 45,
                ),
                SizedBox(height: 24.h),
                // Actions
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redTextFiled,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                          text: 'cancel'.tr,
                          color: AppColors.red,
                          fontSize: 16.sp,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                        ),
                        onPressed: () {
                          updateWork(index);
                          Navigator.of(context).pop();
                        },
                        child: CustomText(
                          text: 'save'.tr,
                          color: Colors.white,
                          fontSize: 16.sp,
                          overflow: TextOverflow.visible,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
