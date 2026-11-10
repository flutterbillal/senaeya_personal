import 'package:Senaeya/Service/api_url.dart';
import 'package:Senaeya/View/Widgegts/custom_text/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../Utils/AppImg/app_img.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String imagePath;
  // final Color color;
  final VoidCallback? onTap;
  final bool isSelected;

  const ServiceCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.onTap,
    // required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    // print("=============imageUrl:$imagePath");

    // Check if the image is SVG or other format (PNG, JPG)
    bool isSvg = imagePath.toLowerCase().endsWith('.svg');

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          SizedBox(
            width: 166.w,
            height: 174.h,
            child: Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16.r),
              ),
              elevation: 3,
              child: Column(
                // Distribute space so image and title don't overflow the fixed card size
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: 77.w,
                    height: 77.h,
                    child: Center(
                      child: _buildImage(isSvg),
                    ),
                  ),
                  // Title should be allowed to wrap to 2 lines and shrink if needed
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: CustomText(
                      text: title,
                      textAlign: TextAlign.center,
                      fontSize:
                          16, // raw value; CustomText applies .sp internally
                      minFontSize: 10,
                      maxLines: 2,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 12.h),
                ],
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(100.r),
                border: Border.all(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              // Ensure the check icon fits inside the small circular container
              child: isSelected
                  ? Center(
                      child: SvgPicture.asset(
                        AppIcon.check,
                        height: 16.w,
                        width: 16.w,
                      ),
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(bool isSvg) {
    // Check if it's a network image (starts with http/https) or local path
    bool isNetworkImage =
        imagePath.startsWith('http') || imagePath.startsWith('https');
    bool isServerPath = imagePath.startsWith('/');

    if (isSvg) {
      // SVG image
      if (isNetworkImage) {
        return SvgPicture.network(
          imagePath,
          fit: BoxFit.contain,
          placeholderBuilder: (context) => const CircularProgressIndicator(),
        );
      } else if (isServerPath) {
        return SvgPicture.network(
          "${ApiConstant.imageBaseUrl}$imagePath",
          fit: BoxFit.contain,
          placeholderBuilder: (context) => const CircularProgressIndicator(),
        );
      } else {
        return SvgPicture.asset(
          imagePath,
          fit: BoxFit.contain,
        );
      }
    } else {
      // PNG, JPG or other image format
      if (isNetworkImage) {
        return Image.network(
          imagePath,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      } else if (isServerPath) {
        return Image.network(
          "${ApiConstant.imageBaseUrl}$imagePath",
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      } else {
        return Image.asset(
          imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error, color: Colors.red);
          },
        );
      }
    }
  }
}
