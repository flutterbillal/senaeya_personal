import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/auth_screens/signup_worshop/model/create_workshop_check_model.dart';
import 'package:Senaeya/View/Screens/auth_screens/signup_worshop/model/sign_up_model.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../../Helper/shared_prefe/shared_prefe.dart';
import '../../../../../Utils/AppLog/app_log.dart';
import '../../../../Widgegts/map_location_picker_dialog/map_location_picker_dialog.dart';
import '../repo/signup_workshop_repo.dart';

class SignupWorkshopController extends GetxController {
  final SignupWorkshopRepo _repo = SignupWorkshopRepo();
  final formKey = GlobalKey<FormState>();

  // Text controllers for all fields
  final workshopNameController = TextEditingController();
  final workshopNameArabicController = TextEditingController();
  final workshopContact = TextEditingController();
  final nationalNumberController = TextEditingController();
  final registrationNumberController = TextEditingController();
  final licenseNumberController = TextEditingController();
  final addressController = TextEditingController();
  final taxNumberController = TextEditingController();
  final ibanController = TextEditingController();
  RxBool isLoading = false.obs;
  Rxn<CreateWorkShopCheckingModel> createWorkShopCheckingModel =
      Rxn<CreateWorkShopCheckingModel>();

  // Checkbox for mobile workshop
  var isMobileWorkshop = false.obs;

  // Working hours
  var regularDayFrom = 'saturday'.obs;
  var regularDayTo = 'thursday'.obs;
  var regularFrom = const TimeOfDay(hour: 8, minute: 0).obs;
  var regularTo = const TimeOfDay(hour: 20, minute: 0).obs;

  var ramadanDayFrom = 'saturday'.obs;
  var ramadanDayTo = 'thursday'.obs;
  var ramadanFrom = const TimeOfDay(hour: 13, minute: 0).obs;
  var ramadanTo = const TimeOfDay(hour: 1, minute: 0).obs;

  // Location
  var isLocationAdded = false.obs;
  LatLng? selectedLocation;
  var locationAddress = ''.obs;

  // Validation
  RxBool isFormValid = false.obs;

  // Validation error messages
  var unnError = ''.obs;
  var mlnError = ''.obs;
  var taxVatError = ''.obs;
  var crnError = ''.obs;
  var ibanError = ''.obs;

  // Validation methods
  bool validateUNN(String value) {
    if (value.isEmpty) {
      unnError.value = 'UNN is required'.tr;
      return false;
    }
    if (value.length != 10) {
      unnError.value = 'UNN must be 10 digits'.tr;
      return false;
    }
    if (!value.startsWith('7')) {
      unnError.value = 'UNN must start with 7'.tr;
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      unnError.value = 'UNN must contain only digits'.tr;
      return false;
    }
    unnError.value = '';
    return true;
  }

  bool validateCRN(String value) {
    if (value.isEmpty) {
      crnError.value = 'CRN is required'.tr;
      return false;
    }
    if (value.length != 10) {
      crnError.value = 'CRN must be exactly 10 digits'.tr;
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      crnError.value = 'CRN must contain only digits'.tr;
      return false;
    }
    crnError.value = '';
    return true;
  }

  bool validateMLN(String value) {
    if (value.isEmpty) {
      mlnError.value = 'MLN is required'.tr;
      return false;
    }
    if (value.length != 11 && value.length != 12) {
      mlnError.value = 'MLN must be 11/12 digits'.tr;
      return false;
    }
    if (!value.startsWith('4')) {
      mlnError.value = 'MLN must start with 4'.tr;
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      mlnError.value = 'MLN must contain only digits'.tr;
      return false;
    }
    mlnError.value = '';
    return true;
  }

  bool validateTaxVAT(String value) {
    if (value.isEmpty) {
      taxVatError.value = '';
      return true;
    }
    if (value.length != 15) {
      taxVatError.value = 'Tax/VAT must be 15 digits'.tr;
      return false;
    }
    if (!value.startsWith('3')) {
      taxVatError.value = 'Tax/VAT must start with 3'.tr;
      return false;
    }
    if (!value.endsWith('3')) {
      taxVatError.value = 'Tax/VAT must end with 3'.tr;
      return false;
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      taxVatError.value = 'Tax/VAT must contain only digits'.tr;
      return false;
    }
    taxVatError.value = '';
    return true;
  }

  bool validateIBAN(String value) {
    // If empty or just "SA", it's valid (optional field)
    if (value.isEmpty || value.trim().toUpperCase() == 'SA') {
      ibanError.value = '';
      return true;
    }
    // If user entered something, validate it
    if (value.length != 24) {
      ibanError.value = 'IBAN must be exactly 24 characters'.tr;
      return false;
    }
    if (!value.toUpperCase().startsWith('SA')) {
      ibanError.value = 'IBAN must start with SA'.tr;
      return false;
    }
    ibanError.value = '';
    return true;
  }

