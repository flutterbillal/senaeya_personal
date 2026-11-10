import 'package:Senaeya/View/Widgegts/customar_car_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../../../Service/api_url.dart';
import '../../../Utils/AppColors/app_colors.dart';
import '../../../Utils/AppImg/app_img.dart';
import '../../Widgegts/custom_text/custom_text.dart';
import '../../Widgets/carplate_text_filed.dart';
import '../../Widgets/commonTextWithoutResize.dart';
import 'package:flutter/services.dart';
import 'controller/customers_screen_controller.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // White status bar
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    );
    CustomersScreenController controller =
        Get.find<CustomersScreenController>();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF1771B7),
        appBar: CustomAppBar(
          backgroundColor: Colors.white,
          title: 'customers'.tr,
          titleColor: Colors.black,
          blackHomeIcon: true,
          backButtonColor: Colors.black,
          //blueCloud: true,
          centerTitle: true,
        ),
        body: Obx(
          () => controller.isLoading.value
              ? Center(
                  child: Image.asset(
                    AppImages.loading,
                    width: 150.w,
                    height: 150.w,
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12.0, bottom: 12.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height,
                      width: 0.92.sw,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 20.h,
                      ),
                      child: Stack(
                        children: [
                          SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //add a search filed like the image
                                    SizedBox(height: 12.h),
                                    // Search field for phone number with search button
                                    Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color(0xffF4F5F7),
                                            borderRadius: BorderRadius.circular(
                                              24.r,
                                            ),
                                          ),
                                          child: Directionality(
                                            textDirection: TextDirection.ltr,
                                            child: IntlPhoneField(
                                              pickerDialogStyle:
                                                  PickerDialogStyle(
                                                searchFieldInputDecoration:
                                                    InputDecoration(
                                                  hintText:
                                                      'Search Country/Region'
                                                          .tr,
                                                ),
                                              ),
                                              controller:
                                                  controller.numberController,
                                              initialCountryCode: 'SA',
                                              onChanged: (phone) {
                                                // Update the phone value with complete number including country code
                                                controller.setPhone(
                                                    phone.completeNumber);
                                              },
                                              decoration: InputDecoration(
                                                labelText: 'phone_number'.tr,
                                                hintText: '5xxxxxxx',
                                                filled: true,
                                                fillColor:
                                                    const Color(0xffF4F5F7),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.r),
                                                  borderSide: BorderSide.none,
                                                ),
                                                counterText: '',
                                                // Remove suffixIcon completely
                                              ),
                                              dropdownDecoration: BoxDecoration(
                                                color: AppColors.textFiledColor,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12.r,
                                                ),
                                              ),
                                              // ... other properties
                                            ),
                                          ),
                                        ),
                                        // Position button absolutely
                                        Positioned(
                                          right: 12.w,
                                          top: 0,
                                          bottom: 0,
                                          child: Center(
                                            child: GestureDetector(
                                              onTap: () {
                                                controller
                                                    .getCustomerListByPhone();
                                              },
                                              child: Container(
                                                width: 60.w,
                                                height: 36.w,
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          24.r),
                                                ),
                                                child: const Icon(
                                                  Icons.search,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    SizedBox(height: 12.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          // Add Expanded wrapper
                                          child: Container(
                                            height: 50.w,
                                            width: 138.w,
                                            padding: EdgeInsets.symmetric(
                                              vertical: 8.h,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[100],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                12.r,
                                              ),
                                            ),
                                            child: Center(
                                              // child: TextField(
                                              //   controller: controller.plateNumberController,
                                              //   textAlign: TextAlign.center,
                                              //   onTapOutside: (_) =>
                                              //       FocusScope.of(context).unfocus(),
                                              //   style: customTextStyle(
                                              //     fontSize: 32.sp,
                                              //     fontWeight: FontWeight.bold,
                                              //   ),
                                              //   keyboardType: TextInputType.number,
                                              //   decoration: const InputDecoration(
                                              //     border: InputBorder.none,
                                              //     hintText: '----',
                                              //   ),
                                              //   onChanged:
                                              //   controller.setPlateNumber,
                                              // ),
                                              child: CarplateTextFiled(
                                                  onChanged: controller
                                                      .setPlateNumber),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        Obx(
                                          () => Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Radio<int>(
                                                    value: 0,
                                                    groupValue: controller
                                                        .boardType.value,
                                                    onChanged:
                                                        controller.setBoardType,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    activeColor:
                                                        AppColors.primary,
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
                                                    groupValue: controller
                                                        .boardType.value,
                                                    onChanged:
                                                        controller.setBoardType,
                                                    materialTapTargetSize:
                                                        MaterialTapTargetSize
                                                            .shrinkWrap,
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                    activeColor:
                                                        AppColors.primary,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: List.generate(
                                        3,
                                        (i) => Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 4.w,
                                            ),
                                            child: PopupMenuButton<String>(
                                              color: AppColors.textFiledColor,
                                              onSelected: (val) => controller
                                                  .setPlateLetter(i, val),
                                              itemBuilder: (context) =>
                                                  controller.letterOptions
                                                      .map(
                                                        (e) => PopupMenuItem<
                                                            String>(
                                                          value: "${e['en']}",
                                                          child: Center(
                                                            child:
                                                                Directionality(
                                                              textDirection:
                                                                  TextDirection
                                                                      .ltr,
                                                              child:
                                                                  Commontextwithoutresize(
                                                                text:
                                                                    "${e['en']}-${e['ar']}",
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                fontSize: 26.w,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                      .toList(),
                                              child: Container(
                                                height: 56.h,
                                                decoration: BoxDecoration(
                                                  color:
                                                      AppColors.textFiledColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          2.r),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    left: 8.0,
                                                    right: 8,
                                                  ),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      Obx(() {
                                                        final en = controller
                                                            .plateLetters[i];
                                                        // Show "---" if nothing is selected, otherwise show selected value
                                                        if (en.isEmpty) {
                                                          return CustomText(
                                                            text: "---",
                                                            fontSize: 27.w,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.grey,
                                                          );
                                                        } else {
                                                          final ar = controller
                                                              .letterOptions
                                                              .firstWhere(
                                                            (e) =>
                                                                e['en'] == en,
                                                            orElse: () => {
                                                              'ar': '',
                                                            },
                                                          )['ar'];
                                                          return Commontextwithoutresize(
                                                            text: "$en - $ar",
                                                            fontSize: 27.w,
                                                            fontWeight:
                                                                FontWeight.bold,
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
                                    Obx(
                                      () => controller.carSymbols.isEmpty
                                          ? const SizedBox()
                                          : SingleChildScrollView(
                                              scrollDirection: Axis.horizontal,
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: List.generate(
                                                  controller.carSymbols.length,
                                                  (i) => Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 8.w),
                                                    child: Column(
                                                      children: [
                                                        Obx(
                                                          () => GestureDetector(
                                                            onTap: () {
                                                              controller
                                                                  .setSelectedColor(
                                                                      i);
                                                              controller
                                                                  .selectedCarSymbolId
                                                                  .value = controller
                                                                      .carSymbols[
                                                                          i]
                                                                      .sId ??
                                                                  '';
                                                              // print("Selected Car Symbol ID: ${controller.selectedCarSymbolId.value}");
                                                            },
                                                            child: Radio<int>(
                                                              value: i,
                                                              groupValue: controller
                                                                  .selectedColor
                                                                  .value,
                                                              onChanged: (val) {
                                                                controller
                                                                    .setSelectedColor(
                                                                        val);
                                                                if (val !=
                                                                        null &&
                                                                    val <
                                                                        controller
                                                                            .carSymbols
                                                                            .length) {
                                                                  controller
                                                                      .selectedCarSymbolId
                                                                      .value = controller
                                                                          .carSymbols[
                                                                              val]
                                                                          .sId ??
                                                                      '';
                                                                  print(
                                                                      "Selected Car Symbol ID: ${controller.selectedCarSymbolId.value}");
                                                                }
                                                              },
                                                              activeColor:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                        Image.network(
                                                          ApiConstant
                                                                  .imageBaseUrl +
                                                              (controller
                                                                      .carSymbols[
                                                                          i]
                                                                      .image ??
                                                                  ''),
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
                                    ),
                                    SizedBox(height: 12.h),
                                    // Plate code field
                                    Obx(
                                      () => Row(
                                        children: [
                                          controller.boardType.value == 1
                                              ? Expanded(
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      vertical: 8.h,
                                                      horizontal: 12.w,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[100],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        12.r,
                                                      ),
                                                      border: Border.all(
                                                        color:
                                                            Colors.grey[300]!,
                                                      ),
                                                    ),
                                                    child: TextFormField(
                                                      initialValue: controller
                                                          .plateCode.value,
                                                      textAlign:
                                                          TextAlign.center,
                                                      keyboardType:
                                                          TextInputType.text,
                                                      style: TextStyle(
                                                        fontSize: 20.sp,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                      decoration:
                                                          const InputDecoration(
                                                        border:
                                                            InputBorder.none,
                                                        hintText: '------',
                                                        isDense: true,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                      ),
                                                      onChanged: controller
                                                          .setPlateCode,
                                                    ),
                                                  ),
                                                )
                                              : Expanded(child: SizedBox()),
                                          SizedBox(width: 12.w),
                                          Container(
                                            height: 44.h,
                                            width: 70.w,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF1771B7),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                24.r,
                                              ),
                                            ),
                                            child: Material(
                                              color: Colors.transparent,
                                              child: InkWell(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  8.r,
                                                ),
                                                onTap: () {
                                                  if (controller
                                                          .boardType.value ==
                                                      0) {
                                                    controller
                                                        .getCustomerListBySaudiCar();
                                                  } else {
                                                    controller
                                                        .getCustomerListByCarPlateInternational();
                                                  }
                                                },
                                                child: const Icon(
                                                  Icons.search,
                                                  color: Colors.white,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    // Customer search results
                                    Obx(
                                      () => controller.listIsLoading.value
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            )
                                          : controller.customerList.isEmpty
                                              ? Center(
                                                  child: CustomText(
                                                      text: "No Customer Found"
                                                          .tr),
                                                )
                                              : ListView.builder(
                                                  shrinkWrap: true,
                                                  physics:
                                                      const AlwaysScrollableScrollPhysics(),
                                                  itemCount: controller
                                                      .customerList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    final customer = controller
                                                        .customerList[index];
                                                    return CustomerCarCard(
                                                      isWarning: controller
                                                              .customerList[
                                                                  index]
                                                              .isWarning ??
                                                          false,
                                                      onTapYes: () {
                                                        controller
                                                            .sendMessageToReceiveCar(
                                                                clientId:
                                                                    customer.id ??
                                                                        '');
                                                        Navigator.pop(context);
                                                      },
                                                      customerName:
                                                          customer.name ??
                                                              'Unknown',
                                                      customerPhone:
                                                          customer.phone ?? '',
                                                      customerId:
                                                          customer.id ?? '',
                                                    );
                                                  },
                                                ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          controller.messageSendingIsLoading.value
                              ? Positioned.fill(
                                  child: Center(
                                  child: Image.asset(
                                    AppImages.loading,
                                    width: 150.w,
                                    height: 150.w,
                                  ),
                                ))
                              : SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
