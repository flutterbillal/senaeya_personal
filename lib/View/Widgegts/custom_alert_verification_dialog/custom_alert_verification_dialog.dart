import 'package:Senaeya/View/Widgegts/custom_alert_dialog/custom_alert_dialog.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:get/get.dart';

import '../../../Utils/AppColors/app_colors.dart';
import 'verification_controller.dart';

class CustomAlertVerificationDialog extends StatefulWidget {
  final TextEditingController? otpContrller;
  final String? phoneNumber;
  final Function(String)? onVerificationComplete;
  final VoidCallback? onResendCode;

  const CustomAlertVerificationDialog({
    super.key,
    this.phoneNumber,
    this.onVerificationComplete,
    this.onResendCode,
    this.otpContrller,
  });

  @override
  State<CustomAlertVerificationDialog> createState() =>
      _CustomAlertVerificationDialogState();
}

class _CustomAlertVerificationDialogState
    extends State<CustomAlertVerificationDialog> {
  late final VerificationController controller;
  late final TextEditingController _otpController;
  late final FocusNode _otpFocusNode;

  @override
  void initState() {
    super.initState();

    controller = Get.isRegistered<VerificationController>()
        ? Get.find<VerificationController>()
        : Get.put(VerificationController());

    _otpController = widget.otpContrller ?? TextEditingController();
    _otpFocusNode = FocusNode();

    // Keep the keyboard focused when the dialog opens.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _otpFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _otpFocusNode.dispose();

    // Dispose only the controller created by this widget.
    if (widget.otpContrller == null) {
      _otpController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 24,
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomText(
                  text: 'OTP Code'.tr,
                  fontSize: 20,
                  color: Colors.black,
                ),
                const SizedBox(height: 16),
                CustomText(
                  text: 'Enter the activation code sent to\n'
                          'the customer\'s mobile via WhatsApp'
                      .tr,
                  textAlign: TextAlign.center,
                  fontSize: 14,
                  color: Colors.grey[600]!,
                ),
                const SizedBox(height: 32),
                PinCodeTextField(
                  appContext: context,
                  length: 4,
                  keyboardType: TextInputType.number,
                  controller: _otpController,
                  focusNode: _otpFocusNode,
                  autoFocus: true,
                  autoDismissKeyboard: false,
                  enablePinAutofill: false,
                  autoDisposeControllers: false,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 50,
                    fieldWidth: 50,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.grey[100]!,
                    selectedFillColor: Colors.white,
                    activeColor: AppColors.primary,
                    inactiveColor: Colors.grey[300]!,
                    selectedColor: AppColors.primary,
                    borderWidth: 2,
                  ),
                  animationDuration: const Duration(milliseconds: 150),
                  backgroundColor: Colors.transparent,
                  enableActiveFill: true,
                  onCompleted: (value) {
                    controller.completeCode(value);
                  },
                  onChanged: (value) {
                    controller.updateCode(value);

                    // Restore focus if it was lost while typing.
                    if (mounted && !_otpFocusNode.hasFocus) {
                      _otpFocusNode.requestFocus();
                    }
                  },
                ),
                const SizedBox(height: 32),
                Obx(
                  () => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: controller.isCodeComplete
                          ? () {
                              widget.onVerificationComplete?.call(
                                controller.currentText.value,
                              );
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        disabledBackgroundColor: Colors.grey[300],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 0,
                      ),
                      child: CustomText(
                        text: 'activation'.tr,
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                CustomText(
                  text: 'You have a problem?'.tr,
                  fontSize: 14,
                  color: Colors.black87,
                ),
                const SizedBox(height: 8),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.formatTime(
                          controller.countdown.value,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: controller.canResend
                            ? () {
                                widget.onResendCode?.call();
                                controller.startCountdown();
                                _otpFocusNode.requestFocus();
                              }
                            : null,
                        child: CustomText(
                          text: 'Resend the code'.tr,
                          fontSize: 14,
                          color: controller.canResend
                              ? AppColors.red
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
