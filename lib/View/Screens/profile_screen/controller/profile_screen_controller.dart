import 'dart:io';

import 'package:Senaeya/Utils/AppLog/app_log.dart';
import 'package:Senaeya/View/Screens/profile_screen/model/subscription_details_model.dart';
import 'package:Senaeya/View/Screens/profile_screen/repo/profile_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:Senaeya/Service/api_client.dart';
import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/Utils/ToastMsg/toast_message.dart';
import 'package:Senaeya/Utils/AppConst/app_const.dart';
import 'package:Senaeya/Helper/shared_prefe/shared_prefe.dart';
import 'package:Senaeya/View/Screens/edit_profile_screen/models/profile_screen_model.dart';
import 'package:Senaeya/View/Screens/home_screen/controller/home_controller.dart';

import '../../../../Core/AppRoute/app_route.dart';
import '../../../../Utils/AppColors/app_colors.dart';
import '../../../Widgegts/custom_text/custom_text.dart';

class ProfileScreenController extends GetxController {
  // Observable variables for profile image
  RxString profileImagePath = "".obs;
  RxString networkImageUrl = "".obs; // For network image URL if available
  RxBool isUploading = false.obs;
  RxBool isLoading = false.obs;
  RxBool subscriptionIsLoading = false.obs;
  String workshopId = '';
  Rxn<ProfileModel> profileData = Rxn<ProfileModel>();

  final ImagePicker _picker = ImagePicker();

  // Get HomeController instance
  final HomeController _homeController = Get.find<HomeController>();

  @override
  void onInit() {
    super.onInit();
    // Use profile data from HomeController instead of fetching again
    initial();
    _loadProfileFromHomeController();
  }

  Future<void> initial() async {
    workshopId =
        await SharePrefsHelper.getString(SharedPreferenceValue.workshopId);
    getSubscriptionByWorkshop();
  }

  Rxn<SubsriptionItem> currentSubscription = Rxn<SubsriptionItem>();

  Future<void> getSubscriptionByWorkshop() async {
    subscriptionIsLoading.value = true;
    try {
      Response response = await ProfileRepo()
          .getSubscriptionByWorkshopId(workshopId: workshopId);
      if (response.statusCode == 200) {
        appLog('Subscription Response: ${response.body}');
        SubscriptionDetailsModel subscriptionDetailsModel =
            SubscriptionDetailsModel.fromJson(response.body);
        if (subscriptionDetailsModel.subsriptionItem != null) {
          appLog(
              'Current Subscription: ${subscriptionDetailsModel.subsriptionItem?.sId}');
          appLog(
              'Current Subscription: ${subscriptionDetailsModel.subsriptionItem?.price}');
          currentSubscription.value = subscriptionDetailsModel.subsriptionItem;
          appLog(
              'Current Subscription: ${subscriptionDetailsModel.subsriptionItem?.sId}');
          appLog(
              'Current Subscription: ${subscriptionDetailsModel.subsriptionItem?.price}');
        } else {
          currentSubscription.value = null;
        }
      } else {
        currentSubscription.value = null;
      }
    } catch (e) {
      currentSubscription.value = null;
    } finally {
      subscriptionIsLoading.value = false;
    }
  }

