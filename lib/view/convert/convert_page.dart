import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:bounce/bounce.dart';
import 'package:thoughtbox/const/colors.dart';
import 'package:thoughtbox/controller/currency/bloc/currency_bloc.dart';
import 'package:thoughtbox/controller/currency/bloc/currency_event.dart';
import 'package:thoughtbox/view/convert/widgets/dropdown.dart';

import '../../controller/currency/bloc/currency_state.dart';

class CurrencyConverterPage extends StatelessWidget {
  CurrencyConverterPage({super.key});

  // final TextEditingController _amountController =
  //     TextEditingController(text: "100");
  final TextEditingController _amountController = TextEditingController();

  final ValueNotifier<String> _sourceCurrency = ValueNotifier('USD');
  final ValueNotifier<String> _targetCurrency = ValueNotifier('EUR');

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    // final primaryColor = const Color(0xFFD81B60);
    // final darkBackground = const Color(0xFF20232B);

    // final List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY'];
    // final String convertedAmount = "91.50";
    // final String lastUpdated = "2025-08-13 10:00 AM";
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyBloc>().add(FetchCurrenciesAndRates());
    });

    Widget buildCurrencyDropdown({
      required String label,
      required String value,
      required List<String> currencies,
      required ValueChanged<String?> onChanged,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              color: Colors.white54,
              fontWeight: FontWeight.w800,
              fontSize: 13.sp,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: currencies.contains(value) ? value : null,
                items: currencies
                    .map((currency) => DropdownMenuItem(
                          value: currency,
                          child: Text(
                            currency,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 18.sp,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: onChanged,
                dropdownColor: AppColors.darkBackground,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: BlocConsumer<CurrencyBloc, CurrencyState>(
            listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error!)),
            );
          }
        }, builder: (context, state) {
          if (state.isLoading && state.currencies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return AnimationLimiter(
            child: ListView(
              padding: EdgeInsets.all(24.w),
              children: AnimationConfiguration.toStaggeredList(
                duration: 800.ms,
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50,
                  child: FadeInAnimation(child: widget),
                ),
                children: [
                  // Animated Title
                  AnimatedTextKit(
                    animatedTexts: [
                      TypewriterAnimatedText(
                        'Currency Converter',
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w900,
                        ),
                        speed: const Duration(milliseconds: 80),
                      ),
                    ],
                    totalRepeatCount: 1,
                  ),

                  SizedBox(height: 20.h),

                  // Lottie Animation
                  // Lottie.asset(
                  //   'asset/lottie/currency.json', // make sure you have this file
                  //   height: 150.h,
                  // ),

                  SizedBox(height: 20.h),

                  // Amount input
                  Text(
                    'AMOUNT',
                    style: TextStyle(
                      color: Colors.white54,
                      fontWeight: FontWeight.w800,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18.sp,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white12,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Currency selection
                  Row(
                    children: [
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: _sourceCurrency,
                          builder: (context, value, _) {
                            return CurrencyDropdown(
                              label: 'From',
                              value: value,
                              currencies: ['USD', 'INR', 'EUR'],
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  _sourceCurrency.value = newValue;
                                }
                              },
                            );

                            // return buildCurrencyDropdown(
                            //   label: 'From',
                            //   value: value,
                            //   currencies: state.currencies,
                            //   onChanged: (newValue) {
                            //     if (newValue != null) {
                            //       _sourceCurrency.value = newValue;
                            //     }
                            //   },
                            // );
                          },
                        ),
                      ),
                      Icon(Icons.swap_horiz_rounded,
                          color: Colors.white54, size: 34.sp),
                      // SizedBox(
                      //   width: 50,
                      // ),
                      Expanded(
                        child: ValueListenableBuilder<String>(
                          valueListenable: _targetCurrency,
                          builder: (context, value, _) {
                            return buildCurrencyDropdown(
                              label: 'To',
                              value: value,
                              currencies: state.currencies,
                              onChanged: (newValue) {
                                if (newValue != null) {
                                  _targetCurrency.value = newValue;
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20.h),

                  // Glassmorphism converted amount with shimmer
                  GlassmorphicContainer(
                    width: double.infinity,
                    height: 100.h,
                    borderRadius: 20.r,
                    blur: 15,
                    alignment: Alignment.center,
                    border: 2,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.1),
                        Colors.white.withOpacity(0.05)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.5),
                        Colors.white.withOpacity(0.5)
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
                  ),

                  SizedBox(height: 8.h),
                  // Enhanced lastUpdated section - replace the existing simple Text widget
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.access_time_rounded,
                            color: AppColors.primaryColor,
                            size: 16.sp,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Last Updated',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.w600,
                                fontSize: 11.sp,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              state.lastUpdated.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 13.sp,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 12.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.h,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                'Live',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .slideY(
                          begin: 0.2,
                          duration: 600.ms,
                          curve: Curves.easeOutCubic)
                      .fadeIn(duration: 800.ms),

                  SizedBox(height: 30.h),

                  // Convert button with bounce animation
                  Bounce(
                    duration: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 18.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        onPressed: state.isLoading
                            ? null
                            : () {
                                context.read<CurrencyBloc>().add(
                                      ConvertCurrency(
                                        sourceCurrency: _sourceCurrency.value,
                                        targetCurrency: _targetCurrency.value,
                                        amount: _amountController.text,
                                      ),
                                    );
                              },
                        child: Text(
                          'Convert',
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