  void validateForm() {
    bool isUNNValid = validateUNN(nationalNumberController.text);
    // bool isCRNValid = validateCRN(registrationNumberController.text);
    bool isMLNValid = validateMLN(licenseNumberController.text);
    bool isTaxVATValid = validateTaxVAT(taxNumberController.text);
    bool isIBANValid = validateIBAN(ibanController.text);

    isFormValid.value = workshopNameController.text.isNotEmpty &&
        workshopNameArabicController.text.isNotEmpty &&
        // workshopContact is optional or not present in the UI, so don't require it here
        isUNNValid &&
        // isCRNValid &&
        isMLNValid &&
        addressController.text.isNotEmpty &&
        isTaxVATValid &&
        isIBANValid;
  }

  void onTapSubmit() {
    // First, run Form validators to show inline errors (safe since this is a user action)
    final isFormStateValid = formKey.currentState?.validate() ?? false;

    // Run controller's logical validation to ensure all rules are satisfied
    validateForm();

    if (isFormStateValid && isFormValid.value) {
      checkWorkshopBeforeSubmit();
    } else {
      showCustomSnackBar("please_fill_all_required_fields".tr, isError: true);
    }
  }

  // Add workshop location
  Future<void> addLocation() async {
    try {
      // Check if location services are enabled
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      // print("serviceEnabled $serviceEnabled");

      if (!serviceEnabled) {
        showCustomSnackBar(
          'location_services_disabled'.tr,
          isError: true,
        );
        return;
      }

      // Check location permission
      PermissionStatus permission = await Permission.location.status;

      // Request permission if denied
      if (permission.isDenied) {
        permission = await Permission.location.request();
      }

      // Handle permanently denied permission
      if (permission.isPermanentlyDenied) {
        showCustomSnackBar(
          'location_permission_permanently_denied'.tr,
          isError: true,
        );

        await openAppSettings();
        return;
      }

      // Handle restricted permission
      if (permission.isRestricted) {
        showCustomSnackBar(
          'location_permission_required'.tr,
          isError: true,
        );
        return;
      }

      // Handle denied permission
      if (!permission.isGranted && !permission.isLimited) {
        showCustomSnackBar(
          'location_permission_required'.tr,
          isError: true,
        );
        return;
      }

      // Show map dialog
      Get.dialog(
        MapLocationPickerDialog(
          initialLocation: selectedLocation,
          onLocationSelected: (location, address) {
            selectedLocation = location;
            locationAddress.value = address;
            isLocationAdded.value = true;

            showCustomSnackBar(
              'location_selected_successfully'.tr,
              isError: false,
            );
          },
        ),
        barrierDismissible: false,
      );
    } catch (e) {
      debugPrint('Add Location Error: $e');

      showCustomSnackBar(
        'location_permission_required'.tr,
        isError: true,
      );
    }
  }

  // Check workshop before submitting
  Future<void> checkWorkshopBeforeSubmit() async {
    if (selectedLocation == null) {
      showCustomSnackBar('please_add_workshop_location'.tr, isError: true);
      return;
    }

    isLoading.value = true;

    try {
      // Use empty string for tax if not provided (for checking API)
      String taxValue = taxNumberController.text.trim();

      final createWorkshopChecking = await _repo.checkingWorkshoisCreatedOrNot(
        mln: licenseNumberController.text.trim(),
        crn: nationalNumberController.text.trim(),
        unn: nationalNumberController.text.trim(),
        tax: taxValue,
      );

      isLoading.value = false;

      if (createWorkshopChecking.success == true) {
        final data = createWorkshopChecking.data;

        // Check if workshop exists by MLN
        if (data?.isExistWorkshopByMln == true) {
          String mln = licenseNumberController.text.trim();
          // String maskedMln = mln.isNotEmpty
          //     ? mln[0] + 'x' * (mln.length - 1)
          //     : mln;

          CustomAlert.showInfo(
            context: Get.context!,
            message:
                'workshop_already_exists_with_mln'.tr.replaceAll('{mln}', mln),
            onPressed: () {
              Get.back();
            },
          );
          return;
        }

        // Check if any other field is duplicate
        bool hasDuplicates = data?.isExistWorkshopByCrn == true ||
            data?.isExistWorkshopByTax == true ||
            data?.isExistWorkshopByUnn == true;

        if (hasDuplicates) {
          // Build duplicate message with translated field names
          List<String> duplicateFields = [];
          if (data?.isExistWorkshopByCrn == true) {
            duplicateFields.add('commercial_registration_number_crn'.tr);
          }
          if (data?.isExistWorkshopByTax == true) {
            duplicateFields.add('tax_vat_number'.tr);
          }
          if (data?.isExistWorkshopByUnn == true) {
            duplicateFields.add('unified_national_number_unn'.tr);
          }

          String duplicateMessage = 'duplicate_data_message'
              .tr
              .replaceAll('{fields}', duplicateFields.join(', '));

          CustomAlert.showConfirmation(
            context: Get.context!,
            message: duplicateMessage,
            yesButtonText: 'yes_continue'.tr,
            noButtonText: 'no_edit'.tr,
            onYesPressed: () {
              Get.back();
              submit();
            },
            onNoPressed: () {
              Get.back();
            },
          );
        } else {
          // No duplicates, proceed with submission
          submit();
        }
      } else {
        showCustomSnackBar(
          createWorkshopChecking.message ?? 'Failed to check workshop data',
          isError: true,
        );
      }
    } catch (e) {
      isLoading.value = false;
      showCustomSnackBar('error_occurred'.tr, isError: true);
      debugPrint('Error checking workshop: $e');
    }
  }

