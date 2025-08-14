import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CurrencyDropdown extends StatelessWidget {
  final String label;
  final String value;
  final List<String> currencies;
  final ValueChanged<String?> onChanged;
  final Color backgroundColor;
  final Color labelColor;
  final Color textColor;
  final Color iconColor;

  const CurrencyDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.currencies,
    required this.onChanged,
    this.backgroundColor = Colors.white12,
    this.labelColor = Colors.white54,
    this.textColor = Colors.white,
    this.iconColor = Colors.white54,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            color: labelColor,
            fontWeight: FontWeight.w800,
            fontSize: 13.sp,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 35.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currencies.contains(value) ? value : null,
              items: currencies
                  .map(
                    (currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(
                        currency,
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18.sp,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              dropdownColor: backgroundColor,
              icon: Icon(Icons.arrow_drop_down, color: iconColor),
            ),
          ),
        ),
      ],
    );
  }
}
