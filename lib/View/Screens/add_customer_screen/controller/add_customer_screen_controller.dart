import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/add_customer_screen/model/car_brand_model.dart';
import 'package:Senaeya/View/Screens/add_customer_screen/repo/add_customer_repo.dart';
import 'package:Senaeya/View/Screens/home_screen/repo/get_cars_repo.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_verification_dialog/custom_alert_verification_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../Service/api_client.dart';
import '../../../../Utils/AppLog/app_log.dart';
import '../../../Widgets/custom_text_style.dart';
import '../../home_screen/model/country_list_model.dart';
import '../../home_screen/controller/home_controller.dart';

class AddCustomerScreenController extends GetxController {
  TextEditingController documentsNumberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController vinController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  RxString clientCarId = ''.obs;
  RxString clientId = ''.obs;
  RxInt userType = 0.obs; // 0: Customer, 1: Workshop
  RxInt boardType = 0.obs; // 0: Saudi, 1: Non-Saudi
  RxString saudiPlateNumber = ''.obs;
  RxList<String> plateLetters = ['', '', ''].obs;
  List<CommonItemModel> selectedCountryList = <CommonItemModel>[];
  RxString selectedCarSymbolId = ''.obs;
  RxString createCarClientId = ''.obs;
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

  bool isFromNewInvoice = false;
  RxBool phoneVerified = false.obs;
  RxString verifiedPhoneNumber = ''.obs;
  bool isTaxAvailable = false;
  bool isAuth = false;

  @override
  void onInit() {
    super.onInit();
    isLoading.value = true;
    isFromNewInvoice = Get.arguments['fromNewInvoice'] ?? false;
  }

  @override
  void onReady() {
    super.onReady();
    initial();
  }

  Future<void> initial() async {
    if (Get.isRegistered<HomeController>()) {
      HomeController homeController = Get.find<HomeController>();

      if (isFromNewInvoice) {
        isAuth =
            await homeController.checkAuthorization(popOnUnAuthorized: true);
        if (!isAuth) {
          isLoading.value = false;
          return;
        }
      }

      await homeController.ensureCountriesLoaded();
      selectedCountryList = homeController.selectedCountries.toList();
      print(
          "selectedCountyList========================${selectedCountryList.length}");
    } else {
      selectedCountryList = Get.arguments['countries'] ?? [];
    }

    documentsNumberController.text = id.value;
    nameController.text = name.value;
    getIsTaxExist();

    carBrandModels =
        await SharePrefsHelper.getCarBrand(SharedPreferenceValue.carBrandList);
    if (carBrandModels.isNotEmpty) {
      // Remove duplicates by using toSet() then toList()
      carBrands = carBrandModels.map((e) => e.title).toSet().toList().obs;
    }
    // print("===================carBrand====${carBrandModels.length}");

    carSymbols = await SharePrefsHelper.getCarSymbolList(
        SharedPreferenceValue.carSymbolList);
    // print("=======================${carSymbols.length}");

    if (carSymbols.isNotEmpty) {
      isLoading.value = false;
    } else {
      isLoading.value = true;
    }

    await getBrands();
    await getCarSymbol();
    isLoading.value = false;
  }

  RxString plateCode = '------'.obs;
  RxString vin = ''.obs;
  RxString brand = ''.obs;
  RxString brandImage = ''.obs;
  RxString brandId = ''.obs;

  RxString model = ''.obs;
  RxString modelId = ''.obs;
  RxString year = ''.obs;
  final List<String> yearOptions = [
    '1980',
    '1981',
    '1982',
    '1983',
    '1984',
    '1985',
    '1986',
    '1987',
    '1988',
    '1989',
    '1990',
    '1991',
    '1992',
    '1993',
    '1994',
    '1995',
    '1996',
    '1997',
    '1998',
    '1999',
    '2000',
    '2001',
    '2002',
    '2003',
    '2004',
    '2005',
    '2006',
    '2007',
    '2008',
    '2009',
    '2010',
    '2011',
    '2012',
    '2013',
    '2014',
    '2015',
    '2016',
    '2017',
    '2018',
    '2019',
    '2020',
    '2021',
    '2022',
    '2023',
    '2024',
    '2025',
    '2026',
    '2027',
    '2028',
    '2029',
    '2030',
    '2031',
    '2032',
    '2033',
    '2034',
    '2035',
    '2036',
    '2037',
    '2038',
    '2039',
  ];
  RxString phone = ''.obs;
  RxString phoneError = ''.obs;
  RxString name = ''.obs;
  RxString id = ''.obs;
  RxInt selectedColor = RxInt(5); // 0: Green, 1: Yellow, 2: White
  RxInt selectedCountryIndex = 0.obs;
  RxString selectedCountryCode =
      'SA'.obs; // Store detected country code from phone number

  void setUserType(int? value) => userType.value = value ?? 0;
  void setBoardType(int? value) => boardType.value = value ?? 0;
  void setPlateNumber(String value) => saudiPlateNumber.value = value;
  void setPlateLetter(int index, String value) {
    final enLetter = value.split('-')[0];
    plateLetters[index] = enLetter;
    update();
  }

  void setSelectedColor(int? value) => selectedColor.value = value ?? 0;

  // Decode year from VIN 10th character
  String? decodeYearFromVin(String vinValue) {
    if (vinValue.length < 10) return null;

    String char10 = vinValue[9].toUpperCase(); // 10th position (index 9)

    // VIN year decoding map - when duplicate, select the most recent year
    Map<String, int> vinYearMap = {
      'A': 2010,
      'B': 2011,
      'C': 2012,
      'D': 2013,
      'E': 2014,
      'F': 2015,
      'G': 2016,
      'H': 2017,
      'J': 2018,
      'K': 2019,
      'L': 2020,
      'M': 2021,
      'N': 2022,
      'P': 2023,
      'R': 2024,
      'S': 2025,
      'T': 2026,
      'V': 2027,
      'W': 2028,
      'X': 2029,
      'Y': 2030,
      '1': 2001,
      '2': 2002,
      '3': 2003,
      '4': 2004,
      '5': 2005,
      '6': 2006,
      '7': 2007,
      '8': 2008,
      '9': 2009,
    };

    if (vinYearMap.containsKey(char10)) {
      return vinYearMap[char10].toString();
    }

    return null;
  }

  // Method to check VIN and auto-populate brand from WMI code
  Future<void> checkVinAndSetBrand(String vinValue) async {
    if (vinValue.length < 3) return;

    // Get first 3 characters of VIN (WMI - World Manufacturer Identifier)
    String wmiCode = vinValue.substring(0, 3).toUpperCase();

    // print("====> VIN WMI Code: $wmiCode");

    // Check if this WMI code exists in wmiBrandMap
    if (wmiBrandMap.containsKey(wmiCode)) {
      String detectedBrandName = wmiBrandMap[wmiCode]!;
      // print("====> WMI Code '$wmiCode' detected as: $detectedBrandName");

      // Check if this brand exists in carBrandModels list
      var matchedBrand = carBrandModels.firstWhere(
        (brandModel) =>
            brandModel.title.toLowerCase() == detectedBrandName.toLowerCase(),
        orElse: () => CarBrand(id: '', image: '', title: ''),
      );

      // print("====> Brand '$detectedBrandName' found in carBrandModels list");
      // print("====> Brand ID: ${matchedBrand.id}");
      // print("====> Brand Name: ${matchedBrand.title}");

      // Set brand value and brand ID
      brand.value = matchedBrand.title;
      brandImage.value = matchedBrand.image;
      brandId.value = matchedBrand.id;

      // Reset model when brand changes
      model.value = '';

      // Call API to fetch models for this brand
      // print("====> Calling API to get models for brand ID: ${brandId.value}");
      await getModels(brandId.value);

      // showCustomSnackBar('Brand detected from VIN: ${matchedBrand.title}', isError: false);
    } else {
      // print("====> WMI Code '$wmiCode' not found in wmiBrandMap database");
    }
  }

  void setVin(String value) {
    vin.value = value;
    vinController.text = value;

    // Auto-decode year from VIN 10th character
    if (value.length >= 10) {
      String? decodedYear = decodeYearFromVin(value);
      if (decodedYear != null && yearOptions.contains(decodedYear)) {
        year.value = decodedYear;
      }
    }

    // Check VIN and auto-set brand if VIN has at least 3 characters
    if (value.length >= 3) {
      checkVinAndSetBrand(value);
    }
  }

  Future<void> setBrand(String value) async {
    // print("====> setBrand called with value: $value");

    // Validate that the brand exists in the unique carBrands list
    if (!carBrands.contains(value)) {
      // print("====> Warning: Brand '$value' not found in carBrands list");
      // If not found, don't set it to avoid dropdown errors
      return;
    }

    brand.value = value;

    // Find brand by title, use firstWhere with orElse to handle not found case
    var matchedBrand = carBrandModels.firstWhere(
      (brandModel) => brandModel.title == value,
      orElse: () => CarBrand(id: '', image: '', title: value),
    );

    brandImage.value = matchedBrand.image;
    brandId.value = matchedBrand.id;

    // Reset model when brand changes
    model.value = '';

    // Only fetch models if we found a valid brand ID
    if (brandId.value.isNotEmpty) {
      await getModels(brandId.value);
    }
  }

  /// Set brand using brand ID from API response
  Future<void> setBrandById(String id, String title, String image) async {
    // print("====> Setting brand by ID: $id, title: $title");

    // Find brand by ID first, if not found, find by title
    var matchedBrand = carBrandModels.firstWhere(
      (brandModel) => brandModel.id == id,
      orElse: () => carBrandModels.firstWhere(
        (brandModel) => brandModel.title == title,
        orElse: () => CarBrand(id: id, image: image, title: title),
      ),
    );

    // Validate that the brand title exists in the unique carBrands list
    if (!carBrands.contains(matchedBrand.title)) {
      // print(
      // "====> Warning: Brand '${matchedBrand.title}' not found in carBrands list");
      // print("====> Available brands: ${carBrands.join(', ')}");

      // Add the brand to the list if it's from a valid API response
      if (matchedBrand.id.isNotEmpty) {
        carBrands.add(matchedBrand.title);
        // print("====> Added '${matchedBrand.title}' to carBrands list");
      } else {
        // If not found and no valid ID, don't set it to avoid dropdown errors
        return;
      }
    }

    brand.value = matchedBrand.title;
    brandImage.value = matchedBrand.image;
    brandId.value = matchedBrand.id;

    // Reset model when brand changes
    model.value = '';

    // Only fetch models if we found a valid brand ID
    if (brandId.value.isNotEmpty) {
      await getModels(brandId.value);
    }
  }

  void setModel(String value) {
    // print("====> setModel called with value: $value");

    // Validate that the model exists in the carModels list
    if (!carModels.contains(value)) {
      // print("====> Warning: Model '$value' not found in carModels list");

      // Try to find it in carModelsList and add to carModels if found
      var foundModel = carModelsList.firstWhere(
        (modelItem) => modelItem.title == value,
        orElse: () => CommonItemModel(),
      );

      if (foundModel.sId != null && foundModel.sId!.isNotEmpty) {
        carModels.add(value);
        // print("====> Added '$value' to carModels list");
      } else {
        // print(
        //     "====> Model '$value' not found in carModelsList either, skipping");
        return;
      }
    }

    model.value = value;

    // Find and store the model ID
    var foundModel = carModelsList.firstWhere(
      (modelItem) => modelItem.title == value,
      orElse: () => CommonItemModel(),
    );
    modelId.value = foundModel.sId ?? '';
    // print("====> Selected Model: $value");
    // print("====> Model ID: ${modelId.value}");
  }

  void setYear(String value) => year.value = value;
  void setPhone(String value) {
    phone.value = value;
    // Update the controller to display the value
    // if (phoneController.text != value) {
    //   phoneController.text = value;
    // }

    // if (!isValidSaudiMobile(value)) {
    //   phoneError.value = 'invalid_saudi_mobile'.tr;
    // } else {
    //   phoneError.value = '';
    // }
  }

  void setContact(String value) {
    // Map of country codes to country indices and their dial codes

    String cleanValue = value.trim();
    String phoneNumber = cleanValue;
    String detectedCountryCode = 'SA'; // Default to Saudi Arabia
    int detectedCountryIndex = 0;
    // phone.value = value;

    // print("====== setContact called with value: $value ======");

    // Check if the number starts with a plus sign (international format)
    if (cleanValue.startsWith('+')) {
      // Try to match country code
      bool matched = false;

      // Sort by length descending to match longer codes first (e.g., +880 before +88)
      var sortedCodes = countryCodeMap.keys.toList()
        ..sort((a, b) => b.length.compareTo(a.length));

      for (String code in sortedCodes) {
        if (cleanValue.startsWith(code)) {
          var countryInfo = countryCodeMap[code]!;
          detectedCountryCode = countryInfo['code'];
          detectedCountryIndex = countryInfo['index'];

          // Remove the country code to get just the phone number
          phoneNumber = cleanValue.substring(code.length);
          matched = true;
          print(
              "====== Matched country code: $code, Country: $detectedCountryCode, Index: $detectedCountryIndex ======");
          break;
        }
      }

      // If no match found, try to extract digits after +
      if (!matched) {
        phoneNumber = cleanValue.substring(1); // Remove the + sign
        // print("====== No country code match found, using default ======");
      }
    } else if (cleanValue.startsWith('00')) {
      // Handle numbers starting with 00 (alternative international format)
      String withPlus = '+' + cleanValue.substring(2);
      // print("====== Converting 00 format to + format: $withPlus ======");
      setContact(withPlus); // Recursively call with + format
      return;
    }

    // Remove any non-digit characters from phone number
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // print(
    //     "====== Setting selectedCountryIndex to: $detectedCountryIndex ======");
    // print("====== Setting selectedCountryCode to: $detectedCountryCode ======");
    // print("====== Phone number without country code: $phoneNumber ======");

    // Update the country selection - store both index and code
    if (detectedCountryIndex != selectedCountryIndex.value) {
      selectedCountryIndex.value = detectedCountryIndex;
    }
    selectedCountryCode.value = detectedCountryCode;

    // Clear the controller first
    phoneController.clear();

    // Set the phone value without country code
    phone.value = phoneNumber;

    // Use Future.delayed to ensure the IntlPhoneField widget rebuilds with new country first
    Future.delayed(const Duration(milliseconds: 100), () {
      // Set only the phone number without country code
      if (phoneController.text != phoneNumber) {
        phoneController.text = phoneNumber;
        // Move cursor to end
        phoneController.selection = TextSelection.fromPosition(
          TextPosition(offset: phoneNumber.length),
        );
      }
    });

    // Validate based on detected country
    if (detectedCountryCode == 'SA') {
      if (!isValidSaudiMobile(phoneNumber)) {
        phoneError.value = 'invalid_saudi_mobile'.tr;
      } else {
        phoneError.value = '';
      }
    } else {
      // For non-Saudi numbers, just check if phone number is not empty
      if (phoneNumber.isEmpty) {
        phoneError.value = 'phone_required'.tr;
      } else {
        phoneError.value = '';
      }
    }
  }

