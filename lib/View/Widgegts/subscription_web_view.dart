import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/View/Screens/profile_screen/model/subscription_details_model.dart';
import 'package:Senaeya/View/Screens/profile_screen/repo/profile_repo.dart';
import 'package:Senaeya/View/Screens/subscription_screen/repo/subscription_repo.dart';
import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../Helper/shared_prefe/shared_prefe.dart';

const String _hideInvoiceHeaderScript = r'''
(function() {
  function applyHiding() {
    // 1. Inject global CSS rules
    if (!document.getElementById('moyasar-custom-hide-style')) {
      var style = document.createElement('style');
      style.id = 'moyasar-custom-hide-style';
      style.innerHTML = `
        /* Hide STC Pay button */
        [class*="stc"], [id*="stc"], button:has([alt*="stc"]), button:has(img[src*="stc"]) {
          display: none !important;
        }
        /* Hide invoice title/header container if present */
        .invoice-details, .invoice-header, .invoice-summary,
        [class*="InvoiceDetails"], [class*="invoice-header"], [class*="invoice_header"] {
          display: none !important;
        }
      `;
      (document.head || document.documentElement).appendChild(style);
    }

    // 2. Hide Back button/link
    document.querySelectorAll('a, button, span').forEach(function(el) {
      var txt = (el.innerText || '').trim();
      if (txt === '← Back' || txt === 'Back' || txt === 'رجوع' || txt === '←') {
        el.style.display = 'none';
      }
    });

    // 3. Hide Invoice summary container (amount, date, Expires, UUID, Description)
    document.querySelectorAll('div, section, header').forEach(function(el) {
      // Never hide elements that contain input fields (payment form)
      if (el.querySelector('input, select, iframe')) return;

      var text = el.innerText || '';
      var hasExpiry = text.includes('Expires') || text.includes('ينتهي') || text.includes('Expiry');
      var hasSAR = text.includes('SAR') || text.includes('ر.س');
      var hasUUID = /[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}/i.test(text);

      if ((hasExpiry || hasUUID) && (hasSAR || text.includes('Invoice') || text.includes('فاتورة'))) {
        el.style.display = 'none';
      }

      // Also hide the description box ("باقة الاشتراك السنوي") right above the form if separate
      if (text.includes('باقة الاشتراك') && !el.querySelector('input')) {
        el.style.display = 'none';
      }
    });

    // 4. Hide STC Pay button & its wrapper
    document.querySelectorAll('button, div[role="button"]').forEach(function(btn) {
      var btnText = (btn.innerText || '').toLowerCase();
      var hasStc = btnText.includes('stc') || 
                   btn.querySelector('img[src*="stc"], img[alt*="stc"], svg[class*="stc"], [class*="stc"]');
      if (hasStc) {
        btn.style.display = 'none';
        if (btn.parentElement && btn.parentElement.children.length === 1) {
          btn.parentElement.style.display = 'none';
        }
      }
    });
  }

  applyHiding();
  var count = 0;
  var interval = setInterval(function() {
    applyHiding();
    count++;
    if (count > 25) clearInterval(interval);
  }, 200);
})();
''';

