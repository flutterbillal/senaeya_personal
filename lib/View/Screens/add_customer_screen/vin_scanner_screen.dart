import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flutter_scalable_ocr/flutter_scalable_ocr.dart';

/// A [MobileScannerController] that always reports [DeviceOrientation.portraitUp]
/// so the internal [CameraPreview] never rotates or resizes on micro-tilts.
class _PortraitLockedScannerController extends MobileScannerController {
  _PortraitLockedScannerController({
    super.detectionSpeed,
    super.autoStart,
    super.facing,
    super.torchEnabled,
  });

  @override
  MobileScannerState get value {
    final state = super.value;
    // Always clamp orientation to portraitUp — this prevents CameraPreview's
    // RotatedBox from firing and the SizedBox from flipping on every tilt.
    if (state.deviceOrientation == DeviceOrientation.portraitUp) return state;
    return state.copyWith(deviceOrientation: DeviceOrientation.portraitUp);
  }
}

class VinScannerScreen extends StatefulWidget {
  const VinScannerScreen({super.key});

  @override
  State<VinScannerScreen> createState() => _VinScannerScreenState();
}

class _VinScannerScreenState extends State<VinScannerScreen>
    with WidgetsBindingObserver {
  late MobileScannerController cameraController;
  bool _isProcessing = false;
  bool _isTorchOn = false;
  bool _isOCRMode = true;
  String _lastScannedText = '';
  bool _hasNavigated = false;

  // Loading state to handle camera rebuild smoothly
  bool _isLoading = false;

  final double scanBoxLeftOff = 30;
  final double scanBoxRightOff = 30;
  final double scanBoxTopOff = 200;
  final double scanBoxBottomOff = 200;

  @override
  void initState() {
    super.initState();
    // autoStart:false + manual start after frame prevents the camera from
    // re-initialising on every minor orientation sensor event (the jitter)
    cameraController = _PortraitLockedScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      autoStart: false,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    WidgetsBinding.instance.addObserver(this);
    // Strict portrait lock so the OS never sends a rotation event to the camera
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Start the camera after the first frame is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isOCRMode) {
        cameraController.start();
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_isOCRMode) {
      switch (state) {
        case AppLifecycleState.resumed:
          cameraController.start();
          break;
        case AppLifecycleState.inactive:
        case AppLifecycleState.paused:
          cameraController.stop();
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    cameraController.dispose();
    // Restore portrait lock when leaving scanner
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  bool _isValidVIN(String vin) {
    if (vin.length != 17) return false;
    final vinPattern = RegExp(r'^[A-HJ-NPR-Z0-9]{17}$');
    return vinPattern.hasMatch(vin.toUpperCase());
  }

  void _processBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final scannedValue = barcodes.first.rawValue ?? '';
    if (scannedValue.isEmpty) return;

    if (_isValidVIN(scannedValue)) {
      setState(() => _isProcessing = true);
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) Navigator.of(context).pop(scannedValue.toUpperCase());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid VIN code. VIN must be 17 characters.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  /// Extracts a clean 17-character VIN from raw OCR text by:
  /// 1. Removing spaces between characters (e.g. "M R 0 H B 8..." -> "MR0HB8...")
  /// 2. Stripping leading/trailing symbols (e.g. *VIN* -> VIN)
  /// 3. Sliding a 17-char window over the cleaned string to find a valid VIN
  String? _extractVIN(String rawText) {
    final candidates = <String>{};

    // Full text with all non-VIN chars removed
    final fullCleaned =
        rawText.toUpperCase().replaceAll(RegExp(r'[^A-HJ-NPR-Z0-9]'), '');
    candidates.add(fullCleaned);

    // Also try line-by-line (handles spaced-out VINs on one line)
    for (final line in rawText.split(RegExp(r'[\n\r]+'))) {
      final lineCleaned =
          line.toUpperCase().replaceAll(RegExp(r'[^A-HJ-NPR-Z0-9]'), '');
      if (lineCleaned.isNotEmpty) candidates.add(lineCleaned);
    }

    // Slide a 17-char window over each candidate
    for (final cleaned in candidates) {
      if (cleaned.length < 17) continue;
      for (int i = 0; i <= cleaned.length - 17; i++) {
        final candidate = cleaned.substring(i, i + 17);
        if (_isValidVIN(candidate)) return candidate;
      }
    }

    return null;
  }

  void _processOCR(String text) {
    if (_isProcessing || !mounted || _hasNavigated || _isLoading) return;

    debugPrint('OCR raw text: $text');

    final vin = _extractVIN(text);

    if (vin == null) {
      debugPrint('No valid VIN found in: $text');
      return;
    }

    if (vin == _lastScannedText) return;
    _lastScannedText = vin;

    debugPrint('Valid VIN found: $vin');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasNavigated) {
        setState(() {
          _isProcessing = true;
          _hasNavigated = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('VIN detected: $vin'),
            backgroundColor: Colors.green,
            duration: const Duration(milliseconds: 500),
          ),
        );

        debugPrint('Navigating back with VIN: $vin');
        Future.delayed(const Duration(milliseconds: 100), () {
          if (mounted) {
            Navigator.of(context).pop(vin);
          }
        });
      }
    });
  }

  // Toggle torch with loading state to prevent white screen
  void _toggleTorch() {
    if (_isOCRMode) {
      // For OCR mode: use loading state pattern from official example
      setState(() {
        _isLoading = true;
        _isTorchOn = !_isTorchOn;
      });
      // Brief delay to allow camera to reinitialize with new torch state
      Future.delayed(const Duration(milliseconds: 150), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      });
    } else {
      // For barcode mode: use MobileScanner controller directly
      setState(() => _isTorchOn = !_isTorchOn);
      cameraController.toggleTorch();
    }
  }

  // Switch camera (only works in barcode mode)
  void _switchCamera() {
    if (_isOCRMode) {
      // ScalableOCR doesn't easily support camera switching
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Camera switch not available in OCR mode'),
          duration: Duration(seconds: 1),
        ),
      );
    } else {
      cameraController.switchCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: CustomText(text: 'Scan VIN Code'.tr),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(
                _isTorchOn ? Icons.flash_on : Icons.flash_off,
                color: _isTorchOn ? Colors.yellow : Colors.grey,
              ),
              onPressed: _toggleTorch,
            ),
            IconButton(
              icon: const Icon(Icons.cameraswitch),
              onPressed: _switchCamera,
            ),
            IconButton(
              icon:
                  Icon(_isOCRMode ? Icons.qr_code_scanner : Icons.text_fields),
              tooltip: _isOCRMode ? "Switch to Barcode" : "Switch to OCR",
              onPressed: () {
                final switchingToBarcode =
                    _isOCRMode; // currently OCR → switching to barcode
                setState(() {
                  _isOCRMode = !_isOCRMode;
                  _isProcessing = false;
                  _lastScannedText = '';
                  _isTorchOn = false;
                  _isLoading = false;
                });
                if (switchingToBarcode) {
                  // Switched to barcode mode — start the MobileScanner camera
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) cameraController.start();
                  });
                } else {
                  // Switched to OCR mode — stop the MobileScanner camera
                  cameraController.stop();
                }
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            // Show camera based on mode and loading state
            if (_isOCRMode)
              _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ScalableOCR(
                      getScannedText: (text) {
                        if (!_isProcessing && !_isLoading) {
                          _processOCR(text);
                        }
                      },
                      boxLeftOff: scanBoxLeftOff,
                      boxRightOff: scanBoxRightOff,
                      paintboxCustom: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.green,
                      torchOn: _isTorchOn,
                    )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  // Fixed scanWindow anchors the preview to a stable rect,
                  // preventing the camera from recomposing on slight tilts
                  final scanWindow = Rect.fromCenter(
                    center: Offset(
                      constraints.maxWidth / 2,
                      constraints.maxHeight / 2,
                    ),
                    width: 300,
                    height: 150,
                  );
                  return MobileScanner(
                    controller: cameraController,
                    fit: BoxFit.cover,
                    scanWindow: scanWindow,
                    onDetect: _processBarcode,
                  );
                },
              ),

            // Overlay frame
            Center(
              child: Container(
                width: 300,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            // Instructions
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.symmetric(horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _isOCRMode
                      ? 'Position VIN text inside the frame\n(17 characters)'
                      : 'Position VIN barcode inside the frame',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Processing indicator
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Processing VIN...',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
