import 'package:get/get_connect/http/src/response/response.dart';

import '../../../../Service/api_client.dart';
import '../../../../Service/api_url.dart';

class AuthRepo {
  Future<Response> login(
      {required String fcmToken,
      required String phone,
      required dynamic password,
      required String deviceId,
      required String deviceType}) async {
    try {
      Map<String, dynamic> body = {
        "contact": phone,
        "password": password,
        "deviceId": fcmToken,
        "deviceType": deviceType == "Android" ? "android" : "ios",
        "fcmToken": fcmToken,
        // "role":"WORKSHOP_OWNER"
      };
      Response response;
      response = await ApiClient.postData(
        ApiConstant.login,
        body: body,
      );
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }

  Future<Response> forgotPassword({required dynamic password}) async {
    try {
      Map<String, dynamic> body = {
        "contact": password,
      };
      Response response;
      response = await ApiClient.postData(
        ApiConstant.forgetPassword,
        body: body,
      );
      return response;
    } catch (e) {
      return Response(statusCode: 1, statusText: "Error: ${e.toString()}");
    }
  }
}
