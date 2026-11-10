import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/subscription_screen/model/subscrioption_model.dart';
import 'package:Senaeya/View/Screens/subscription_screen/repo/subscription_repo.dart';
import 'package:Senaeya/View/Screens/subscription_screen/model/moyasar_payment_model.dart';
import 'package:Senaeya/View/Widgegts/subscription_web_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SubscriptionScreenController extends GetxController {
  RxBool isLoading = false.obs;
  RxList<SubscriptionItem> subscriptionsList = <SubscriptionItem>[].obs;
  TextEditingController cuponCodeController = TextEditingController();
  String successCuponCode = '';
  RxInt cuponDiscount = 0.obs;
  @override
  onInit() {
    super.onInit();
    getSubscriptions();
  }

  ///Api call to get subscriptions
  Future<void> getSubscriptions() async {
    isLoading.value = true;
    Response response = await SubscriptionRepo().getSubscription();
    isLoading.value = false;
    if (response.statusCode == 200) {
      subscriptionsList.clear();
      SubscriptionResponseModel subscriptionResponseModel =
          SubscriptionResponseModel.fromJson(response.body);
      subscriptionsList.addAll(
        subscriptionResponseModel.subscriptionList ?? [],
      );
    } else {
      showCustomSnackBar(response.statusText ?? "Something went wrong");
    }
  }

  ///Api call to checkout subscription
  RxBool checkoutLoading = false.obs;
  Future<void> onTapCheckout(String subscriptionId) async {
    checkoutLoading.value = true;
    Response response = await SubscriptionRepo().prepareMoyasarPayment(
        subscriptionId: subscriptionId, cuponCode: successCuponCode);
    checkoutLoading.value = false;
    if (response.statusCode == 200) {
      try {
        final data = response.body is Map ? response.body['data'] : null;
        if (data is! Map) {
          showCustomSnackBar('Invalid checkout response');
          return;
        }
        final preparation = MoyasarPaymentPreparation.fromJson(
          Map<String, dynamic>.from(data),
        );
        if (!preparation.isValid) {
          showCustomSnackBar('Invalid checkout response');
          return;
        }
        // launchUrl(Uri.parse(preparation.checkoutUrl));
        openSubscriptionWebView(Get.context!, preparation.checkoutUrl,
            vatPercent: '15',
            paymentSuccessUrl: preparation.callbackUrl,
            packageId: subscriptionsList[0].sId ?? '',
            amountPaid: "${preparation.amount}",
            flatDiscountedAmount:
                "${(subscriptionsList[0].price * cuponDiscount.value / 100)}",
            flatVatAmount:
                "${((subscriptionsList[0].price - (subscriptionsList[0].price * cuponDiscount.value / 100)) * 0.15)}");

        // Get.to(() => MoyasarPaymentScreen(preparation: preparation));
      } catch (e) {
        showCustomSnackBar("Error processing checkout: ${e.toString()}");
      }
    } else {
      showCustomSnackBar(response.statusText ?? "Checkout failed");
    }
  }

  ///Api call to get cupon discount
  RxBool cuponLoading = false.obs;
  Future<void> onTapCuponCheck() async {
    cuponLoading.value = true;
    Response response = await SubscriptionRepo().getCuponDiscount(
        cuponCode: cuponCodeController.text.trim(),
        packageId: subscriptionsList[0].sId ?? '');
    cuponLoading.value = false;
    if (response.statusCode == 200) {
      cuponDiscount.value = 0;
      successCuponCode = cuponCodeController.text.trim();

      cuponDiscount.value =
          response.body['data']['coupon']['discountValue'] ?? 0;
      showCustomSnackBar("cupon_applied_successfully".tr, isError: false);
    } else {
      cuponDiscount.value = 0;
      showCustomSnackBar(response.statusText ?? "Something went wrong");
    }
  }
}
