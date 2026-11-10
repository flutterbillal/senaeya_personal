import 'package:Senaeya/View/Widgegts/custom_button/next_button.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgegts/custom_data_table/custom_data_table.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/AppImg/app_img.dart';
import '../../Widgegts/custom_text_field/custom_text_field.dart';
import '../../Widgegts/edit_dialog.dart';
import '../../Widgets/custom_dropdown.dart';
import 'controller/add_spare_parts_controller.dart';

class AddSparePartsScreen extends StatelessWidget {
  const AddSparePartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AddSparePartsController controller = Get.put(
      AddSparePartsController(),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppColors.primary,
        appBar: CustomAppBar(
          title: 'add_spare_parts'.tr,
          titleColor: Colors.black,
          // //redCloud: true,
          onBack: Get.back,
          centerTitle: true,
        ),
        body: SafeArea(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.only(
              top: 16,
              bottom: 16,
              left: 6,
              right: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Are spare parts added?
                Row(
                  spacing: 12,
                  children: [
                    Flexible(
                      child: CustomText(
                        text: 'are_spare_parts_added'.tr,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.w,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                    Obx(
                      () => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<bool>(
                                activeColor: AppColors.primary,
                                value: true,
                                groupValue: controller.sparePartsAdded.value,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onChanged: (bool? val) {
                                  if (val != null) {
                                    controller.sparePartsAdded.value = val;
                                  }
                                },
                              ),
                              CustomText(text: 'yes'.tr),
                            ],
                          ),
                          SizedBox(width: 6.w),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<bool>(
                                activeColor: AppColors.primary,
                                value: false,
                                groupValue: controller.sparePartsAdded.value,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                visualDensity: VisualDensity.compact,
                                onChanged: (bool? val) {
                                  if (val != null) {
                                    controller.sparePartsAdded.value = val;
                                  }
                                },
                              ),
                              CustomText(text: 'no'.tr),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),

                // Input Row: Code, Works
                // Replace your existing "Input Row: Code, Works" section with this:
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        keyboardType: TextInputType.number,
                        hintText: 'code'.tr,
                        controller: controller.codeController,
                        onChanged: controller.onCodeTextChanged,
                      ),
                    ),
                    SizedBox(width: 6.h),
                    Expanded(
                      flex: 6,
                      child: Obx(
                        () => Stack(
                          children: [
                            Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: TextFormField(
                                decoration: InputDecoration(
                                  hintText: 'spare parts'.tr,
                                  hintStyle:
                                      const TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                ),
                                onChanged: controller.sparePartsAdded.value
                                    ? controller.onWorkNameChanged
                                    : null,
                                enabled: controller.sparePartsAdded.value,
                                style: const TextStyle(fontSize: 14),
                                controller: TextEditingController(
                                    text: controller.workName.value)
                                  ..selection = TextSelection.collapsed(
                                      offset: controller.workName.value.length),
                              ),
                            ),
                            if (controller.isSearchingSpare.value)
                              Positioned(
                                right: 12,
                                top: 0,
                                bottom: 0,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
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
                          height: 45,
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
                    SizedBox(width: 6.h),
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        hintText: 'price'.tr,
                        keyboardType: TextInputType.number,
                        onChanged: controller.onPriceChanged,
                        height: 45,
                      ),
                    ),
                    SizedBox(width: 6.h),
                    Expanded(
                      flex: 3,
                      child: ElevatedButton(
                        onPressed: controller.addWork,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24.r),
                          ),
                          elevation: 0,
                        ),
                        child: CustomText(
                          text: 'add'.tr,
                          fontSize: 12.w,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),
                // New/Used toggle
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        flex: 4, // Increased flex to give more space
                        child: GestureDetector(
                          onTap: () => controller.isNew.value = true,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              6.0,
                            ), // Reduced padding from 8.0 to 6.0
                            child: Row(
                              children: [
                                CustomText(
                                  text: 'new'.tr,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18.w,
                                  color: Colors.green,
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(60.r),
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    color: controller.isNew.value
                                        ? Colors.green
                                        : Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3, // Increased flex to give more space
                        child: GestureDetector(
                          onTap: () => controller.isNew.value = false,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              6.0,
                            ), // Reduced padding from 8.0 to 6.0
                            child: Row(
                              children: [
                                CustomText(
                                  text: 'used'.tr,
                                  fontSize: 18.w,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.red,
                                ),
                                const SizedBox(width: 4),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.grey,
                                    ),
                                    borderRadius: BorderRadius.circular(60.r),
                                  ),
                                  child: Icon(
                                    Icons.circle,
                                    color: !controller.isNew.value
                                        ? AppColors.red
                                        : Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (controller.selectedIndex.value >= 0) {
                              final index = controller.selectedIndex.value;
                              showEditDialog(context, controller, index);
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              6.0,
                            ), // Reduced padding from 8.0 to 6.0
                            child: SvgPicture.asset(
                              AppIcon.editIcon,
                              height: 20.w,
                              width: 20.w,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () {
                            if (controller.selectedIndex.value >= 0) {
                              controller.deleteWork(
                                controller.selectedIndex.value,
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(
                              6.0,
                            ), // Reduced padding from 8.0 to 6.0
                            child: SvgPicture.asset(
                              AppIcon.deleteIcon,
                              height: 20.w,
                              width: 20.w,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                // Data Table
                Expanded(
                  child: GetBuilder<AddSparePartsController>(
                    builder: (addSparePartsController) {
                      return Obx(
                        () => SparePartsDataTable(
                          spareParts: addSparePartsController.filteredWorks,
                          onSparePartTap: addSparePartsController.selectWork,
                          selectedIndex:
                              addSparePartsController.selectedIndex.value,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 4.h),
                // Total amount
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.red),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SvgPicture.asset(height: 20.w, AppIcon.riyalRed),
                      const SizedBox(width: 4),
                      Obx(
                        () => CustomText(
                          text: controller.totalAmount.toStringAsFixed(2),
                          fontSize: 18.w,
                          color: AppColors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      CustomText(
                        text: 'total_amount_of_spare_parts'.tr,
                        fontSize: 12.w,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
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
                        backgroundColor: AppColors.redTextFiled,
                        textColor: AppColors.red,
                      ),
                      SizedBox(width: 20.w),
                      Obx(
                        () => NextButton(
                          text: controller.isLoading.value
                              ? 'loading..'.tr
                              : 'next'.tr,
                          onTap: () {
                            controller.isLoading.value
                                ? null
                                : controller.submitSpareParts();
                          },
                          textColor: (controller.works.isEmpty &&
                                  controller.sparePartsAdded.value == true)
                              ? Colors.white
                              : Colors.white,
                          backgroundColor: (controller.works.isEmpty &&
                                  controller.sparePartsAdded.value == true)
                              ? Colors.grey
                              : AppColors.primary,
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
