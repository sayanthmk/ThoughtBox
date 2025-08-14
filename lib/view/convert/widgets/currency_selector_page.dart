import 'package:flutter/material.dart';
import 'package:thoughtbox/view/convert/widgets/dropdown.dart';

class CurrencySelectorPage extends StatelessWidget {
  const CurrencySelectorPage({
    super.key,
    required ValueNotifier<String> sourceCurrency,
    required ValueNotifier<String> targetCurrency,
    this.state,
  })  : _sourceCurrency = sourceCurrency,
        _targetCurrency = targetCurrency;

  final ValueNotifier<String> _sourceCurrency;
  final ValueNotifier<String> _targetCurrency;
  final dynamic state;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: _sourceCurrency,
            builder: (context, value, _) {
              return CurrencyDropdown(
                label: 'From',
                value: value,
                currencies: state.currencies,
                onChanged: (newValue) {
                  if (newValue != null) {
                    _sourceCurrency.value = newValue;
                  }
                },
              );
            },
          ),
        ),
        // Icon(Icons.swap_horiz_rounded, color: Colors.white54, size: 34.sp),
        Icon(Icons.swap_horiz_rounded, color: Colors.white54, size: 34),

        // SizedBox(
        //   width: 50,
        // ),
        Expanded(
          child: ValueListenableBuilder<String>(
            valueListenable: _targetCurrency,
            builder: (context, value, _) {
              return CurrencyDropdown(
                label: 'From',
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
    );
  }
}
