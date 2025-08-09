// // models/exchange_rate_model.dart
// import 'package:flutter/material.dart';

// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class ExchangeRate {
//   final String currency;
//   final double rate;

//   ExchangeRate({required this.currency, required this.rate});

//   factory ExchangeRate.fromMapEntry(String key, dynamic value) {
//     // Removes the "USD" prefix
//     final currencyCode = key.replaceFirst('USD', '');
//     return ExchangeRate(currency: currencyCode, rate: value.toDouble());
//   }
// }
// // services/exchange_rate_service.dart

// class ExchangeRateService {
//   Future<List<ExchangeRate>> fetchExchangeRates() async {
//     final url = Uri.parse(
//         'https://api.currencylayer.com/live?access_key=a69dedc38f5137de957fa2651a67fb88'); // Replace with actual URL and your API key

//     final headers = {
//       'apikey':
//           'a69dedc38f5137de957fa2651a67fb88' // Replace this with your actual API key
//     };

//     final response = await http.get(url, headers: headers);

//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       final Map<String, dynamic> quotes = data['quotes'];

//       return quotes.entries
//           .map((entry) => ExchangeRate.fromMapEntry(entry.key, entry.value))
//           .toList();
//     } else {
//       throw Exception('Failed to fetch exchange rates');
//     }
//   }
// }
// // main.dart

// class CurrencyApp extends StatelessWidget {
//   const CurrencyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Currency Exchange',
//       theme: ThemeData(primarySwatch: Colors.teal),
//       home: const ExchangeRateScreen(),
//     );
//   }
// }

// class ExchangeRateScreen extends StatefulWidget {
//   const ExchangeRateScreen({super.key});

//   @override
//   State<ExchangeRateScreen> createState() => _ExchangeRateScreenState();
// }

// class _ExchangeRateScreenState extends State<ExchangeRateScreen> {
//   final ExchangeRateService _service = ExchangeRateService();
//   late Future<List<ExchangeRate>> _ratesFuture;

//   @override
//   void initState() {
//     super.initState();
//     _ratesFuture = _service.fetchExchangeRates();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Exchange Rates from USD')),
//       body: FutureBuilder<List<ExchangeRate>>(
//         future: _ratesFuture,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return const Center(child: Text('No exchange rates found.'));
//           }

//           final rates = snapshot.data!;
//           return ListView.builder(
//             itemCount: rates.length,
//             itemBuilder: (context, index) {
//               final rate = rates[index];
//               return ListTile(
//                 leading: const Icon(Icons.monetization_on),
//                 title: Text('USD to ${rate.currency}'),
//                 trailing: Text(rate.rate.toStringAsFixed(2)),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
