import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/View/Screens/previous_invoices_screen/common_parse_date/converted_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../custom_text/custom_text.dart';
import '../liscence_plate_widget.dart';
import 'package:Senaeya/View/Screens/customer_cars_screen/model/client_car_list_model.dart';

class CarCard extends StatelessWidget {
  final CarModel? car;
  final String carBrand;
  final String carModel;
  final String carYear;
  final String registrationDate;
  final String carNumber;
  final String invoiceAmount;
  final String invoiceDate;

  const CarCard({
    super.key,
    this.car,
    this.carBrand = "",
    this.carModel = "",
    this.carYear = "",
    this.registrationDate = "",
    this.carNumber = "",
    this.invoiceAmount = "",
    this.invoiceDate = "",
  });

  @override
  Widget build(BuildContext context) {
    final brandTitle = car?.brand?.title ?? carBrand;
    // Use vin as model fallback
    final brandImage = car?.brand?.image ?? '';
    final modelTitle = car?.model?.title ?? '';
    final yearTitle = car?.year ?? carYear;
    final regDate = car?.createdAt != null
        ? FormateDateTime.formatDateTime(car!.createdAt!)
        : registrationDate;
    final plateNumber = car?.plateNumberForSaudi?.numberEnglish ?? carNumber;
    final plateLetters =
        (car?.plateNumberForSaudi?.alphabetsCombinations != null &&
                car!.plateNumberForSaudi!.alphabetsCombinations!.isNotEmpty)
            ? car!.plateNumberForSaudi!.alphabetsCombinations![0]
            : 'TGD';

    print('Plate Letters: $plateLetters');
    print('Plate Number: $plateNumber');
    print('Brand Title: $brandTitle');
    print('Brand Image: $brandImage');
    print('Model Title: $modelTitle');
    print('Year Title: $yearTitle');
    appLog("saudi car image:${car?.plateNumberForSaudi?.symbol?.image ?? ''}");

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        color: const Color(0xFF1771B7), // Blue background matching app theme
        margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              // Left side - logo and car info
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Center(
                          child: Image.network(
                            ApiConstant.imageBaseUrl + brandImage,
                            width: 26.w,
                            height: 26.w,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        CustomText(
                          text: brandTitle,
                          color: Colors.white,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Text(
                          modelTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 30.w),
                        Text(
                          yearTitle,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomText(
                      text: "Car registration date",
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    SizedBox(height: 4.h),
                    CustomText(
                      text: regDate,
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                    SizedBox(height: 12.h),
                  ],
                ),
              ),

              // Right side - Car invoices and plate
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(AppRoute.carInvoiceScreen, arguments: {
                        'carId': car?.id,
                      });
                    },
                    child: Container(
                      width: 120.w,
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: CustomText(
                        text: "Car invoices".tr,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15.w,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  (car?.plateNumberForSaudi == null ||
                          car!.plateNumberForSaudi.toString().isEmpty)
                      ? Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CustomText(
                              text: car?.plateNumberForInternational ?? '',
                            ),
                          ),
                        )
                      : SizedBox(),
                  (car?.plateNumberForSaudi != null &&
                          car!.plateNumberForSaudi.toString().isNotEmpty)
                      ? SaudiLicensePlate(
                          borderColor: Colors.black,
                          saudiCarPlateImage:
                              car?.plateNumberForSaudi?.symbol?.image ?? '',
                          textColor: Colors.black,
                          width: 120.w,
                          plateNumber: plateNumber,
                          plateLetters: plateLetters,
                        )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
