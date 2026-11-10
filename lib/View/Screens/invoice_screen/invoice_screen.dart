import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/View/Screens/invoice_screen/widget/invoice_widget.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/View/Screens/auth_screens/login_screen/widgets/custom_button.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:Senaeya/View/Widgets/invoice_card.dart';
import 'controller/invoice_screen_controller.dart';

class InvoiceScreen extends StatelessWidget {
  const InvoiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<InvoiceScreenController>();

    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: AppColors.primary,
          appBar: CustomAppBar(
            title: "Invoice".tr,
            titleColor: Colors.black,
            centerTitle: true,
            //blueCloud: true,
            blackHomeIcon: true,
          ),
          body: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = controller.invoiceScreenModel.value?.data;
            if (data == null) {
              return Center(
                  child: CustomText(text: 'No invoice data available'.tr));
            }

            // Calculate amounts
            // Safely convert dynamic values (could be int, double, or String) to double
            double _toDouble(dynamic v) {
              if (v == null) return 0.0;
              if (v is double) return v;
              if (v is int) return v.toDouble();
              if (v is String) return double.tryParse(v) ?? 0.0;
              if (v is num) return v.toDouble();
              return 0.0;
            }

            final price = _toDouble(data.price);
            final amountPaid = _toDouble(data.amountPaid);
            final discount = (price - amountPaid);
            const taxRate = 0.15;

            // Compute price before tax from the paid amount (inclusive of tax): priceBeforeTax = amountPaid / (1 + taxRate)
            // Guard against division by zero and unexpected values
            final priceBeforeTax =
                (1 + taxRate) != 0 ? (amountPaid / (1 + taxRate)) : 0.0;

            // taxAmount = amountPaid - priceBeforeTax
            double taxAmount = amountPaid - priceBeforeTax;

            // Clamp tiny floating point artifacts to zero (for display) and ensure non-negative
            if (taxAmount.abs() < 0.0005) taxAmount = 0.0;
            if (taxAmount < 0) taxAmount = 0.0;

            appLog(
                'UI calc -> price: $price, amountPaid: $amountPaid, priceBeforeTax: $priceBeforeTax, taxAmount: $taxAmount');

            appLog('taxAmount: $taxAmount');
            print(
                "==================================${ApiConstant.imageBaseUrl + (controller.invoiceScreenModel.value?.data?.qrImage ?? '')}");

            // Format dates
            final createdDate = data.createdAt != null
                ? DateFormat('dd-MM-yyyy hh:mm a').format(
                    data.createdAt!.toUtc().add(const Duration(hours: 3)),
                  )
                : '';
            final expiryDate = data.currentPeriodEnd != null
                ? DateFormat('dd-MM-yyyy').format(data.currentPeriodEnd!)
                : '';

