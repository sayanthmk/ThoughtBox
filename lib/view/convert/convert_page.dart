import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bounce/bounce.dart';
import 'package:thoughtbox/const/colors.dart';
import 'package:thoughtbox/controller/currency/bloc/currency_bloc.dart';
import 'package:thoughtbox/controller/currency/bloc/currency_event.dart';
import 'package:thoughtbox/view/convert/widgets/convert_card.dart';
import 'package:thoughtbox/view/convert/widgets/currency_selector_page.dart';
import '../../controller/currency/bloc/currency_state.dart';

class CurrencyConverterPage extends StatelessWidget {
  CurrencyConverterPage({super.key});

  final TextEditingController _amountController = TextEditingController();

  final ValueNotifier<String> _sourceCurrency = ValueNotifier('USD');
  final ValueNotifier<String> _targetCurrency = ValueNotifier('EUR');

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyBloc>().add(FetchCurrenciesAndRates());
    });

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
                  CurrencySelectorPage(
                      sourceCurrency: _sourceCurrency,
                      targetCurrency: _targetCurrency,
                      state: state),

                  SizedBox(height: 20.h),

                  // Glassmorphism converted amount with shimmer
                  ConvertedAmountCard(state: state),
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
