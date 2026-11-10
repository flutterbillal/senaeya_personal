import 'package:Senaeya/Service/api_client.dart';
import 'package:Senaeya/View/Screens/customers_screen/model/client_by_car_model.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../Service/api_url.dart';
import '../../../../Utils/ToastMsg/toast_message.dart';
import '../../add_customer_screen/repo/add_customer_repo.dart';
import '../../home_screen/model/country_list_model.dart';
import '../../home_screen/repo/get_cars_repo.dart';
import '../model/customer_custom_model.dart';

class CustomersScreenController extends GetxController {
  RxInt userType = 0.obs; // 0: Customer, 1: Workshop
  RxInt boardType = 0.obs; // 0: Saudi, 1: Non-Saudi
  RxString plateNumber = ''.obs;
  RxList<String> plateLetters = ['', '', ''].obs;
  TextEditingController idController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  TextEditingController plateNumberController = TextEditingController();
  RxString searchText = ''.obs;
  RxString selectedCarSymbolId = ''.obs;
  RxBool isSearchActive = false.obs;
  final List<Map<String, String>> letterOptions = [
    {'en': 'A', 'ar': 'ا'},
    {'en': 'B', 'ar': 'ب'},
    {'en': 'J', 'ar': 'ح'},
    {'en': 'D', 'ar': 'د'},
    {'en': 'R', 'ar': 'ر'},
    {'en': 'S', 'ar': 'س'},
    {'en': 'X', 'ar': 'ص'},
    {'en': 'T', 'ar': 'ط'},
    {'en': 'E', 'ar': 'ع'},
    {'en': 'G', 'ar': 'ق'},
    {'en': 'K', 'ar': 'ك'},
    {'en': 'L', 'ar': 'ل'},
    {'en': 'Z', 'ar': 'م'},
    {'en': 'N', 'ar': 'ن'},
    {'en': 'H', 'ar': 'ه'},
    {'en': 'U', 'ar': 'و'},
    {'en': 'V', 'ar': 'ى'},
  ];

  @override
  onInit() {
    idController.text = id.value;
    nameController.text = name.value;
    getCarSymbol();
    super.onInit();
  }

  RxString plateCode = ''.obs;
  RxString vin = ''.obs;
  RxString brand = ''.obs;
  final List<String> brandOptions = ['Toyota', 'Nissan', 'Hyundai'];
  RxString model = ''.obs;
  final List<String> modelOptions = ['Corolla', 'Camry', 'Altima'];
  RxString year = ''.obs;
  final List<String> yearOptions = ['2022', '2023', '2024'];
  RxString phone = ''.obs;
  RxString name = ''.obs;
  RxString id = ''.obs;
  RxInt selectedColor = RxInt(-1); // 0: Green, 1: Yellow, 2: White
  final List<Map<String, String>> countries = [
    {'name': 'Saudi Arabia', 'code': '+966', 'flag': 'assets/images/saudi.png'},
    {'name': 'United Kingdom', 'code': '+44', 'flag': 'assets/images/uk.png'},
  ];
  RxInt selectedCountryIndex = 0.obs;

