import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/View/Screens/invoice_summary_screen/model/invoice_details_response.dart';
import 'package:Senaeya/View/Screens/invoice_summary_screen/repo/invoice_summary_repo.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/ToastMsg/toast_message.dart';
import '../../../Widgegts/custom_text/custom_text.dart';

enum PayMethod { postpaid, transfer, card, cash }

class InvoiceSummaryController extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController idController = TextEditingController();

  // Received data from previous screen
  String clientId = '';
  String clientCarId = '';
  List<Map<String, dynamic>> workList = [];
  List<Map<String, dynamic>> sparePartsList = [];
  double discount = 0.0;

  // Brand and model information
  String brandId = '';
  String brandName = '';
  String modelId = '';
  String modelName = '';
  String year = '';
  String brandImage = '';

  // Client information
  String clientName = '';
  String clientPhone = '';

  // Saudi plate information - Make these observable
  var saudiPlateEnglishText = ''.obs;
  var saudiPlateArabicText = ''.obs;
  var inputEnglishPlateNumber = ''.obs;
  var inputArabicPlateNumber = ''.obs;
  var symbolImageForSaudiUrl = ''.obs;

  // International plate information - Make this observable
  var internationalPlateNumber = ''.obs;

  // Customer info
  var customerName = ''.obs;
  var customerPhone = ''.obs;

  // Car info
  var carBrand = ''.obs;
  var carModel = ''.obs;
  var carYear = ''.obs;
  var carPlate = ''.obs;
  var carPlateType = ''.obs;
  var carPlateCountry = ''.obs;

  // Costs
  var sparePartsCost = 0.0.obs;
  var workshopCost = 0.0.obs;
  double get totalAmountDue => sparePartsCost.value + workshopCost.value;
  String invoiceId = '';

  // Payment method - null by default (nothing selected)
  Rxn<PayMethod> payMethod = Rxn<PayMethod>(null);
  RxBool nextIsLoading = false.obs;
  RxBool saveIsLoading = false.obs;

  // Conditional fields - null by default (nothing selected)
  Rxn<bool> receiveCash = Rxn<bool>(null);
  var cardApprovalCode = ''.obs;
  Rxn<bool> receiveTransfer = Rxn<bool>(null);
  var postpaidDate = ''.obs;
  var postpaidDateForServer = ''.obs; // Format: YYYY-MM-DD for server
  dynamic costOfWorks = 0.0;
  dynamic costOfSpareParts = 0.0;

  @override
  void onInit() {
    super.onInit();

    // Receive data from navigation arguments
    if (Get.arguments != null) {
      // Check if invoiceId exists (coming from existing invoice)
      invoiceId = Get.arguments['invoiceId'] ?? '';

      // If invoiceId exists, fetch invoice details from server
      if (invoiceId.isNotEmpty) {
        getInvoiceById();
      } else {
        // Otherwise, receive all data from previous screen (new invoice)
        clientId = Get.arguments['clientId'] ?? '';
        clientCarId = Get.arguments['clientCarId'] ?? '';
        workList = Get.arguments['workList'] ?? [];
        sparePartsList = Get.arguments['sparePartsList'] ?? [];
        discount = Get.arguments['discount'] ?? 0.0;

        // Receive brand and model information
        brandId = Get.arguments['brandId'] ?? '';
        brandName = Get.arguments['brandName'] ?? '';
        modelId = Get.arguments['modelId'] ?? '';
        modelName = Get.arguments['modelName'] ?? '';
        year = Get.arguments['year'] ?? '';
        brandImage = Get.arguments['brandImage'] ?? '';

        // Receive client information
        clientName = Get.arguments['clientName'] ?? '';
        clientPhone = Get.arguments['clientPhone'] ?? '';

        // Receive Saudi plate information
        saudiPlateEnglishText.value =
            Get.arguments['saudiPlateEnglishText'] ?? '';
        saudiPlateArabicText.value =
            Get.arguments['saudiPlateArabicText'] ?? '';
        inputEnglishPlateNumber.value =
            Get.arguments['inputEnglishPlateNumber'] ?? '';
        inputArabicPlateNumber.value =
            Get.arguments['inputArabicPlateNumber'] ?? '';
        symbolImageForSaudiUrl.value =
            Get.arguments['symbolImageForSaudi'] ?? '';

        // Receive international plate information
        internationalPlateNumber.value =
            Get.arguments['internationalPlateNumber'] ?? '';
        costOfWorks = Get.arguments['costOfWorks'] ?? 0.0;
        costOfSpareParts = Get.arguments['costOfSpareParts'] ?? 0.0;

        sparePartsCost.value = (costOfSpareParts).toDouble();
        workshopCost.value = (costOfWorks).toDouble();

        // Populate display fields with received data
        customerName.value = clientName;
        customerPhone.value = clientPhone;
        nameController.text = clientName;
        idController.text = clientPhone;

        carBrand.value = brandName;
        carModel.value = modelName;
        carYear.value = year;

        // Set plate information based on type
        if (internationalPlateNumber.isNotEmpty) {
          carPlate = internationalPlateNumber;
          carPlateType.value = 'International';
        } else if (inputEnglishPlateNumber.isNotEmpty) {
          carPlate = inputEnglishPlateNumber;
          carPlateType.value = saudiPlateEnglishText.value;
        }

        print("Received clientId: $clientId");
        print("Received clientCarId: $clientCarId");
        print("Received workList: $workList");
        print("Received sparePartsList: $sparePartsList");
        print("Received discount: $discount");
        print("Received brandName: $brandName");
        print("Received clientName: $clientName");
        print("Received internationalPlateNumber: $internationalPlateNumber");
        print("Received inputEnglishPlateNumber: $inputEnglishPlateNumber");
        print("Received saudiPlateEnglishText: $saudiPlateEnglishText");
      }
    }
  }

  Rxn<InvoiceDetailsModel> invoiceDetails = Rxn<InvoiceDetailsModel>();

  ///Get invoice by id
  RxBool isLoading = false.obs;
  Future<void> getInvoiceById() async {
    isLoading.value = true;
    Response response =
        await InvoiceSummaryRepo().getInvoiceById(invoiceId: invoiceId);
    isLoading.value = false;
    if (response.statusCode == 200) {
      InvoiceDetailsModel invoice =
          InvoiceDetailsModel.fromJson(response.body['data']);
      invoiceDetails.value = invoice;
      sparePartsCost.value =
          ((invoice.totalCostOfSparePartsExcludingTax ?? 0)).toDouble();
      workshopCost.value = ((invoice.totalCostOfWorkShopExcludingTax ?? 0) +
              (invoice.taxAmount ?? 0) -
              (invoice.discount ?? 0))
          .toDouble();
      // Populate fields from invoice data
      _populateFieldsFromInvoice(invoice);
    } else {
      showCustomSnackBar(response.statusText ?? 'Unknown error occurred');
    }
  }

  /// if slelect postpaid
  void showYesNoDialog(
      {required BuildContext context,
      required VoidCallback onYes,
      required String title}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
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
                    maxLines: 4,
                    text: '$title'.tr,
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
                          onYes();
                          Navigator.of(ctx).pop();
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
        );
      },
    );
  }

  Future<void> onTapPostPaid() async {
    // Validate date is selected
    if (postpaidDateForServer.value.isEmpty) {
      showCustomSnackBar('Please select payment date'.tr);
      return;
    }

    nextIsLoading.value = true;
    Response response;

    // Check if creating new invoice or updating existing one
    if (invoiceId.isEmpty) {
      // Create new invoice
      response = await InvoiceSummaryRepo().createInvoice(
          clientName: clientName,
          clientId: clientId,
          carId: clientCarId,
          paymentMethod: 'postpaid',
          postPaymentDate:
              postpaidDateForServer.value, // Already in yyyy-MM-dd format
          isCashRecieved: false,
          isReleased: false,
          worksList: workList,
          sparePartsList: sparePartsList,
          discount: discount,
          cardApprovalCode: cardApprovalCode.value);
    } else {
      // Update existing invoice
      response = await InvoiceSummaryRepo().saveInvoice(
        invoiceId: invoiceId,
        paymentType: 'postpaid',
        isReleased: false,
        workList: workList,
        sparePartList: sparePartsList,
        discount: discount,
        isCashRecieved: false,
        carId: clientCarId,
        postPaymentDate:
            postpaidDateForServer.value, // Already in yyyy-MM-dd format
        clientId: clientId,
      );
    }

    nextIsLoading.value = false;
    if (response.statusCode == 200) {
      String qrCode = response.body['data']['webInvoiceQRLink'] ?? '';
      print("✅ Invoice created successfully");
      releaseInvoice(qrLink: qrCode);
    } else {
      showCustomSnackBar(response.statusText ?? 'Unknown error occurred');
    }
  }

  /// if slelect other payment methods
  // Future<void>onTapPostPayment()async{
  //   if (payMethod.value == null) return;
  //
  //   nextIsLoading.value = true;
  //   Response response = await InvoiceSummaryRepo().saveInvoice(
  //     invoiceId: invoiceId,
  //     paymentType: payMethod.value!.name,
  //     isReleased: false,
  //     workList: workList,
  //     sparePartList: sparePartsList,
  //     discount: discount,
  //     isCashRecieved: false,
  //     carId: clientCarId,
  //     postPaymentDate: '', // Empty string for non-postpaid methods
  //     clientId: clientId,
  //   );
  //   nextIsLoading.value = false;
  //   if(response.statusCode==200){
  //     saveInvoice();
  //   }else{
  //     showCustomSnackBar(response.statusText);
  //   }
  // }

  // Future<void>onTapReleases()async{
  //   if (payMethod.value == null) return;
  //
  //   saveIsLoading.value = true;
  //   Response response = await InvoiceSummaryRepo().saveInvoice(
  //     invoiceId: invoiceId,
  //     paymentType: payMethod.value!.name,
  //     isReleased: true,
  //     workList: workList,
  //     sparePartList: sparePartsList,
  //     discount: discount,
  //     isCashRecieved: true,
  //     carId: clientCarId,
  //     postPaymentDate: '', // Empty string for non-postpaid methods
  //     clientId: clientId,
  //   );
  //   saveIsLoading.value = false;
  //   if(response.statusCode==200){
  //     saveInvoice();
  //   }else{
  //     showCustomSnackBar(response.statusText);
  //   }
  // }

  Future<void> onTapRelease({bool saveLoading = false}) async {
    if (payMethod.value == null) return;

    saveLoading == false
        ? nextIsLoading.value = true
        : saveIsLoading.value = true;

    // Determine if cash/transfer was received based on payment method
    bool isCashReceived = false;
    if (payMethod.value == PayMethod.cash && receiveCash.value == true) {
      isCashReceived = true;
    } else if (payMethod.value == PayMethod.transfer &&
        receiveTransfer.value == true) {
      isCashReceived = true;
    } else if (payMethod.value == PayMethod.card &&
        cardApprovalCode.value.isNotEmpty) {
      isCashReceived =
          true; // Card approval code entered means payment received
    }

    Response saveResponse;

    // Check if creating new invoice or updating existing one
    // Determine isReleased based on payment method and required fields
    bool isReleased = false;
    if (payMethod.value == PayMethod.transfer) {
      isReleased = receiveTransfer.value == true;
    } else if (payMethod.value == PayMethod.card) {
      isReleased = cardApprovalCode.value.isNotEmpty;
    } else if (payMethod.value == PayMethod.cash) {
      isReleased = receiveCash.value == true;
    } else {
      // For other payment methods, keep previous logic or set as needed
      isReleased = true;
    }

    if (invoiceId.isEmpty) {
      // Create new invoice
      saveResponse = await InvoiceSummaryRepo().createInvoice(
          clientId: clientId,
          carId: clientCarId,
          paymentMethod: payMethod.value!.name,
          postPaymentDate: postpaidDateForServer.value.isNotEmpty
              ? postpaidDateForServer.value
              : '', // Use yyyy-MM-dd format or empty
          isCashRecieved: isCashReceived,
          isReleased: isReleased,
          worksList: workList,
          sparePartsList: sparePartsList,
          discount: discount,
          cardApprovalCode: cardApprovalCode.value,
          clientName: clientName);
    } else {
      // Update existing invoice
      saveResponse = await InvoiceSummaryRepo().makeThePayment(
        paymentMethod: payMethod.value!.name,
        invoiceId: invoiceId,
        cardApprovalCode: cardApprovalCode.value,
        isCashRecieved: isCashReceived,
        isRecievedTransfer: receiveTransfer.value,
        postPaymentDate: postpaidDate.value,
      );
    }

    if (saveResponse.statusCode == 200) {
      print("✅ Invoice created successfully");
      // Response response = await PreviousInvoicesRepo().payInvoice(invoiceId: invoiceId,paymentMethod: payMethod.value!.name,cardApprovalCode: cardApprovalCode.value);
      cardApprovalCode.value = '';
      saveLoading == false
          ? nextIsLoading.value = false
          : saveIsLoading.value = false;
      // if(response.statusCode==200){
      if (canSaveInvoice) {
        saveInvoice();
      } else {
        releaseInvoice(
            qrLink: saveResponse.body['data']['webInvoiceQRLink'] ?? '');
      }
      // }
      // }
    } else {
      showCustomSnackBar(saveResponse.statusText ?? 'Unknown error occurred');
    }
    saveLoading == false
        ? nextIsLoading.value = false
        : saveIsLoading.value = false;
  }

  void _populateFieldsFromInvoice(InvoiceDetailsModel invoice) {
    // Populate client and car IDs
    if (invoice.client?.id != null) {
      clientId = invoice.client!.id!;
    }
    if (invoice.car?.id != null) {
      clientCarId = invoice.car!.id!;
    }

    // Populate customer info (prefer nested client.clientId)
    // Handle both User and WorkShop clientType
    if (invoice.client?.clientId != null) {
      // User type: has nested clientId with name and contact
      customerName.value = invoice.client!.clientId!.name ?? 'N/A';
      customerPhone.value =
          invoice.client!.clientId!.contact ?? invoice.client?.contact ?? 'N/A';
    } else {
      // WorkShop type: has workShopNameAsClient and direct contact
      customerName.value = invoice.client?.workShopNameAsClient ??
          invoice.client?.contact ??
          'N/A';
      customerPhone.value = invoice.client?.contact ?? 'N/A';
    }
    nameController.text = customerName.value;
    idController.text = customerPhone.value;

    // Populate car info
    if (invoice.car != null) {
      // Handle brand - it's a dynamic type that could be a Map
      if (invoice.car!.brand != null) {
        if (invoice.car!.brand is Map<String, dynamic>) {
          carBrand.value =
              (invoice.car!.brand as Map<String, dynamic>)['title'] ?? 'N/A';
          brandId = (invoice.car!.brand as Map<String, dynamic>)['_id'] ?? '';
          brandName = carBrand.value;
          brandImage =
              (invoice.car!.brand as Map<String, dynamic>)['image'] ?? '';
        } else if (invoice.car!.brand is String) {
          carBrand.value = invoice.car!.brand as String;
          brandName = carBrand.value;
        } else {
          carBrand.value = 'N/A';
        }
      }

      carModel.value = invoice.car!.model?.title ?? 'N/A';
      modelName = carModel.value;
      modelId = invoice.car!.model?.id ?? '';

      carYear.value = invoice.car!.year ?? 'N/A';
      year = carYear.value;

      // Handle license plate
      if (invoice.car!.plateNumberForSaudi != null) {
        carPlate.value = invoice.car!.plateNumberForSaudi!.numberEnglish ?? '';
        inputEnglishPlateNumber.value =
            invoice.car!.plateNumberForSaudi!.numberEnglish ?? '';
        inputArabicPlateNumber.value =
            invoice.car!.plateNumberForSaudi!.numberArabic ?? '';

        if (invoice.car!.plateNumberForSaudi!.alphabetsCombinations != null &&
            invoice
                .car!.plateNumberForSaudi!.alphabetsCombinations!.isNotEmpty) {
          carPlateType.value =
              invoice.car!.plateNumberForSaudi!.alphabetsCombinations![0];
          saudiPlateEnglishText.value =
              invoice.car!.plateNumberForSaudi!.alphabetsCombinations![0];
        }

        if (invoice.car!.plateNumberForSaudi!.symbol?.image != null) {
          symbolImageForSaudiUrl.value =
              invoice.car!.plateNumberForSaudi!.symbol!.image ?? '';
        }
      } else if (invoice.car!.plateNumberForInternational != null) {
        internationalPlateNumber.value =
            invoice.car!.plateNumberForInternational ?? '';
      }
    }

    // Populate worksList
    if (invoice.worksList != null && invoice.worksList!.isNotEmpty) {
      workList.clear();
      for (var workItem in invoice.worksList!) {
        workList.add({
          "work": workItem.work?.id ?? '',
          "quantity": workItem.quantity ?? 0,
          "cost": (workItem.work?.cost ?? 0).toDouble(),
        });
      }
    }

    // Populate sparePartsList
    if (invoice.sparePartsList != null && invoice.sparePartsList!.isNotEmpty) {
      sparePartsList.clear();
      for (var spareItem in invoice.sparePartsList!) {
        sparePartsList.add({
          "itemName": spareItem.work?.title?.en ?? '',
          "quantity": spareItem.quantity ?? 0,
          "cost": (spareItem.work?.cost ?? 0).toDouble(),
          "code": spareItem.work?.id ?? '',
        });
      }
    }

    // Populate discount
    if (invoice.discount != null) {
      discount = invoice.discount!.toDouble();
    }

    // Costs are already populated in getInvoiceById, no need to set them again here

    // Populate payment method
    if (invoice.paymentMethod != null) {
      switch (invoice.paymentMethod!.toLowerCase()) {
        case 'postpaid':
          payMethod.value = PayMethod.postpaid;
          if (invoice.postPaymentDate != null) {
            postpaidDate.value =
                '${invoice.postPaymentDate!.day.toString().padLeft(2, '0')}-${invoice.postPaymentDate!.month.toString().padLeft(2, '0')}-${invoice.postPaymentDate!.year}';
            postpaidDateForServer.value =
                '${invoice.postPaymentDate!.year}-${invoice.postPaymentDate!.month.toString().padLeft(2, '0')}-${invoice.postPaymentDate!.day.toString().padLeft(2, '0')}'; // Convert to YYYY-MM-DD
          }
          break;
        case 'transfer':
          payMethod.value = PayMethod.transfer;
          break;
        case 'card':
          payMethod.value = PayMethod.card;
          break;
        case 'cash':
          payMethod.value = PayMethod.cash;
          break;
        default:
          payMethod.value = PayMethod.cash;
      }
    }
  }

  void releaseInvoice({String qrLink = ''}) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: CustomAlertDialog(
          image: qrLink.isNotEmpty
              ? Image.network(ApiConstant.imageBaseUrl + qrLink)
              : const SizedBox(),
          message: 'invoice_issued_message'.tr,
          onPressed: () {
            Navigator.of(context).pop(); // Close dialog
            Get.offAllNamed(AppRoute.navScreen);
          },
        ),
      ),
    );
  }

  void saveInvoice() {
    CustomAlert.showInfo(
        context: Get.context!,
        message: 'invoice_saved_message'.tr,
        onPressed: () {
          Get.offAllNamed(AppRoute.navScreen);
        });
  }

  void setPayMethod(PayMethod method) {
    payMethod.value = method;

    // Reset all payment-specific fields when switching payment methods
    receiveCash.value = null;
    receiveTransfer.value = null;
    cardApprovalCode.value = '';
    postpaidDate.value = '';
    postpaidDateForServer.value = '';
  }

  void setReceiveCash(bool value) {
    receiveCash.value = value;
  }

  void setCardApprovalCode(String code) {
    cardApprovalCode.value = code;
  }

  void setReceiveTransfer(bool value) {
    receiveTransfer.value = value;
  }

  void setPostpaidDate(String date, DateTime dateTime) {
    postpaidDate.value = date;
    // Convert to server format: YYYY-MM-DD
    postpaidDateForServer.value =
        '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  // Validation for release button
  bool get canReleaseInvoice {
    // If no payment method selected, disable button
    if (payMethod.value == null) return false;

    switch (payMethod.value!) {
      case PayMethod.cash:
        return receiveCash.value == true;
      case PayMethod.transfer:
        return receiveTransfer.value == true;
      case PayMethod.card:
        return cardApprovalCode.value.isNotEmpty &&
            cardApprovalCode.value.length == 6;
      case PayMethod.postpaid:
        return postpaidDateForServer
            .value.isNotEmpty; // Can release if date is selected
    }
  }

  // Validation for save button
  bool get canSaveInvoice {
    // If no payment method selected, disable button
    if (payMethod.value == null) return false;

    switch (payMethod.value!) {
      case PayMethod.cash:
        return receiveCash.value == false; // Can save if cash not received yet
      case PayMethod.transfer:
        return receiveTransfer.value ==
            false; // Can save if transfer not received yet
      case PayMethod.card:
        return false; // Can save if approval code not entered
      case PayMethod.postpaid:
        return false; // Postpaid invoices cannot be saved, only released after date selection
    }
  }

  // Computed getters for plate information
  // These prioritize received arguments over invoice data

  bool get hasSaudiPlateFromArgs => inputEnglishPlateNumber.isNotEmpty;
  bool get hasInternationalPlateFromArgs => internationalPlateNumber.isNotEmpty;

  String get displayPlateNumber {
    // Prioritize arguments
    if (hasInternationalPlateFromArgs) {
      return internationalPlateNumber.value;
    } else if (hasSaudiPlateFromArgs) {
      return inputEnglishPlateNumber.value;
    }

    // Fallback to invoice data
    if (invoiceDetails.value?.car?.plateNumberForInternational != null &&
        invoiceDetails.value!.car!.plateNumberForInternational!.isNotEmpty) {
      return invoiceDetails.value!.car!.plateNumberForInternational!;
    } else if (invoiceDetails.value?.car?.plateNumberForSaudi?.numberEnglish !=
        null) {
      return invoiceDetails.value!.car!.plateNumberForSaudi!.numberEnglish ??
          '';
    }

    return 'N/A';
  }

  String get displayPlateLetters {
    // Prioritize arguments
    if (hasSaudiPlateFromArgs) {
      return saudiPlateEnglishText.value;
    }

    // Fallback to invoice data
    if (invoiceDetails.value?.car?.plateNumberForSaudi?.alphabetsCombinations !=
            null &&
        invoiceDetails.value!.car!.plateNumberForSaudi!.alphabetsCombinations!
            .isNotEmpty) {
      return invoiceDetails
          .value!.car!.plateNumberForSaudi!.alphabetsCombinations![0];
    }

    return '';
  }

  String get displayPlateArabicText {
    // Prioritize arguments
    if (hasSaudiPlateFromArgs) {
      return inputArabicPlateNumber.value;
    }

    // Fallback to invoice data
    if (invoiceDetails.value?.car?.plateNumberForSaudi?.numberArabic != null) {
      return invoiceDetails.value!.car!.plateNumberForSaudi!.numberArabic ?? '';
    }

    return '';
  }

  String get displaySymbolImage {
    // Prioritize arguments
    if (hasSaudiPlateFromArgs && symbolImageForSaudiUrl.value.isNotEmpty) {
      return symbolImageForSaudiUrl.value;
    }

    // Fallback to invoice data
    if (invoiceDetails.value?.car?.plateNumberForSaudi?.symbol?.image != null) {
      return invoiceDetails.value!.car!.plateNumberForSaudi!.symbol!.image ??
          '';
    }

    return '';
  }

  bool get isSaudiPlate {
    // Check arguments first
    if (hasSaudiPlateFromArgs) return true;
    if (hasInternationalPlateFromArgs) return false;

    // Fallback to invoice data
    if (invoiceDetails.value?.car?.plateNumberForSaudi != null &&
        invoiceDetails.value!.car!.plateNumberForSaudi!.numberEnglish != null &&
        invoiceDetails
            .value!.car!.plateNumberForSaudi!.numberEnglish!.isNotEmpty) {
      return true;
    }

    return false;
  }

  bool get isInternationalPlate {
    // Check arguments first
    if (hasInternationalPlateFromArgs) return true;
    if (hasSaudiPlateFromArgs) return false;

    // Fallback to invoice data
    if (invoiceDetails.value?.car?.plateNumberForInternational != null &&
        invoiceDetails.value!.car!.plateNumberForInternational!.isNotEmpty) {
      return true;
    }

    return false;
  }
}
