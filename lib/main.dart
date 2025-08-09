import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:thoughtbox/controller/bloc/currency_bloc.dart';
import 'package:thoughtbox/services/currency_service.dart';
import 'package:thoughtbox/view/convert_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CurrencyBloc>(
          create: (context) => CurrencyBloc(
            repository: CurrencyRepository(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: CurrencyConverterPage(),
      ),
    );
  }
}

// Main entry point of the app.

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// // Main entry point of the app.
// void main() {
//   runApp(const MyApp());
// }

// // The main application widget.
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Currency Converter',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//         useMaterial3: true,
//       ),
//       home: const CurrencyConverterPage(),
//     );
//   }
// }

// A stateful widget to handle the currency conversion logic.

// A stateful widget to handle the currency conversion logic.
// class CurrencyConverterPage extends StatefulWidget {
//   const CurrencyConverterPage({super.key});

//   @override
//   State<CurrencyConverterPage> createState() => _CurrencyConverterPageState();
// }

// class _CurrencyConverterPageState extends State<CurrencyConverterPage> {
//   // A list to hold all available currency codes.
//   List<String> _currencies = [];
//   // The selected source currency.
//   String _sourceCurrency = 'USD';
//   // The selected target currency.
//   String _targetCurrency = 'EUR';
//   // The input controller for the amount.
//   final TextEditingController _amountController = TextEditingController();
//   // The result of the conversion.
//   String _convertedAmount = '0.00';
//   // A loading state to show a progress indicator.
//   bool _isLoading = false;

//   // The API key for currencylayer.com.
//   static const String _apiKey = 'a69dedc38f5137de957fa2651a67fb88';
//   // The base URL for the API.
//   static const String _apiUrl = 'http://api.currencylayer.com/live';

//   // State variable to store the fetched exchange rates.
//   Map<String, dynamic> _exchangeRates = {};

//   @override
//   void initState() {
//     super.initState();
//     // Fetch the list of currencies when the app starts.
//     _fetchCurrenciesAndRates();
//   }

//   // Fetches the exchange rates and populates the currency list.
//   Future<void> _fetchCurrenciesAndRates() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final response =
//           await http.get(Uri.parse('$_apiUrl?access_key=$_apiKey'));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> data = json.decode(response.body);
//         if (data['success'] == true) {
//           final Map<String, dynamic> quotes = data['quotes'];

//           // The API returns rates like "USDEUR", "USDGBP", etc.
//           // We extract the target currencies (e.g., "EUR", "GBP").
//           _exchangeRates = quotes;
//           final List<String> currencyKeys =
//               quotes.keys.map((key) => key.substring(3)).toList();

//           setState(() {
//             _currencies = currencyKeys..sort();
//             // Ensure the target and source currencies are in the new list.
//             if (!_currencies.contains(_sourceCurrency)) {
//               _sourceCurrency = _currencies.isNotEmpty ? _currencies.first : '';
//             }
//             if (!_currencies.contains(_targetCurrency)) {
//               _targetCurrency = _currencies.isNotEmpty ? _currencies.first : '';
//             }
//             _isLoading = false;
//           });
//         } else {
//           _handleApiError(data['error']['code'], data['error']['info']);
//         }
//       } else {
//         _handleApiError(response.statusCode, 'Failed to fetch exchange rates.');
//       }
//     } catch (e) {
//       _handleException(e);
//     }
//   }

//   // Performs the currency conversion based on the fetched rates.
//   Future<void> _convertCurrency() async {
//     if (_amountController.text.isEmpty) {
//       _showAlertDialog('Input Error', 'Please enter an amount to convert.');
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final double amount = double.parse(_amountController.text);
//       double convertedValue = 0.0;

//       // Handle direct conversion (if source and target are the same).
//       if (_sourceCurrency == _targetCurrency) {
//         convertedValue = amount;
//       } else {
//         // Since the free API only provides rates relative to USD,
//         // we must convert to USD first, then to the target currency.
//         final double sourceToUsdRate =
//             1.0 / (_exchangeRates['USD$_sourceCurrency'] ?? 1.0);
//         final double usdToTargetRate =
//             _exchangeRates['USD$_targetCurrency'] ?? 1.0;

//         convertedValue = amount * sourceToUsdRate * usdToTargetRate;
//       }

//       setState(() {
//         _convertedAmount = convertedValue.toStringAsFixed(2);
//       });
//     } catch (e) {
//       _handleException(e);
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // Handles API errors by showing an alert dialog.
//   void _handleApiError(int code, String message) {
//     setState(() {
//       _isLoading = false;
//     });
//     _showAlertDialog('API Error ($code)', message);
//   }

//   // Handles exceptions (e.g., network errors) by showing an alert dialog.
//   void _handleException(dynamic e) {
//     setState(() {
//       _isLoading = false;
//     });
//     _showAlertDialog('Network Error', 'An error occurred: $e');
//   }

//   // Shows an alert dialog to the user.
//   void _showAlertDialog(String title, String message) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(title),
//         content: Text(message),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('OK'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Currency Converter'),
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: <Widget>[
//               // Input field for the amount
//               TextField(
//                 controller: _amountController,
//                 keyboardType: TextInputType.number,
//                 decoration: InputDecoration(
//                   labelText: 'Amount',
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 20),

//               // Dropdown for the source currency
//               _buildCurrencyDropdown(
//                 label: 'From',
//                 value: _sourceCurrency,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _sourceCurrency = newValue!;
//                   });
//                 },
//               ),
//               const SizedBox(height: 10),

//               // Dropdown for the target currency
//               _buildCurrencyDropdown(
//                 label: 'To',
//                 value: _targetCurrency,
//                 onChanged: (String? newValue) {
//                   setState(() {
//                     _targetCurrency = newValue!;
//                   });
//                 },
//               ),
//               const SizedBox(height: 20),

//               // "Convert" button
//               ElevatedButton(
//                 onPressed: _isLoading ? null : _convertCurrency,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 16.0),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10.0),
//                   ),
//                   backgroundColor: Colors.blueAccent,
//                   foregroundColor: Colors.white,
//                 ),
//                 child: _isLoading
//                     ? const CircularProgressIndicator(color: Colors.white)
//                     : const Text(
//                         'Convert',
//                         style: TextStyle(fontSize: 18),
//                       ),
//               ),
//               const SizedBox(height: 30),

//               // Display the converted amount
//               Container(
//                 padding: const EdgeInsets.all(20.0),
//                 decoration: BoxDecoration(
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(10.0),
//                 ),
//                 child: Text(
//                   'Converted Amount: $_convertedAmount $_targetCurrency',
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper method to build a currency dropdown widget.
//   Widget _buildCurrencyDropdown({
//     required String label,
//     required String value,
//     required ValueChanged<String?> onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         filled: true,
//         fillColor: Colors.grey[100],
//       ),
//       value: _currencies.contains(value) ? value : null,
//       isExpanded: true,
//       items: _currencies.map<DropdownMenuItem<String>>((String currency) {
//         return DropdownMenuItem<String>(
//           value: currency,
//           child: Text(currency),
//         );
//       }).toList(),
//       onChanged: onChanged,
//     );
//   }
// }
