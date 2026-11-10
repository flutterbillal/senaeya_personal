import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/Utils/AppImg/app_img.dart';
import 'package:Senaeya/View/Screens/auth_screens/select_language_screen/controller/select_language_controller.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../Widgets/commonTextWithoutResize.dart';

class SelectLanguageScreen extends StatefulWidget {
  const SelectLanguageScreen({super.key});

  @override
  State<SelectLanguageScreen> createState() => _SelectLanguageScreenState();
}

class _SelectLanguageScreenState extends State<SelectLanguageScreen> {
  final SelectLanguageController controller =
      Get.put(SelectLanguageController());

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Always set status bar color to white after any dependency change
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.dark,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppColors.primary,
        appBar: CustomAppBar(
          title: "Languages",
          titleColor: Colors.black,
          // //blueCloud: true,
          blackHomeIcon: controller.arg.isEmpty ? true : false,
        ),
        body: Obx(() {
          return Column(
            children: [
              const SizedBox(height: 32),
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    children:
                        List.generate(controller.languages.length, (index) {
                      final lang = controller.languages[index];
                      final isSelected =
                          lang.code == controller.selectedLang.value;
                      return Column(
                        children: [
                          if (index != 0)
                            const Divider(height: 1, color: Color(0xFFF3F4F8)),
                          ListTile(
                            title: Padding(
                              padding: EdgeInsets.only(left: 28.0.w),
                              child: Center(
                                child: SizedBox(
                                  width: 100.w,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        height: 32,
                                        width: 32,
                                        alignment: Alignment.center,
                                        child: SvgPicture.asset(
                                          lang.flagAsset,
                                          width: 32,
                                          height: 32,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Commontextwithoutresize(
                                        text: lang.name,
                                        fontSize: 18,
                                        textAlign: TextAlign.start,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            trailing: SizedBox(
                              width: 28,
                              height: 28,
                              child: isSelected
                                  ? const Icon(
                                      Icons.check,
                                      color: Color(0xFFE94F4F),
                                      size: 28,
                                    )
                                  : null,
                            ),
                            onTap: () => controller.selectLanguage(lang.code),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            minLeadingWidth: 0,
                          ),
                        ],
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: controller.confirmSelection,
                child: Container(
                  width: 95.w,
                  height: 95.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 8)
                    ],
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      AppIcon.check2,
                      width: 37.w,
                      height: 50.h,
                    ),
                  ),
                ),
              )
            ],
          );
        }),
      ),
    );
  }
}
