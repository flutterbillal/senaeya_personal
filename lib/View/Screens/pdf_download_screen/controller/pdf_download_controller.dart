import 'dart:math';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import '../repo_downloadpdf.dart';

class PdfDownloadController extends GetxController {
  final RxBool _inProgress = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString pricePDF = ''.obs;
  final RxBool isZoomEnabled = false.obs;

  final PdfViewerController pdfViewerController = PdfViewerController();

  bool get inProgress => _inProgress.value;

  String get errorMessage => _errorMessage.value;

  // Store the path where PDF is saved
  RxString savedFilePath = ''.obs;

  @override
  void onInit() {
    super.onInit();

    final args = Get.arguments as Map<String, dynamic>;
    pricePDF.value = args['invoice'] ?? '';
  }

  void toggleZoom() {
    isZoomEnabled.value = !isZoomEnabled.value;
  }

  void setInProgress(bool value) {
    _inProgress.value = value;
  }

  void setErrorMessage(String message) {
    _errorMessage.value = message;
  }

  void zoomIn() {
    pdfViewerController.zoomLevel += 0.25;
  }

  void zoomOut() {
    pdfViewerController.zoomLevel -= 0.25;
  }

  Future<void> downloadPDF() async {
    // AWS link is already a complete URL, don't prepend base URL
    String pdfUrl = pricePDF.value;
    final DownloadRepository downloadRepository = DownloadRepository();

    String fileName;
    var random = Random();
    int value = random.nextInt(100000);

    fileName = 'invoice$value.pdf';

    downloadRepository.downloadPDF(pdfUrl,
        setInProgress: setInProgress,
        setErrorMessage: setErrorMessage,
        name: fileName,
        folderName: folderName);
  }

  String folderName = "Invoices";

// Method to download the PDF
}
