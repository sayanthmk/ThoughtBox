import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:shimmer/shimmer.dart';

class ConvertedAmountCard extends StatelessWidget {
  final dynamic state; // You can replace dynamic with your actual state type

  const ConvertedAmountCard({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100.h,
      borderRadius: 20.r,
      blur: 15,
      alignment: Alignment.center,
      border: 2,
      linearGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.1),
          Colors.white.withOpacity(0.05),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderGradient: LinearGradient(
        colors: [
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.5),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.white,
        highlightColor: Colors.pinkAccent,
        child: Text(
          " ${state.convertedAmount}",
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