void openSubscriptionWebView(BuildContext context, String paymentUrl,
    {required String paymentSuccessUrl,
    required String packageId,
    required String amountPaid,
    String couponCode = "",
    required String vatPercent,
    required String flatDiscountedAmount,
    required String flatVatAmount}) {
  final logger = Logger();
  String url = paymentUrl;
  logger.i("Opening subscription URL: $url");

  late final WebViewController controller;
  controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (String url) {
          controller.runJavaScript(_hideInvoiceHeaderScript);
        },
        onNavigationRequest: (NavigationRequest request) async {
          logger.i("Navigating to URL: ${request.url}");
          if (request.url.contains(paymentSuccessUrl) &&
              request.url.contains("message=APPROVED")) {
            logger.i("Payment Success URL detected");
            logger.i("Payment Success URL: ${request.url}");
            logger.i("Payment Success URL: $paymentSuccessUrl");
            // Verify payment status from the success URL

            try {
              final Response response = await SubscriptionRepo()
                  .createSubscription(
                      packageId: packageId,
                      amountPaid: amountPaid,
                      couponCode: couponCode,
                      vatPercent: vatPercent,
                      flatDiscountedAmount: flatDiscountedAmount,
                      flatVatAmount: flatVatAmount);

              if (response.statusCode == 200 || response.statusCode == 201) {
                logger.i("Payment verified successfully");
                String subscriptionId = await getSubscriptionByWorkshop();
                CustomAlert.showInfo(
                  context: Get.context!,
                  message:
                      "${'Payment Successful'.tr}\n ${'Your subscription payment was successful.'.tr}",
                  onPressed: () {
                    Navigator.of(context).pop(); // Close alert dialog
                    Navigator.of(context).pop(); // Close webview

                    Get.toNamed(AppRoute.invoiceScreen,
                        arguments: {"subscriptionId": subscriptionId});
                  },
                );
              } else {
                logger.e(
                    "Payment verification failed with status: ${response.statusCode}");
                CustomAlert.showInfo(
                  context: Get.context!,
                  message:
                      "${'Payment Verification Failed'.tr}\n ${'Unable to verify payment. Please contact support.'.tr}",
                  onPressed: () {
                    Navigator.of(context).pop(); // Close alert dialog
                    Navigator.of(context).pop(); // Close webview
                  },
                );
              }
            } catch (e) {
              logger.e("Error verifying payment: $e");
              CustomAlert.showInfo(
                context: Get.context!,
                message:
                    "${'Error'.tr}\n ${'An error occurred while verifying payment.'.tr}",
                onPressed: () {
                  Navigator.of(context).pop(); // Close alert dialog
                  Navigator.of(context).pop(); // Close webview
                },
              );
            }
            return NavigationDecision.prevent;
          } else if (request.url.contains(paymentSuccessUrl) &&
              request.url.contains("message=DECLINED")) {
            logger.i("Payment Failed URL detected");
            logger.i("Payment Failed URL: ${request.url}");
            logger.i("Payment Failed URL: $paymentSuccessUrl");
            CustomAlert.showInfo(
              context: Get.context!,
              message:
                  "${'Payment Failed'.tr}\n ${'Your subscription payment was not successful.'.tr}",
              onPressed: () {
                Navigator.of(context).pop(); // Close alert dialog
                Navigator.of(context).pop(); // Close webview
              },
            );

            return NavigationDecision.prevent;
          } else if (request.url.contains("message=CANCELLED")) {
            logger.i("Payment Cancelled URL detected");
            logger.i("Payment Cancelled URL: ${request.url}");
            logger.i("Payment Cancelled URL: $paymentSuccessUrl");
            CustomAlert.showInfo(
              context: Get.context!,
              message:
                  "${'Payment Cancelled'.tr}\n ${'Your subscription payment was cancelled.'.tr}",
              onPressed: () {
                Navigator.of(context).pop(); // Close alert dialog
                Navigator.of(context).pop(); // Close webview
              },
            );

            return NavigationDecision.prevent;
          } else if (request.url.contains("message=")) {
            CustomAlert.showInfo(
              context: Get.context!,
              message: "${'Payment Failed'.tr}\n ${'Something went wrong'.tr}",
              onPressed: () {
                Navigator.of(context).pop(); // Close alert dialog
                Navigator.of(context).pop(); // Close webview
              },
            );
          }
          return NavigationDecision.navigate;
        },
      ),
    )
    ..loadRequest(Uri.parse(url));

  Get.dialog(
    Scaffold(
      appBar: AppBar(
        title: CustomText(text: 'Complete Payment'.tr),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context); // Close WebView screen
          },
        ),
      ),
      body: WebViewWidget(controller: controller),
    ),
    barrierDismissible: false,
  );
}

String subscriptionIdGlobal = '';
Future<String> getSubscriptionByWorkshop() async {
  final workshopId =
      await SharePrefsHelper.getString(SharedPreferenceValue.workshopId);
  try {
    Response response =
        await ProfileRepo().getSubscriptionByWorkshopId(workshopId: workshopId);
    appLog("subscription Model====");
    if (response.statusCode == 200) {
      SubscriptionDetailsModel subscriptionDetailsModel =
          SubscriptionDetailsModel.fromJson(response.body);
      if (subscriptionDetailsModel.subsriptionItem != null) {
        appLog(
          "subscriptionId: ${subscriptionDetailsModel.subsriptionItem?.sId}",
        );
        return subscriptionDetailsModel.subsriptionItem?.sId ?? '';
      } else {
        return subscriptionIdGlobal = '';
      }
    } else {
      return subscriptionIdGlobal = '';
    }
  } catch (e) {
    return subscriptionIdGlobal = '';
  }
}