  // Submit
  Future<void> submit() async {
    isLoading.value = true;

    try {
      // Prepare workshop location data
      Map<String, dynamic> workshopGEOlocation = {
        "type": "Point",
        "coordinates": [
          selectedLocation!.longitude,
          selectedLocation!.latitude,
        ],
      };

      // Prepare regular working schedule
      Map<String, dynamic> regularWorkingSchedule = {
        "startDay": regularDayFrom.value.capitalize,
        "endDay": regularDayTo.value.capitalize,
        "startTime": _formatTime(regularFrom.value),
        "endTime": _formatTime(regularTo.value),
      };

      // Prepare ramadan working schedule
      Map<String, dynamic> ramadanWorkingSchedule = {
        "startDay": ramadanDayFrom.value.capitalize,
        "endDay": ramadanDayTo.value.capitalize,
        "startTime": _formatTime(ramadanFrom.value),
        "endTime": _formatTime(ramadanTo.value),
      };

      // Prepare optional fields
      String? taxVatNumber = taxNumberController.text.trim().isEmpty
          ? null
          : taxNumberController.text.trim();

      String? bankAccountNumber;
      String ibanValue = ibanController.text.trim().toUpperCase();
      if (ibanValue.isEmpty || ibanValue == 'SA') {
        bankAccountNumber = null;
      } else {
        bankAccountNumber = ibanValue;
      }

      // Call API
      final response = await _repo.createWorkshop(
        workshopNameEnglish: workshopNameController.text.trim(),
        workshopNameArabic: workshopNameArabicController.text.trim(),
        contact: workshopContact.text.trim(),
        unn: nationalNumberController.text.trim(),
        crn: nationalNumberController.text.trim(),
        mln: licenseNumberController.text.trim(),
        address: addressController.text.trim(),
        taxVatNumber: taxVatNumber,
        bankAccountNumber: bankAccountNumber,
        isAvailableMobileWorkshop: isMobileWorkshop.value,
        workshopGEOlocation: workshopGEOlocation,
        regularWorkingSchedule: regularWorkingSchedule,
        ramadanWorkingSchedule: ramadanWorkingSchedule,
      );

      isLoading.value = false;

      if (response.statusCode == 200 || response.statusCode == 201) {
        // String workshopId = response.body['data']['_id'];
        // appLog('Workshop created with ID: $workshopId');
        // await SharePrefsHelper.setString(SharedPreferenceValue.workshopId, workshopId);
        showCustomSnackBar(
          'workshop_registered_successfully'.tr,
          isError: false,
        );

        try {
          appLog('Response body: ${response.body}');
          GetWorkShop getWorkShop = GetWorkShop.fromRawJson(response.body);
          String workshopId = getWorkShop.data?.id ?? '';
          debugPrint('Workshop ID: $workshopId');
          await SharePrefsHelper.setString(
            SharedPreferenceValue.workshopId,
            workshopId,
          );
          await SharePrefsHelper.setString(
            SharedPreferenceValue.role,
            'WORKSHOP_OWNER',
          );

          Get.offAllNamed(
            AppRoute.navScreen,
          );
        } catch (parseError) {
          debugPrint('Parse error: $parseError');
          showCustomSnackBar('Failed to parse workshop data', isError: true);
        }
      } else {
        showCustomSnackBar(
          response.body['message'] ?? 'failed_to_register_workshop'.tr,
          isError: true,
        );
      }
    } catch (e) {
      isLoading.value = false;
      showCustomSnackBar('error_occurred'.tr, isError: true);
      debugPrint('Error creating workshop: $e');
    }
  }

  // Helper method to format time
  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  void onInit() {
    super.onInit();
    // Initialize IBAN with "SA" prefix
    ibanController.text = 'SA';
    ibanController.selection = TextSelection.fromPosition(
      TextPosition(offset: ibanController.text.length),
    );

    workshopNameController.addListener(validateForm);
    workshopNameArabicController.addListener(validateForm);
    nationalNumberController.addListener(validateForm);
    registrationNumberController.addListener(validateForm);
    licenseNumberController.addListener(validateForm);
    addressController.addListener(validateForm);
    taxNumberController.addListener(validateForm);
    ibanController.addListener(validateForm);
  }

  @override
  void onClose() {
    workshopNameController.dispose();
    workshopNameArabicController.dispose();
    nationalNumberController.dispose();
    registrationNumberController.dispose();
    licenseNumberController.dispose();
    addressController.dispose();
    taxNumberController.dispose();
    ibanController.dispose();
    super.onClose();
  }
}
