import 'package:Senaeya/View/Screens/invoice_summary_screen/widget/invoice_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../Utils/AppImg/app_img.dart';
import '../../Widgets/custom_app_bar.dart';
import 'controller/invoice_summary_controller.dart';
import 'package:flutter/services.dart';
import '../../../Utils/AppColors/app_colors.dart';

class InvoiceSummaryScreen extends StatelessWidget {
  const InvoiceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final InvoiceSummaryController controller =
        Get.find<InvoiceSummaryController>();
    return Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: AppColors.primary,
          appBar: CustomAppBar(
            title: 'invoice_summary'.tr,
            titleColor: Colors.black,
            //blueCloud: true,
            onBack: Get.back,
            centerTitle: true,
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: double.infinity,
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Obx(
                    () => controller.isLoading.value
                        ? Center(
                            child: Image.asset(
                              AppImages.loading,
                              width: 150.w,
                              height: 150.w,
                            ),
                          )
                        : invoiceSummary(controller, context),
                  ),
                ),
              ),
              Obx(
                () => (controller.nextIsLoading.value ||
                        controller.saveIsLoading.value)
                    ? Positioned(
                        top: 10,
                        left: 10,
                        right: 10,
                        bottom: 10,
                        child: Center(
                          child: Image.asset(
                            AppImages.loading,
                            width: 150.w,
                            height: 150.w,
                          ),
                        ),
                      )
                    : const SizedBox(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
