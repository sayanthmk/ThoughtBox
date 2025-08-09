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
//     // Fetch currency list when widget is first built
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       context.read<CurrencyBloc>().add(FetchCurrenciesAndRates());
//     });

//     return Scaffold(
//       appBar: AppBar(title: const Text('Currency Converter')),
//       body: BlocConsumer<CurrencyBloc, CurrencyState>(
//         listener: (context, state) {
//           if (state.error != null) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(content: Text(state.error!)),
//             );
//           }
//         },
//         builder: (context, state) {
//           if (state.isLoading && state.currencies.isEmpty) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 // Amount input
//                 TextField(
//                   controller: _amountController,
//                   keyboardType: TextInputType.number,
//                   decoration: const InputDecoration(
//                     labelText: 'Amount',
//                     border: OutlineInputBorder(),
//                   ),
//                 ),
//                 const SizedBox(height: 16),

//                 // From currency dropdown
//                 ValueListenableBuilder<String>(
//                   valueListenable: _sourceCurrency,
//                   builder: (context, value, _) {
//                     return _buildCurrencyDropdown(
//                       label: 'From',
//                       value: value,
//                       currencies: state.currencies,
//                       onChanged: (newValue) {
//                         if (newValue != null) _sourceCurrency.value = newValue;
//                       },
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),

//                 // To currency dropdown
//                 ValueListenableBuilder<String>(
//                   valueListenable: _targetCurrency,
//                   builder: (context, value, _) {
//                     return _buildCurrencyDropdown(
//                       label: 'To',
//                       value: value,
//                       currencies: state.currencies,
//                       onChanged: (newValue) {
//                         if (newValue != null) _targetCurrency.value = newValue;
//                       },
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 20),

//                 // Convert button
//                 ElevatedButton(
//                   onPressed: state.isLoading
//                       ? null
//                       : () {
//                           context.read<CurrencyBloc>().add(
//                                 ConvertCurrency(
//                                   sourceCurrency: _sourceCurrency.value,
//                                   targetCurrency: _targetCurrency.value,
//                                   amount: _amountController.text,
//                                 ),
//                               );
//                         },
//                   child: state.isLoading
//                       ? const CircularProgressIndicator(color: Colors.white)
//                       : const Text('Convert'),
//                 ),
//                 const SizedBox(height: 30),

//                 // Converted amount
//                 Text(
//                   'Converted Amount: ${state.convertedAmount} ${_targetCurrency.value}',
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildCurrencyDropdown({
//     required String label,
//     required String value,
//     required List<String> currencies,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: label,
//         border: const OutlineInputBorder(),
//       ),
//       value: currencies.contains(value) ? value : null,
//       items: currencies
//           .map((currency) => DropdownMenuItem(
//                 value: currency,
//                 child: Text(currency),
//               ))
//           .toList(),
//       onChanged: onChanged,
//     );
//   }
// }
