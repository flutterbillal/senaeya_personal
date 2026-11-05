import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/previous_invoices_screen/common_parse_date/converted_date.dart';
import 'package:Senaeya/View/Screens/previous_invoices_screen/model/previous_invoices_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../custom_alert_dialog/custom_alert_dialog.dart';
import '../custom_text/custom_text.dart';
import '../liscence_plate_widget.dart';

class CustomerInvoiceCard extends StatelessWidget {
  final InvoiceModel? invoice;
  final String carBrand;
  final String carModel;
  final String carYear;

  final String carNumber;
  final String invoiceAmount;
  final String invoiceDate;
  final String invoiceStatus;
  final VoidCallback? onTapPay;
  final VoidCallback? onTapDefaultersList;
  final VoidCallback? onTapExtendTime;
  final bool isLoading;

  const CustomerInvoiceCard({
    this.invoice,
    super.key,
    this.carBrand = "",
    this.carModel = "",
    this.carYear = "",
    this.carNumber = "",
    this.invoiceAmount = "",
    this.invoiceDate = "",
    required this.invoiceStatus,
    this.onTapPay,
    this.onTapDefaultersList,
    this.onTapExtendTime,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate if invoice is older than 5 days
    bool hasNotAvailableDay = true;
    final car = invoice?.car ?? '';
    final DateTime now = DateTime.now();

    if (invoice?.postPaymentDate != null) {
      final DateTime postDate = invoice!.postPaymentDate!;

      if (now.isBefore(postDate)) {
        hasNotAvailableDay = false;
      }
    } else {
      // If no post payment date, check createdAt date
      final DateTime createDate = invoice!.createdAt!;
      if ((now.difference(createDate).inDays < 10)) {
        hasNotAvailableDay = false;
      }
    }
    // print("===================hasNotAvailAbleDate:$hasNotAvailableDay");

    // Show warning if invoice is "release_invoice" or "pay_invoice" AND older than 5 days
    bool warningView = (invoiceStatus == "release_invoice".tr ||
            invoiceStatus == "pay_invoice".tr) &&
        hasNotAvailableDay;

    Color invoiceColor = invoiceStatus == "view_invoice".tr
        ? Colors.green
        : invoiceStatus == "pay_invoice".tr
            ? Colors.orange
            : AppColors.red;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            color: AppColors.primary, // Blue background matching app theme
            margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
            child: Stack(
              children: [
                // Top-left CircleAvatar
                Positioned(
                  top: 4.h,
                  left: 4.w,
                  child: CircleAvatar(
                    radius: 6.w,
                    backgroundColor: invoiceColor,
                  ),
                ),
                // Warning icon - fixed position
                if (warningView)
                  Positioned(
                    top: 20.h,
                    left: 140.w, // Adjust this value based on your layout
                    child: GestureDetector(
                      onTap: () {
                        CustomAlert.showConfirmationColumn(
                          onYesPressed: () {
                            Get.back();
                            onTapDefaultersList?.call();
                          },
                          onNoPressed: () {
                            Get.back();
                            onTapExtendTime?.call();
                          },
                          context: context,
                          title: "The customer has an overdue invoice".tr,
                          yesButtonText:
                              "Add or Remove from the defaulters list".tr,
                          noButtonText: "Give the customer extra time".tr,
                          message:
                              "Do you want to place the customer\non the defaulters list?"
                                  .tr,
                        );
                      },
                      child: SvgPicture.asset(
                        AppIcon.warning,
                        height: 32.w,
                        width: 32.w,
                      ),
                    ),
                  ),
                // Main content with padding to avoid overlap
                Padding(
                  padding: EdgeInsets.only(top: 4.w, left: 16.w, right: 16.w),
                  child: Row(
                    children: [
                      // Left side - Toyota logo and car info
                      Expanded(
                        flex: 3,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                car.toString().isNotEmpty
                                    ? Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                // Removed CircleAvatar from here since it's now positioned at top-left
                                                Image.network(
                                                  "${ApiConstant.imageBaseUrl}${invoice?.car?.brand?.image ?? ''}",
                                                  width: 26.w,
                                                  height: 26.w,
                                                ),
                                                SizedBox(width: 6.w),
                                                // Brand name
                                                Expanded(
                                                  child: CustomText(
                                                    text: invoice?.car?.brand
                                                            ?.title ??
                                                        '',
                                                    color: Colors.white,
                                                    fontSize: 18.sp,
                                                    fontWeight: FontWeight.bold,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.h),
                                            // Car model and year row
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: CustomText(
                                                    text: invoice?.car?.model
                                                            ?.title ??
                                                        '',
                                                    color: Colors.white,
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 2,
                                                  ),
                                                ),
                                                SizedBox(width: 8.w),
                                                CustomText(
                                                  text:
                                                      invoice?.car?.year ?? '',
                                                  color: Colors.white,
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                SizedBox(
                                                  width: 4.w,
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    : Column(
                                        children: [
                                          const CustomText(
                                            text: "Workshop",
                                            color: Colors.white,
                                          ),
                                          CustomText(
                                            text: invoice?.client
                                                    ?.workShopNameAsClient ??
                                                '',
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcon.riyalWhite,
                                  width: 16.w,
                                  height: 16.w,
                                ),
                                Flexible(
                                  child: CustomText(
                                    maxLines: 2,
                                    text:
                                        " ${invoice?.finalCost ?? 0}  inv. amount",
                                    color: Colors.white,
                                    fontSize: 14.w,
                                    fontWeight: FontWeight.w700,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            (invoiceStatus != "view_invoice".tr &&
                                    invoice?.postPaymentDate != null &&
                                    invoice!.postPaymentDate
                                        .toString()
                                        .isNotEmpty)
                                ? Row(
                                    children: [
                                      Flexible(
                                        child: CustomText(
                                          text: FormateDateTime
                                              .convertToDueDateFormat(
                                            (invoice!.postPaymentDate),
                                          ),
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          maxLines: 2,
                                        ),
                                      ),
                                      SizedBox(width: 4.w),
                                      Flexible(
                                        child: CustomText(
                                          text: "Due Date",
                                          color: Colors.white,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w500,
                                          maxLines: 2,
                                        ),
                                      ),
                                    ],
                                  )
                                : SizedBox(),
                            SizedBox(height: 4.h),

                            CustomText(
                              text: FormateDateTime.formatDateTime(
                                invoiceStatus != "view_invoice".tr
                                    ? (invoice?.createdAt != null
                                        ? invoice!.createdAt
                                        : DateTime.now())
                                    : (invoice?.payment?.createdAt != null
                                        ? invoice!.payment!.createdAt
                                        : DateTime.now()),
                              ),
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              maxLines: 2,
                            ),
                            SizedBox(height: 4.h),

                            // Action icons row
                          ],
                        ),
                      ),

                      // Right side - Car invoices section
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (isLoading) return; // Prevent tap when loading
                              if (invoiceStatus == "view_invoice".tr) {
                                final Uri url = Uri.parse(
                                    "https://report-v2.senaeya.net/invoice/${invoice?.id ?? ''}?providerWorkShopId=${invoice?.providerWorkShopId ?? ''}");
                                _launchUrl(url);
                                // Get.toNamed(
                                //   AppRoute.pdfDownLoadSceen,
                                //   arguments: {
                                //     'invoice': invoice?.invoiceAwsLink ?? '',
                                //   },
                                // );
                              } else {
                                Get.toNamed(AppRoute.invoiceSummaryScreen,
                                    arguments: {
                                      "invoiceId": invoice?.id ?? ''
                                    });
                              }
                            },
                            child: Container(
                              width: 120.w,
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: isLoading
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 20.w,
                                          height: 20.w,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              invoiceColor,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 4.h),
                                        CustomText(
                                          text: "Processing...".tr,
                                          fontWeight: FontWeight.w600,
                                          color: invoiceColor,
                                          fontSize: 12.sp,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                  : CustomText(
                                      text: invoiceStatus,
                                      fontWeight: FontWeight.w700,
                                      color: invoiceColor,
                                      fontSize: 14.sp,
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                          SizedBox(height: 10.h),
                          if ((car.toString().isNotEmpty) &&
                              (invoice?.car?.plateNumberForInternational
                                          ?.isNotEmpty !=
                                      null &&
                                  invoice?.car?.plateNumberForInternational
                                          ?.isNotEmpty ==
                                      true))
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: CustomText(
                                  text: invoice
                                          ?.car?.plateNumberForInternational ??
                                      '',
                                ),
                              ),
                            ),
                          if ((car.toString().isNotEmpty) &&
                              (invoice?.car?.plateNumberForInternational
                                          ?.isNotEmpty ==
                                      null ||
                                  invoice?.car?.plateNumberForInternational
                                          .isNotEmpty ==
                                      false))
                            SaudiLicensePlate(
                              width: 120.w,
                              saudiCarPlateImage: invoice?.car
                                      ?.plateNumberForSaudi?.symbol?.image ??
                                  '',
                              plateNumber: invoice?.car?.plateNumberForSaudi
                                      ?.numberEnglish ??
                                  '',
                              plateLetters: invoice?.car?.plateNumberForSaudi
                                      ?.alphabetsCombinations?[0] ??
                                  '',
                              borderColor: Colors.black,
                              textColor: Colors.black,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(Uri url) async {
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
