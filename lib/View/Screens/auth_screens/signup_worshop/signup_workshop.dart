import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/auth_screens/signup_worshop/controller/signup_workshop_controller.dart';
import 'package:Senaeya/utils/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../Widgegts/custom_text/custom_text.dart';
import '../../../Widgets/custom_app_bar.dart';
import '../login_screen/widgets/custom_button.dart';
import '../login_screen/widgets/custom_text_field.dart';

class SignupWorkshopScreen extends StatelessWidget {
  const SignupWorkshopScreen({super.key});

  // Form key to perform validation checks for enabling the Create button

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SignupWorkshopController>(
      init: SignupWorkshopController(),
      builder: (controller) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Scaffold(
            appBar: CustomAppBar(
              title: 'new_workshop_data'.tr,
              titleColor: Colors.black,
              // //blueCloud: true,
              onBack: () => Navigator.pop(context),
            ),
            backgroundColor: const Color(0xFF0C5CA8),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: Form(
                    key: controller.formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // _sectionTitle('workshop_info'.tr),
                        // SizedBox(height: 12.h),
                        _requiredField(
                          controller.workshopNameController,
                          'workshop_name_in_board'.tr,
                          requiredDouble: false,
                        ),
                        SizedBox(height: 12.h),
                        _requiredField(
                          controller.workshopNameArabicController,
                          'Workshop name in the commercial register'.tr,
                          requiredDouble: true,
                        ),
                        // SizedBox(height: 12.h),
                        // _requiredField(
                        //   controller.workshopContact,
                        //   'contact information'.tr,
                        //   requiredDouble: true,
                        // ),
                        SizedBox(height: 12.h),
                        _requiredField(
                          controller.nationalNumberController,
                          'unified_national_number'.tr,
                          requiredDouble: true,
                          fontSize: 18.h,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty)
                              return 'UNN is required'.tr;
                            final ok = controller.validateUNN(val.trim());
                            return ok ? null : controller.unnError.value;
                          },
                        ),
                        // Show UNN validation error
                        Obx(
                          () => controller.unnError.value.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(top: 4.h, left: 8.w),
                                  child: CustomText(
                                    text: controller.unnError.value,
                                    fontSize: 11.sp,
                                    color: Colors.red,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // SizedBox(height: 12.h),
                        // _requiredField(
                        //   controller.registrationNumberController,
                        //   'commercial_reg_number'.tr,
                        //   fontSize: 18.h,
                        //   requiredDouble: true,
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     LengthLimitingTextInputFormatter(10),
                        //   ],
                        //   keyboardType: TextInputType.number,
                        //   validator: (val) {
                        //     if (val == null || val.trim().isEmpty) return 'CRN is required'.tr;
                        //     final ok = controller.validateCRN(val.trim());
                        //     return ok ? null : controller.crnError.value;
                        //   },
                        // ),
                        // Show CRN validation error
                        // Obx(
                        //   () => controller.crnError.value.isNotEmpty
                        //       ? Padding(
                        //           padding: EdgeInsets.only(top: 4.h, left: 8.w),
                        //           child: CustomText(
                        //             text: controller.crnError.value,
                        //             fontSize: 11.sp,
                        //             color: Colors.red,
                        //           ),
                        //         )
                        //       : const SizedBox.shrink(),
                        // ),
                        SizedBox(height: 12.h),
                        _requiredField(
                          controller.licenseNumberController,
                          'municipality_license_number'.tr,
                          requiredDouble: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(12)
                          ],
                          fontSize: 18.h,
                          keyboardType: TextInputType.number,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty)
                              return 'MLN is required'.tr;
                            final ok = controller.validateMLN(val.trim());
                            return ok ? null : controller.mlnError.value;
                          },
                        ),
                        // Show MLN validation error
                        Obx(
                          () => controller.mlnError.value.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(top: 4.h, left: 8.w),
                                  child: CustomText(
                                    text: controller.mlnError.value,
                                    fontSize: 11.sp,
                                    color: Colors.red,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 12.h),
                        _requiredField(
                          controller.addressController,
                          'workshop_address'.tr,
                          requiredDouble: false,
                          manxLines: 2,
                        ),
                        SizedBox(height: 12.h),
                        _requiredField(
                          controller.taxNumberController,
                          'tax_number_vat'.tr,
                          fontSize: 18.h,
                          requiredDouble: false,
                          requiredSingle: false,
                          showNoStar: true,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(15),
                          ],
                          keyboardType: TextInputType.number,
                          // Make tax optional: don't show "required" error when empty.
                          validator: (value) {
                            if (value == null || value.trim().isEmpty)
                              return null;
                            // Use controller validation for format/length and return message if invalid.
                            final ok = controller.validateTaxVAT(value.trim());
                            return ok ? null : controller.taxVatError.value;
                          },
                        ),
                        // Show Tax/VAT validation error
                        Obx(
                          () => controller.taxVatError.value.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(top: 4.h, left: 8.w),
                                  child: CustomText(
                                    text: controller.taxVatError.value,
                                    fontSize: 11.sp,
                                    color: Colors.red,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 12.h),
                        Stack(
                          children: [
                            _requiredField(
                              fontSize: 18.h,
                              controller.ibanController,
                              'bank_account_iban'.tr,
                              requiredDouble: false,
                              requiredSingle: false,
                              showNoStar: true,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(24),
                                TextInputFormatter.withFunction(
                                    (oldValue, newValue) {
                                  // Ensure text always starts with "SA"
                                  String text = newValue.text.toUpperCase();

                                  // If user tries to delete "SA" or text is empty, reset to "SA"
                                  if (text.isEmpty ||
                                      text.length < 2 ||
                                      !text.startsWith('SA')) {
                                    return const TextEditingValue(
                                      text: 'SA',
                                      selection:
                                          TextSelection.collapsed(offset: 2),
                                    );
                                  }

                                  // Only allow digits after "SA"
                                  if (text.length > 2) {
                                    String afterSA = text.substring(2);
                                    String digitsOnly = afterSA.replaceAll(
                                        RegExp(r'[^0-9]'), '');
                                    text = 'SA$digitsOnly';
                                  }

                                  return TextEditingValue(
                                    text: text,
                                    selection: TextSelection.collapsed(
                                        offset: text.length),
                                  );
                                }),
                              ],
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: false,
                                signed: false,
                              ),
                            ),
                            const Positioned(
                                top: 4,
                                left: 0,
                                child: CustomText(text: 'iBan'))
                          ],
                        ),
                        // Show IBAN validation error
                        Obx(
                          () => controller.ibanError.value.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.only(top: 4.h, left: 8.w),
                                  child: CustomText(
                                    text: controller.ibanError.value,
                                    fontSize: 11.sp,
                                    color: Colors.red,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        // SizedBox(height: 12.h),
                        // _sectionTitle('workshop_settings'.tr),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Obx(
                              () => Checkbox(
                                value: controller.isMobileWorkshop.value,
                                onChanged: (val) => controller
                                    .isMobileWorkshop.value = val ?? false,
                                activeColor: const Color(0xFF0C5CA8),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'available_mobile_workshop'.tr,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Text(
                              ' *',
                              style: TextStyle(
                                color: AppColors.red,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            InkWell(
                              onTap: controller.addLocation,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 12.w,
                                  vertical: 10.h,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(24.r),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF0C5CA8,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SvgPicture.asset(
                                      AppIcon.location,
                                      width: 20.w,
                                      height: 20.h,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'add_workshop_location'.tr,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Show selected location
                        Obx(
                          () => controller.isLocationAdded.value &&
                                  controller.locationAddress.value.isNotEmpty
                              ? Padding(
                                  padding:
                                      EdgeInsets.only(top: 8.h, left: 24.w),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16.w,
                                      ),
                                      SizedBox(width: 4.w),
                                      Expanded(
                                        child: CustomText(
                                          text:
                                              controller.locationAddress.value,
                                          fontSize: 12.sp,
                                          color: Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                        SizedBox(height: 20.h),
                        // _sectionTitle('working_hours'.tr),
                        // SizedBox(height: 12.h),
                        _workingHoursSection(
                          'regular_working_hours'.tr,
                          controller.regularDayFrom,
                          controller.regularDayTo,
                          controller.regularFrom,
                          controller.regularTo,
                          controller,
                        ),
                        SizedBox(height: 16.h),
                        _workingHoursSection(
                          'ramadan_working_hours'.tr,
                          controller.ramadanDayFrom,
                          controller.ramadanDayTo,
                          controller.ramadanFrom,
                          controller.ramadanTo,
                          controller,
                        ),
                        SizedBox(height: 32.h),
                        Obx(
                          () => CustomButton(
                            text: 'Create Workshop'.tr,
                            // Avoid calling `formKey.currentState?.validate()` in build; rely on controller.isFormValid
                            onPressed: controller.isFormValid.value
                                ? controller.onTapSubmit
                                : null,
                            enabled: controller.isFormValid.value,
                            isLoading: controller.isLoading.value,
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ignore: unused_element
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _requiredField(
    TextEditingController controller,
    String hint, {
    bool requiredDouble = false,
    bool requiredSingle = false,
    bool showNoStar = false,
    int manxLines = 1,
    double fontSize = 14,
    List<TextInputFormatter>? inputFormatters,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: CustomTextFormField(
                controller: controller,
                hintText: hint,
                fontSize: fontSize,
                maxLines: manxLines,
                isRightStar: false,
                centerHintText: true,
                keyboardType: keyboardType,
                inputFormatters: inputFormatters,
                validator: validator,
                showOneStar: showNoStar
                    ? false
                    : requiredSingle
                        ? true
                        : requiredDouble
                            ? false
                            : true,
                showTwoStar: requiredDouble ? true : false,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _workingHoursSection(
    String title,
    RxString dayFrom,
    RxString dayTo,
    Rx<TimeOfDay> from,
    Rx<TimeOfDay> to,
    SignupWorkshopController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              ' *',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(width: 4.w),
            CustomText(
              text: title,
              fontWeight: FontWeight.w400,
              fontSize: 14.sp,
              color: Colors.black87,
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Column(
          children: [
            Row(
              children: [
                // Day dropdown
                Text(
                  'from'.tr,
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                ),
                SizedBox(width: 4.w),
                Expanded(flex: 2, child: _dayDropdown(dayFrom)),
                SizedBox(width: 4.w),
                Text(
                  'to'.tr,
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                ),
                SizedBox(width: 4.w),
                Expanded(flex: 2, child: _dayDropdown(dayTo)),
              ],
            ),
            SizedBox(height: 08.h),
            Row(
              children: [
                Text(
                  'from'.tr,
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                ),
                SizedBox(width: 4.w),
                // From time picker
                Expanded(flex: 2, child: _timePicker(from, controller)),
                SizedBox(width: 4.w),
                // To label
                Text(
                  'to'.tr,
                  style: TextStyle(fontSize: 11.sp, color: Colors.black54),
                ),
                SizedBox(width: 4.w),
                // To time picker
                Expanded(flex: 2, child: _timePicker(to, controller)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _dayDropdown(RxString day) {
    final dayKeys = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];

    return Obx(() {
      if (day.value.isEmpty || !dayKeys.contains(day.value.toLowerCase())) {
        day.value = dayKeys.first;
      } else {
        day.value = day.value.toLowerCase();
      }

      return Container(
        height: 34.w,
        // padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F8),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: DropdownButton<String>(
            icon: SvgPicture.asset(AppIcon.dropDown),
            value: day.value,
            isExpanded: true,
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.black87, fontSize: 10),
            items: dayKeys
                .map(
                  (key) => DropdownMenuItem(
                    value: key,
                    child: CustomText(text: key.tr, fontSize: 11.w),
                  ),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) {
                day.value = val;
              }
            },
          ),
        ),
      );
    });
  }

  Widget _timePicker(Rx<TimeOfDay> time, SignupWorkshopController controller) {
    return Obx(
      () => InkWell(
        onTap: () async {
          final picked = await showTimePicker(
            context: Get.context!,
            initialTime: time.value,
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: Theme.of(
                    context,
                  ).colorScheme.copyWith(primary: const Color(0xFF0C5CA8)),
                ),
                child: child!,
              );
            },
          );
          if (picked != null) {
            time.value = picked;
          }
        },
        child: Container(
          // padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F8),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  text: time.value.format(Get.context!),
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
                SvgPicture.asset(AppIcon.dropDown),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
