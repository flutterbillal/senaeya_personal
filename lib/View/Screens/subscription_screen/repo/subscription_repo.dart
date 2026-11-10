import 'package:get/get_connect/http/src/response/response.dart';

import '../../../../Service/api_client.dart';
import '../../../../Service/api_url.dart';

class SubscriptionRepo {
  Future<Response> getSubscription() async {
    try {
      Response response;
      response = await ApiClient.getData(
        ApiConstant.getSubscriptionUrl,
      );
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }

  Future<Response> prepareMoyasarPayment(
      {String? cuponCode, required String subscriptionId}) async {
    try {
      Map<String, dynamic> query = {};
      if (cuponCode != null && cuponCode.isNotEmpty) {
        query["couponCode"] = cuponCode;
      }
      Response response;
      response = await ApiClient.postData(
          ApiConstant.prepareMoyasarPayment(subscriptionId),
          query: query);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }

  Future<Response> getCuponDiscount(
      {required String cuponCode, required String packageId}) async {
    try {
      Map<String, dynamic> body = {"packageId": packageId};

      Response response;
      response = await ApiClient.postData(
          ApiConstant.getDiscountByCupon(cuponCode),
          body: body);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }

  Future<Response> verifyMoyasarPayment({required String paymentId}) async {
    try {
      Response response;
      response =
          await ApiClient.postData(ApiConstant.verifyMoyasarPayment(paymentId));
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }

  Future<Response> getMoyasarPaymentStatus({required String paymentId}) async {
    try {
      return await ApiClient.getData(
        ApiConstant.moyasarPaymentStatus(paymentId),
      );
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }

  Future<Response> createSubscription({
    required String packageId,
    required String amountPaid,
    required String couponCode,
    required String vatPercent,
    required String flatDiscountedAmount,
    required String flatVatAmount,
  }) async {
    try {
      Map<String, dynamic> body = {
        "packageId": packageId,
        "amountPaid": amountPaid,
        "couponCode": couponCode,
        "vatPercent": vatPercent,
        "flatDiscountedAmount": flatDiscountedAmount,
        "flatVatAmount": flatVatAmount,
      };

      Response response;
      response =
          await ApiClient.postData(ApiConstant.createSubscription, body: body);
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }
}
