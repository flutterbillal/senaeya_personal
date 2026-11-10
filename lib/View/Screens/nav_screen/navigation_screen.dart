import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/auth_screens/login_screen/login_screen.dart';
import 'package:Senaeya/View/Screens/auth_screens/select_language_screen/select_language_screen.dart';
import 'package:Senaeya/View/Screens/auth_screens/signup_worshop/signup_workshop.dart';
import 'package:Senaeya/View/Screens/menu/contact_us_screen/contact_us_screen.dart';
import 'package:Senaeya/View/Screens/works_and_cars_screen/works_and_cars_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../Helper/shared_prefe/shared_prefe.dart';
import '../../../Utils/AppLog/app_log.dart';
import '../home_screen/home.dart';
import '../profile_screen/profile_screen.dart';
import '../../../Utils/AppColors/app_colors.dart';
import 'package:flutter/services.dart';
import 'controller/navigation_controller.dart';

class NavigationScreen extends StatelessWidget {
  const NavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: AppColors.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    );
    final NavigationController navController = Get.put(NavigationController());

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Obx(
        () => navController.isInitializing.value
            ? const Scaffold(
                backgroundColor: AppColors.primary,
                body: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              )
            : Scaffold(
                body: _getBody(navController.currentIndex.value, navController),
                bottomNavigationBar: BottomNavigationBar(
                  backgroundColor: Colors.white,
                  currentIndex: navController.currentIndex.value,
                  onTap: (index) async {
                    if (index == 4) {
                      if (navController.token.isEmpty) {
                        return navController.showLoginAlertDialog();
                      }
                      if (navController.role != 'WORKSHOP_OWNER') {
                        navController.restrictedForOwner();
                        return;
                      }

                      // Profile tab - check authentication
                      String workShopId = await SharePrefsHelper.getString(
                        SharedPreferenceValue.workshopId,
                      );

                      String token = await SharePrefsHelper.getString(
                        SharedPreferenceValue.token,
                      );

                      if (token.isEmpty) {
                        Get.to(() => const LoginScreen());
                        return;
                      } else if (workShopId.isEmpty) {
                        appLog('workShopId: $workShopId');
                        Get.to(
                          () => const SignupWorkshopScreen(),
                          arguments: {"screen": "nav_screen"},
                        );
                        return;
                      }
                    }
                    if (index == 1) {
                      if (navController.token.isEmpty) {
                        return navController.showLoginAlertDialog();
                      }
                    }
                    // Update the current index
                    navController.changeIndex(index);
                  },
                  type: BottomNavigationBarType.fixed,
                  selectedItemColor: const Color(0xFF1766A0),
                  unselectedItemColor: Colors.grey,
                  items: [
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SvgPicture.asset(
                          AppIcon.home,
                          height: 24.w,
                          width: 24.w,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SvgPicture.asset(
                          AppIcon.setting,
                          height: 24.w,
                          width: 24.w,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SvgPicture.asset(
                          AppIcon.internet,
                          height: 24.w,
                          width: 24.w,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SvgPicture.asset(
                          AppIcon.mail,
                          height: 24.w,
                          width: 24.w,
                        ),
                      ),
                      label: '',
                    ),
                    BottomNavigationBarItem(
                      icon: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: SvgPicture.asset(
                          AppIcon.profile,
                          height: 24.w,
                          width: 24.w,
                        ),
                      ),
                      label: '',
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _getBody(int index, NavigationController controller) {
    switch (index) {
      case 0:
        return const HomeScreen();
      case 1:
        return const WorksAndCarsScreen();
      case 2:
        return const SelectLanguageScreen();
      case 3:
        return const ContactUsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }
}
