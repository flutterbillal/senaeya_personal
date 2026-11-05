import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/home_screen/widget/home_card_widget.dart';
import 'package:Senaeya/View/Screens/nav_screen/controller/navigation_controller.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:Senaeya/View/Widgets/common_alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Senaeya/View/Screens/home_screen/controller/home_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Senaeya/View/Screens/Menu/menu_drawer/menu_drawer_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    HomeController controller = Get.find<HomeController>();
    NavigationController navController = Get.find<NavigationController>();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        drawer: const MenuDrawerScreen(),
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(110.h),
          child: Container(
            color: AppColors.primary,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: SvgPicture.asset(
                          AppIcon.menu,
                          height: 28.w,
                          width: 28.w,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        controller.token.isNotEmpty
                            ? Get.toNamed(AppRoute.notificationScreen)
                            : controller.showLoginAlertDialog();
                      },
                      child: SvgPicture.asset(
                        AppIcon.notification,
                        height: 24.w,
                        width: 24.w,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Obx(
          () => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : Column(
                  children: [
                    // Blue header section with welcome text
                    Container(
                      width: double.infinity,
                      color: AppColors.primary,
                      child: Column(
                        children: [
                          SizedBox(height: 8.h),
                          CustomText(
                            text: 'welcome'.tr,
                            color: Colors.white,
                            fontSize: 20,
                          ),
                          Text(
                            controller.workShopName.value.isNotEmpty
                                ? controller.workShopName.value
                                : "",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16.h),
                        ],
                      ),
                    ),
                    // Curved design implementation
                    Stack(
                      children: [
                        // Blue container with bottom curved corners
                        Container(
                          width: double.infinity,
                          height: 32.h,
                          color: AppColors.primary,
                        ),
                        // Red container with top curved corners positioned over blue
                        Positioned(
                          top: 8.h,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 24.h,
                            decoration: const BoxDecoration(
                              color: Color(0xFFCA3C40),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24),
                                topRight: Radius.circular(24),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Main content area
                    Expanded(
                      child: Container(
                        color: const Color(0xFFCA3C40),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24.r),
                              topRight: Radius.circular(24.r),
                            ),
                          ),
                          child: GridView.count(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 24.h,
                            ),
                            crossAxisCount: 2,
                            mainAxisSpacing: 24.h,
                            crossAxisSpacing: 32.w,
                            childAspectRatio: 0.9.w / 1.01.h,
                            children: [
                              HomeCard(
                                icon: AppImages.person,
                                label: 'add_customer'.tr,
                                onTap: controller.token.isNotEmpty
                                    ? controller.onAddCustomer
                                    : controller.showLoginAlertDialog,
                              ),
                              HomeCard(
                                icon: AppImages.invoice,
                                label: 'new_invoice'.tr,
                                onTap: controller.onTapAddInvoice,
                              ),
                              HomeCard(
                                icon: AppImages.persons,
                                label: 'customers'.tr,
                                onTap: controller.checkingAuthorization.value ==
                                        true
                                    ? () {}
                                    : controller.token.isEmpty
                                        ? controller.showLoginAlertDialog
                                        : controller.workShopId.isEmpty
                                            ? CommonAlertDialog
                                                .showRegisterWorkshopDialog
                                            : controller.onCustomers,
                              ),
                              HomeCard(
                                icon: AppImages.previousInvoice,
                                label: 'previous_invoices'.tr,
                                onTap: controller.checkingAuthorization.value ==
                                        true
                                    ? () {}
                                    : controller.token.isEmpty
                                        ? controller.showLoginAlertDialog
                                        : controller.workShopId.isEmpty
                                            ? CommonAlertDialog
                                                .showRegisterWorkshopDialog
                                            : controller.onPreviousInvoices,
                              ),
                              HomeCard(
                                icon: AppImages.report,
                                label: 'reports'.tr,
                                onTap: controller.onTapReport,
                              ),
                              HomeCard(
                                icon: AppImages.expense,
                                label: 'expenses'.tr,
                                onTap: controller.token.isEmpty
                                    ? controller.showLoginAlertDialog
                                    : controller.workShopId.isEmpty
                                        ? navController.restrictedForOwner
                                        : controller.onExpenses,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