  void setPlateCode(String value) => plateCode.value = value;
  void setSelectedCountry(int? index) =>
      selectedCountryIndex.value = index ?? 0;

  void setSelectedCountryCode(String code) {
    selectedCountryCode.value = code;
    // print("====== Country code manually changed to: $code ======");
  }

  void setName(String value) {
    name.value = value;
    if (nameController.text != value) nameController.text = value;
  }

  void setId(String value) {
    id.value = value;
    if (documentsNumberController.text != value) {
      documentsNumberController.text = value;
    }
  }

  void checkPlate() {
    CustomAlert.showInfo(
      context: Get.context!,
      message: 'vehicle_unregistered_message'.tr,
    );
  }

  TextEditingController carPlateController = TextEditingController();

  ///Api call

  RxBool checkIsLoading = false.obs;

  RxBool isLoading = false.obs;
  RxList<String> carBrands = <String>[].obs;
  RxList<String> carModels = <String>[].obs;
  RxList<CommonItemModel> carSymbols = <CommonItemModel>[].obs;

  RxList<CarBrand> carBrandModels = <CarBrand>[].obs;
  List<CommonItemModel> carModelsList = <CommonItemModel>[];

  Future<void> getBrands() async {
    // print("====================================${selectedCountryList.length}");
    // for (CommonItemModel item in selectedCountryList) {
    //   // print("====================================${item.title}");
    // }
    // Build query string with repeated 'country' keys
    String queryString =
        selectedCountryList.map((item) => 'country=${item.sId}').join('&');
    String url = '/car-brands?' + queryString;
    // print("===========url: $url");
    Response response = await AddCustomerRepo().getBrands(url: url);
    if (response.statusCode == 200) {
      CarBrandResponse commonListModel = CarBrandResponse.fromJson(
        response.body,
      );
      carBrandModels.value = commonListModel.data.result;
      SharePrefsHelper.setCarBrandList(
          SharedPreferenceValue.carBrandList, carBrandModels);

      // Clear and rebuild with unique titles only
      carBrands.clear();
      // Use Set to remove duplicates, then convert back to List
      Set<String> uniqueBrands = {};
      for (var item in carBrandModels) {
        uniqueBrands.add(item.title);
      }
      carBrands.addAll(uniqueBrands.toList());
      // print("====== Total brands loaded: ${carBrands.length} (unique) ======");
    } else {
      showCustomSnackBar(response.statusText ?? 'error_message'.tr);
    }
  }

  Future<void> getModels(String brand) async {
    Response response = await GetCarsRepo().getApi(
      getUrl: ApiConstant.carModels(brand),
    );
    if (response.statusCode == 200) {
      carModelsList.clear();
      carModels.clear();
      // print(
      //   "=================model length========================${carModels.length}",
      // );

      CommonListModel commonListModel = CommonListModel.fromJson(response.body);
      carModelsList = commonListModel.data ?? [];

      // Use Set to avoid duplicates
      Set<String> uniqueModels = {};
      for (var item in carModelsList) {
        if (item.title != null && item.title!.isNotEmpty) {
          uniqueModels.add(item.title!);
        }
      }
      carModels.addAll(uniqueModels.toList());

      // print(
      //   "=================model length========================${carModels.length}",
      // );
    } else {
      // Clear models on error
      carModels.value = [];
      showCustomSnackBar(response.statusText ?? 'error_message'.tr);
    }
  }

  Future<void> getCarSymbol() async {
    Response response = await GetCarsRepo().getApi(
      getUrl: ApiConstant.getSymbolUrl,
    );
    if (response.statusCode == 200) {
      CommonListModel commonListModel = CommonListModel.fromJson(response.body);
      carSymbols.value = commonListModel.data ?? [];
      SharePrefsHelper.setCarSymbolList(
          SharedPreferenceValue.carSymbolList, carSymbols);
    }
  }

  RxBool phoneCheckIsLoading = false.obs;

  /// get Client By Car Plate
  Future<void> getClientByCarPlate() async {
    checkIsLoading.value = true;
    Response response = await AddCustomerRepo().getCustomerByCarPlate(
      number: carPlateController.text.trim(),
    );
    checkIsLoading.value = false;

    print('====> Response status (by plate): ${response.statusCode}');
    print('====> Response body (by plate): ${response.body}');

    if (response.statusCode == 200) {
      var responseData = response.body;

      if (responseData['data'] != null &&
          responseData['data'] is Map &&
          responseData['data']['result'] != null &&
          responseData['data']['result'] is List &&
          (responseData['data']['result'] as List).isNotEmpty) {
        // Get the first car from the result
        var firstCar = responseData['data']['result'][0];
        var clientData = firstCar['client'];
        var clientIdData = clientData != null ? clientData['clientId'] : null;
        var brandData = firstCar['brand'];

        // Fill all the form fields with the first car data
        clientCarId.value = firstCar['_id'] ?? '';
        clientId.value = clientData?['_id'] ?? '';
        setName(clientIdData?['name'] ?? '');
        setId(clientData?['documentNumber'] ?? '');
        setVin(firstCar['vin'] ?? '');

        // Use setBrandById with brand data from API
        if (brandData != null) {
          await setBrandById(
            brandData['_id'] ?? '',
            brandData['title'] ?? '',
            brandData['image'] ?? '',
          );
        }

        setModel(firstCar['model']['title'] ?? '');
        setContact(clientData?['contact'] ?? '');
        print(
          "=================model========================${firstCar['model']}",
        );
        setYear(firstCar['year'] ?? '');
        // setPhone(clientData?['contact'] ?? ''); // Removed: setContact already handles phone number

        // Set plate code for non-Saudi
        setPlateCode(firstCar['plateNumberForInternational'] ?? '');

        showCustomSnackBar('Customer found successfully'.tr, isError: false);
      } else {
        checkPlate();
      }
    } else {
      checkPlate();
    }
  }

  /// get Customer By Contact Number
  Future<void> getCustomerByContactNumber() async {
    phoneCheckIsLoading.value = true;
    Response response = await AddCustomerRepo().getCustomerByNumber(
      number: phone.value,
    );

    ///get car data for client
    phoneCheckIsLoading.value = false;
    if (response.statusCode == 200) {
      var data = response.body['data'];

      // data is a List, not a Map - need to check if it's not empty and get first item
      if (data != null && data is List && data.isNotEmpty) {
        var firstCar = data[0]; // Get the first car object
        var clientData = firstCar['client']; // Get the client object
        var clientIdData = clientData?['clientId']; // Get the clientId object
        var brandData = firstCar['brand'];
        // Set name from clientId.name and contact from client.contact
        setName(clientIdData?['name'] ?? '');
        setId(clientData?['documentNumber'] ?? '');
        setVin(firstCar['vin'] ?? '');

        // Use setBrandById with brand data from API
        if (brandData != null) {
          await setBrandById(
            brandData['_id'] ?? '',
            brandData['title'] ?? '',
            brandData['image'] ?? '',
          );
        }

        setModel(firstCar['model']['title'] ?? '');
        setContact(clientData?['contact'] ?? '');
        clientCarId.value = firstCar['client']['cars'][0] ?? '';
        clientId.value = clientData?['_id'] ?? '';

        setYear(firstCar['year'] ?? '');
        // setPhone(clientData?['contact'] ?? ''); // Removed: setContact already handles phone number

        // Set plate code for non-Saudi
        setPlateCode(firstCar['plateNumberForInternational'] ?? '');

        showCustomSnackBar('Customer found successfully'.tr, isError: false);
      } else {
        showCustomSnackBar('customer_not_found_message'.tr);
      }
    } else {
      showCustomSnackBar(response.statusText ?? 'error_message'.tr);
    }
  }

  String arabicPlateNumber = '';
  String englishLettersForSaudi = '';
  String arabicLettersForSaudi = '';
  String carSymbolImageForSaudi = '';

  /// get Customer By Saudi Car Plate

  Future<void> getCustomerListBySaudiCarPlate() async {
    // Validate inputs
    if (saudiPlateNumber.value.isEmpty) {
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
      showCustomSnackBar('Please select plate letters'.tr, isError: true);
      return;
    }

    // Convert English plate number to Arabic numerals
    arabicPlateNumber = _convertToArabicNumerals(saudiPlateNumber.value);

    // Join letters WITH DASH to match database format
    englishLettersForSaudi = englishLetters.join('');
    arabicLettersForSaudi = arabicLetters.join('');
    carSymbolImageForSaudi = carSymbols
            .firstWhere(
              (symbol) => symbol.sId == selectedCarSymbolId.value,
              orElse: () => CommonItemModel(),
            )
            .image ??
        '';

    // Construct the slug: symbolId-plateNumberEnglish-plateNumberArabic-englishLetters
    // Example: 68e0b3451a87a17657aab6c5-1234-١٢٣٤-ABD
    String slug =
        "${selectedCarSymbolId.value}-${saudiPlateNumber.value}-$arabicPlateNumber-$englishLettersForSaudi-$arabicLettersForSaudi";

    // print('====> Searching by Saudi plate slug: $slug');
    // print('====> Plate Number (English): ${saudiPlateNumber.value}');
    // print('====> Plate Number (Arabic): $arabicPlateNumber');
    // print('====> English letters (dash-separated): $englishLettersForSaudi');

    checkIsLoading.value = true;
    Response response = await AddCustomerRepo().getCustomerBySaudiCarPlate(
      slug: slug,
    );
    checkIsLoading.value = false;

    print('====> Response status (by Saudi plate): ${response.statusCode}');
    print('====> Response body (by Saudi plate): ${response.body}');

    if (response.statusCode == 200) {
      var responseData = response.body;

      if (responseData['data'] != null &&
          responseData['data'] is Map &&
          responseData['data']['result'] != null &&
          responseData['data']['result'] is List &&
          (responseData['data']['result'] as List).isNotEmpty) {
        // Get the first car from the result
        var firstCar = responseData['data']['result'][0];
        var clientData = firstCar['client'];
        var clientIdData = clientData != null ? clientData['clientId'] : null;
        var brandData = firstCar['brand'];
        // var plateData = firstCar['plateNumberForSaudi'];

        // Set name from clientId.name and contact from client.contact
        setName(clientIdData?['name'] ?? '');
        setId(clientData?['documentNumber'] ?? '');
        setVin(firstCar['vin'] ?? '');

        // Use setBrandById with brand data from API (includes _id, title, and image)
        if (brandData != null) {
          await setBrandById(
            brandData['_id'] ?? '',
            brandData['title'] ?? '',
            brandData['image'] ?? '',
          );
        }

        setModel(firstCar['model']['title'] ?? '');
        clientCarId.value = firstCar['_id'] ?? '';
        clientId.value = clientData?['_id'] ?? '';
        // print("========================$clientIdData");
        // print("========================$clientId");
        setContact(clientData?['contact'] ?? '');
        setYear(firstCar['year'] ?? '');
        setPhone(clientData?['contact'] ?? '');

        // Set plate code for non-Saudi
        setPlateCode(firstCar['plateNumberForInternational'] ?? '');

        // Set Saudi plate info
        // if (plateData != null) {
        //   setPlateNumber(plateData['numberEnglish'] ?? '');
        //   // selectedCarSymbolId.value = plateData['symbol'] ?? '';
        //
        //   // Set plate letters from alphabetsCombinations
        //   if (plateData['alphabetsCombinations'] != null &&
        //       plateData['alphabetsCombinations'] is List &&
        //       (plateData['alphabetsCombinations'] as List).isNotEmpty) {
        //     var combinations = plateData['alphabetsCombinations'] as List;
        //     for (int i = 0; i < combinations.length && i < 3; i++) {
        //       String combo = combinations[i].toString();
        //       // Each combination can be like "AB" or "A", take first letter
        //       if (combo.length >= 1) {
        //         setPlateLetter(i, combo[0]);
        //       }
        //     }
        //   }
        // }

        showCustomSnackBar('Customer found successfully'.tr, isError: false);
      } else {
        searchCustomerByCar();
      }
    } else if (response.statusCode == 400) {
      searchCustomerByCar();
    } else {
      showCustomSnackBar(
        response.statusText ?? 'Error fetching customer',
        isError: true,
      );
    }
  }

  /// Add Customer API Call
  RxBool addIsLoading = false.obs;
  String workShopAsClientId = '';

