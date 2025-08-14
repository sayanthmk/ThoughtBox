// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:thoughtbox/controller/currency/bloc/currency_bloc.dart';
// import 'package:thoughtbox/controller/currency/bloc/currency_event.dart';
// import 'package:thoughtbox/controller/currency/bloc/currency_state.dart';

// class CurrencyConverterPage extends StatelessWidget {
//   CurrencyConverterPage({super.key});

//   final TextEditingController _amountController = TextEditingController();
//   final ValueNotifier<String> _sourceCurrency = ValueNotifier('USD');
//   final ValueNotifier<String> _targetCurrency = ValueNotifier('EUR');

//   @override
//   Widget build(BuildContext context) {
//     final primaryColor = Color(0xFFD81B60); // bright pink for button
//     final darkBackground = Color(0xFF20232B); // dark background color

//     // Fetch currency list when widget is first built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CurrencyBloc>().add(FetchCurrenciesAndRates());
//     });

//     Widget labelValue(String label, String value, {bool isButton = false}) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label.toUpperCase(),
//             style: TextStyle(
//               color: Colors.white54,
//               fontWeight: FontWeight.w800,
//               fontSize: 13,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: EdgeInsets.symmetric(
//               vertical: 6,
//               horizontal: isButton ? 20 : 8,
//             ),
//             decoration: isButton
//                 ? BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(20),
//                   )
//                 : null,
//             child: Text(
//               value,
//               style: TextStyle(
//                 color: isButton ? darkBackground : Colors.white,
//                 fontWeight: FontWeight.w900,
//                 fontSize: isButton ? 12 : 18,
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     Widget buildCurrencyDropdown({
//       required String label,
//       required String value,
//       required List<String> currencies,
//       required ValueChanged<String?> onChanged,
//     }) {
//       return Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label.toUpperCase(),
//             style: TextStyle(
//               color: Colors.white54,
//               fontWeight: FontWeight.w800,
//               fontSize: 13,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//             decoration: BoxDecoration(
//               color: Colors.white12,
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: DropdownButtonHideUnderline(
//               child: DropdownButton<String>(
//                 value: currencies.contains(value) ? value : null,
//                 items: currencies
//                     .map((currency) => DropdownMenuItem(
//                           value: currency,
//                           child: Text(
//                             currency,
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.w900,
//                               fontSize: 18,
//                             ),
//                           ),
//                         ))
//                     .toList(),
//                 onChanged: onChanged,
//                 dropdownColor: darkBackground,
//                 icon: Icon(Icons.arrow_drop_down, color: Colors.white54),
//               ),
//             ),
//           ),
//         ],
//       );
//     }

//     return Scaffold(
//       backgroundColor: darkBackground,
//       body: SafeArea(
//         minimum: EdgeInsets.all(24),
//         child: BlocConsumer<CurrencyBloc, CurrencyState>(
//           listener: (context, state) {
//             if (state.error != null) {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 SnackBar(content: Text(state.error!)),
//               );
//             }
//           },
//           builder: (context, state) {
//             if (state.isLoading && state.currencies.isEmpty) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Currency Converter',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 22,
//                     fontWeight: FontWeight.w900,
//                   ),
//                 ),
//                 SizedBox(height: 40),
//                 // Amount input
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'AMOUNT',
//                       style: TextStyle(
//                         color: Colors.white54,
//                         fontWeight: FontWeight.w800,
//                         fontSize: 13,
//                       ),
//                     ),
//                     SizedBox(height: 4),
//                     TextField(
//                       controller: _amountController,
//                       keyboardType: TextInputType.number,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.w900,
//                         fontSize: 18,
//                       ),
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.white12,
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(12),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 32),
//                 // Currency selection
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: ValueListenableBuilder<String>(
//                         valueListenable: _sourceCurrency,
//                         builder: (context, value, _) {
//                           return buildCurrencyDropdown(
//                             label: 'From',
//                             value: value,
//                             currencies: state.currencies,
//                             onChanged: (newValue) {
//                               if (newValue != null)
//                                 _sourceCurrency.value = newValue;
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16),
//                       child: Icon(Icons.swap_horiz_rounded,
//                           color: Colors.white54, size: 34),
//                     ),
//                     Expanded(
//                       child: ValueListenableBuilder<String>(
//                         valueListenable: _targetCurrency,
//                         builder: (context, value, _) {
//                           return buildCurrencyDropdown(
//                             label: 'To',
//                             value: value,
//                             currencies: state.currencies,
//                             onChanged: (newValue) {
//                               if (newValue != null)
//                                 _targetCurrency.value = newValue;
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 30),
//                 // Converted amount
//                 labelValue(
//                   'Converted Amount',
//                   state.convertedAmount.isEmpty
//                       ? '0 ${_targetCurrency.value}'
//                       : '${state.convertedAmount} ${_targetCurrency.value}',
//                 ),
//                 SizedBox(height: 4),
//                 Text(
//                   state.lastUpdated.toString(),
//                   style: TextStyle(
//                     color: Colors.white54,
//                     fontWeight: FontWeight.w800,
//                     fontSize: 13,
//                   ),
//                 ),
//                 Spacer(),
//                 // Convert button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: primaryColor,
//                       padding: EdgeInsets.symmetric(vertical: 18),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                     ),
//                     onPressed: state.isLoading
//                         ? null
//                         : () {
//                             context.read<CurrencyBloc>().add(
//                                   ConvertCurrency(
//                                     sourceCurrency: _sourceCurrency.value,
//                                     targetCurrency: _targetCurrency.value,
//                                     amount: _amountController.text,
//                                   ),
//                                 );
//                           },
//                     child: state.isLoading
//                         ? CircularProgressIndicator(color: Colors.white)
//                         : Text(
//                             'Convert',
//                             style: TextStyle(
//                               fontSize: 20,
//                               fontWeight: FontWeight.w900,
//                               color: Colors.white,
//                             ),
//                           ),
//                   ),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
