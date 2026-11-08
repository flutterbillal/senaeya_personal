import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/edit_workshop_screen/controller/edit_workshop_controller.dart';
import 'package:Senaeya/View/Screens/edit_workshop_screen/widget/edit_workshop_widget.dart';
import 'package:Senaeya/View/Screens/edit_workshop_screen/widget/working_hour_selection.dart';
import 'package:Senaeya/utils/AppColors/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../Widgegts/custom_text/custom_text.dart';
import '../../Widgets/custom_app_bar.dart';
import '../auth_screens/login_screen/widgets/custom_button.dart';
import 'widget/required_filed.dart';

class EditWorkshopScreen extends StatelessWidget {
  const EditWorkshopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    EditWorkshopController controller = Get.find<EditWorkshopController>();
    return Directionality(
        textDirection: TextDirection.ltr,
        child: Scaffold(
          appBar: CustomAppBar(
            title: 'edit_workshop_data'.tr,
            titleColor: Colors.black,
            //blueCloud: true,
            onBack: () => Navigator.pop(context),
          ),
          backgroundColor: const Color(0xFF0C5CA8),
          body: Obx(
            () => controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : SafeArea(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.all(16.w),
                        child: Form(
                          key: controller.formKey,
                          autovalidateMode: AutovalidateMode.disabled,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // _sectionTitle('workshop_info'.tr),
                              // SizedBox(height: 12.h),
                              requiredField(
                                controller.workshopNameController,
                                'workshop_name_in_board'.tr,
                                requiredDouble: false,
                              ),
                              SizedBox(height: 12.h),
                              requiredField(
                                controller.workshopNameArabicController,
                                'Workshop name in the commercial register'.tr,
                                requiredDouble: true,
                                readOnly: true,
                              ),
                              SizedBox(height: 12.h),
                              // SizedBox(height: 12.h),
                              // _requiredField(
                              //   controller.workshopContact,
                              //   'contact number'.tr,
                              //   requiredDouble: true,
                              // ),
                              requiredField(
                                controller.nationalNumberController,
                                'unified_national_number'.tr,
                                requiredDouble: true,
                                fontSize: 18.sp,
                                readOnly: true,
                              ),
                              SizedBox(height: 12.h),
                              requiredField(
                                controller.registrationNumberController,
                                'commercial_reg_number'.tr,
                                requiredDouble: true,
                                fontSize: 18.sp,
                                readOnly: true,
                              ),
                              SizedBox(height: 12.h),
                              requiredField(
                                controller.licenseNumberController,
                                'municipality_license_number'.tr,
                                fontSize: 18.sp,
                                requiredDouble: true,
                                readOnly: true,
                              ),
                              SizedBox(height: 12.h),
                              requiredField(
                                controller.addressController,
                                'workshop_address'.tr,
                                requiredDouble: false,
                                manxLines: 2,
                              ),
                              SizedBox(height: 12.h),
                              requiredField(
                                controller.taxNumberController,
                                'tax_number_vat'.tr,
                                requiredDouble: true,
                                readOnly: controller
                                        .taxNumberController.text.isNotEmpty
                                    ? true
                                    : false,
                                requiredSingle: true,
                                isTaxNumber: true,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(15),
                                ],
                                keyboardType: TextInputType.number,
                                fontSize: 18.sp,
                              ),
                              SizedBox(height: 12.h),
                              Stack(
                                children: [
                                  customTextFiled(
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
                                        String text =
                                            newValue.text.toUpperCase();

                                        // If user tries to delete "SA" or text is empty, reset to "SA"
                                        if (text.isEmpty ||
                                            text.length < 2 ||
                                            !text.startsWith('SA')) {
                                          return const TextEditingValue(
                                            text: 'SA',
                                            selection: TextSelection.collapsed(
                                                offset: 2),
                                          );
                                        }

                                        // Only allow digits after "SA"
                                        if (text.length > 2) {
                                          String afterSA = text.substring(2);
                                          String digitsOnly =
                                              afterSA.replaceAll(
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
                                    // Validator: if not empty, must start with 'SA' (case-insensitive)
                                    validator: (value) {
                                      final v = (value ?? '').trim();
                                      if (v.isEmpty || v == 'SA')
                                        return null; // optional field
                                      if (v.length < 24) {
                                        return 'iban_must_be_24_characters'.tr;
                                      }
                                      if (!v.toUpperCase().startsWith('SA')) {
                                        return 'iban_must_start_with_sa'.tr;
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.number,
                                  ),
                                  const Positioned(
                                      top: 4,
                                      left: 0,
                                      child: CustomText(text: 'iBan'))
                                ],
                              ),
                              // SizedBox(height: 20.h),
                              // _sectionTitle('workshop_settings'.tr),
                              SizedBox(height: 12.h),
                              Row(
                                children: [
                                  Obx(
                                    () => Checkbox(
                                      value: controller.isMobileWorkshop.value,
                                      onChanged: (val) => controller
                                          .isMobileWorkshop
                                          .value = val ?? false,
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
                                        borderRadius:
                                            BorderRadius.circular(24.r),
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
                              SizedBox(height: 20.h),
                              // _sectionTitle('working_hours'.tr),
                              // SizedBox(height: 12.h),
                              workingHoursSection(
                                'regular_working_hours'.tr,
                                controller.regularDayFrom,
                                controller.regularDayTo,
                                controller.regularFrom,
                                controller.regularTo,
                                controller,
                              ),
                              SizedBox(height: 16.h),
                              workingHoursSection(
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
                                  text: 'save'.tr,
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
        ));
  }
}
