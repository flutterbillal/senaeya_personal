import 'package:Senaeya/Utils/AppColors/app_colors.dart';
import 'package:Senaeya/View/Widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'controller/pdf_download_controller.dart';

class PdfDownloadScreen extends StatelessWidget {
  const PdfDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PdfDownloadController>(
      init: PdfDownloadController(),
      builder: (controller) {
        return Scaffold(
          appBar: CustomAppBar(
            title: "invoice".tr, titleColor: AppColors.black500,
            onBack: () => Navigator.pop(context), centerTitle: true,
            //blueCloud: true,
          ),

          floatingActionButton: controller.pricePDF.value.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 40, right: 10),
                  child: FloatingActionButton(
                    onPressed: () {
                      controller.downloadPDF();
                    },
                    child: Icon(
                      Icons.download,
                      color: AppColors.primary,
                    ),
                  ),
                )
              : null, // Hide the button if there's no pricePDF available
          body: Padding(
            padding: const EdgeInsets.only(left: 17, right: 17, bottom: 8),
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    if (controller.inProgress) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (controller.errorMessage.isNotEmpty) {
                      return Center(child: Text(controller.errorMessage));
                    }
                    if (controller.pricePDF.value.isEmpty) {
                      return const Center(
                          child: Text('No Price pdf available'));
                    }

                    return GestureDetector(
                      onDoubleTap: () {
                        controller.isZoomEnabled.value
                            ? controller.zoomOut()
                            : controller.zoomIn();
                      },
                      child: SfPdfViewer.network(
                        controller.pricePDF.value,
                        controller: controller.pdfViewerController,
                        onDocumentLoaded: (details) {
                          controller.setInProgress(false);
                        },
                        onDocumentLoadFailed: (details) {
                          controller.setInProgress(false);
                          controller.setErrorMessage(
                              'Failed to load PDF: ${details.error}');
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
