import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../controller/splash_screen_controller.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<SplashScreenController>();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xffF2F5F8), // White status bar
      statusBarIconBrightness: Brightness.dark, // Dark icons for visibility
      statusBarBrightness: Brightness.dark, // For iOS
    ));
    final Size screenSize = MediaQuery.of(context).size;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
          backgroundColor: const Color(0xffF2F5F8),
          body: Center(
            child: Column(
              children: [
                SizedBox(
                  height: screenSize.height * 0.3,
                ),
                Container(
                  height: 182.w,
                  width: 182.w,
                  decoration: BoxDecoration(
                      color: const Color(0xffFFFFFF),
                      borderRadius: BorderRadius.circular(24.r),
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
                      ]),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: SvgPicture.asset(
                      AppLogo.appLogo,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(
                  height: 6.h,
                ),
                SvgPicture.asset(
                  AppLogo.name,
                )
              ],
            ),
          )),
    );
  }
}