  void setUserType(int? value) => userType.value = value ?? 0;
  void setBoardType(int? value) => boardType.value = value ?? 0;
  void setPlateNumber(String value) {
    // Only accept digits and limit to 4 characters
    final digitsOnly = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length <= 4) {
      plateNumber.value = digitsOnly;
      // Update the controller to reflect the validated value
      if (plateNumberController.text != digitsOnly) {
        plateNumberController.value = TextEditingValue(
          text: digitsOnly,
          selection: TextSelection.collapsed(offset: digitsOnly.length),
        );
      }
    } else {
      // Prevent input beyond 4 digits by resetting to current valid value
      plateNumberController.value = TextEditingValue(
        text: plateNumber.value,
        selection: TextSelection.collapsed(offset: plateNumber.value.length),
      );
    }
  }

  void setPlateLetter(int index, String value) => plateLetters[index] = value;
  void setSelectedColor(int? value) => selectedColor.value = value ?? 0;
  void setVin(String value) => vin.value = value;
  void setBrand(String value) => brand.value = value;
  void setModel(String value) => model.value = value;
  void setYear(String value) => year.value = value;
  void setPhone(String value) => phone.value = value;
  void setPlateCode(String value) => plateCode.value = value;
  void setSelectedCountry(int? index) =>
      selectedCountryIndex.value = index ?? 0;
  void setName(String value) {
    name.value = value;
    if (nameController.text != value) nameController.text = value;
  }

  void setId(String value) {
    id.value = value;
    if (idController.text != value) idController.text = value;
  }

  void setSearchText(String value) {
    searchText.value = value;
    isSearchActive.value = value.isNotEmpty;
  }

  void clearSearch() {
    searchController.clear();
    searchText.value = '';
    isSearchActive.value = false;
  }

  void searchCustomer() {
    if (searchText.value.isNotEmpty) {
      CustomAlert.showInfo(
        context: Get.context!,
        message: 'searching_for'.tr.replaceAll('{query}', searchText.value),
      );
    }
  }

  RxList<CommonItemModel> carSymbols = <CommonItemModel>[].obs;
  RxBool isLoading = false.obs;

  Future<void> getCarSymbol() async {
    isLoading.value = true;
    Response response = await GetCarsRepo().getApi(
      getUrl: ApiConstant.getSymbolUrl,
    );
    isLoading.value = false;

    if (response.statusCode == 200) {
      CommonListModel commonListModel = CommonListModel.fromJson(response.body);
      carSymbols.value = commonListModel.data ?? [];
      update(); // Add this to trigger UI rebuild
    }
  }

  RxList<CustomerCustomModel> customerList = <CustomerCustomModel>[].obs;
  TextEditingController numberController = TextEditingController();
  RxBool listIsLoading = false.obs;

  ///Customer lIst by Phone number
  Future<void> getCustomerListByPhone() async {
    if (phone.value.isEmpty) {
      showCustomSnackBar('Please enter a phone number'.tr, isError: true);
      return;
    }

    print('====> Searching for customer with phone: ${phone.value}');

    listIsLoading.value = true;
    Response response = await AddCustomerRepo().getCustomerByNumber(
      number: phone.value,
    );
    listIsLoading.value = false;

    print('====> Response status: ${response.statusCode}');
    print('====> Response body: ${response.body}');
    customerList.clear();
    if (response.statusCode == 200) {
      var responseData = response.body;

      if (responseData['data'] != null &&
          responseData['data'] is List &&
          (responseData['data'] as List).isNotEmpty) {
        final dataList = responseData['data'] as List?;
        if (dataList == null || dataList.isEmpty) return;

        final firstItem = dataList.first;

// Check if the response has nested "client" field
        final clientData = firstItem['client'] is Map<String, dynamic>
            ? firstItem['client']
            : firstItem;

// Safely cast to Map
        Map<String, dynamic>? clientMap;
        if (clientData is Map<String, dynamic>) {
          clientMap = clientData;
        }

// Handle optional nested clientId
        final clientIdData = clientMap?['clientId'];
        Map<String, dynamic>? clientIdMap;
        if (clientIdData is Map<String, dynamic>) {
          clientIdMap = clientIdData;
        }

// Extract fields safely

        final clientName =
            clientIdMap?['name'] ?? clientMap?['workShopNameAsClient'] ?? '';

        final clientPhone =
            clientIdMap?['contact'] ?? clientMap?['contact'] ?? '';
        final isWarning = clientMap?['hasPaymentIssues'];

        final clientId = clientMap?['_id'] ?? firstItem['_id'] ?? '';

        customerList.add(
          CustomerCustomModel(
            id: clientId,
            name: clientName,
            phone: clientPhone,
            isWarning: isWarning,
          ),
        );

        showCustomSnackBar('Customer found successfully'.tr, isError: false);
      } else {
        showCustomSnackBar('No customer data found'.tr, isError: true);
      }
    } else if (response.statusCode == 400) {
      showCustomSnackBar('Customer not found with this phone number'.tr,
          isError: true);
    } else {
      showCustomSnackBar('Client not found'.tr, isError: true);
    }
  }

  ///Customer lIst by non saudi Car palte
  Future<void> getCustomerListByCarPlate() async {
    if (plateCode.value.isEmpty || plateCode.value == '------') {
      showCustomSnackBar('Please enter a plate number'.tr, isError: true);
      return;
    }

    listIsLoading.value = true;
    Response response =
        await AddCustomerRepo().getCustomerByCarPlate(number: plateCode.value);
    listIsLoading.value = false;

    print('====> Response status (by plate): ${response.statusCode}');
    print('====> Response body (by plate): ${response.body}');
    customerList.clear();
    if (response.statusCode == 200) {
      var responseData = response.body;

      if (responseData['data'] != null &&
          responseData['data'] is Map &&
          responseData['data']['result'] != null &&
          responseData['data']['result'] is List &&
          (responseData['data']['result'] as List).isNotEmpty) {
        for (var item in responseData['data']['result']) {
          var clientData = item['client'];
          var clientIdData = clientData != null ? clientData['clientId'] : null;
          final isWarning = clientData?['hasPaymentIssues'] ?? false;

          customerList.add(
            CustomerCustomModel(
              isWarning: isWarning,
              id: clientData != null
                  ? (clientData['_id'] ?? '')
                  : (clientIdData?['_id'] ?? ''),
              name: clientIdData != null
                  ? (clientIdData['name'] ?? 'Unknown')
                  : (clientData?['name'] ?? 'Unknown'),
              phone: clientData != null
                  ? (clientData['contact'] ?? '')
                  : (clientIdData?['contact'] ?? ''),
            ),
          );
        }

        showCustomSnackBar('Customer(s) found successfully'.tr, isError: false);
      } else {
        showCustomSnackBar('No customer data found'.tr, isError: true);
      }
    } else if (response.statusCode == 400) {
      showCustomSnackBar('Customer not found with this plate number'.tr,
          isError: true);
    } else {
      showCustomSnackBar('Client not found'.tr, isError: true);
    }
  }

  ///Customer lIst by Saudi Car palte

  ///Send customer to recieve car
  RxBool messageSendingIsLoading = false.obs;

  Future<void> sendMessageToReceiveCar({required String clientId}) async {
    messageSendingIsLoading.value = true;
    Response response = await ApiClient.postData(
      ApiConstant.sendMessageToReceiveCar(clientId: clientId),
    );
    messageSendingIsLoading.value = false;
    if (response.statusCode == 200) {
      CustomAlert.showInfo(
        context: Get.context!,
        message:
            'A message has been sent to the customer to pick up the car'.tr,
        onPressed: () {
          Get.back(); // Close the dialog only
        },
      );
      // showCustomSnackBar('A message has been sent to the customer to pick up the car'.tr, isError: false);
    } else {
      showCustomSnackBar(response.statusText ?? 'Error sending message',
          isError: true);
    }
  }

  // Helper function to convert English numerals to Arabic numerals
  String _convertToArabicNumerals(String englishNumber) {
    const Map<String, String> arabicNumerals = {
      '0': '٠',
      '1': '١',
      '2': '٢',
      '3': '٣',
      '4': '٤',
      '5': '٥',
      '6': '٦',
      '7': '٧',
      '8': '٨',
      '9': '٩',
    };

    String result = '';
    for (int i = 0; i < englishNumber.length; i++) {
      String char = englishNumber[i];
      result += arabicNumerals[char] ?? char;
    }
    return result;
  }

  void searchCustomerByPhone() {
    CustomAlert.showInfo(
      context: Get.context!,
      message: "Mobile is Not Registered\nwith the workshop".tr,
    );
  }

  void searchCustomerByCar() {
    CustomAlert.showInfo(
      context: Get.context!,
      message:
          "The Car is Not Registered\nat the workshop,\nPlease complete the data entry"
              .tr,
    );
  }

  void onCancel() {
    Get.back();
  }

  void onAddition() {
    CustomAlert.showInfo(
      context: Get.context!,
      message: 'customer_added_success'.tr,
      onPressed: () {
        Get.back();
        Get.back();
      },
    );
  }

  Future<void> getCustomerListByCarPlateInternational() async {
    if (plateCode.value.isEmpty || plateCode.value == '------') {
      showCustomSnackBar('Please enter a plate number'.tr, isError: true);
      return;
    }

    listIsLoading.value = true;
    Response response = await AddCustomerRepo()
        .getCustomerByCarPlateNumberOrSlag(slugOrPlateNumber: plateCode.value);
    listIsLoading.value = false;

    print('====> Response status (by plate): ${response.statusCode}');
    print('====> Response body (by plate): ${response.body}');
    customerList.clear();
    if (response.statusCode == 200) {
      ClientByCarModel clientByCarModel =
          ClientByCarModel.fromJson(response.body);
      List<ClientItem> clients = clientByCarModel.clientList ?? [];
      for (var client in clients) {
        String? name = (client.workShopNameAsClient != null &&
                client.workShopNameAsClient!.isNotEmpty)
            ? client.workShopNameAsClient
            : client.clientId?.name ?? "";
        customerList.add(
          CustomerCustomModel(
            isWarning: client.isWarning,
            id: client.sId ?? '',
            name: name ?? 'Unknown',
            phone: client.contact ?? '',
          ),
        );
      }

      if (customerList.isNotEmpty) {
        showCustomSnackBar('Customer(s) found successfully'.tr, isError: false);
      } else {
        showCustomSnackBar('No customer data found', isError: true);
      }
    } else if (response.statusCode == 400) {
      showCustomSnackBar('Customer not found with this plate number',
          isError: true);
    } else {
      showCustomSnackBar('Client not found'.tr, isError: true);
    }
  }

  Future<void> getCustomerListBySaudiCar() async {
    if (plateNumber.value.isEmpty) {
      showCustomSnackBar('Please enter a plate number'.tr, isError: true);
      return;
    }

    if (selectedCarSymbolId.value.isEmpty) {
      showCustomSnackBar('Please select a car symbol'.tr, isError: true);
      return;
    }

    // Build Arabic and English letters from plateLetters
    List<String> arabicLetters = [];
    List<String> englishLetters = [];

    for (String letter in plateLetters) {
      if (letter.isNotEmpty) {
        // Find matching option for this letter
        var matchedOption = letterOptions.firstWhere(
          (option) => option['ar'] == letter || option['en'] == letter,
          orElse: () => {'en': '', 'ar': ''},
        );

        if (matchedOption['ar']!.isNotEmpty) {
          arabicLetters.add(matchedOption['ar']!);
          englishLetters.add(matchedOption['en']!);
        }
      }
    }

    if (arabicLetters.isEmpty || englishLetters.isEmpty) {
      showCustomSnackBar('Please select plate letters', isError: true);
      return;
    }

    // Convert English plate number to Arabic numerals
    String arabicPlateNumber = _convertToArabicNumerals(plateNumber.value);

    // Join letters with dash
    String englishLettersString = englishLetters.join('');
    String arabicLettersString = arabicLetters.join('');
    String slug =
        "${selectedCarSymbolId.value}-${plateNumber.value}-$arabicPlateNumber-$englishLettersString-$arabicLettersString";

    // Construct the slug: symbolId-plateNumberEnglish-plateNumberArabic-englishLetters
    // Example: 68e0b3451a87a17657aab6c5-1234-١٢٣٤-AB-CD

    listIsLoading.value = true;
    Response response = await AddCustomerRepo()
        .getCustomerByCarPlateNumberOrSlag(slugOrPlateNumber: slug);
    listIsLoading.value = false;

    print('====> Response status (by plate): ${response.statusCode}');
    print('====> Response body (by plate): ${response.body}');
    customerList.clear();
    if (response.statusCode == 200) {
      ClientByCarModel clientByCarModel =
          ClientByCarModel.fromJson(response.body);
      List<ClientItem> clients = clientByCarModel.clientList ?? [];
      for (var client in clients) {
        String? name = (client.workShopNameAsClient != null &&
                client.workShopNameAsClient!.isNotEmpty)
            ? client.workShopNameAsClient
            : client.clientId?.name ?? "";
        customerList.add(
          CustomerCustomModel(
            isWarning: client.isWarning,
            id: client.sId ?? '',
            name: name ?? 'Unknown',
            phone: client.contact ?? '',
          ),
        );
      }

      if (customerList.isNotEmpty) {
        showCustomSnackBar('Customer(s) found successfully'.tr, isError: false);
      } else {
        showCustomSnackBar('No customer data found', isError: true);
      }
    } else if (response.statusCode == 400) {
      showCustomSnackBar('Customer not found with this plate number',
          isError: true);
    } else {
      showCustomSnackBar('Client not found'.tr, isError: true);
    }
  }
}
