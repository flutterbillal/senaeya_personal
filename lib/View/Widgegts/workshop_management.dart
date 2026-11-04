import 'package:Senaeya/View/Widgegts/vin_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../Core/AppRoute/app_route.dart';
import '../../Service/api_url.dart';
import '../../Utils/AppColors/app_colors.dart';
import '../../Utils/AppImg/app_img.dart';
import '../../Utils/ToastMsg/toast_message.dart';
import '../Screens/add_customer_screen/controller/add_customer_screen_controller.dart';
import '../Screens/auth_screens/login_screen/widgets/custom_button.dart';
import '../Widgets/carplate_text_filed.dart';
import '../Widgets/commonTextWithoutResize.dart';
import '../Widgets/custom_dropdown_field.dart';
import '../Widgets/custom_phone_field_with_button.dart';
import 'customUserTextFiled.dart';
import 'custom_button/next_button.dart';
import 'custom_text/custom_text.dart';
import 'custom_text_field/custom_text_field.dart';

class UserManagement extends StatelessWidget {
  const UserManagement({
    super.key,
    required this.formKey,
    required this.controller,
  });

  final GlobalKey<FormState> formKey;
  final AddCustomerScreenController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          // Plate number input
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 50.w,
                  width: 138.w,
                  padding: EdgeInsets.symmetric(
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Center(
                    child: CarplateTextFiled(
                      onChanged: (value) {
                        controller.setPlateNumber(value.toUpperCase());
                      },
                      validator: (value) {
                        final v = (value ?? '').trim();
                        if (v.isEmpty) {
                          return 'Enter 1 to 4 digits';
                        }
                        if (!RegExp(r'^\d{1,4}$').hasMatch(v)) {
                          return 'Only digits allowed (max 4)';
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Radio<int>(
                          value: 0,
                          groupValue: controller.boardType.value,
                          onChanged: controller.setBoardType,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          activeColor: AppColors.primary,
                        ),
                        CustomText(
                          text: 'saudi_board'.tr,
                          fontSize: 18.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Radio<int>(
                          value: 1,
                          groupValue: controller.boardType.value,
                          onChanged: controller.setBoardType,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          activeColor: AppColors.primary,
                        ),
                        CustomText(
                          text: 'non_saudi_board'.tr,
                          fontSize: 18.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Plate letters dropdowns
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              3,
              (i) => Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                  ),
                  child: PopupMenuButton<String>(
                    color: AppColors.textFiledColor,
                    onSelected: (val) => controller.setPlateLetter(i, val),
                    itemBuilder: (context) => controller.letterOptions
                        .map(
                          (e) => PopupMenuItem<String>(
                            value: "${e['en']}-${e['ar']}",
                            child: Center(
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: Commontextwithoutresize(
                                  text: "${e['en']}-${e['ar']}",
                                  fontSize: 26.w,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      height: 56.h,
                      decoration: BoxDecoration(
                        color: AppColors.textFiledColor,
                        borderRadius: BorderRadius.circular(
                          2.r,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 8.0,
                          right: 8,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Obx(() {
                              final en = controller.plateLetters[i];
                              if (en.isEmpty) {
                                return CustomText(
                                  text: "---",
                                  fontSize: 27.w,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey,
                                );
                              } else {
                                final ar = controller.letterOptions.firstWhere(
                                  (e) => e['en'] == en,
                                  orElse: () => {
                                    'ar': '',
                                  },
                                )['ar'];
                                return Commontextwithoutresize(
                                  text: "$en - $ar",
                                  fontSize: 27.w,
                                  fontWeight: FontWeight.bold,
                                );
                              }
                            }),
                            SvgPicture.asset(
                              AppIcon.dropDown,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // KSA color indicators
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                controller.carSymbols.length,
                (i) => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.setSelectedColor(i);
                          controller.selectedCarSymbolId.value =
                              controller.carSymbols[i].sId ?? '';
                          print(
                              "Selected Car Symbol ID: ${controller.selectedCarSymbolId.value}");
                        },
                        child: Obx(() => Radio<int>(
                              value: i,
                              groupValue: controller.selectedColor.value,
                              onChanged: (val) {
                                controller.setSelectedColor(val);
                                if (val != null &&
                                    val < controller.carSymbols.length) {
                                  controller.selectedCarSymbolId.value =
                                      controller.carSymbols[val].sId ?? '';
                                  print(
                                      "Selected Car Symbol ID: ${controller.selectedCarSymbolId.value}");
                                }
                              },
                              activeColor: Colors.black,
                            )),
                      ),
                      Image.network(
                        ApiConstant.imageBaseUrl +
                            (controller.carSymbols[i].image ?? ''),
                        width: 32.w,
                        height: 80.h,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          // Plate code field
          Obx(
            () => controller.boardType.value == 1
                ? SizedBox(
                    width: 220.w,
                    child: CustomTextField(
                      controller: controller.carPlateController,
                      height: 46.h,
                      hintText: '------'.tr,
                      borderColor: Colors.grey,
                      fillColor: Colors.white,
                      textAlign: TextAlign.center,
                      borderRadius: 8.r,
                      hintFontSize: 18.sp,
                      fontSize: 18.sp,
                      fontWidth: FontWeight.w700,
                    ),
                  )
                : const SizedBox(),
          ),
          SizedBox(height: 12.h),
          // Check button
          CustomButton(
            text: "check".tr,
            backgroundColor: AppColors.primary,
            onPressed: controller.boardType.value == 1
                ? controller.getClientByCarPlate
                : controller.getCustomerListBySaudiCarPlate,
          ),
          SizedBox(height: 12.h),
          // VIN input with scan icon
          VinTextFiled(
            controller: controller.vinController,
            hintText: 'VIN Chassis number (17 characters)'.tr,
            icon: AppIcon.vin,
            iconSize: 32.w,
            enabled: !controller.isFromNewInvoice,
            isRequired: true,
            onChanged: (value) {
              controller.setVin(value.toUpperCase());
            },
            onTapIcon: controller.isFromNewInvoice
                ? null
                : () async {
                    final scannedVin = await Get.toNamed(
                      AppRoute.vinScannerScreen,
                    );
                    if (scannedVin != null &&
                        scannedVin is String &&
                        scannedVin.isNotEmpty) {
                      controller.setVin(scannedVin);
                    }
                  },
          ),
          SizedBox(height: 12.h),
          // Brand dropdown with logo
          Row(
            children: [
              Obx(() => controller.brandImage.value.isNotEmpty
                  ? Image.network(
                      ApiConstant.imageBaseUrl + controller.brandImage.value,
                      width: 40.w,
                      height: 50.h,
                    )
                  : SizedBox(
                      width: 40.w,
                      height: 50.h,
                    )),
              SizedBox(width: 8.w),
              Obx(() {
                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      debugPrint(
                          "==================================${controller.carBrands.length}");
                    },
                    child: CustomDropdownField(
                      value: controller.brand.value,
                      items: controller.carBrands,
                      hintText: 'brand'.tr,
                      onChanged: controller.isFromNewInvoice
                          ? null
                          : (val) => controller.setBrand(val!),
                      isRequired: true,
                    ),
                  ),
                );
              })
            ],
          ),
          SizedBox(height: 12.h),
          // Model and Year dropdowns
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Obx(() {
                  debugPrint(
                      "=============adf========${controller.carModels.length}");
                  return CustomDropdownField(
                    value: controller.model.value.isEmpty
                        ? null
                        : controller.model.value,
                    items: controller.carModels,
                    hintText: 'model'.tr,
                    onChanged: controller.isFromNewInvoice
                        ? null
                        : (val) => controller.setModel(val!),
                    isRequired: true,
                  );
                }),
              ),
              SizedBox(width: 8.w),
              Expanded(
                flex: 2,
                child: Obx(() => CustomDropdownField(
                      value: controller.year.value,
                      items: controller.yearOptions,
                      hintText: 'year'.tr,
                      onChanged: controller.isFromNewInvoice
                          ? null
                          : (val) => controller.setYear(val!),
                      isRequired: true,
                    )),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          // Phone field with Check button
          Obx(() {
            // Use the detected country code directly from controller
            String countryCode = controller.selectedCountryCode.value;

            return CustomPhoneFieldWithButton(
              key: ValueKey(countryCode),
              controller: controller.phoneController,
              isCountryCodeFixed: false,
              enabled: !controller.isFromNewInvoice,
              buttonEnabled: true, // Always keep button enabled
              onButtonTap: () {
                // Always allow verification button tap
                controller.verifiedPhone(controller.phone.value,
                    isCanAddCustomer: true);
              },
              onPhoneChanged: (
                phone,
              ) =>
                  controller.setPhone(phone),
              onCountryChanged: (code) =>
                  controller.setSelectedCountryCode(code),
              initialCountryCode: countryCode,
            );
          }),
          SizedBox(height: 12.h),
          // Name field
          CustomUserInputField(
            controller: controller.nameController,
            icon: AppIcon.blueProfile,
            hintText: 'Customer name'.tr,
            isRequired: true,
            enabled: !controller.isFromNewInvoice,
          ),
          SizedBox(height: 12.h),
          CustomUserInputField(
            controller: controller.documentsNumberController,
            icon: AppIcon.id,
            hintText: 'VAT Number (optional)'.tr,
            keyboardType: TextInputType.number,
            enabled: !controller.isFromNewInvoice,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(15),
            ],
            validator: (value) {
              final v = (value ?? '').trim();
              if (v.isEmpty) {
                return null; // Optional field
              }
              if (!RegExp(r'^3\d{13}3$').hasMatch(v)) {
                return 'document_number_invalid'.tr;
              }
              return null;
            },
          ),
          SizedBox(height: 20.h),
          // Cancel and Addition buttons
          Row(
            children: [
              NextButton(
                text: 'cancel'.tr,
                onTap: controller.onCancel,
                backgroundColor: AppColors.cancelButton,
                textColor: AppColors.red,
              ),
              SizedBox(width: 16.w),
              NextButton(
                text: controller.isFromNewInvoice
                    ? 'next'.tr
                    : controller.clientCarId.value.isNotEmpty
                        ? 'update'.tr
                        : controller.createCarClientId.value.isNotEmpty
                            ? 'add_car'.tr
                            : 'addition'.tr,
                onTap: () {
                  // final isValid = _formKey
                  //     .currentState
                  //     ?.validate() ??
                  //     true;
                  // if (!isValid) {
                  //   Get.snackbar('error'.tr,
                  //       'Please correct the highlighted fields');
                  //   return;
                  // }
                  if (controller.areRequiredFieldsFilled()) {
                    if (controller.isFromNewInvoice) {
                      controller.onTapNext();
                    } else {
                      (controller.createCarClientId.value.isNotEmpty &&
                              controller.clientCarId.value.isEmpty)
                          ? controller.createCustomerCar()
                          : controller.onTapAddCustomer();
                    }
                  } else {
                    showCustomSnackBar("please_fill_all_fields".tr,
                        isError: true);
                  }
                },
                backgroundColor: AppColors.primary,
                textColor: Colors.white,
              )
            ],
          ),
        ],
      ),
    );
  }
}