  Future<void> onTapAddCustomer() async {
    // Validate required fields
    if (userType.value == 0) {
      String currentPhone =
          phone.value.isNotEmpty ? phone.value : phoneController.text.trim();

      // Get full phone number with country code for comparison
      String currentPhoneWithCode = getFullPhoneNumber(currentPhone);

      // Check if phone is verified
      if (!phoneVerified.value) {
        print('====> Phone not verified');
        showCustomSnackBar('verified_phone_required'.tr, isError: true);
        return;
      }

      // Check if verified phone matches current phone (with country code)
      if (verifiedPhoneNumber.value != currentPhoneWithCode) {
        print('====> Verified phone: ${verifiedPhoneNumber.value}');
        print('====> Current phone: $currentPhoneWithCode');
        showCustomSnackBar('verified_phone_required'.tr, isError: true);
        return;
      }
      if (name.value.isEmpty && nameController.text.trim().isEmpty) {
        showCustomSnackBar('Please enter customer name', isError: true);
        return;
      }

      // if(phone.value.isEmpty || !isValidSaudiMobile(phone.value)){
      //   showCustomSnackBar('Please enter valid phone number', isError: true);
      //   return;
      // }

      if (brandId.value.isEmpty) {
        showCustomSnackBar('Please select a brand', isError: true);
        return;
      }

      if (model.value.isEmpty) {
        showCustomSnackBar('Please select a model', isError: true);
        return;
      }

      if (year.value.isEmpty) {
        showCustomSnackBar('Please select a year', isError: true);
        return;
      }

      // Build alphabet combinations for Saudi plates
      List<String> englishLetters = [];
      List<String> arabicLetters = [];

      for (String letter in plateLetters) {
        if (letter.isNotEmpty) {
          // Find matching option for this letter
          var matchedOption = letterOptions.firstWhere(
            (option) => option['ar'] == letter || option['en'] == letter,
            orElse: () => {'en': '', 'ar': ''},
          );

          if (matchedOption['ar']!.isNotEmpty) {
            englishLetters.add(matchedOption['en']!);
            arabicLetters.add(matchedOption['ar']!);
          }
        }
      }

      // Set loading state
      addIsLoading.value = true;

      Response response;

      if (boardType.value == 0) {
        // Saudi plate
        if (saudiPlateNumber.value.isEmpty) {
          addIsLoading.value = false;
          showCustomSnackBar('Please enter plate number', isError: true);
          return;
        }

        // Validate plate number contains only digits
        if (!RegExp(r'^[0-9]+$').hasMatch(saudiPlateNumber.value)) {
          addIsLoading.value = false;
          showCustomSnackBar(
            'Plate number must contain only digits (0-9)',
            isError: true,
          );
          return;
        }

        if (selectedCarSymbolId.value.isEmpty) {
          addIsLoading.value = false;
          showCustomSnackBar('Please select car symbol', isError: true);
          return;
        }

        if (englishLetters.isEmpty) {
          addIsLoading.value = false;
          showCustomSnackBar('Please select plate letters', isError: true);
          return;
        }

        // Combine English letters only as a single concatenated string
        String alphabetCombination = englishLetters.join('');
        String alphabetCombinationArabic = arabicLetters.join('');
        List<String> alphabetCombinationList = [];
        alphabetCombinationList.add(alphabetCombination);
        alphabetCombinationList.add(alphabetCombinationArabic);
        print("==========================${clientId.value}");

        response = await AddCustomerRepo().addCustomerForUser(
            name: nameController.text.trim().isNotEmpty
                ? nameController.text.trim()
                : name.value,
            contact: phone.value,
            vin: vin.value.isNotEmpty ? vin.value : vinController.text.trim(),
            brandId: brandId.value,
            modelId: modelId.value,
            year: year.value,
            plateNumber: null,
            alphabetCombination: alphabetCombinationList,
            symbolId: selectedCarSymbolId.value,
            documentNumber: documentsNumberController.text.trim(),
            arabicText: _convertToArabicNumerals(saudiPlateNumber.value),
            englishText: saudiPlateNumber.value,
            symbol: selectedCarSymbolId.value,
            clientCarId: clientCarId.value,
            clientId: clientId.value,
            isUpdate: clientId.value.isEmpty ? false : true);
      } else {
        // print("===========plateCode:$plateCode");
        // International plate
        if (carPlateController.text.trim().isEmpty) {
          addIsLoading.value = false;
          showCustomSnackBar('Please enter plate number', isError: true);
          return;
        }

        response = await AddCustomerRepo().addCustomerForUser(
            name:
                name.value.isNotEmpty ? name.value : nameController.text.trim(),
            contact: phone.value,
            vin: vin.value.isNotEmpty ? vin.value : vinController.text.trim(),
            brandId: brandId.value,
            modelId: modelId.value,
            year: year.value,
            plateNumber: carPlateController.text.trim(),
            alphabetCombination: null,
            symbolId: null,
            documentNumber: documentsNumberController.text.trim(),
            arabicText: null,
            englishText: null,
            symbol: null,
            clientCarId: '',
            clientId: '');
      }

      addIsLoading.value = false;

      // Handle response
      if (response.statusCode == 200 || response.statusCode == 201) {
        onAddition();
      } else {
        showCustomSnackBar(
          response.statusText ?? 'Failed to add customer',
          isError: true,
        );
      }
    } else {
      // if(workShopName.isEmpty){
      //   showCustomSnackBar('please_enter_workshop_name'.tr,isError: true);
      //   return;
      // }
      // // if(workPhone.isEmpty || !isValidSaudiMobile(workPhone)){
      // //   showCustomSnackBar('please_enter_valid_workshop_phone'.tr,isError: true);
      // //   return;
      // // }
      // if(workShopDocumentId.isEmpty){
      //   showCustomSnackBar('please_enter_workshop_document_id'.tr,isError: true);
      //   return;
      // }
      String currentPhone =
          workPhone.isEmpty ? workshopPhone.text.trim() : workPhone;

      // Get full phone number with country code for comparison
      String currentPhoneWithCode = getFullWorkshopPhone(currentPhone);

      if (!phoneVerified.value) {
        showCustomSnackBar('verified_phone_required'.tr, isError: true);
        return;
      }

      // Check if verified phone matches current phone (with country code)
      if (verifiedPhoneNumber.value != currentPhoneWithCode) {
        print("====== Verified phone: ${verifiedPhoneNumber.value} ======");
        print("====== Current phone: $currentPhoneWithCode ======");
        showCustomSnackBar('verified_phone_required'.tr, isError: true);
        return;
      }
      print("===================$workShopName");
      print("===================$workPhone");
      print("===================$workShopDocumentId");
      print("===================$workShopAsClientId");
      Response response = await AddCustomerRepo().addWorkShop(
        name: workShopName.isEmpty
            ? workShopNameController.text.trim()
            : workShopName,
        number: workPhone.isEmpty ? workshopPhone.text.trim() : workPhone,
        documentId: workShopDocumentNumber.text.trim(),
        workShopIdAsClient: workShopAsClientId,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        onAddition();
      } else {
        showCustomSnackBar(
          response.statusText ?? 'Failed to add workshop',
          isError: true,
        );
      }
    }
  }

