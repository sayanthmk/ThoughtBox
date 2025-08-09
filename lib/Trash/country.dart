// // models/country_model.dart
// import 'package:flutter/material.dart'; 
// import 'dart:convert';
// import 'package:http/http.dart' as http;

// class Country {
//   final String commonName;

//   Country({required this.commonName});

//   factory Country.fromJson(Map<String, dynamic> json) {
//     return Country(
//       commonName: json['name']['common'],
//     );
//   }
// }
// // services/api_service.dart

// class ApiService {
//   static const String url = 'https://restcountries.com/v3.1/all?fields=name';

//   Future<List<Country>> fetchCountries() async {
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final List<dynamic> data = jsonDecode(response.body);
//       return data.map((json) => Country.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load countries');
//     }
//   }
// }
// // main.dart
// // import 'package:flutter/material.dart';
// // import 'models/country_model.dart';
// // import 'services/api_service.dart';

// // void main() {
// //   runApp(MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       title: 'Country List',
// //       theme: ThemeData(primarySwatch: Colors.blue),
// //       home: CountryListScreen(),
// //     );
// //   }
// // }

// class CountryListScreen extends StatefulWidget {
//   @override
//   _CountryListScreenState createState() => _CountryListScreenState();
// }

// class _CountryListScreenState extends State<CountryListScreen> {
//   final ApiService apiService = ApiService();
//   late Future<List<Country>> futureCountries;

//   @override
//   void initState() {
//     super.initState();
//     futureCountries = apiService.fetchCountries();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Countries')),
//       body: FutureBuilder<List<Country>>(
//         future: futureCountries,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//             return Center(child: Text('No countries found'));
//           }

//           final countries = snapshot.data!;

//           return ListView.builder(
//             itemCount: countries.length,
//             itemBuilder: (context, index) {
//               return ListTile(
//                 title: Text(countries[index].commonName),
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }
