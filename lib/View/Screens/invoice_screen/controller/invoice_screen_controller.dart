import 'package:Senaeya/Service/api_client.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/View/Screens/invoice_screen/models/invoice_screen_model.dart';
import 'package:get/get.dart';

class InvoiceScreenController extends GetxController {
  RxBool isLoading = false.obs;
  Rxn<InvoiceScreenModel> invoiceScreenModel = Rxn<InvoiceScreenModel>();
  String subscriptionId = '';
  @override
  void onInit() {
    super.onInit();
    subscriptionId = Get.arguments['subscriptionId'] ?? '';
    // print("====================subsriptionId$subscriptionId");
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      String subscriptionID = subscriptionId;

      if (subscriptionID.isEmpty) {
        isLoading.value = false;
        showCustomSnackBar("Subscription ID not found");
        return;
      }
      // print("subsriptionId============$subscriptionID");
      Response response = await ApiClient.getData(
        ApiConstant.getSubscriptionDetails(subscriptionID),
      );

      if (response.statusCode == 200) {
        invoiceScreenModel.value = InvoiceScreenModel.fromJson(response.body);
      } else {
        showCustomSnackBar("Error in showing data : ${response.statusCode}");
      }
    } catch (e) {
      showCustomSnackBar("Error in showing data : ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}