  Widget openDropDown(int i) {
    return DropdownButtonFormField<String>(
      initialValue: plateLetters[i],
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      isExpanded: true,
      isDense: true,
      menuMaxHeight: 300,
      items: letterOptions
          .map(
            (e) => DropdownMenuItem(
              value: e['en'],
              child: SizedBox(
                height: 48,
                child: Center(
                  child: Text(
                    '${e['en']}-${e['ar']}',
                    style: customTextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 22.sp,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          )
          .toList(),
      onChanged: (val) => setPlateLetter(i, val!),
      selectedItemBuilder: (BuildContext context) {
        return letterOptions.map<Widget>((e) {
          return Center(
            child: Text(
              '${e['en']}-${e['ar']}',
              style: customTextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 27.sp,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }).toList();
      },
    );
  }

  void onCancel() {
    Get.back();
  }

  void onAddition() {
    CustomAlert.showInfo(
      context: Get.context!,
      message: clientId.isNotEmpty
          ? 'customer_updated_successfully'.tr
          : 'customer_added_message'.tr,
      onPressed: () {
        Get.back();
        Get.back();
      },
    );
  }

  bool isValidSaudiMobile(String phone) {
    // Remove country code if presentPeople
    //
    // Leave
    String normalized = phone.replaceAll('+966', '');
    // Remove any non-digit characters
    normalized = normalized.replaceAll(RegExp(r'[^0-9]'), '');
    // Must start with '5' and be 9 digits
    return normalized.length == 9 && normalized.startsWith('5');
  }

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
      // Only convert if it's a numeric digit
      if (arabicNumerals.containsKey(char)) {
        result += arabicNumerals[char]!;
      }
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

  void checkPhone() {
    if (userType.value == 0) {
      getCustomerByContactNumber();
    } else {
      getWorkshopByContactNumber();
    }
  }

  String workPhone = '';
  String workShopName = '';
  String workShopDocumentId = '';
  RxString workShopCountryCode =
      'SA'.obs; // Default to Saudi Arabia for workshop

  void setWorkShopName(String value) {
    workShopName = value;
    workShopNameController.text = value;
  }

  void setWorkShopDocumentId(String value) {
    workShopDocumentId = value;
    workShopDocumentNumber.text = value;
  }

  TextEditingController workshopPhone = TextEditingController();
  TextEditingController workShopNameController = TextEditingController();
  TextEditingController workShopDocumentNumber = TextEditingController();

  /// Get full workshop phone number with country code
  String getFullWorkshopPhone(String phoneNumberOnly) {
    // The workshop phone field has a hardcoded prefix, so we need to check if the phone already has it
    if (phoneNumberOnly.startsWith('+')) {
      return phoneNumberOnly; // Already has country code
    }

    // Get the dial code for workshop country (default Saudi Arabia)
    String dialCode = getDialCodeForCountry(workShopCountryCode.value);
    return dialCode + phoneNumberOnly;
  }

  ///get workshop by contact number
  Future<void> getWorkshopByContactNumber() async {
    Response response = await AddCustomerRepo().getCustomerByNumber(
      number: workPhone,
    );
    if (response.statusCode == 200) {
      var data = response.body['data'][0];
      // var client = response.body['data'][0]['clientId'];

      if (data != null && data is Map && data.isNotEmpty) {
        setWorkShopName(data['workShopNameAsClient'] ?? '');
        setWorkShopDocumentId(data['documentNumber'] ?? '');
        workShopAsClientId = data['_id'] ?? '';

        showCustomSnackBar('workshop_found_message'.tr, isError: false);
      } else {
        showCustomSnackBar('workshop_not_found_message'.tr);
      }
    } else {
      showCustomSnackBar(response.statusText ?? 'error_message'.tr);
    }
  }

  void setWorkShopPhone(String value) {
    workPhone = value;
    print("====== Workshop phone set: $value ======");
  }

  String selectedSaudiPlateEnglishText = '';

  void onTapNext() {
    print("====== onTapNext called ======");

    // Validate brand and model selection first
    if (brand.value.isEmpty) {
      showCustomSnackBar('Please select a car brand'.tr, isError: true);
      return;
    }

    if (model.value.isEmpty) {
      showCustomSnackBar('Please select a car model'.tr, isError: true);
      return;
    }

    print("====== phoneVerified.value: ${phoneVerified.value} ======");
    print(
        "====== verifiedPhoneNumber.value: ${verifiedPhoneNumber.value} ======");
    print("====== phone.value: ${phone.value} ======");
    print("====== phoneController.text: ${phoneController.text} ======");
    print(
        "====== selectedCountryCode.value: ${selectedCountryCode.value} ======");
    print("====== brand.value: ${brand.value} ======");
    print("====== model.value: ${model.value} ======");

    // Get current phone number
    String currentPhone =
        phone.value.isNotEmpty ? phone.value : phoneController.text.trim();

    print("====== currentPhone (before country code): $currentPhone ======");

    // Get full phone number with country code for comparison
    String currentPhoneWithCode = getFullPhoneNumber(currentPhone);

    print("====== currentPhoneWithCode: $currentPhoneWithCode ======");

    // Check if phone is verified
    if (!phoneVerified.value) {
      print("====== Phone NOT verified ======");
      showCustomSnackBar('verified_phone_required'.tr, isError: true);
      return;
    }

    // Check if verified phone matches current phone (with country code)
    // Trim both values and compare
    String verifiedPhone = verifiedPhoneNumber.value.trim();
    String currentPhoneTrimmed = currentPhoneWithCode.trim();

    print("====== Comparison ======");
    print("====== Verified phone: '$verifiedPhone' ======");
    print("====== Current phone: '$currentPhoneTrimmed' ======");
    print("====== Are equal: ${verifiedPhone == currentPhoneTrimmed} ======");

    if (verifiedPhone != currentPhoneTrimmed) {
      print("====== Phone MISMATCH - verification required ======");
      showCustomSnackBar('verified_phone_required'.tr, isError: true);
      return;
    }

    print("====== Phone verification passed! ======");

    // Safely get model ID - check if model exists in the list
    try {
      var matchedModel = carModelsList.firstWhere(
        (modelItem) => modelItem.title == model.value,
        orElse: () => CommonItemModel(sId: '', title: ''),
      );
      modelId.value = matchedModel.sId ?? '';

      print("====== Model lookup ======");
      print("====== Looking for model: ${model.value} ======");
      print("====== Found model ID: ${modelId.value} ======");
      print("====== carModelsList length: ${carModelsList.length} ======");
    } catch (e) {
      print("====== Error finding model: $e ======");
      showCustomSnackBar('Please select a valid car model'.tr, isError: true);
      return;
    }

    if (modelId.value.isEmpty) {
      print("====== Model ID is empty ======");
      showCustomSnackBar('Please select a car model'.tr, isError: true);
      return;
    }
    // print( "clientId =========$clientId,");
    // print( "clientCarId =========$clientCarId,");
    // print( "brandId =========$brandId,");
    // print( "modelName =========$model,");
    // print( "modelId =========$modelId,");
    // print( "year =========$year,");
    // print( "brandImage =========$brandImage,");
    // print( "name ==========${nameController.text.trim()},");
    // print( "phone ==========${phone},");
    // print( "englishLettersForSaudi =========$englishLettersForSaudi,");
    // print( "arabicLettersForSaudi =========$arabicLettersForSaudi,");
    // print( "saudiPlateNumber =========$saudiPlateNumber,");
    // print( "arabicPlateNumber =========$arabicPlateNumber,");
    // print( "carSymbolImageForSaudi =========$carSymbolImageForSaudi,");
    // print( "internationalPlateNumber =========${carPlateController.text.trim()},");

    Map<String, dynamic> arguments = {
      "isTaxAvailable": isTaxAvailable,
      "clientId": clientId.value,
      "clientCarId": clientCarId.value,
      'brandId': brandId.value,
      'brandName': brand.value,
      'modelId': modelId.value,
      'modelName': model.value,
      'year': year.value,
      'brandImage': brandImage.value,
      'clientName': nameController.text.trim().isEmpty
          ? name.value
          : nameController.text.trim(),
      'clientPhone':
          phone.value.isNotEmpty ? phone.value : phoneController.text.trim(),
    };
    // print("boradType=================${boardType.value}");

    if (boardType.value == 0) {
      arguments.addAll({
        'saudiPlateEnglishText': englishLettersForSaudi,
        'saudiPlateArabicText': arabicLettersForSaudi,
        'inputEnglishPlateNumber': saudiPlateNumber.value,
        'inputArabicPlateNumber': arabicPlateNumber,
        'symbolImageForSaudi': carSymbolImageForSaudi,
      });
    } else {
      arguments.addAll({
        'internationalPlateNumber': carPlateController.text.trim(),
      });
    }

    Get.toNamed(AppRoute.addWorksScreen, arguments: arguments);
  }

  Future<void> getIsTaxExist() async {
    Response response = await AddCustomerRepo().isTaxAvailable();
    if (response.statusCode == 200) {
      if (response.body['data'] == true) {
        isTaxAvailable = true;
      } else {
        isTaxAvailable = false;
      }
    }
  }

  ///Working

  void onTapSpareParts() {
    if (workPhone.trim().isEmpty) {
      showCustomSnackBar('please_enter_workshop_phone'.tr, isError: true);
      return;
    }
    if (workShopNameController.text.trim().isEmpty) {
      showCustomSnackBar('please_enter_workshop_name'.tr, isError: true);
      return;
    }

    Get.toNamed(AppRoute.addWorksScreen, arguments: {
      "clientId": workShopAsClientId,
      'clientName': workShopName.isNotEmpty
          ? workShopName
          : workShopNameController.text.trim(),
      'clientPhone': workPhone.isEmpty ? workshopPhone.text.trim() : workPhone
    });
  }

  // Terms agreement
  var isVerified = false.obs;
  var isOtpVerified = false.obs;
  var isMainPhoneVerified = false.obs;

  // Track verification status for additional users
  Map<int, bool> additionalUserPhoneVerified = {};

  /// Helper method to get the full phone number with country code
  String getFullPhoneNumber(String phoneNumberOnly) {
    // Trim and clean the phone number
    String cleanPhone = phoneNumberOnly.trim();

    // If already has country code prefix, return as is
    if (cleanPhone.startsWith('+')) {
      print("====== getFullPhoneNumber (already has +) ======");
      print("Full Phone: $cleanPhone");
      return cleanPhone;
    }

    // Get the dial code for the selected country
    String dialCode = getDialCodeForCountry(selectedCountryCode.value);

    // Combine dial code with phone number
    String fullPhone = dialCode + cleanPhone;

    print("====== getFullPhoneNumber ======");
    print("Country Code: ${selectedCountryCode.value}");
    print("Dial Code: $dialCode");
    print("Phone Number: $cleanPhone");
    print("Full Phone: $fullPhone");

    return fullPhone;
  }

  /// Get dial code from country code (e.g., 'BD' -> '+880', 'SA' -> '+966')
  String getDialCodeForCountry(String countryCode) {
    // Find the dial code from countryCodeMap
    for (var entry in countryCodeMap.entries) {
      if (entry.value['code'] == countryCode) {
        return entry.key;
      }
    }
    // Default to Saudi Arabia if not found
    return '+966';
  }

  bool isCustomerBlockList = false;
  int unpaidInvoiceCount = 0;
  void verifiedPhone(String phone,
      {int? userIndex, bool isCanAddCustomer = false}) async {
    createCarClientId.value = '';
    print("Phone =====================$phone");
    if (phone.isEmpty) {
      showCustomSnackBar("Please enter phone number".tr);
      return;
    }

    // Get the full phone number with country code
    String fullPhoneNumber = getFullPhoneNumber(phone);
    print("====== Full phone number for verification: $fullPhoneNumber ======");

    // Send OTP with full phone number

    bool isSuccess = await sendPhoneNumber(fullPhoneNumber);

    if (isCanAddCustomer) {
      getCustomerListByPhone();
    }
    if (isSuccess) {
      CustomAlert.showInfo(
        context: Get.context!,
        message: 'otp_sent_customer_message'.tr,
        onPressed: () {
          Navigator.pop(Get.context!);
          Get.dialog(
            CustomAlertVerificationDialog(
              phoneNumber: fullPhoneNumber,
              onVerificationComplete: (code) async {
                // Verify OTP with full phone number
                bool verified = await verifyPhoneNumber(
                  fullPhoneNumber,
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
                    phoneVerified.value = true;
                    verifiedPhoneNumber.value =
                        fullPhoneNumber; // Store full phone number
                  }
                  Navigator.pop(Get.context!);
                  CustomAlert.showInfo(
                    context: Get.context!,
                    message: 'Activation Successful'.tr,
                  );
                }
              },
              onResendCode: () async {
                // Resend OTP with full phone number
                await sendPhoneNumber(fullPhoneNumber);
                CustomAlert.showInfo(
                  context: Get.context!,
                  message: 'otp_sent_user_message'.tr,
                );
              },
            ),
          );
        },
      );
      if (isCustomerBlockList) {
        CustomAlert.showInfo(
          context: Get.context!,
          image: SvgPicture.asset(
            AppIcon.warning,
          ),
          message: 'This Customer has %s unpaid invoice at another workshop'
              .trArgs([unpaidInvoiceCount.toString()]),
        );
      }
    }
  }

  Future<void> getCustomerListByPhone() async {
    if (phone.value.isEmpty) {
      showCustomSnackBar('Please enter a phone number'.tr, isError: true);
      return;
    }

    print('====> Searching for customer with phone: ${phone.value}');

    Response response = await AddCustomerRepo().getCustomerByNumber(
      number: phone.value,
    );

    print('====> Response status: ${response.statusCode}');
    print('====> Response body: ${response.body}');

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

        createCarClientId.value = clientData?['_id'] ?? '';
        appLog('Customer found with ID: ${createCarClientId.value}');
      }
    }
  }

  Future<bool> sendPhoneNumber(String phoneNumber) async {
    bool isSuccess = false;
    isCustomerBlockList = false;
    unpaidInvoiceCount = 0;

    try {
      isVerified(true);
      Response response = await ApiClient.postData(
        ApiConstant.chekPhoneNumber,
        body: {"phoneNumber": phoneNumber},
      );
      if (response.statusCode == 200) {
        isSuccess = true;
        unpaidInvoiceCount = response.body['data']['unpaidInvoicesCount'] ?? 0;
        isCustomerBlockList =
            response.body['data']['isAlreadyBlocked'] ?? false;

        appLog(response.body.toString());
        showCustomSnackBar("OTP sent successfully".tr, isError: false);
        return isSuccess;
      } else {
        showCustomSnackBar("Failed to send OTP");
      }
      isVerified(false);
    } catch (e) {
      isVerified(false);
      showCustomSnackBar("Error sending OTP: ${e.toString()}");
    }
    return isSuccess;
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
        showCustomSnackBar("Invalid OTP");
        isOtpVerified(false);
        return false;
      }
    } catch (e) {
      isOtpVerified(false);
      showCustomSnackBar("Error verifying OTP: ${e.toString()}");
      return false;
    }
  }

  ///Create Customer car
  // dart
  Future<void> createCustomerCar() async {
    List<String> englishLetters = [];
    List<String> arabicLetters = [];

    for (String letter in plateLetters) {
      if (letter.isNotEmpty) {
        // Find matching option for this letter
        var matchedOption = letterOptions.firstWhere(
          (option) => option['ar'] == letter || option['en'] == letter,
          orElse: () => {'en': '', 'ar': ''},
        );

        if (matchedOption['ar']!.isNotEmpty) {
          englishLetters.add(matchedOption['en']!);
          arabicLetters.add(matchedOption['ar']!);
        }
      }
    }
    List<String> alphabetCombinationList = [];
    String alphabetCombination = englishLetters.join('');
    String alphabetCombinationArabic = arabicLetters.join('');
    alphabetCombinationList.add(alphabetCombination);
    alphabetCombinationList.add(alphabetCombinationArabic);

    addIsLoading.value = true;
    Response response = await AddCustomerRepo().createCar(
      clientId: createCarClientId.value,
      vin: vin.value,
      brandId: brandId.value,
      modelId: modelId.value,
      year: year.value,
      alphabetCombination: alphabetCombinationList,
      arabicText: _convertToArabicNumerals(saudiPlateNumber.value),
      englishText: saudiPlateNumber.value,
      symbol: selectedCarSymbolId.value,
      plateNumberForInternational: carPlateController.text.trim(),
    );
    addIsLoading.value = false;

    if (response.statusCode == 200 || response.statusCode == 201) {
      onCrateCar();
    } else {
      showCustomSnackBar(response.statusText ?? 'error_message'.tr,
          isError: true);
    }
  }

  void onCrateCar() {
    CustomAlert.showInfo(
      context: Get.context!,
      message: 'Car Added successfully to this Customer'.tr,
      onPressed: () {
        Get.back();
        Get.back();
      },
    );
  }

  ///vin

  final Map<String, String> wmiBrandMap = {
    "HJR": "Jetour",
    "LVU": "Jetour",
    "HGL": "Geely",
    "HGX": "Geely",
    "HJZ": "Geely",
    "10T": "Oshkosh",
    "11V": "Ottawa",
    "137": "Hummer",
    "145": "Hyundai",
    "15G": "Gillig",
    "17N": "John Deere",
    "18X": "WRV",
    "19U": "Acura",
    "1A4": "Chrysler",
    "1A8": "Chrysler",
    "1AC": "AMC",
    "1AM": "AMC",
    "1B3": "Dodge",
    "1B4": "Dodge",
    "1B6": "Dodge",
    "1B7": "Dodge",
    "1BA": "Blue Bird",
    "1BB": "Blue Bird",
    "1BD": "Blue Bird",
    "1C3": "Chrysler",
    "1C4": "Chrysler",
    "1C6": "Chrysler",
    "1C8": "Chrysler",
    "1C9": "Chance",
    "1CY": "Crane Carrier",
    "1D3": "Dodge",
    "1D4": "Dodge",
    "1D5": "Dodge",
    "1D7": "Dodge",
    "1D8": "Dodge",
    "1EC": "Fleetwood",
    "1F1": "Ford",
    "1F4": "Ford",
    "1F6": "Ford",
    "1FA": "Ford",
    "1FB": "Ford",
    "1FC": "Ford",
    "1FD": "Ford",
    "1FM": "Ford",
    "1FT": "Ford",
    "1FU": "Freightliner",
    "1FV": "Freightliner",
    "1G1": "Chevrolet",
    "1G2": "Pontiac",
    "1G3": "Oldsmobile",
    "1G4": "Buick",
    "1G6": "Cadillac",
    "1GD": "GMC",
    "1GT": "GMC",
    "1GY": "Cadillac",
    "1HG": "Honda",
    "1HF": "Honda",
    "1HD": "Harley-Davidson",
    "1HT": "International",
    "1J4": "Jeep",
    "1J6": "Jeep",
    "1J8": "Jeep",
    "1LN": "Lincoln",
    "1M1": "Mack",
    "1M2": "Mack",
    "1ME": "Mercury",
    "1N4": "Nissan",
    "1N6": "Nissan",
    "1NX": "Toyota",
    "1P3": "Plymouth",
    "1RF": "Roadmaster",
    "1V1": "Volkswagen",
    "1VW": "Volkswagen",
    "1XK": "Kenworth",
    "1XP": "Peterbilt",
    "1YV": "Mazda",
    "1Z3": "Mitsubishi",
    '1ZW': 'Mercury',
    "1ZV": "Ford",
    "2A4": "Chrysler",
    "2B3": "Dodge",
    "2C3": "Chrysler",
    "2D4": "Dodge",
    "2FZ": "Sterling",
    "2G1": "Chevrolet",
    "2G2": "Pontiac",
    "2HG": "Honda",
    "2HJ": "Honda",
    "2HK": "Honda",
    "2HS": "International",
    "2J4": "Jeep",
    "2LM": "Lincoln",
    "2M2": "Mack",
    "2ME": "Mercury",
    "2NK": "Kenworth",
    "2NP": "Peterbilt",
    "2P3": "Plymouth",
    "2S3": "Suzuki",
    "2T1": "Toyota",
    "2T2": "Lexus",
    "2T3": "Toyota",
    "2V4": "Volkswagen",
    "3A4": "Chrysler",
    "3C4": "Chrysler",
    "3CZ": "Honda",
    "3D3": "Dodge",
    "3FA": "Ford",
    "3FD": "Ford",
    "3G1": "Chevrolet",
    "3G2": "Pontiac",
    "3GN": "Chevrolet",
    "3HG": "Honda",
    "3N1": "Nissan",
    "3TM": "Toyota",
    "3VW": "Volkswagen",
    "4A3": "Mitsubishi",
    "4A4": "Mitsubishi",
    "4F2": "Mazda",
    "4JG": "Mercedes-Benz",
    "4S3": "Subaru",
    "4S4": "Subaru",
    "4T1": "Toyota",
    "4T3": "Toyota",
    "4US": "BMW",
    "4UZ": "Freightliner",
    "4V1": "Volvo",
    "4V2": "Volvo",
    "4V4": "Volvo",
    "4VZ": "Spartan",
    "5GA": "Buick",
    "5GR": "Hummer",
    "5J6": "Honda",
    "5J8": "Acura",
    "5LM": "Lincoln",
    "5N1": "Nissan",
    "5NP": "Hyundai",
    "5TD": "Toyota",
    "5TF": "Toyota",
    "5UX": "BMW",
    "5XY": "Kia",
    "5Y2": "Pontiac",
    "5Z6": "Suzuki",
    "6G1": "General Motors",
    "6MM": "Mitsubishi",
    "6T1": "Toyota",
    "8A1": "Renault",
    "8AJ": "Toyota",
    "8AW": "Volkswagen",
    "93H": "Honda",
    "93R": "Toyota",
    "93U": "Audi",
    "93Y": "Renault",
    "9BF": "Ford",
    "9BG": "Chevrolet",
    "9BM": "Mercedes-Benz",
    "9BW": "Volkswagen",
    "AFA": "Ford",
    "JHM": "Honda",
    "JHL": "Honda",
    "JHG": "Honda",
    "JMB": "Mitsubishi",
    "JM1": "Mazda",
    "JM3": "Mazda",
    "JTE": "Toyota",
    "JTH": "Lexus",
    "JTJ": "Lexus",
    "JTK": "Scion",
    "JTM": "Toyota",
    "JT8": "Lexus",
    "KL1": "Chevrolet",
    "KM8": "Hyundai",
    "KMH": "Hyundai",
    "KNA": "Kia",
    "KND": "Kia",
    "KNM": "Renault Samsung",
    "LTV": "Toyota",
    "LVV": "Chery",
    "MA3": "Suzuki",
    "MAL": "Hyundai",
    "MNT": "Nissan",
    "MR0": "Toyota",
    "NM0": "Ford",
    "NMT": "Toyota",
    "PE3": "Mazda",
    "PL1": "Proton",
    "SAL": "Land Rover",
    "SAJ": "Jaguar",
    "SB1": "Toyota",
    "SCA": "Rolls Royce",
    "SCB": "Bentley",
    "SCC": "Lotus",
    "SHH": "Honda",
    "SHS": "Honda",
    "SJN": "Nissan",
    "TMA": "Hyundai",
    "TMB": "Skoda",
    "TMK": "Karosa",
    "TM9": "Skoda",
    "TRU": "Audi",
    "TSM": "Suzuki",
    "TYA": "Mitsubishi",
    "U5Y": "Kia",
    "VF1": "Renault",
    "VF3": "Peugeot",
    "VF7": "Citroen",
    "VNK": "Toyota",
    "VSK": "Nissan",
    "VS6": "Ford",
    "VTN": "Honda",
    "VWA": "Nissan",
    "VWV": "Volkswagen",
    "WAU": "Audi",
    "WBA": "BMW",
    "WBS": "BMW",
    "WDC": "Mercedes-Benz",
    "WDD": "Mercedes-Benz",
    "WMW": "Mini",
    "WP0": "Porsche",
    "WP1": "Porsche",
    "WVG": "Volkswagen",
    "WVW": "Volkswagen",
    "YV1": "Volvo",
    "YV2": "Volvo",
    "YV4": "Volvo",
    "ZFA": "Fiat",
    "ZFF": "Ferrari",
    "ZHW": "Lamborghini",
    "ZAR": "Alfa Romeo",
    "ZAM": "Maserati",
    '1F9': 'FWD',
    '1FF': 'Ford',
    '1FE': 'Ford',
    '1GF': 'Flexible',
    '1GG': 'Isuzu',
    '1GH': 'Oldsmobile',
    '1GJ': 'GMC',
    '1GM': 'Pontiac',
    '1GN': 'Chevrolet',
    '1HS': 'International',
    '1HV': 'International',
    '1JD': 'Jeep',
    '1JM': 'Jeep',
    '1JT': 'Jeep',
    '2B1': 'Orion',
    '2B5': 'Dodge',
    '2B6': 'Dodge',
    '2B7': 'Dodge',
    '2B8': 'Dodge',
    '2BT': 'Jeep',
    '2C1': 'Chevrolet',
    '2C7': 'Pontiac',
    '2C8': 'Chrysler',
    '3AL': 'Freightliner',
    '3B3': 'Dodge',
    '3B7': 'Dodge',
    '3G4': 'Buick',
    '3G5': 'Buick',
    '3GA': 'Chevrolet',
    '3GB': 'Chevrolet',
    '3GD': 'GMC',
    '3GE': 'Chevrolet',
    '4CD': 'Oshkosh',
    '4DR': 'Genesis',
    '4GT': 'Isuzu',
    '4KB': 'Chevrolet',
    '4KD': 'GMC',
    '4KL': 'Isuzu',
    '4N1': 'Nissan',
    '4N2': 'Nissan',
    '5B4': 'Workhorse',
    '5KJ': 'Western Star Trucks',
    '5KK': 'Western Star Trucks',
    '5PV': 'Hino',
    '5SA': 'Suzuki',
    '5S3': 'Saab',
    '5SX': 'American LaFrance',
    '6AB': 'MAN',
    '6F4': 'Nissan',
    '6F5': 'Kenworth',
    '6FP': 'Ford',
    '6H8': 'General Motors',
    '8AG': 'Chevrolet',
    '8AF': 'Ford',
    '8AD': 'Peugeot',
    '8GD': 'Peugeot',
    '9DB': 'Mercedes-Benz',
    '9DW': 'Volkswagen',
    '9FB': 'Renault',
    'AAV': 'Volkswagen',
    'AC5': 'Hyundai',
    'ADD': 'Hyundai',
    'AHT': 'Toyota',
    'JA3': 'Mitsubishi',
    'JA7': 'Mitsubishi',
    'JAA': 'Isuzu',
    'JAB': 'Isuzu',
    'JAC': 'Isuzu',
    'JAE': 'Acura',
    'JAL': 'Isuzu',
    'JB3': 'Dodge',
    'JB4': 'Dodge',
    'JB7': 'Dodge',
    'JC2': 'Ford',
    'JD1': 'Daihatsu',
    'KL7': 'Asuna',
    'KLA': 'Daewoo',
    'KM1': 'Suzuki',
    'KM4': 'Suzuki',
    'KMF': 'Hyundai',
    'LKL': 'King Long',
    'LM5': 'Isuzu',
    'LN1': 'Suzuki',
    'LSY': 'Brilliance',
    'MA1': 'Mahindra',
    'MA7': 'Honda',
    'MDH': 'Nissan',
    'MEE': 'Renault',
    'MMM': 'Chevrolet',
    'MMT': 'Mitsubishi',
    'SA9': 'Morgan',
    'SAT': 'Triumph',
    'SAR': 'Rover',
    'SAX': 'Sterling',
    'SCE': 'DeLorean',
    'TDM': 'Quantya',
    'TK9': 'SOR',
    'TMT': 'Tatra',
    'TRA': 'Ikarus',
    'TSE': 'Ikarus',
    'U6Y': 'Kia',
    'UU1': 'Dacia',
    'UU6': 'Daewoo',
    'W06': 'Cadillac',
    'WAG': 'Neoplan',
    'WAP': 'Alpina',
    'WB1': 'BMW',
    'WEB': 'EvoBus',
    'WJM': 'Iveco',
    'WJR': 'Irmscher',
    'WMA': 'MAN',
    'WMX': 'Mercedes-Benz',
    'YS2': 'Scania',
    'YS3': 'Saab',
    'YS4': 'Scania',
    'YTN': 'Saab',
    'Z8M': 'Marussia',
    'ZAA': 'Autobianchi',
    'ZAP': 'Piaggio/Vespa/Gilera',
    'ZBN': 'Benelli',
    'ZCG': 'Cagiva',
    'ZDC': 'Honda',
    'ZDM': 'Ducati',
    'ZGA': 'Iveco',
    'ZGU': 'Moto Guzzi',
    'ZLA': 'Lancia',
    'ZOM': 'OM',
    '1G5': 'Pontiac',
    '1G8': 'Chevrolet',
    '1GA': 'Chevrolet',
    '1GB': 'Chevrolet',
    '1GC': 'Chevrolet',
    '1GE': 'Cadillac',
    '1GK': 'GMC',
    '1JC': 'Jeep',
    '1JE': 'Jeep',
    '1JF': 'Jeep',
    '1JH': 'Jeep',
    '1L1': 'Lincoln',
    '1M3': 'Mack',
    '1M8': 'MCI',
    '1MB': 'Mercedes-Benz',
    '1MR': 'Lincoln',
    '1N9': 'Neoplan',
    '1NK': 'Kenworth',
    '1NP': 'Peterbilt',
    '1P4': 'Plymouth',
    '1P7': 'Plymouth',
    '1P9': 'Panoz',
    '1S9': 'Saleen',
    '177': 'Thomas',
    '1T8': 'Thomas',
    '1TU': 'TMC',
    '1WA': 'Autostar',
    '1WB': 'Autostar',
    '1WU': 'White Volvo',
    '1WV': 'Winnebago',
    '1XM': 'AMC',
    '1Y1': 'Chevrolet',
    '1Z5': 'Mitsubishi',
    '1Z7': 'Mitsubishi',
    '2A3': 'Chrysler',
    '2A8': 'Chrysler',
    '2B4': 'Dodge',
    '2BC': 'Jeep',
    '2BD': 'Jeep',
    '2C4': 'Chrysler',
    '2CC': 'AMC',
    '2CK': 'Pontiac',
    '2CH': 'Chevrolet',
    '2CM': 'AMC',
    '2CN': 'Chevrolet',
    '2D6': 'Dodge',
    '2D7': 'Dodge',
    '2D8': 'Dodge',
    '2FA': 'Ford',
    '2FB': 'Ford',
    '2FC': 'Ford',
    '2FD': 'Ford',
    '2FF': 'Ford',
    '2FM': 'Ford',
    '2FT': 'Ford',
    '2FU': 'Freightliner',
    '2FV': 'Freightliner',
    '2FW': 'Sterling',
    '2G0': 'GMC',
    '2G3': 'Oldsmobile',
    '2G4': 'Buick',
    '2G5': 'GMC',
    '2G7': 'Pontiac',
    '2G8': 'Chevrolet',
    '2GA': 'Chevrolet',
    '2GB': 'Chevrolet',
    '2GC': 'Chevrolet',
    '2GD': 'GMC',
    '2GJ': 'GMC',
    '2GK': 'GMC',
    '2GN': 'Chevrolet',
    '2GM': 'Pontiac',
    '2GT': 'GMC',
    '2GY': 'Cadillac',
    '2HH': 'Acura',
    '2HM': 'Hyundai',
    '2HN': 'Acura',
    '2HT': 'International',
    '2J7': 'Jeep',
    '2MH': 'Mercury',
    '2MR': 'Mercury',
    '2NV': 'Nova Bus',
    '2P4': 'Plymouth',
    '2P5': 'Plymouth',
    '2P9': 'Prevost',
    '2PC': 'Prevost',
    '2S2': 'Suzuki',
    '2S4': 'Suzuki',
    '2V8': 'Volkswagen',
    '2WK': 'Western Star',
    '2WL': 'Western Star',
    '2WM': 'Western Star',
    '2XK': 'Kenworth',
    '2XM': 'Eagle',
    '2XP': 'Peterbilt',
    '3A8': 'Chrysler',
    '3AB': 'Dina',
    '3B4': 'Dodge',
    '3B6': 'Dodge',
    '3BK': 'Kenworth',
    '3BP': 'Peterbilt',
    '3C3': 'Chrysler',
    '3C8': 'Chrysler',
    '3CA': 'Chrysler',
    '3CE': 'Volvo',
    '3D5': 'Dodge',
    '3D6': 'Dodge',
    '3D7': 'Dodge',
    '3FB': 'Ford',
    '3FC': 'Ford',
    '3FE': 'Ford',
    '3FF': 'Ford',
    '3FR': 'Ford',
    '3FT': 'Ford',
    '3G7': 'Pontiac',
    '3G8': 'Chevrolet',
    '3GC': 'Chevrolet',
    '3GG': 'Cadillac',
    '3GK': 'GMC',
    '3GM': 'Pontiac',
    '3H1': 'Honda',
    '3HA': 'International',
    '3HM': 'Honda',
    '3HS': 'International',
    '3HT': 'International',
    '3LN': 'Lincoln',
    '3MA': 'Mercury',
    '3N6': 'Nissan',
    '3N8': 'Nissan',
    '3NK': 'Kenworth',
    '3NM': 'Peterbilt',
    '3P3': 'Plymouth',
    '3WK': 'Kenworth',
    '45V': 'Utilimaster',
    '46G': 'Gillig',
    '478': 'Honda',
    '49H': 'Sterling',
    '4B3': 'Dodge',
    '4C3': 'Chrysler',
    '4F4': 'Mazda',
    '4G1': 'Chevrolet',
    '4G2': 'Pontiac',
    '4GB': 'Chevrolet',
    '4GD': 'GMC',
    '4J4': 'Jeep',
    '4M2': 'Mercury',
    '4NU': 'Isuzu',
    '4P3': 'Plymouth',
    '4RK': 'Nova Bus',
    '4S1': 'Isuzu',
    '4S2': 'Isuzu',
    '4S6': 'Honda',
    '4S7': 'Spartan',
    '4SL': 'Magnum',
    '4TA': 'Toyota',
    '4V5': 'Volvo',
    '4V6': 'Volvo',
    '4VA': 'Volvo',
    '4VG': 'Volvo',
    '4VH': 'Volvo',
    '4VJ': 'Volvo',
    '4VK': 'Volvo',
    '4VL': 'Volvo',
    '4VM': 'Volvo',
    '5AS': 'GEM',
    '5CK': 'Western Star Trucks',
    '5FN': 'Honda',
    '5FP': 'Honda',
    '5FY': 'New Flyer',
    '5GT': 'Hummer',
    '5GZ': 'Saturn',
    '5LT': 'Lincoln',
    '5N3': 'Infiniti',
    '5NM': 'Hyundai',
    '5T4': 'Workhorse',
    '5TB': 'Toyota',
    '5TE': 'Toyota',
    '5UM': 'BMW',
    '5YM': 'BMW',
    '935': 'Citroen',
    '936': 'Peugeot',
    '8AK': 'Suzuki',
    '8AP': 'Fiat',
    '9BD': 'Fiat',
    '9BS': 'Scania',
    '9C2': 'Honda',
    'CL9': 'Wallyscar',
    'J81': 'Chevrolet',
    'J87': 'Isuzu',
    'J8B': 'Chevrolet',
    'J8C': 'Chevrolet',
    'J8D': 'GMC',
    'J8Y': 'Chevrolet',
    'J8Z': 'Chevrolet',
    'JA4': 'Mitsubishi',
    'JD2': 'Daihatsu',
    'JE3': 'Eagle',
    'JF1': 'Subaru',
    'JF2': 'Subaru',
    'JF3': 'Subaru',
    'JF4': 'Saab',
    'JG1': 'Chevrolet',
    'JG7': 'Pontiac',
    'JGC': 'Chevrolet',
    'JH2': 'Honda',
    'JH3': 'Honda',
    'JH4': 'Acura',
    'JHB': 'Hino',
    'JHK': 'Honda',
    'JJ3': 'Chrysler',
    'JL5': 'Mitsubishi',
    'JL6': 'Mitsubishi',
    'JLS': 'Sterling',
    'JK8': 'Suzuki',
    'JKS': 'Suzuki',
    'JM2': 'Mazda',
    'JMZ': 'Mazda',
    'JN1': 'Nissan',
    'JN3': 'Nissan',
    'JN4': 'Nissan',
    'JN6': 'Nissan',
    'JN8': 'Nissan',
    'JNA': 'Nissan',
    'JNK': 'Infiniti',
    'JNR': 'Infiniti',
    'JNX': 'Infiniti',
    'JP3': 'Plymouth',
    'JP4': 'Plymouth',
    'JP7': 'Plymouth',
    'JR2': 'Isuzu',
    'JS1': 'Suzuki',
    'JS2': 'Suzuki',
    'JS3': 'Suzuki',
    'JS4': 'Suzuki',
    'JSA': 'Suzuki',
    'JSL': 'Suzuki',
    'JT2': 'Toyota',
    'JT3': 'Toyota',
    'JT4': 'Toyota',
    'JT5': 'Toyota',
    'JT6': 'Lexus',
    'JTD': 'Toyota',
    'JTL': 'Scion',
    'JTN': 'Toyota',
    'JW6': 'Mitsubishi',
    'JW7': 'Mitsubishi',
    'KL2': 'Pontiac',
    'KL5': 'Suzuki',
    'KNB': 'Kia',
    'KNC': 'Kia',
    'KNJ': 'Ford',
    'KPA': 'Ssangyong',
    'KPH': 'Mitsubishi',
    'KPT': 'SsangYong',
    'L56': 'Renault Samsung',
    'L5Y': 'Taizhou Zhongneng',
    'LDN': 'Soueast',
    'LDY': 'Zhongtong Coach',
    'LES': 'Isuzu',
    'LGH': 'Dong Feng',
    'LM1': 'Suzuki',
    'LM4': 'Suzuki',
    'LVS': 'Ford',
    'LVT': 'Soueast',
    'LVZ': 'DFSK',
    'LZM': 'MAN',
    'LZE': 'Isuzu',
    'LZG': 'Shaanxi',
    'LZY': 'Yutong Zhengzhou',
    'MHF': 'Toyota',
    'MHR': 'Honda',
    'MEX': 'Volkswagen',
    'ML3': 'Dodge',
    'MLC': 'Suzuki',
    'MLH': 'Honda',
    'MMB': 'Mitsubishi',
    'MMC': 'Mitsubishi',
    'MNB': 'Ford',
    'MM8': 'Mazda',
    'MPA': 'Isuzu',
    'MP1': 'Isuzu',
    'MRH': 'Honda',
    'NLA': 'Honda',
    'NLE': 'Mercedes-Benz',
    'NM4': 'Tofas',
    'PE1': 'Ford',
    'SCF': 'Aston Martin',
    'SDB': 'Peugeot',
    'SFD': 'Alexander Dennis',
    'SU9': 'Solaris',
    'TCC': 'SMART',
    'TMP': 'Skoda',
    'TN9': 'Karosa',
    'TW1': 'Toyota',
    'TYB': 'Mitsubishi',
    'UU3': 'ARO',
    'VA0': 'ÖAF',
    'VBK': 'KTM',
    'VF2': 'Renault',
    'VF4': 'Talbot',
    'VF6': 'Renault',
    'VF8': 'Matra',
    'VFE': 'IvecoBus',
    'VG6': 'Mack',
    'VLU': 'Scania',
    'VN1': 'SOVAB',
    'VNE': 'Irisbus',
    'VNV': 'Renault',
    'VSA': 'Mercedes-Benz',
    'VSE': 'Suzuki',
    'VSS': 'SEAT',
    'VSX': 'Opel',
    'VS9': 'Carrocerias Ayats',
    'VTM': 'Honda',
    'VTT': 'Suzuki',
    'VV9': 'Tauro',
    'VX1': 'Zastava',
    'WA1': 'Audi',
    'WBX': 'BMW',
    'WBY': 'BMW',
    'WD0': 'Dodge',
    'WD1': 'Dodge',
    'WD2': 'Dodge',
    'WD3': 'Mercedes-Benz',
    'WD4': 'Mercedes-Benz',
    'WD5': 'Dodge',
    'WD8': 'Dodge',
    'WDA': 'Mercedes-Benz',
    'WDB': 'Mercedes-Benz',
    'WDP': 'Dodge',
    'WDX': 'Dodge',
    'WDY': 'Dodge',
    'WDZ': 'Mercedes-Benz',
    'WF0': 'Ford',
    'WF1': 'Merkur',
    'WKK': 'Fahrzeugwerke',
    'WME': 'Mercedes-Benz',
    'WUA': 'Audi',
    'WV1': 'Volkswagen',
    'WV2': 'Volkswagen',
    'WV3': 'Volkswagen',
    'XL9': 'Spyker',
    'XLB': 'Volvo',
    'XLE': 'Scania',
    'XLR': 'DAF',
    'XMC': 'Mitsubishi',
    'XTA': 'Lada',
    'XTT': 'UAZ/Sollers',
    'XUF': 'GMC',
    'XUU': 'AvtoTor',
    'XW8': 'Volkswagen',
    'XWB': 'Daewoo',
    'W0L': 'Opel',
    'XWE': 'AvtoTor',
    'X4X': 'AvtoTor',
    'X7L': 'Renault',
    'X7M': 'Hyundai',
    'YC1': 'Honda',
    'Y6D': 'Zaporozhets',
    'YB3': 'Volvo',
    'YBW': 'Volkswagen',
    'YCM': 'Mazda',
    'YE2': 'Van Hool',
    'YK1': 'Saab',
    'YV3': 'Volvo',
    'YV5': 'Volvo',
    'ZA9': 'Lamborghini',
    'ZC2': 'Chrysler',
    'ZCF': 'Iveco',
    'ZDF': 'Ferrari',
    'ZD0': 'Yamaha',
    'ZD3': 'Beta Motor',
    'ZD4': 'Aprilia',
    'ZFC': 'Fiat',
    'ZJM': 'Malaguti',
    'ZJN': 'Innocenti',
    'ZKH': 'Husqvarna',
    '1J7': 'Jeep',
    '2J6': 'Jeep',
    '6G2': 'Pontiac',
    '6MP': 'Mercury',
    '8GG': 'Chevrolet',

    //aditional
    '795': 'Bugatti',
    '937': 'Dodge',
    '953': 'Volkswagen',
    '988': 'Jeep',
    '19V': 'Acura',
    '19X': 'Honda',
    '1F0': 'Ford',
    '1G0': 'Opel',
    '1G7': 'Pontiac',
    '1HA': 'Chevrolet',
    '1LJ': 'Lincoln',
    '1UT': 'Jeep',
    '1V2': 'Volkswagen',
    '2AY': 'Hino',
    '2AZ': 'Hino',
    '2CG': 'Pontiac',
    '2CT': 'GMC',
    '2F0': 'Ford',
    '2G6': 'Cadillac',
    '2GE': 'Cadillac',
    '2GH': 'GMC',
    '2Gx': 'GMC',
    '2L1': 'Lincoln',
    '2LJ': 'Lincoln',
    '2LN': 'Lincoln',
    '3AK': 'Chrysler',
    '3AV': 'BMW',
    '3C6': 'Chrysler',
    '3C7': 'Chrysler',
    '3D2': 'Dodge',
    '3D4': 'Dodge',
    '3F0': 'Ford',
    '3FM': 'Ford',
    '3FN': 'Ford',
    '3G0': 'Saab',
    '3H3': 'Hyundai',
    '3HC': 'International',
    '3KP': 'Kia',
    '3MD': 'Mazda',
    '3MV': 'Mazda',
    '3MW': 'BMW',
    '3MY': 'Toyota',
    '3MZ': 'Mazda',
    '3PC': 'Infiniti',
    '3TY': 'Toyota',
    '3VV': 'Volkswagen',
    '4B9': 'BYD',
    '4G3': 'Toyota',
    '4G5': 'GMC',
    '4GL': 'Buick',
    '4T4': 'Toyota',
    '4VE': 'Volvo',
    '50E': 'Lucid',
    '50G': 'Karma',
    '54D': 'Isuzu',
    '55S': 'Mercedes-Benz',
    '58A': 'Lexus',
    '5BZ': 'Nissan',
    '5FR': 'Acura',
    '5GD': 'Daewoo',
    '5GN': 'Hummer',
    '5KB': 'Honda',
    '5L1': 'Lincoln',
    '5LD': 'Ford',
    '5MZ': 'Lincoln',
    '5NT': 'Hyundai',
    '5XX': 'Kia',
    '5YF': 'Toyota',
    '5YJ': 'Tesla',
    '6F1': 'Ford',
    '6F2': 'Iveco',
    '6FM': 'Mack',
    '6G0': 'GMC',
    '6G3': 'Chevrolet',
    '7A1': 'Mitsubishi',
    '7A3': 'Honda',
    '7A4': 'Toyota',
    '7A5': 'Ford',
    '7A7': 'Nissan',
    '7FA': 'Honda',
    '7FC': 'Rivian',
    '7G2': 'Tesla',
    '7GZ': 'GMC',
    '7H4': 'Hino',
    '7JR': 'Volvo',
    '7MM': 'Mazda',
    '7MU': 'Toyota',
    '7PD': 'Rivian',
    '7SA': 'Tesla',
    '7SV': 'Toyota',
    '8A3': 'Scania',
    '8AC': 'Mercedes-Benz',
    '8AE': 'Peugeot',
    '8AN': 'Nissan',
    '8AT': 'Iveco',
    '8BC': 'Citroen',
    '8BN': 'Mercedes-Benz',
    '8BR': 'Mercedes-Benz',
    '8BT': 'Mercedes-Benz',
    '8BU': 'Mercedes-Benz',
    '8C3': 'Honda',
    '8CH': 'Honda',
    '8G1': 'Renault',
    '8L4': 'Great Wall',
    '8LB': 'GMC',
    '8LF': 'Mazda',
    '8LG': 'Hyundai',
    '8XD': 'Ford',
    '8XV': 'Iveco',
    '8Z1': 'GMC',
    '93C': 'Chevrolet',
    '93K': 'Volvo',
    '93W': 'Fiat',
    '93Z': 'Iveco',
    '94D': 'Nissan',
    '95P': 'Hyundai',
    '95V': 'KTM',
    '98M': 'BMW',
    '98R': 'Chery',
    '99A': 'Audi',
    '99J': 'Jaguar',
    '99L': 'BYD',
    '9BH': 'Hyundai',
    '9BR': 'Toyota',
    '9BV': 'Volvo',
    '9CD': 'Suzuki',
    '9FC': 'Mazda',
    '9GA': 'Chevrolet',
    '9UJ': 'Chery',
    '9UK': 'Lifan',
    '9UW': 'Kia',
    '9V7': 'Citroen',
    '9V8': 'Peugeot',
    'A12': 'Lamborghini',
    'AAA': 'Audi',
    'AAK': 'FAW',
    'AAM': 'MAN',
    'ABJ': 'Mitsubishi',
    'ABM': 'BMW',
    'ACV': 'Isuzu',
    'ADM': 'GMC',
    'ADN': 'Nissan',
    'ADR': 'Renault',
    'ADX': 'Tata',
    'AFB': 'Mazda',
    'AHH': 'Hino',
    'AHM': 'Honda',
    'BAB': 'BMW',
    'D39': 'Bugatti',
    'DAA': 'Fiat',
    'DAB': 'BMW',
    'GA1': 'Renault',
    'J8T': 'GMC',
    'JAM': 'Isuzu',
    'JC0': 'Ford',
    'JC1': 'Fiat',
    'JD4': 'Daihatsu',
    'JDA': 'Daihatsu',
    'JE4': 'Mitsubishi',
    'JGT': 'GMC',
    'JHA': 'Hino',
    'JHD': 'Hino',
    'JHF': 'Hino',
    'JHH': 'Hino',
    'JLF': 'Mitsubishi',
    'JM0': 'Mazda',
    'JM6': 'Mazda',
    'JM7': 'Mazda',
    'JMA': 'Mitsubishi',
    'JMF': 'Mitsubishi',
    'JMY': 'Mitsubishi',
    'JN0': 'Nissan',
    'JNC': 'Nissan',
    'JNE': 'Nissan',
    'JPC': 'Nissan',
    'JS0': 'Suzuki',
    'JT0': 'Toyota',
    'JTF': 'Toyota',
    'JTG': 'Toyota',
    'KL3': 'Daewoo',
    'KL4': 'Buick',
    'KL6': 'GMC',
    'KL8': 'Daewoo',
    'KLT': 'Tata',
    'KLU': 'Tata',
    'KME': 'Hyundai',
    'KMJ': 'Hyundai',
    'KMT': 'Genesis',
    'KMU': 'Genesis',
    'KNE': 'Kia',
    'KNG': 'Kia',
    'L2C': 'Chery',
    'L6T': 'Geely',
    'LA6': 'King Long',
    'LA9': 'BYD',
    'LB2': 'Geely',
    'LB3': 'Geely',
    'LBE': 'Hyundai',
    'LBV': 'BMW',
    'LC0': 'BYD',
    'LDC': 'Dong feng',
    'LDK': 'FAW',
    'LEF': 'JMC',
    'LET': 'Isuzu',
    'LF3': 'Lifan',
    'LFA': 'Ford',
    'LFB': 'FAW',
    'LFM': 'FAW',
    'LFN': 'FAW',
    'LFP': 'FAW',
    'LFV': 'FAW',
    'LGA': 'Dong feng',
    'LGB': 'Dong feng',
    'LGC': 'Dong feng',
    'LGG': 'Dong feng',
    'LGJ': 'Dong feng',
    'LGX': 'BYD',
    'LH1': 'FAW',
    'LJ1': 'JAC',
    'LJ8': 'Zotye',
    'LJD': 'Dong feng',
    'LJX': 'JMC',
    'LL6': 'GAC',
    'LLN': 'Qoros',
    'LLV': 'Lifan',
    'LMG': 'GAC',
    'LNB': 'BAIC',
    'LPA': 'Changan',
    'LPE': 'BYD',
    'LPS': 'Polestar',
    'LRB': 'SAIC',
    'LRD': 'Foton',
    'LRE': 'SAIC',
    'LRW': 'Tesla',
    'LS5': 'Changan',
    'LS7': 'JMC',
    'LSF': 'SAIC',
    'LSG': 'SAIC',
    'LSH': 'SAIC',
    'LSJ': 'SAIC',
    'LSK': 'SAIC',
    'LSV': 'SAIC',
    'LTA': 'ZXauto',
    'LTN': 'Soueast',
    'LUC': 'Honda',
    'LUD': 'Dong feng',
    'LUX': 'Dong feng',
    'LVA': 'Foton',
    'LVB': 'Foton',
    'LVC': 'Foton',
    'LVG': 'GAC',
    'LVH': 'Dong feng',
    'LVM': 'Chery',
    'LVR': 'Changan',
    'LVY': 'Volvo',
    'LWV': 'GAC',
    'LXV': 'Borgward',
    'LYV': 'Volvo',
    'LZF': 'SAIC',
    'LZW': 'SAIC',
    'M3G': 'Isuzu',
    'MA6': 'GMC',
    'MAH': 'Fiat',
    'MAJ': 'Ford',
    'MAK': 'Honda',
    'MAT': 'Tata',
    'MB8': 'Suzuki',
    'MBH': 'Nissan',
    'MBJ': 'Toyota',
    'MBK': 'MAN',
    'MCD': 'Mahindra',
    'MCL': 'International',
    'ME4': 'Honda',
    'MH1': 'Honda',
    'MHH': 'BMW',
    'MHK': 'Daihatsu',
    'MHL': 'Mercedes-Benz',
    'MHY': 'Suzuki',
    'MJB': 'GMC',
    'MK2': 'Mitsubishi',
    'MM0': 'Mazda',
    'MM6': 'Mazda',
    'MM7': 'Mazda',
    'MMA': 'Mitsubishi',
    'MMD': 'Mitsubishi',
    'MMF': 'BMW',
    'MMH': 'Tata',
    'MMK': 'Toyota',
    'MML': 'MG',
    'MMR': 'Subaru',
    'MMS': 'Suzuki',
    'MNA': 'Ford',
    'MNC': 'Ford',
    'MNK': 'Hino',
    'MP2': 'Mazda',
    'MP5': 'Foton',
    'MPB': 'Ford',
    'MR1': 'Toyota',
    'MR2': 'Toyota',
    'MRX': 'BYD',
    'MS3': 'Suzuki',
    'MX3': 'Hyundai',
    'MZ7': 'MG',
    'MZB': 'Kia',
    'NC0': 'BMW',
    'NFB': 'Honda',
    'NLH': 'Hyundai',
    'NLJ': 'Hyundai',
    'NM1': 'Renault',
    'NMA': 'MAN',
    'NMB': 'Mercedes-Benz',
    'NMH': 'Honda',
    'NNA': 'Isuzu',
    'PAB': 'Isuzu',
    'PAD': 'Honda',
    'PAF': 'BMW',
    'PL8': 'Hyundai',
    'PLP': 'Subaru',
    'PLZ': 'Isuzu',
    'PM1': 'BMW',
    'PMH': 'Honda',
    'PMK': 'Honda',
    'PN1': 'Toyota',
    'PN2': 'Toyota',
    'PN8': 'Nissan',
    'PNA': 'Peugeot',
    'PNV': 'Volvo',
    'PP1': 'Mazda',
    'PP3': 'Hyundai',
    'PPP': 'Suzuki',
    'PPV': 'Volkswagen',
    'PR8': 'Ford',
    'PRB': 'Jaecoo',
    'PRH': 'Chery',
    'PRN': 'GAC',
    'RFV': 'PGO',
    'RHA': 'Ford',
    'RKT': 'Honda',
    'RL0': 'Ford',
    'RL4': 'Toyota',
    'RLA': 'Mitsubishi',
    'RLE': 'Isuzu',
    'RLF': 'BMW',
    'RLH': 'Honda',
    'RLL': 'VinFast',
    'RLM': 'Mercedes-Benz',
    'SAD': 'Jaguar',
    'SAH': 'Honda',
    'SBC': 'Iveco',
    'SBM': 'McLaren',
    'SC6': 'INEOS',
    'SCV': 'Volvo',
    'SD7': 'Aston Martin',
    'SDF': 'Dodge',
    'SDG': 'Renault',
    'SDP': 'MG',
    'SFA': 'Ford',
    'SFZ': 'Tesla',
    'SJA': 'Bentley',
    'SJK': 'Nissan',
    'SLA': 'Rolls Royce',
    'SLV': 'Volvo',
    'SZA': 'Scania',
    'TMC': 'Hyundai',
    'TW3': 'Renault',
    'TW7': 'Mini',
    'TX5': 'Mini',
    'VCF': 'Fisker',
    'VF5': 'Iveco',
    'VF9': 'Bugatti',
    'VFA': 'Bugatti',
    'VG7': 'Renault',
    'VG8': 'Renault',
    'VGA': 'Peugeot',
    'VMK': 'Renault',
    'VR1': 'DS',
    'VR3': 'Peugeot',
    'VR7': 'Citroen',
    'VS5': 'Renault',
    'VS7': 'Citroen',
    'VS8': 'Peugeot',
    'VSC': 'Mercedes-Benz',
    'VXE': 'Opel',
    'VXK': 'Opel',
    'W04': 'Buick',
    'W0S': 'Opel',
    'W0V': 'Opel',
    'W1A': 'Smart',
    'W1K': 'Mercedes-Benz',
    'W1N': 'Mercedes-Benz',
    'W1T': 'Mercedes-Benz',
    'W1V': 'Mercedes-Benz',
    'W1W': 'Mercedes-Benz',
    'W1X': 'Mercedes-Benz',
    'W1Y': 'Mercedes-Benz',
    'W1Z': 'Mercedes-Benz',
    'WAC': 'Audi',
    'WB3': 'BMW',
    'WB4': 'BMW',
    'WB5': 'BMW',
    'WB6': 'BMW',
    'WDF': 'Mercedes-Benz',
    'WDW': 'Dodge',
    'WMZ': 'Mini',
    'WU1': 'Audi',
    'WVM': 'Volkswagen',
    'WZ1': 'Toyota',
    'X9F': 'Ford',
    'X9P': 'Volvo',
    'X9X': 'Great Wall',
    'XBB': 'Great Wall',
    'XLV': 'DAF',
    'XNC': 'Mitsubishi',
    'XP7': 'Tesla',
    'XW7': 'Toyota',
    'Y6U': 'Skoda',
    'Y7C': 'Great Wall',
    'YAR': 'Toyota',
    'YH4': 'Fisker',
    'YSC': 'Cadillac',
    'YSM': 'Polestar',
    'YT9': 'Koenigsegg',
    'Z6F': 'Ford',
    'Z8N': 'Nissan',
    'Z94': 'Hyundai',
    'ZAC': 'Jeep',
    'ZAS': 'Alfa Romeo',
    'ZBA': 'BMW',
    'ZBI': 'BMW',
    'ZBM': 'BMW',
    'ZBP': 'BMW',
    'ZBT': 'BMW',
    'ZFB': 'Fiat',
    'ZK5': 'Hyundai',
    'ZN3': 'Iveco',
    'ZN6': 'Maserati',
    'ZPB': 'Lamborghini'
  };
  bool areRequiredFieldsFilled() {
    // For Workshop (userType == 1)
    if (userType.value == 1) {
      // If boardType == 1 (Non-Saudi), document number and Non-Saudi car fields are not required
      return workShopNameController.text.trim().isNotEmpty &&
          workshopPhone.text.trim().isNotEmpty;
    } else {
      // For Non-Saudi board, document number and Non-Saudi car fields are not required
      if (boardType.value == 1) {
        return nameController.text.trim().isNotEmpty &&
            phoneController.text.trim().isNotEmpty &&
            vinController.text.trim().isNotEmpty &&
            carPlateController.text.trim().isNotEmpty &&
            brand.value.isNotEmpty &&
            model.value.isNotEmpty &&
            year.value.isNotEmpty;
      } else {
        // For Saudi, require all fields
        return nameController.text.trim().isNotEmpty &&
            phoneController.text.trim().isNotEmpty &&
            vinController.text.trim().isNotEmpty &&
            brand.value.isNotEmpty &&
            model.value.isNotEmpty &&
            year.value.isNotEmpty &&
            saudiPlateNumber.value.isNotEmpty;
      }
    }
  }

  final Map<String, Map<String, dynamic>> countryCodeMap = {
    // A
    '+93': {'index': 0, 'code': 'AF', 'length': 9}, // Afghanistan
    '+355': {'index': 1, 'code': 'AL', 'length': 9}, // Albania
    '+213': {'index': 2, 'code': 'DZ', 'length': 9}, // Algeria
    '+1684': {'index': 3, 'code': 'AS', 'length': 10}, // American Samoa
    '+376': {'index': 4, 'code': 'AD', 'length': 6}, // Andorra
    '+244': {'index': 5, 'code': 'AO', 'length': 9}, // Angola
    '+1264': {'index': 6, 'code': 'AI', 'length': 10}, // Anguilla
    '+1268': {'index': 7, 'code': 'AG', 'length': 10}, // Antigua and Barbuda
    '+54': {'index': 8, 'code': 'AR', 'length': 10}, // Argentina
    '+374': {'index': 9, 'code': 'AM', 'length': 8}, // Armenia
    '+297': {'index': 10, 'code': 'AW', 'length': 7}, // Aruba
    '+61': {'index': 11, 'code': 'AU', 'length': 9}, // Australia
    '+43': {'index': 12, 'code': 'AT', 'length': 10}, // Austria
    '+994': {'index': 13, 'code': 'AZ', 'length': 9}, // Azerbaijan

    // B
    '+1242': {'index': 14, 'code': 'BS', 'length': 10}, // Bahamas
    '+973': {'index': 15, 'code': 'BH', 'length': 8}, // Bahrain
    '+880': {'index': 16, 'code': 'BD', 'length': 10}, // Bangladesh
    '+1246': {'index': 17, 'code': 'BB', 'length': 10}, // Barbados
    '+375': {'index': 18, 'code': 'BY', 'length': 9}, // Belarus
    '+32': {'index': 19, 'code': 'BE', 'length': 9}, // Belgium
    '+501': {'index': 20, 'code': 'BZ', 'length': 7}, // Belize
    '+229': {'index': 21, 'code': 'BJ', 'length': 8}, // Benin
    '+1441': {'index': 22, 'code': 'BM', 'length': 10}, // Bermuda
    '+975': {'index': 23, 'code': 'BT', 'length': 8}, // Bhutan
    '+591': {'index': 24, 'code': 'BO', 'length': 8}, // Bolivia
    '+387': {'index': 25, 'code': 'BA', 'length': 8}, // Bosnia and Herzegovina
    '+267': {'index': 26, 'code': 'BW', 'length': 8}, // Botswana
    '+55': {'index': 27, 'code': 'BR', 'length': 11}, // Brazil
    '+673': {'index': 28, 'code': 'BN', 'length': 7}, // Brunei
    '+359': {'index': 29, 'code': 'BG', 'length': 9}, // Bulgaria
    '+226': {'index': 30, 'code': 'BF', 'length': 8}, // Burkina Faso
    '+257': {'index': 31, 'code': 'BI', 'length': 8}, // Burundi

    // C
    '+855': {'index': 32, 'code': 'KH', 'length': 9}, // Cambodia
    '+237': {'index': 33, 'code': 'CM', 'length': 9}, // Cameroon
    '+1': {'index': 34, 'code': 'CA', 'length': 10}, // Canada
    '+238': {'index': 35, 'code': 'CV', 'length': 7}, // Cape Verde
    '+1345': {'index': 36, 'code': 'KY', 'length': 10}, // Cayman Islands
    '+236': {
      'index': 37,
      'code': 'CF',
      'length': 8
    }, // Central African Republic
    '+235': {'index': 38, 'code': 'TD', 'length': 8}, // Chad
    '+56': {'index': 39, 'code': 'CL', 'length': 9}, // Chile
    '+86': {'index': 40, 'code': 'CN', 'length': 11}, // China
    '+57': {'index': 41, 'code': 'CO', 'length': 10}, // Colombia
    '+269': {'index': 42, 'code': 'KM', 'length': 7}, // Comoros
    '+242': {'index': 43, 'code': 'CG', 'length': 9}, // Congo
    '+243': {'index': 44, 'code': 'CD', 'length': 9}, // Congo (DRC)
    '+682': {'index': 45, 'code': 'CK', 'length': 5}, // Cook Islands
    '+506': {'index': 46, 'code': 'CR', 'length': 8}, // Costa Rica
    '+225': {'index': 47, 'code': 'CI', 'length': 10}, // Côte d'Ivoire
    '+385': {'index': 48, 'code': 'HR', 'length': 9}, // Croatia
    '+53': {'index': 49, 'code': 'CU', 'length': 8}, // Cuba
    '+599': {'index': 50, 'code': 'CW', 'length': 8}, // Curaçao
    '+357': {'index': 51, 'code': 'CY', 'length': 8}, // Cyprus
    '+420': {'index': 52, 'code': 'CZ', 'length': 9}, // Czech Republic

    // D
    '+45': {'index': 53, 'code': 'DK', 'length': 8}, // Denmark
    '+253': {'index': 54, 'code': 'DJ', 'length': 8}, // Djibouti
    '+1767': {'index': 55, 'code': 'DM', 'length': 10}, // Dominica
    '+1809': {'index': 56, 'code': 'DO', 'length': 10}, // Dominican Republic
    '+1829': {'index': 57, 'code': 'DO', 'length': 10}, // Dominican Republic
    '+1849': {'index': 58, 'code': 'DO', 'length': 10}, // Dominican Republic

    // E
    '+593': {'index': 59, 'code': 'EC', 'length': 9}, // Ecuador
    '+20': {'index': 60, 'code': 'EG', 'length': 10}, // Egypt
    '+503': {'index': 61, 'code': 'SV', 'length': 8}, // El Salvador
    '+240': {'index': 62, 'code': 'GQ', 'length': 9}, // Equatorial Guinea
    '+291': {'index': 63, 'code': 'ER', 'length': 7}, // Eritrea
    '+372': {'index': 64, 'code': 'EE', 'length': 8}, // Estonia
    '+251': {'index': 65, 'code': 'ET', 'length': 9}, // Ethiopia

    // F
    '+500': {'index': 66, 'code': 'FK', 'length': 5}, // Falkland Islands
    '+298': {'index': 67, 'code': 'FO', 'length': 6}, // Faroe Islands
    '+679': {'index': 68, 'code': 'FJ', 'length': 7}, // Fiji
    '+358': {'index': 69, 'code': 'FI', 'length': 10}, // Finland
    '+33': {'index': 70, 'code': 'FR', 'length': 9}, // France
    '+594': {'index': 71, 'code': 'GF', 'length': 9}, // French Guiana
    '+689': {'index': 72, 'code': 'PF', 'length': 6}, // French Polynesia

    // G
    '+241': {'index': 73, 'code': 'GA', 'length': 7}, // Gabon
    '+220': {'index': 74, 'code': 'GM', 'length': 7}, // Gambia
    '+995': {'index': 75, 'code': 'GE', 'length': 9}, // Georgia
    '+49': {'index': 76, 'code': 'DE', 'length': 10}, // Germany
    '+233': {'index': 77, 'code': 'GH', 'length': 9}, // Ghana
    '+350': {'index': 78, 'code': 'GI', 'length': 8}, // Gibraltar
    '+30': {'index': 79, 'code': 'GR', 'length': 10}, // Greece
    '+299': {'index': 80, 'code': 'GL', 'length': 6}, // Greenland
    '+1473': {'index': 81, 'code': 'GD', 'length': 10}, // Grenada
    '+590': {'index': 82, 'code': 'GP', 'length': 9}, // Guadeloupe
    '+1671': {'index': 83, 'code': 'GU', 'length': 10}, // Guam
    '+502': {'index': 84, 'code': 'GT', 'length': 8}, // Guatemala
    '+224': {'index': 85, 'code': 'GN', 'length': 9}, // Guinea
    '+245': {'index': 86, 'code': 'GW', 'length': 9}, // Guinea-Bissau
    '+592': {'index': 87, 'code': 'GY', 'length': 7}, // Guyana

    // H
    '+509': {'index': 88, 'code': 'HT', 'length': 8}, // Haiti
    '+504': {'index': 89, 'code': 'HN', 'length': 8}, // Honduras
    '+852': {'index': 90, 'code': 'HK', 'length': 8}, // Hong Kong
    '+36': {'index': 91, 'code': 'HU', 'length': 9}, // Hungary

    // I
    '+354': {'index': 92, 'code': 'IS', 'length': 7}, // Iceland
    '+91': {'index': 93, 'code': 'IN', 'length': 10}, // India
    '+62': {'index': 94, 'code': 'ID', 'length': 10}, // Indonesia
    '+98': {'index': 95, 'code': 'IR', 'length': 10}, // Iran
    '+964': {'index': 96, 'code': 'IQ', 'length': 10}, // Iraq
    '+353': {'index': 97, 'code': 'IE', 'length': 9}, // Ireland
    '+972': {'index': 98, 'code': 'IL', 'length': 9}, // Israel
    '+39': {'index': 99, 'code': 'IT', 'length': 10}, // Italy

    // J
    '+1876': {'index': 100, 'code': 'JM', 'length': 10}, // Jamaica
    '+81': {'index': 101, 'code': 'JP', 'length': 10}, // Japan
    '+962': {'index': 102, 'code': 'JO', 'length': 9}, // Jordan

    // K
    '+7': {'index': 103, 'code': 'KZ', 'length': 10}, // Kazakhstan
    '+254': {'index': 104, 'code': 'KE', 'length': 10}, // Kenya
    '+686': {'index': 105, 'code': 'KI', 'length': 8}, // Kiribati
    '+383': {'index': 106, 'code': 'XK', 'length': 8}, // Kosovo
    '+965': {'index': 107, 'code': 'KW', 'length': 8}, // Kuwait
    '+996': {'index': 108, 'code': 'KG', 'length': 9}, // Kyrgyzstan

    // L
    '+856': {'index': 109, 'code': 'LA', 'length': 9}, // Laos
    '+371': {'index': 110, 'code': 'LV', 'length': 8}, // Latvia
    '+961': {'index': 111, 'code': 'LB', 'length': 8}, // Lebanon
    '+266': {'index': 112, 'code': 'LS', 'length': 8}, // Lesotho
    '+231': {'index': 113, 'code': 'LR', 'length': 8}, // Liberia
    '+218': {'index': 114, 'code': 'LY', 'length': 10}, // Libya
    '+423': {'index': 115, 'code': 'LI', 'length': 7}, // Liechtenstein
    '+370': {'index': 116, 'code': 'LT', 'length': 8}, // Lithuania
    '+352': {'index': 117, 'code': 'LU', 'length': 9}, // Luxembourg

    // M
    '+853': {'index': 118, 'code': 'MO', 'length': 8}, // Macau
    '+389': {'index': 119, 'code': 'MK', 'length': 8}, // North Macedonia
    '+261': {'index': 120, 'code': 'MG', 'length': 9}, // Madagascar
    '+265': {'index': 121, 'code': 'MW', 'length': 9}, // Malawi
    '+60': {'index': 122, 'code': 'MY', 'length': 9}, // Malaysia
    '+960': {'index': 123, 'code': 'MV', 'length': 7}, // Maldives
    '+223': {'index': 124, 'code': 'ML', 'length': 8}, // Mali
    '+356': {'index': 125, 'code': 'MT', 'length': 8}, // Malta
    '+692': {'index': 126, 'code': 'MH', 'length': 7}, // Marshall Islands
    '+596': {'index': 127, 'code': 'MQ', 'length': 9}, // Martinique
    '+222': {'index': 128, 'code': 'MR', 'length': 8}, // Mauritania
    '+230': {'index': 129, 'code': 'MU', 'length': 8}, // Mauritius
    '+262': {'index': 130, 'code': 'YT', 'length': 9}, // Mayotte
    '+52': {'index': 131, 'code': 'MX', 'length': 10}, // Mexico
    '+691': {'index': 132, 'code': 'FM', 'length': 7}, // Micronesia
    '+373': {'index': 133, 'code': 'MD', 'length': 8}, // Moldova
    '+377': {'index': 134, 'code': 'MC', 'length': 8}, // Monaco
    '+976': {'index': 135, 'code': 'MN', 'length': 8}, // Mongolia
    '+382': {'index': 136, 'code': 'ME', 'length': 8}, // Montenegro
    '+1664': {'index': 137, 'code': 'MS', 'length': 10}, // Montserrat
    '+212': {'index': 138, 'code': 'MA', 'length': 9}, // Morocco
    '+258': {'index': 139, 'code': 'MZ', 'length': 9}, // Mozambique
    '+95': {'index': 140, 'code': 'MM', 'length': 9}, // Myanmar

    // N
    '+264': {'index': 141, 'code': 'NA', 'length': 9}, // Namibia
    '+674': {'index': 142, 'code': 'NR', 'length': 7}, // Nauru
    '+977': {'index': 143, 'code': 'NP', 'length': 10}, // Nepal
    '+31': {'index': 144, 'code': 'NL', 'length': 9}, // Netherlands
    '+687': {'index': 145, 'code': 'NC', 'length': 6}, // New Caledonia
    '+64': {'index': 146, 'code': 'NZ', 'length': 9}, // New Zealand
    '+505': {'index': 147, 'code': 'NI', 'length': 8}, // Nicaragua
    '+227': {'index': 148, 'code': 'NE', 'length': 8}, // Niger
    '+234': {'index': 149, 'code': 'NG', 'length': 10}, // Nigeria
    '+850': {'index': 150, 'code': 'KP', 'length': 10}, // North Korea
    '+1670': {
      'index': 151,
      'code': 'MP',
      'length': 10
    }, // Northern Mariana Islands
    '+47': {'index': 152, 'code': 'NO', 'length': 8}, // Norway

    // O
    '+968': {'index': 153, 'code': 'OM', 'length': 8}, // Oman

    // P
    '+92': {'index': 154, 'code': 'PK', 'length': 10}, // Pakistan
    '+680': {'index': 155, 'code': 'PW', 'length': 7}, // Palau
    '+970': {'index': 156, 'code': 'PS', 'length': 9}, // Palestine
    '+507': {'index': 157, 'code': 'PA', 'length': 8}, // Panama
    '+675': {'index': 158, 'code': 'PG', 'length': 8}, // Papua New Guinea
    '+595': {'index': 159, 'code': 'PY', 'length': 9}, // Paraguay
    '+51': {'index': 160, 'code': 'PE', 'length': 9}, // Peru
    '+63': {'index': 161, 'code': 'PH', 'length': 10}, // Philippines
    '+48': {'index': 162, 'code': 'PL', 'length': 9}, // Poland
    '+351': {'index': 163, 'code': 'PT', 'length': 9}, // Portugal
    '+1787': {'index': 164, 'code': 'PR', 'length': 10}, // Puerto Rico
    '+1939': {'index': 165, 'code': 'PR', 'length': 10}, // Puerto Rico

    // Q
    '+974': {'index': 166, 'code': 'QA', 'length': 8}, // Qatar

    // R
    '+40': {'index': 168, 'code': 'RO', 'length': 10}, // Romania
    '+250': {'index': 170, 'code': 'RW', 'length': 9}, // Rwanda

    // S
    '+290': {'index': 172, 'code': 'SH', 'length': 4}, // Saint Helena
    '+1869': {
      'index': 173,
      'code': 'KN',
      'length': 10
    }, // Saint Kitts and Nevis
    '+1758': {'index': 174, 'code': 'LC', 'length': 10}, // Saint Lucia
    '+508': {
      'index': 176,
      'code': 'PM',
      'length': 6
    }, // Saint Pierre and Miquelon
    '+1784': {
      'index': 177,
      'code': 'VC',
      'length': 10
    }, // Saint Vincent and the Grenadines
    '+685': {'index': 178, 'code': 'WS', 'length': 7}, // Samoa
    '+378': {'index': 179, 'code': 'SM', 'length': 10}, // San Marino
    '+239': {'index': 180, 'code': 'ST', 'length': 7}, // São Tomé and Príncipe
    '+966': {'index': 181, 'code': 'SA', 'length': 9}, // Saudi Arabia
    '+221': {'index': 182, 'code': 'SN', 'length': 9}, // Senegal
    '+381': {'index': 183, 'code': 'RS', 'length': 9}, // Serbia
    '+248': {'index': 184, 'code': 'SC', 'length': 7}, // Seychelles
    '+232': {'index': 185, 'code': 'SL', 'length': 8}, // Sierra Leone
    '+65': {'index': 186, 'code': 'SG', 'length': 8}, // Singapore
    '+1721': {'index': 187, 'code': 'SX', 'length': 10}, // Sint Maarten
    '+421': {'index': 188, 'code': 'SK', 'length': 9}, // Slovakia
    '+386': {'index': 189, 'code': 'SI', 'length': 8}, // Slovenia
    '+677': {'index': 190, 'code': 'SB', 'length': 7}, // Solomon Islands
    '+252': {'index': 191, 'code': 'SO', 'length': 8}, // Somalia
    '+27': {'index': 192, 'code': 'ZA', 'length': 9}, // South Africa
    '+82': {'index': 193, 'code': 'KR', 'length': 10}, // South Korea
    '+211': {'index': 194, 'code': 'SS', 'length': 9}, // South Sudan
    '+34': {'index': 195, 'code': 'ES', 'length': 9}, // Spain
    '+94': {'index': 196, 'code': 'LK', 'length': 9}, // Sri Lanka
    '+249': {'index': 197, 'code': 'SD', 'length': 9}, // Sudan
    '+597': {'index': 198, 'code': 'SR', 'length': 7}, // Suriname
    '+268': {'index': 199, 'code': 'SZ', 'length': 8}, // Eswatini (Swaziland)
    '+46': {'index': 200, 'code': 'SE', 'length': 9}, // Sweden
    '+41': {'index': 201, 'code': 'CH', 'length': 9}, // Switzerland
    '+963': {'index': 202, 'code': 'SY', 'length': 9}, // Syria

    // T
    '+886': {'index': 203, 'code': 'TW', 'length': 9}, // Taiwan
    '+992': {'index': 204, 'code': 'TJ', 'length': 9}, // Tajikistan
    '+255': {'index': 205, 'code': 'TZ', 'length': 9}, // Tanzania
    '+66': {'index': 206, 'code': 'TH', 'length': 9}, // Thailand
    '+670': {'index': 207, 'code': 'TL', 'length': 8}, // Timor-Leste
    '+228': {'index': 208, 'code': 'TG', 'length': 8}, // Togo
    '+690': {'index': 209, 'code': 'TK', 'length': 4}, // Tokelau
    '+676': {'index': 210, 'code': 'TO', 'length': 5}, // Tonga
    '+1868': {'index': 211, 'code': 'TT', 'length': 10}, // Trinidad and Tobago
    '+216': {'index': 212, 'code': 'TN', 'length': 8}, // Tunisia
    '+90': {'index': 213, 'code': 'TR', 'length': 10}, // Turkey
    '+993': {'index': 214, 'code': 'TM', 'length': 8}, // Turkmenistan
    '+1649': {
      'index': 215,
      'code': 'TC',
      'length': 10
    }, // Turks and Caicos Islands
    '+688': {'index': 216, 'code': 'TV', 'length': 6}, // Tuvalu

    // U
    '+256': {'index': 217, 'code': 'UG', 'length': 9}, // Uganda
    '+380': {'index': 218, 'code': 'UA', 'length': 9}, // Ukraine
    '+971': {'index': 219, 'code': 'AE', 'length': 9}, // United Arab Emirates
    '+44': {'index': 220, 'code': 'GB', 'length': 10}, // United Kingdom
    '+598': {'index': 222, 'code': 'UY', 'length': 8}, // Uruguay
    '+998': {'index': 223, 'code': 'UZ', 'length': 9}, // Uzbekistan

    // V
    '+678': {'index': 224, 'code': 'VU', 'length': 7}, // Vanuatu
    '+379': {'index': 225, 'code': 'VA', 'length': 10}, // Vatican City
    '+58': {'index': 226, 'code': 'VE', 'length': 10}, // Venezuela
    '+84': {'index': 227, 'code': 'VN', 'length': 9}, // Vietnam
    '+1284': {
      'index': 228,
      'code': 'VG',
      'length': 10
    }, // British Virgin Islands
    '+1340': {'index': 229, 'code': 'VI', 'length': 10}, // U.S. Virgin Islands

    // W
    '+681': {'index': 230, 'code': 'WF', 'length': 6}, // Wallis and Futuna

    // Y
    '+967': {'index': 231, 'code': 'YE', 'length': 9}, // Yemen

    // Z
    '+260': {'index': 232, 'code': 'ZM', 'length': 9}, // Zambia
    '+263': {'index': 233, 'code': 'ZW', 'length': 9}, // Zimbabwe
  };
}