  void exitApp() {
    _showLogoutDialog(Get.context!);
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CustomText(
                    text: 'delete_confirm'.tr,
                    overflow: TextOverflow.visible,
                    fontSize: 18.w,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffFAECEC),
                          foregroundColor: AppColors.red,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: CustomText(
                          text: 'no'.tr,
                          fontWeight: FontWeight.bold,
                          color: AppColors.red,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1766A0),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        onPressed: () {
                          onLogOut();
                        },
                        child: CustomText(
                          text: 'yes'.tr,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> onLogOut() async {
    Get.delete<HomeController>();
    Get.deleteAll();
    await SharePrefsHelper.clearData();
    Navigator.pop(Get.context!);
    Get.offAllNamed(AppRoute.navScreen);
  }

  /// Load profile data from HomeController
  void _loadProfileFromHomeController() {
    profileData.value = _homeController.profileData.value;
    networkImageUrl.value = _homeController.profileImageUrl.value;
  }

  /// Fetch profile data from API (only called after image upload)
  Future<void> fetchProfile() async {
    try {
      isLoading(true);
      Response response = await ApiClient.getData(ApiConstant.getProfile);

      if (response.statusCode == 200) {
        profileData.value = ProfileModel.fromJson(response.body);

        // Set network image URL if available
        if (profileData.value?.data?.image != null &&
            profileData.value!.data!.image!.isNotEmpty) {
          String imagePath = profileData.value!.data!.image!;
          // If the image path doesn't start with http, prepend the image base URL
          if (!imagePath.startsWith('http')) {
            networkImageUrl.value = ApiConstant.imageBaseUrl + imagePath;
          } else {
            networkImageUrl.value = imagePath;
          }
          debugPrint('====> Profile Image URL: ${networkImageUrl.value}');
        }

        // Update HomeController with new profile data
        _homeController.profileData.value = profileData.value;
        _homeController.profileImageUrl.value = networkImageUrl.value;
        if (profileData.value?.data?.name != null) {
          _homeController.profileName.value = profileData.value!.data!.name!;
        }
      } else {
        showCustomSnackBar("Failed to load profile", isError: true);
      }
      isLoading(false);
    } catch (e) {
      isLoading(false);
      showCustomSnackBar(
        "Error loading profile: ${e.toString()}",
        isError: true,
      );
    }
  }

  /// Pick image from gallery with permission handling
  Future<void> pickImageFromGallery() async {
    try {
      // For Android 13+ (API 33+), image_picker uses Photo Picker which doesn't need permissions
      // For older versions, we need storage permission
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo < 33) {
          // Only request permission for Android 12 and below
          final permission = await Permission.storage.request();
          if (permission.isDenied) {
            _showPermissionDialog(
              'Permission Required',
              'Please allow access to storage to select a profile picture.',
              false,
            );
            return;
          } else if (permission.isPermanentlyDenied) {
            _showPermissionDialog(
              'Permission Required',
              'Storage access is permanently denied. Please enable it from app settings.',
              true,
            );
            return;
          }
        }
        // For Android 13+, no permission needed - Photo Picker handles it
      } else if (Platform.isIOS) {
        // For iOS, check and request photos permission
        final permission = await Permission.photos.request();
        if (permission.isDenied) {
          _showPermissionDialog(
            'Permission Required',
            'Please allow access to photos to select a profile picture.',
            false,
          );
          return;
        } else if (permission.isPermanentlyDenied) {
          _showPermissionDialog(
            'Permission Required',
            'Photo access is permanently denied. Please enable it from app settings.',
            true,
          );
          return;
        }
      }

      // Pick image from gallery
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        debugPrint('====> Image picked from gallery: ${pickedFile.path}');
        profileImagePath.value = pickedFile.path;
        // Upload image immediately after selection
        debugPrint('====> Starting upload...');
        await uploadProfileImage(File(pickedFile.path));
      } else {
        debugPrint('====> No image selected from gallery');
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to pick image: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  /// Pick image from camera with permission handling
  Future<void> pickImageFromCamera() async {
    try {
      // Request camera permission
      PermissionStatus cameraPermission = await Permission.camera.request();

      if (cameraPermission.isGranted) {
        final XFile? pickedFile = await _picker.pickImage(
          source: ImageSource.camera,
          imageQuality: 85,
        );

        if (pickedFile != null) {
          debugPrint('====> Image captured from camera: ${pickedFile.path}');
          profileImagePath.value = pickedFile.path;
          // Upload image immediately after capture
          debugPrint('====> Starting upload...');
          await uploadProfileImage(File(pickedFile.path));
        } else {
          debugPrint('====> No image captured from camera');
        }
      } else if (cameraPermission.isDenied) {
        _showPermissionDialog(
          'Permission Required',
          'Please allow camera access to take a profile picture.',
          false,
        );
      } else if (cameraPermission.isPermanentlyDenied) {
        _showPermissionDialog(
          'Permission Required',
          'Camera access is permanently denied. Please enable it from app settings.',
          true,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to take photo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  /// Upload profile image to server
  Future<void> uploadProfileImage(File imageFile) async {
    try {
      isUploading(true);

      // Get bearer token
      String bearerToken = await SharePrefsHelper.getString(
        AppConstants.bearerToken,
      );

      var mainHeaders = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $bearerToken',
      };

      debugPrint('====> Uploading image: ${imageFile.path}');
      debugPrint('====> API Call: ${ApiConstant.updateProfile}');

      // Create multipart request
      var request = http.MultipartRequest(
        'PATCH',
        Uri.parse(ApiConstant.baseUrl + ApiConstant.updateProfile),
      );

      // Add headers
      request.headers.addAll(mainHeaders);

      // Add the image file
      var mimeType = lookupMimeType(imageFile.path);
      debugPrint('====> MimeType: $mimeType');

      var multipartFile = await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
      );
      request.files.add(multipartFile);

      debugPrint('====> Sending request...');

      // Send request
      http.StreamedResponse streamedResponse = await request.send();
      final content = await streamedResponse.stream.bytesToString();

      debugPrint(
        '====> API Response: [${streamedResponse.statusCode}] $content',
      );

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        // Refresh profile to get updated image URL
        await fetchProfile();

        Get.snackbar(
          'Success',
          'Profile image updated successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1771B7),
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        showCustomSnackBar(
          "Failed to upload image: ${streamedResponse.reasonPhrase}",
          isError: true,
        );
      }
      isUploading(false);
    } catch (e) {
      isUploading(false);
      debugPrint('====> Upload error: ${e.toString()}');
      showCustomSnackBar(
        "Error uploading image: ${e.toString()}",
        isError: true,
      );
    }
  }

  /// Show image source selection dialog
  void showImageSourceDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomText(
                text: 'Select Image Source'.tr,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF1771B7),
                ),
                title: const Text('Gallery'),
                onTap: () {
                  Get.back();
                  pickImageFromGallery();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF1771B7)),
                title: const Text('Camera'),
                onTap: () {
                  Get.back();
                  pickImageFromCamera();
                },
              ),
              if (profileImagePath.value.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Remove Photo'),
                  onTap: () {
                    Get.back();
                    profileImagePath.value = "";
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Get Android SDK version
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  /// Show permission dialog
  void _showPermissionDialog(String title, String message, bool openSettings) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(Get.context!),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                      if (openSettings) {
                        openAppSettings();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1771B7),
                    ),
                    child: Text(openSettings ? 'Open Settings' : 'OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
