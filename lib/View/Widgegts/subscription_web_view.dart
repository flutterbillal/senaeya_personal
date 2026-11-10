import 'package:Senaeya/Core/AppRoute/app_route.dart';
import 'package:Senaeya/Service/api_client.dart';
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
import 'package:http/http.dart' as http;
import '../../../Helper/shared_prefe/shared_prefe.dart';

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

  final WebViewController controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: (NavigationRequest request) async {
          logger.i("Navigating to URL: ${request.url}");
          if (request.url.contains(paymentSuccessUrl) &&
              request.url.contains("message=APPROVED")) {
            logger.i("Payment Success URL detected");
            logger.i("Payment Success URL: ${request.url}");
            logger.i("Payment Success URL: ${paymentSuccessUrl}");
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
                // showDialog(
                //   context: context,
                //   builder: (context) => SizedBox(
                //     height: 400,
                //     child: Directionality(
                //       textDirection: TextDirection.ltr,
                //       child: AlertDialog(
                //         title: CustomText(text: 'Payment Successful'.tr),
                //         content: CustomText(
                //           text: ,
                //           maxLines: 3,
                //         ),
                //         actions: [
                //           TextButton(
                //             onPressed: () async {
                //               Navigator.of(context).pop(); // Close alert dialog
                //               Navigator.of(context).pop(); // Close webview

                //               Get.toNamed(AppRoute.invoiceScreen, arguments: {
                //                 "subscriptionId": subscriptionId
                //               });
                //             },
                //             child: CustomText(text: 'OK'.tr),
                //           )
                //         ],
                //       ),
                //     ),
                //   ),
                // );
              } else {
                logger.e(
                    "Payment verification failed with status: ${response.statusCode}");
                // showDialog(
                //   context: context,
                //   builder: (context) => Directionality(
                //     textDirection: TextDirection.ltr,
                //     child: AlertDialog(
                //       title: CustomText(text: 'Payment Verification Failed'.tr),
                //       content: CustomText(
                //           maxLines: 4,
                //           text:
                //               'Unable to verify payment. Please contact support.'
                //                   .tr),
                //       actions: [
                //         TextButton(
                //           onPressed: () {
                //             Navigator.of(context).pop(); // Close alert dialog
                //             Navigator.of(context).pop(); // Close webview
                //           },
                //           child: CustomText(text: 'OK'.tr),
                //         )
                //       ],
                //     ),
                //   ),
                // );
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
              // showDialog(
              //   context: context,
              //   builder: (context) => Directionality(
              //     textDirection: TextDirection.ltr,
              //     child: AlertDialog(
              //       title: CustomText(text: 'Error'.tr),
              //       content: CustomText(
              //           maxLines: 4,
              //           text: 'An error occurred while verifying payment.'.tr),
              //       actions: [
              //         TextButton(
              //           onPressed: () {
              //             Navigator.of(context).pop(); // Close alert dialog
              //             Navigator.of(context).pop(); // Close webview
              //           },
              //           child: CustomText(text: 'OK'.tr),
              //         )
              //       ],
              //     ),
              //   ),
              // );
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
            logger.i("Payment Failed URL: ${paymentSuccessUrl}");
            CustomAlert.showInfo(
              context: Get.context!,
              message:
                  "${'Payment Failed'.tr}\n ${'Your subscription payment was not successful.'.tr}",
              onPressed: () {
                Navigator.of(context).pop(); // Close alert dialog
                Navigator.of(context).pop(); // Close webview
              },
            );

            // showDialog(
            //   context: context,
            //   builder: (context) => Directionality(
            //     textDirection: TextDirection.ltr,
            //     child: AlertDialog(
            //       title: CustomText(text: 'Payment Failed'.tr),
            //       content: CustomText(
            //         text: 'Your subscription payment was not successful.'.tr,
            //         maxLines: 3,
            //       ),
            //       actions: [
            //         TextButton(
            //           onPressed: () {
            //             Navigator.of(context).pop(); // Close alert dialog
            //             Navigator.of(context).pop(); // Close webview
            //           },
            //           child: CustomText(text: 'OK'.tr),
            //         )
            //       ],
            //     ),
            //   ),
            // );

            return NavigationDecision.prevent;
          } else if (request.url.contains("message=CANCELLED")) {
            logger.i("Payment Cancelled URL detected");
            logger.i("Payment Cancelled URL: ${request.url}");
            logger.i("Payment Cancelled URL: ${paymentSuccessUrl}");
            CustomAlert.showInfo(
              context: Get.context!,
              message:
                  "${'Payment Cancelled'.tr}\n ${'Your subscription payment was cancelled.'.tr}",
              onPressed: () {
                Navigator.of(context).pop(); // Close alert dialog
                Navigator.of(context).pop(); // Close webview
              },
            );
            // showDialog(
            //   context: context,
            //   builder: (context) => Directionality(
            //     textDirection: TextDirection.ltr,
            //     child: AlertDialog(
            //       title: CustomText(text: 'Payment Cancelled'.tr),
            //       content: CustomText(
            //         text: 'Your subscription payment was cancelled.'.tr,
            //         maxLines: 3,
            //       ),
            //       actions: [
            //         TextButton(
            //           onPressed: () {
            //             Navigator.of(context).pop(); // Close alert dialog
            //             Navigator.of(context).pop(); // Close webview
            //           },
            //           child: CustomText(text: 'OK'.tr),
            //         )
            //       ],
            //     ),
            //   ),
            // );

            return NavigationDecision.prevent;
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
            // Get.find<SubscriptionScreenController>().getSubscriptions();
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