            return Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      height: 80.w,
                      width: 80.w,
                      decoration: BoxDecoration(
                        color: const Color(0xffFFFFFF),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(-1, 2),
                          ),
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 2,
                            offset: Offset(1, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: SvgPicture.asset(AppLogo.appLogo,
                            fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 6.w),
                    CustomText(text: "فاتورة ضريبية مبسطة", fontSize: 15.w),
                    CustomText(
                        text: "تطبيق الصناعية .. مسجل لدى", fontSize: 18.w),
                    CustomText(
                      text: "مؤسسة مرافئ التجارية",
                      fontWeight: FontWeight.w700,
                      fontSize: 20.w,
                    ),
                    CustomText(
                      text: "الرياض - العليا - طريق مكة المكرمة",
                      fontWeight: FontWeight.w700,
                      fontSize: 14.w,
                    ),
                    CustomText(
                      text:
                          "CR: ${controller.invoiceScreenModel.value?.data?.workshop?.crn ?? ''}",
                      fontWeight: FontWeight.w400,
                      fontSize: 14.w,
                    ),
                    CustomText(
                      text:
                          // "VAT: ${controller.invoiceScreenModel.value?.data?.workshop?.taxVatNumber ?? ''}",
                          "VAT: 300787972600003",
                      fontWeight: FontWeight.w400,
                      fontSize: 14.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: createdDate,
                          fontWeight: FontWeight.w400,
                          fontSize: 14.w,
                        ),
                        Row(
                          children: [
                            CustomText(
                              text: controller.invoiceScreenModel.value?.data
                                          ?.recieptNumber !=
                                      null
                                  ? "${controller.invoiceScreenModel.value!.data!.recieptNumber!}"
                                  : 'N/A',
                              fontWeight: FontWeight.w700,
                              fontSize: 20.w,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 8.w),
                            CustomText(
                              text: "رقم الفاتورة",
                              fontWeight: FontWeight.w400,
                              fontSize: 18.w,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(height: 2.h),
                    SizedBox(height: 10.h),
                    CustomText(
                      text:
                          "(${controller.invoiceScreenModel.value?.data?.workshop?.workshopNameArabic ?? ''})",
                      fontSize: 16.w,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                            text:
                                "VAT: ${controller.invoiceScreenModel.value?.data?.workshop?.taxVatNumber ?? ''}",
                            fontSize: 16.w),
                        CustomText(
                            text: controller.invoiceScreenModel.value?.data
                                    ?.workshop?.contact ??
                                '',
                            fontSize: 16.w),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.textFiledColor,
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              decoration: const BoxDecoration(
                                border: Border(
                                  right: BorderSide(color: Colors.grey),
                                ),
                              ),
                              child: Column(
                                children: [
                                  CustomText(
                                    text: "الاشتراك في تطبيق الصناعية",
                                    fontSize: 14.w,
                                  ),
                                  Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CustomText(
                                          text: "12 months +",
                                          fontSize: 15.w,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                        CustomText(
                                          text: "6 months free",
                                          fontSize: 12.w,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: CustomText(
                              text: "تفاصيل الفاتورة",
                              fontSize: 16.w,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                    InvoiceCard(
                      title: "    ${priceBeforeTax.toStringAsFixed(2)} ",
                      rightText: "المبلغ قبل الضريبة",
                      icon: AppIcon.riyal,
                    ),
                    SizedBox(height: 4.h),
                    InvoiceCard(
                      title: "    ${discount.toStringAsFixed(2)} ",
                      rightText: "مبلغ الخصم",
                      icon: AppIcon.riyalRed,
                      fontWeight: FontWeight.w400,
                      tittleColor: AppColors.red,
                    ),
                    SizedBox(height: 4.h),
                    InvoiceCard(
                      title: "    ${taxAmount.toStringAsFixed(2)} ",
                      rightText: "ضريبة القيمة المضافة",
                      icon: AppIcon.riyal,
                      vatText: "(TAX 15%)",
                      fontWeight: FontWeight.w400,
                    ),
                    SizedBox(height: 4.h),
                    InvoiceCard(
                      extraPadding: true,
                      title: "    ${amountPaid.toStringAsFixed(2)} ",
                      rightText: "المجموع شامل الضريبة",
                      icon: AppIcon.riyalBlue,
                      fontWeight: FontWeight.bold,
                      tittleColor: AppColors.primary,
                      tittleFontWeight: FontWeight.w700,
                      borderColor: AppColors.primary,
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      width: 300.w,
                      decoration: BoxDecoration(
                        color: AppColors.redTextFiled,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(4.0.r),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: expiryDate,
                              fontSize: 16.w,
                              color: AppColors.red,
                            ),
                            CustomText(
                              text: "ينتهي اشتراك التطبيق بتاريخ",
                              fontSize: 16.w,
                              color: AppColors.red,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    SizedBox(
                        height: 100.h,
                        width: 100.w,
                        child: Image.network(
                          ApiConstant.imageBaseUrl +
                              (controller.invoiceScreenModel.value?.data
                                      ?.qrImage ??
                                  ''),
                        )
                        // fit: BoxFit.cover,
                        // PrettyQrView.data(data: data.id ?? 'invoice'),
                        ),
                    SizedBox(height: 10.h),
                    Padding(
                      padding: const EdgeInsets.only(left: 28.0, right: 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // GestureDetector(
                          //   onTap: () {
                          //     // Add share functionality here
                          //   },
                          //   child: SvgPicture.asset(AppIcon.share),
                          // ),
                          const SizedBox.shrink(),

                          GestureDetector(
                            onTap: () => generatePDF(context, controller),
                            child: SvgPicture.asset(AppIcon.download),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                    CustomButton(
                      text: "End And Return".tr,
                      backgroundColor: AppColors.primary,
                      onPressed: () {
                        Get.offAllNamed(AppRoute.navScreen);
                      },
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
