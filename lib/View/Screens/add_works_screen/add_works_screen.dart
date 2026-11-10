import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/View/Widgegts/custom_button/next_button.dart';
import 'package:Senaeya/View/Widgegts/custom_text_field/custom_text_field.dart';
import 'package:Senaeya/View/Widgegts/custom_data_table/custom_data_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../Utils/AppImg/app_img.dart';
import '../../Widgegts/custom_text/custom_text.dart';
import '../../Widgets/custom_app_bar.dart';
import '../../Widgets/custom_dropdown.dart';
import 'controller/add_works_controller.dart';

class AddWorksScreen extends StatelessWidget {
  const AddWorksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
    AddWorksController controller = Get.find<AddWorksController>();

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.primary,
        appBar: CustomAppBar(
          title: 'add_works'.tr,
          titleColor: Colors.black,
          // //blueCloud: true,
          onBack: Get.back,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding:
                const EdgeInsets.only(left: 6, right: 6, top: 12, bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Input Row 1: Code and Works
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Obx(
                        () => CustomDropdown<String>(
                          value: controller.selectedCode.value.isEmpty
                              ? null
                              : controller.selectedCode.value,
                          items: controller.availableCodes,
                          hint: 'code'.tr,
                          onChanged: controller.onCodeChanged,
                          height: 40.h,
                          width: double.infinity,
                          borderRadius: 24.r,
                          fillColor: AppColors.textFiledColor,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          iconSize: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          hintStyle: const TextStyle(color: Colors.grey),
                          itemStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      flex: 6,
                      child: Obx(
                        () => CustomDropdown<String>(
                          value: controller.workName.value.isNotEmpty &&
                                  controller.availableWorks.contains(
                                    controller.workName.value,
                                  )
                              ? controller.workName.value
                              : null,
                          items: controller.availableWorks.toSet().toList(),
                          hint: 'works'.tr,
                          onChanged: (val) {
                            if (val != null &&
                                controller.availableWorks.contains(val)) {
                              controller.onWorkNameChanged(val);
                            } else {
                              controller.onWorkNameChanged('');
                            }
                          },
                          height: 40.h,
                          width: double.infinity,
                          borderRadius: 24.r,
                          fillColor: AppColors.textFiledColor,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          iconSize: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          hintStyle: const TextStyle(color: Colors.grey),
                          itemStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Obx(
                        () => CustomDropdown<int>(
                          value: controller.qty.value > 0
                              ? controller.qty.value
                              : null,
                          items: List.generate(20, (i) => i + 1),
                          hint: 'Qty'.tr,
                          onChanged: (val) {
                            if (val != null) {
                              controller.onQtyChanged(val.toString());
                            }
                          },
                          height: 40.h,
                          width: double.infinity,
                          borderRadius: 24.r,
                          fillColor: AppColors.textFiledColor,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          iconSize: 20,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          hintStyle: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                          ),
                          itemStyle: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: controller.priceController,
                        hintText: 'price'.tr,
                        keyboardType: TextInputType.number,
                        onChanged: controller.onPriceChanged,
                        height: 40.h,
                      ),
                    ),
                    SizedBox(
                      width: 4.w,
                    ),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: controller.addWork,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 14.w,
                            vertical: 8.h,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child: CustomText(
                            text: 'add'.tr,
                            fontSize: 14.w,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.w),

                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        hintText: 'search'.tr,
                        onChanged: controller.onSearchChanged,
                        height: 40.h,
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          if (controller.selectedIndex.value >= 0) {
                            controller.showEditDialog(
                                context, controller.selectedIndex.value);
                          }
                        },
                        child: SvgPicture.asset(
                          AppIcon.editIcon,
                          height: 20.w,
                          width: 20.w,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                          onTap: () {
                            if (controller.selectedIndex.value >= 0) {
                              controller
                                  .deleteWork(controller.selectedIndex.value);
                            }
                          },
                          child: SvgPicture.asset(AppIcon.deleteIcon,
                              height: 20.w, width: 20.w)),
                    )
                  ],
                ),

                const SizedBox(height: 12),

                // Data Table
                Expanded(
                  child: GetBuilder<AddWorksController>(builder: (context) {
                    return WorksDataTable(
                      works: controller.filteredWorks,
                      onWorkTap: controller.selectWork,
                      selectedIndex: controller.selectedIndex.value,
                    );
                  }),
                ),

                SizedBox(height: 8.h),

                // Summary Row 1: Total Before Tax & Discount
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GestureDetector(
                        onTap: () {
                          controller.showDiscountDialog(context);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.textFiledColor,
                            border: Border.all(
                                color: Colors.grey.shade300, width: 2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8.0, right: 8, top: 2, bottom: 2),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: 'discount'.tr,
                                  fontSize: 13.w,
                                  fontWeight: FontWeight.w700,
                                  overflow: TextOverflow.visible,
                                ),
                                SizedBox(
                                  height: 4.h,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                        height: 20.w, AppIcon.riyal),
                                    const SizedBox(width: 4),
                                    Obx(
                                      () => CustomText(
                                        text: controller.discount.value
                                            .toStringAsFixed(2),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8, top: 2, bottom: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textFiledColor,
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            CustomText(
                              text: 'total_before_tax'.tr,
                              fontSize: 13.w,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                    height: 20.w, AppIcon.riyalBlue),
                                const SizedBox(width: 4),
                                Obx(
                                  () => CustomText(
                                    text: controller.totalBeforeTax
                                        .toStringAsFixed(2),
                                    fontSize: 14,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                // Summary Row 2: Tax & Total Including Tax
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8, top: 2, bottom: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textFiledColor,
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            CustomText(
                              text: 'tax_vat'.tr,
                              fontSize: 13.w,
                              overflow: TextOverflow.visible,
                              fontWeight: FontWeight.w700,
                            ),
                            // CustomText(text: 'TAX (15%)', fontSize: 13.w,overflow: TextOverflow.visible,fontWeight: FontWeight.w700,),
                            SizedBox(
                              height: 4.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(height: 20.w, AppIcon.riyal),
                                SizedBox(width: 4.w),
                                Obx(
                                  () => CustomText(
                                    text: controller.tax.toStringAsFixed(2),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      flex: 4,
                      child: Container(
                        padding: const EdgeInsets.only(
                            left: 8.0, right: 8, top: 2, bottom: 2),
                        decoration: BoxDecoration(
                          color: AppColors.textFiledColor,
                          border: Border.all(color: AppColors.red),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            CustomText(
                              text: 'total_including_tax'.tr,
                              fontSize: 13.w,
                              color: AppColors.red,
                              fontWeight: FontWeight.w700,
                              overflow: TextOverflow.visible,
                            ),
                            SizedBox(
                              height: 4.h,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset(
                                    height: 20.w, AppIcon.riyalRed),
                                const SizedBox(width: 4),
                                Obx(
                                  () => CustomText(
                                    text: controller.totalIncludingTax
                                        .toStringAsFixed(2),
                                    fontSize: 14,
                                    color: AppColors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(width: 8.w),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Bottom Buttons
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16),
                  child: Row(
                    children: [
                      NextButton(
                        text: 'previous'.tr,
                        onTap: () {
                          Get.back();
                        },
                        textColor: AppColors.red,
                        backgroundColor: AppColors.redTextFiled,
                      ),
                      const SizedBox(width: 20),
                      Obx(
                        () => NextButton(
                          text: "next".tr,
                          onTap: controller.works.isEmpty
                              ? () {}
                              : () {
                                  controller.onTapNext();
                                },
                          backgroundColor: controller.works.isEmpty
                              ? Colors.grey
                              : AppColors.primary,
                          textColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
