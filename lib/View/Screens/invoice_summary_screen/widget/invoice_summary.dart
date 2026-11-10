import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../Service/api_url.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../../Utils/AppImg/app_img.dart';
import '../../../Widgegts/customUserTextFiled.dart';
import '../../../Widgegts/custom_button/next_button.dart';
import '../../../Widgegts/custom_text/custom_text.dart';
import '../../../Widgegts/liscence_plate_widget.dart';
import '../../../Widgets/custom_text_style.dart';
import '../controller/invoice_summary_controller.dart';

Widget invoiceSummary(
    InvoiceSummaryController controller, BuildContext context) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Customer info
              CustomUserInputField(
                readOnly: true,
                controller: controller.nameController,
                icon: AppIcon.blueProfile,
                hintText: 'name'.tr,
              ),
              SizedBox(height: 12.h),
              CustomUserInputField(
                readOnly: true,
                controller: controller.idController,
                icon: AppIcon.phone,
                hintText: '+966 5xxxxxxxx'.tr,
              ),

              SizedBox(height: 8.h),
              // Car info
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: controller.brandName.isEmpty
                        ? CustomText(text: "Workshop")
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.network(
                                    ApiConstant.imageBaseUrl +
                                        controller.brandImage,
                                    width: 28.w,
                                    height: 28.w,
                                  ),
                                  SizedBox(width: 14.w),
                                  Flexible(
                                    child: Obx(
                                      () => CustomText(
                                        text: controller.carBrand.value,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 18.sp,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  Flexible(
                                    flex: 3,
                                    child: Obx(
                                      () => CustomText(
                                        text: controller.carModel.value,
                                        fontSize: 16.sp,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 30.w),
                                  Flexible(
                                    flex: 1,
                                    child: Obx(
                                      () => CustomText(
                                        text: controller.carYear.value,
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
                  SizedBox(width: 8.w),
                  Obx(() {
                    // Use controller getter methods that prioritize arguments over invoice data
                    if (controller.isSaudiPlate) {
                      return SaudiLicensePlate(
                        saudiCarPlateImage: controller.displaySymbolImage,
                        arabicText: controller.displayPlateArabicText,
                        plateNumber: controller.displayPlateNumber,
                        plateLetters: controller.displayPlateLetters,
                        textColor: Colors.black,
                        borderColor: Colors.black,
                      );
                    } else if (controller.isInternationalPlate) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CustomText(
                            text: controller.displayPlateNumber,
                          ),
                        ),
                      );
                    } else {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.black),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CustomText(text: 'N/A'),
                        ),
                      );
                    }
                  }),
                ],
              ),
              SizedBox(height: 8.h),
              // Costs
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 4,
                        bottom: 4,
                        left: 8,
                        right: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textFiledColor,
                        border: Border.all(color: AppColors.red),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CustomText(
                            overflow: TextOverflow.visible,
                            text: 'cost_of_spare_parts'.tr,
                            fontSize: 12.w,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                height: 20.w,
                                AppIcon.riyalRed,
                              ),
                              const SizedBox(width: 4),
                              Obx(
                                () => CustomText(
                                  text: controller.sparePartsCost.value
                                      .toStringAsFixed(2),
                                  fontSize: 20.w,
                                  color: AppColors.red,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 6.h),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.only(
                        top: 4,
                        bottom: 4,
                        left: 8,
                        right: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.textFiledColor,
                        border: Border.all(color: AppColors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          CustomText(
                            overflow: TextOverflow.visible,
                            text: 'cost_of_workshop'.tr,
                            fontSize: 12.w,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                height: 20.w,
                                AppIcon.riyalRed,
                              ),
                              const SizedBox(width: 4),
                              Obx(
                                () => CustomText(
                                  text: controller.workshopCost.value
                                      .toStringAsFixed(2),
                                  fontSize: 20.w,
                                  color: AppColors.red,
                                  fontWeight: FontWeight.w300,
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppIcon.riyalWhite,
                      height: 24.w,
                      width: 24.w,
                    ),
                    SizedBox(width: 6.w),
                    Obx(
                      () => CustomText(
                        text: controller.totalAmountDue.toStringAsFixed(2),
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    CustomText(
                      text: 'total_amount_due'.tr,
                      fontSize: 18.w,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: CustomText(
                      text: 'pay_method'.tr,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.w,
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              // Pay method
              Obx(
                () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<PayMethod>(
                          value: PayMethod.postpaid,
                          groupValue: controller.payMethod.value,
                          onChanged: (val) =>
                              controller.setPayMethod(PayMethod.postpaid),
                          activeColor: AppColors.primary,
                          // materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                        CustomText(
                          text: 'postpaid'.tr,
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<PayMethod>(
                          value: PayMethod.transfer,
                          groupValue: controller.payMethod.value,
                          onChanged: (val) =>
                              controller.setPayMethod(PayMethod.transfer),
                          activeColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                        CustomText(
                          text: 'transfer'.tr,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.w,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<PayMethod>(
                          value: PayMethod.card,
                          groupValue: controller.payMethod.value,
                          onChanged: (val) =>
                              controller.setPayMethod(PayMethod.card),
                          activeColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                        CustomText(
                          text: 'card'.tr,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.w,
                        ),
                      ],
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Radio<PayMethod>(
                          value: PayMethod.cash,
                          groupValue: controller.payMethod.value,
                          onChanged: (val) =>
                              controller.setPayMethod(PayMethod.cash),
                          activeColor: AppColors.primary,
                          visualDensity: VisualDensity.compact,
                        ),
                        CustomText(
                          text: 'cash'.tr,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.w,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),
              // Conditional fields
              Obx(() {
                // Show nothing if no payment method is selected
                if (controller.payMethod.value == null) {
                  return SizedBox.shrink();
                }

                switch (controller.payMethod.value!) {
                  case PayMethod.cash:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'if_cash_receive_money'.tr,
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: controller.receiveCash.value,
                              onChanged: (val) =>
                                  controller.setReceiveCash(true),
                              activeColor: AppColors.primary,
                            ),
                            CustomText(
                              text: 'yes'.tr,
                              fontSize: 16.w,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(width: 20.w),
                            Radio<bool>(
                              value: false,
                              groupValue: controller.receiveCash.value,
                              onChanged: (val) =>
                                  controller.setReceiveCash(false),
                              activeColor: AppColors.primary,
                            ),
                            CustomText(
                              text: 'no'.tr,
                              fontSize: 16.w,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ],
                    );
                  case PayMethod.card:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'if_card_enter_approval_code'.tr,
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(
                          width: 120,
                          child: TextFormField(
                            onTapOutside: (_) {
                              FocusScope.of(Get.key.currentContext!).unfocus();
                            },
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: customTextStyle(fontSize: 22.h),
                            initialValue: controller.cardApprovalCode.value,
                            onChanged: controller.setCardApprovalCode,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  case PayMethod.transfer:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'if_transfer_receive_transfer'.tr,
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Radio<bool>(
                              value: true,
                              groupValue: controller.receiveTransfer.value,
                              onChanged: (val) =>
                                  controller.setReceiveTransfer(true),
                              activeColor: AppColors.primary,
                            ),
                            CustomText(
                              text: 'yes'.tr,
                              fontSize: 16.w,
                              fontWeight: FontWeight.bold,
                            ),
                            SizedBox(width: 20.w),
                            Radio<bool>(
                              value: false,
                              groupValue: controller.receiveTransfer.value,
                              onChanged: (val) =>
                                  controller.setReceiveTransfer(false),
                              activeColor: AppColors.primary,
                            ),
                            CustomText(
                              text: 'no'.tr,
                              fontSize: 16.w,
                              fontWeight: FontWeight.bold,
                            ),
                          ],
                        ),
                      ],
                    );
                  case PayMethod.postpaid:
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomText(
                          text: 'if_postpaid_select_payment_date'.tr,
                          fontSize: 16.w,
                          fontWeight: FontWeight.bold,
                        ),
                        SizedBox(
                          width: 160,
                          child: TextFormField(
                            readOnly: true,
                            textAlign: TextAlign.center,
                            decoration: const InputDecoration(
                              hintText: 'DD-MM-YYYY',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                            ),
                            onTap: () async {
                              DateTime? picked = await _showDatePicker(context);

                              if (picked != null) {
                                controller.setPostpaidDate(
                                  '${picked.day.toString().padLeft(2, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.year}',
                                  picked,
                                );
                              }
                            },
                            controller: TextEditingController(
                              text: controller.postpaidDate.value,
                            ),
                          ),
                        ),
                      ],
                    );
                }
              }),
            ],
          ),
        ),
      ),
      SizedBox(height: 16.h),
      Obx(() {
        // Always show both buttons
        bool isCard = controller.payMethod.value == PayMethod.card;
        bool validCardCode = controller.cardApprovalCode.value.length == 6;
        return Row(
          children: [
            (controller.saveIsLoading.value || controller.nextIsLoading.value)
                ? SizedBox()
                : NextButton(
                    text: 'save_invoice'.tr,
                    onTap: isCard
                        ? () {}
                        : (controller.canSaveInvoice
                            ? () {
                                controller.showYesNoDialog(
                                    context: context,
                                    onYes: () {
                                      controller.invoiceId.isNotEmpty
                                          ? Get.back()
                                          : controller.onTapRelease(
                                              saveLoading: true,
                                            );
                                    },
                                    title: 'do_you_want_to_save_invoice'.tr);
                              }
                            : () {}),
                    backgroundColor: isCard
                        ? Colors.grey
                        : (controller.canSaveInvoice
                            ? AppColors.redTextFiled
                            : Colors.grey),
                    textColor: isCard
                        ? Colors.white
                        : (controller.canSaveInvoice
                            ? AppColors.red
                            : Colors.white),
                  ),
            const SizedBox(width: 20),
            (controller.nextIsLoading.value || controller.saveIsLoading.value)
                ? SizedBox()
                : NextButton(
                    text: 'release_invoice'.tr,
                    onTap: isCard
                        ? (validCardCode
                            ? () {
                                controller.showYesNoDialog(
                                    context: context,
                                    onYes: () {
                                      controller.onTapRelease();
                                    },
                                    title: 'do_you_want_to_release_invoice'.tr);
                              }
                            : () {})
                        : (controller.canReleaseInvoice
                            ? (controller.payMethod.value?.name == "postpaid"
                                ? () {
                                    controller.showYesNoDialog(
                                        context: context,
                                        onYes: () {
                                          controller.onTapPostPaid();
                                        },
                                        title: 'do_you_want_to_release_invoice'
                                            .tr);
                                  }
                                : () {
                                    controller.showYesNoDialog(
                                        context: context,
                                        onYes: () {
                                          controller.onTapRelease();
                                        },
                                        title: 'do_you_want_to_release_invoice'
                                            .tr);
                                  })
                            : () {}),
                    backgroundColor: isCard
                        ? (validCardCode ? AppColors.primary : Colors.grey)
                        : (controller.canReleaseInvoice
                            ? AppColors.primary
                            : Colors.grey),
                    textColor: isCard
                        ? (validCardCode ? Colors.white : Colors.white)
                        : (controller.canReleaseInvoice
                            ? Colors.white
                            : Colors.white),
                  ),
          ],
        );
      }),
    ],
  );
}

Future<DateTime?> _showDatePicker(BuildContext context) {
  return showDatePicker(
    context: context,
    initialDate: DateTime.now(),
    firstDate: DateTime(2020),
    lastDate: DateTime(2100),
    builder: (BuildContext context, Widget? child) {
      return Theme(
        data: Theme.of(context).copyWith(
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              iconColor: MaterialStateProperty.all(Color(0xFF1771B7)),
            ),
          ),
          colorScheme: const ColorScheme(
            brightness: Brightness.light,
            primary: Color(0xFF1771B7), // selected date background color
            onPrimary: Colors.white,
            secondary: Colors.black,
            onSecondary: Colors.red,
            error: Colors.red,
            onError: Colors.red,
            surface: Color(0xFFF4F5F7),
            onSurface: Colors.black,
          ),
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: child!,
        ),
      );
    },
  );
}
