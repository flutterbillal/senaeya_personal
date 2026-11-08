import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../../Service/api_url.dart';
import '../../../../Utils/AppImg/app_img.dart';
import '../../../../Utils/AppLog/app_log.dart';
import '../../../../Utils/ToastMsg/toast_message.dart';
import '../controller/invoice_screen_controller.dart';

Future<void> generatePDF(
  BuildContext context,
  InvoiceScreenController controller,
) async {
  final pdf = pw.Document();

  final data = controller.invoiceScreenModel.value?.data;
  if (data == null) {
    showCustomSnackBar('No invoice data available'.tr);
    return;
  }

  // Load logo
  final logoSvg = await rootBundle.loadString(AppLogo.appLogo);

  // Load Arabic fonts
  final arabicFont = await rootBundle.load('assets/fonts/Cairo-Regular.ttf');
  final ttfArabic = pw.Font.ttf(arabicFont);

  // Calculate amounts
  // Safely convert dynamic values (could be int, double, or String) to double
  double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    if (v is num) return v.toDouble();
    return 0.0;
  }

  final price = _toDouble(data.price);
  final amountPaid = _toDouble(data.amountPaid);
  final discount = (price - amountPaid);
  const taxRate = 0.15;

  // Compute price before tax from the paid amount (inclusive of tax): priceBeforeTax = amountPaid / (1 + taxRate)
  // Guard against division by zero and unexpected values
  final priceBeforeTax =
      (1 + taxRate) != 0 ? (amountPaid / (1 + taxRate)) : 0.0;
  double taxAmount = amountPaid - priceBeforeTax;

  // Clamp tiny floating point artifacts to zero (for display) and ensure non-negative
  if (taxAmount.abs() < 0.0005) taxAmount = 0.0;
  if (taxAmount < 0) taxAmount = 0.0;

  appLog(
      'PDF calc -> price: $price, amountPaid: $amountPaid, priceBeforeTax: $priceBeforeTax, taxAmount: $taxAmount');
  print(
      "==================================${ApiConstant.imageBaseUrl + (controller.invoiceScreenModel.value?.data?.qrImage ?? '')}");

  // Format dates
  final createdDate = data.createdAt != null
      ? DateFormat('dd-MM-yyyy hh:mm a').format(data.createdAt!)
      : '';
  final expiryDate = data.currentPeriodEnd != null
      ? DateFormat('dd-MM-yyyy').format(data.currentPeriodEnd!)
      : '';

  // Load QR Image with proper PNG decoding
  pw.ImageProvider? qrImage;
  try {
    final qrImagePath =
        controller.invoiceScreenModel.value?.data?.qrImage ?? '';
    if (qrImagePath.isNotEmpty) {
      final imageUrl = ApiConstant.imageBaseUrl + qrImagePath;
      appLog('Loading QR image from: $imageUrl');

      final response = await http.get(Uri.parse(imageUrl));
      appLog('QR image response status: ${response.statusCode}');
      appLog('QR image content type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final Uint8List imageBytes = response.bodyBytes;
        appLog('QR image size: ${imageBytes.length} bytes');

        // Decode PNG using image package and re-encode for PDF compatibility
        try {
          appLog('Attempting to decode image...');
          final decodedImage = img.decodeImage(imageBytes);

          if (decodedImage != null) {
            appLog(
                'Image decoded successfully, dimensions: ${decodedImage.width}x${decodedImage.height}');

            // Re-encode as PNG to ensure PDF compatibility
            final pngBytes = img.encodePng(decodedImage);
            appLog('Image re-encoded as PNG, size: ${pngBytes.length} bytes');

            qrImage = pw.MemoryImage(Uint8List.fromList(pngBytes));
            appLog('✅ QR image decoded and loaded successfully for PDF');
          } else {
            appLog('❌ Failed to decode image - decodedImage is null');
          }
        } catch (imageError) {
          appLog('❌ Error decoding/encoding image: $imageError');
        }
      } else {
        appLog('Failed to load QR image. Status code: ${response.statusCode}');
        appLog('Response body: ${response.body}');
      }
    } else {
      appLog('QR image path is empty');
    }
  } catch (e) {
    appLog('Error loading QR image: $e');
  }

  pdf.addPage(
    pw.Page(
      pageFormat: const PdfPageFormat(612, 792),
      textDirection: pw.TextDirection.rtl,
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(16),
          decoration: const pw.BoxDecoration(
            color: PdfColors.white,
            borderRadius: pw.BorderRadius.all(pw.Radius.circular(12)),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Logo
              pw.Container(
                height: 80,
                width: 80,
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(12),
                  ),
                  border: pw.Border.all(color: PdfColors.grey300),
                  boxShadow: const [
                    pw.BoxShadow(
                      color: PdfColors.grey300,
                      blurRadius: 2,
                      offset: PdfPoint(-1, 2),
                    ),
                    pw.BoxShadow(
                      color: PdfColors.grey300,
                      blurRadius: 2,
                      offset: PdfPoint(1, 2),
                    ),
                  ],
                ),
                child: pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.SvgImage(svg: logoSvg, fit: pw.BoxFit.cover),
                ),
              ),
              pw.SizedBox(height: 6),

              // Header texts
              pw.Text(
                "فاتورة ضريبية مبسطة",
                style: pw.TextStyle(font: ttfArabic, fontSize: 15),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                "تطبيق الصناعية .. مسجل لدى",
                style: pw.TextStyle(font: ttfArabic, fontSize: 18),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                "مؤسسة مرافئ التجارية",
                style: pw.TextStyle(
                  font: ttfArabic,
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                "الرياض - العليا - طريق مكة المكرمة",
                style: pw.TextStyle(
                  font: ttfArabic,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Text(
                "CR: ${controller.invoiceScreenModel.value?.data?.workshop?.crn ?? ''}",
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.Text(
                // "VAT: ${controller.invoiceScreenModel.value?.data?.workshop?.taxVatNumber ?? ''}",
                "VAT: 300787972600003",
                style: const pw.TextStyle(fontSize: 14),
              ),
              pw.SizedBox(height: 10),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    createdDate,
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.Row(
                    children: [
                      pw.Text(
                        data.recieptNumber != null
                            ? "${data.recieptNumber}"
                            : 'N/A',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#00B4D8'),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Text(
                        "رقم الفاتورة",
                        style: pw.TextStyle(font: ttfArabic, fontSize: 18),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
              ),

              pw.Divider(height: 2),
              pw.SizedBox(height: 10),
              // Workshop info
              pw.Text(
                "(${controller.invoiceScreenModel.value?.data?.workshop?.workshopNameArabic ?? ''})",
                style: pw.TextStyle(
                  font: ttfArabic,
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
                textDirection: pw.TextDirection.rtl,
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "VAT: ${controller.invoiceScreenModel.value?.data?.workshop?.taxVatNumber ?? ''}",
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                  pw.Text(
                    data.contact ?? '',
                    style: const pw.TextStyle(fontSize: 16),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),

              // Subscription details
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  border: pw.Border.all(color: PdfColors.grey),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(8),
                  ),
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        decoration: const pw.BoxDecoration(
                          border: pw.Border(
                            right: pw.BorderSide(color: PdfColors.grey),
                          ),
                        ),
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Column(
                          children: [
                            pw.Text(
                              "الاشتراك في تطبيق الصناعية",
                              style: pw.TextStyle(
                                font: ttfArabic,
                                fontSize: 14,
                              ),
                              textDirection: pw.TextDirection.rtl,
                            ),
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.center,
                              children: [
                                pw.Text(
                                  controller.invoiceScreenModel.value?.data
                                          ?.title ??
                                      "12 months+6 months free",
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColor.fromHex('#00B4D8'),
                                  ),
                                ),
                                // pw.Text(
                                //   "6 months free",
                                //   style: pw.TextStyle(
                                //     fontSize: 12,
                                //     fontWeight: pw.FontWeight.bold,
                                //     color: PdfColor.fromHex('#00B4D8'),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          "تفاصيل الفاتورة",
                          style: pw.TextStyle(
                            font: ttfArabic,
                            fontSize: 16,
                            fontWeight: pw.FontWeight.bold,
                          ),
                          textDirection: pw.TextDirection.rtl,
                          textAlign: pw.TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 4),

              // Invoice items
              buildPdfInvoiceCard(
                "    ${priceBeforeTax.toStringAsFixed(2)} ",
                "المبلغ قبل الضريبة",
                font: ttfArabic,
              ),
              pw.SizedBox(height: 4),
              buildPdfInvoiceCard(
                "    ${discount.toStringAsFixed(2)} ",
                "مبلغ الخصم",
                font: ttfArabic,
                titleColor: PdfColors.red,
              ),
              pw.SizedBox(height: 4),
              buildPdfInvoiceCard(
                "    ${taxAmount.toStringAsFixed(2)} ",
                "ضريبة القيمة المضافة (TAX 15%)",
                font: ttfArabic,
              ),
              pw.SizedBox(height: 4),
              buildPdfInvoiceCard(
                "    ${amountPaid.toStringAsFixed(2)} ",
                "المجموع شامل الضريبة",
                font: ttfArabic,
                titleColor: PdfColor.fromHex('#00B4D8'),
                borderColor: PdfColor.fromHex('#00B4D8'),
                bold: true,
              ),
              pw.SizedBox(height: 10),

              // Expiry date
              pw.Container(
                width: 300,
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#FFE5E5'),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(24),
                  ),
                ),
                padding: const pw.EdgeInsets.all(4),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      expiryDate,
                      style: const pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.red,
                      ),
                    ),
                    pw.Text(
                      "ينتهي اشتراك التطبيق بتاريخ",
                      style: pw.TextStyle(
                        font: ttfArabic,
                        fontSize: 16,
                        color: PdfColors.red,
                      ),
                      textDirection: pw.TextDirection.rtl,
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // QR Code
              if (qrImage != null)
                pw.Center(
                  child: pw.Container(
                    height: 120,
                    width: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.Image(qrImage,
                        fit: pw.BoxFit.contain), // পরিবর্তন করুন এখানে
                  ),
                )
              else
                pw.Center(
                  child: pw.Container(
                    height: 120,
                    width: 120,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey),
                      color: PdfColors.grey100,
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'QR غير متوفر',
                        style: pw.TextStyle(
                          font: ttfArabic,
                          fontSize: 14,
                          color: PdfColors.grey600,
                        ),
                        textDirection: pw.TextDirection.rtl,
                      ),
                    ),
                  ),
                )
            ],
          ),
        );
      },
    ),
  );

  // Save PDF
  try {
    Directory? directory;
    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    final invoiceNum = data.recieptNumber != null
        ? '${data.recieptNumber}'
        : '${DateTime.now().millisecondsSinceEpoch}';
    final fileName = 'invoice_$invoiceNum.pdf';
    final file = File('${directory!.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    try {
      final result = await OpenFile.open(file.path);

      if (result.type == ResultType.done) {
        Get.snackbar(
          'Success',
          'PDF generated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'PDF Saved',
          'PDF saved to Downloads',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (openError) {
      Get.snackbar(
        'Success',
        'PDF saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      appLog('Open file error: $openError');
    }
  } catch (e) {
    Get.snackbar(
      'Error',
      'Failed to generate PDF: $e',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
    appLog(e.toString());
  }
}

pw.Widget buildPdfInvoiceCard(
  String title,
  String rightText, {
  PdfColor? titleColor,
  PdfColor? borderColor,
  bool bold = false,
  pw.Font? font,
}) {
  appLog('Building PDF invoice card: $title - $rightText');
  return pw.Container(
    decoration: pw.BoxDecoration(
      color: PdfColors.grey200,
      border: pw.Border.all(color: borderColor ?? PdfColors.grey),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
    ),
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            fontSize: bold ? 18 : 16,
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            color: titleColor ?? PdfColors.black,
          ),
        ),
        pw.Text(
          rightText,
          style: pw.TextStyle(font: font, fontSize: 14),
          textDirection: pw.TextDirection.rtl,
        ),
      ],
    ),
  );
}
