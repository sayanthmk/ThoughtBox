// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:equatable/equatable.dart';

// class RateModel {
//   final double rate;
//   final int timestamp; // unix epoch seconds

//   RateModel({required this.rate, required this.timestamp});

//   factory RateModel.fromJson(Map<String, dynamic> json) {
//     return RateModel(
//       rate: (json['rate'] as num).toDouble(),
//       timestamp: json['timestamp'] as int,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'rate': rate,
//         'timestamp': timestamp,
//       };
// }

// class CurrencyRepository {
//   static const _baseUrl = 'https://www.freeforexapi.com/api/live';
//   static const cacheKeyPrefix = 'rate_cache'; // e.g., rate_cache_USDINR
//   static const cacheTimestampKeyPrefix = 'cache_ts'; // e.g., cache_ts_USDINR

//   // helper to build the API pair format -> USDINR USDxxx
//   String _pair(String from, String to) {
//     // freeforexapi uses pairs where USD must be base - we'll handle general pair logic
//     // For simplicity: request pairs where USD is base for rates available e.g., USDINR, USDAED.
//     // If neither from nor to is USD, we compute via USD as an intermediate.
//     return 'USD$to';
//   }

//   Future<Map<String, RateModel>> fetchRatesForPairs(List<String> pairs) async {
//     // pairs example: ['USDAED','USDINR']
//     final url = Uri.parse('$_baseUrl?pairs=${pairs.join(",")}');
//     final resp = await http.get(url);
//     if (resp.statusCode != 200) {
//       throw Exception('HTTP ${resp.statusCode}');
//     }
//     final jsonBody = json.decode(resp.body) as Map<String, dynamic>;
//     if (!jsonBody.containsKey('rates')) {
//       throw Exception('Invalid response');
//     }
//     final Map<String, dynamic> ratesJson = jsonBody['rates'];
//     final out = <String, RateModel>{};
//     ratesJson.forEach((k, v) {
//       out[k] = RateModel.fromJson(v);
//     });
//     return out;
//   }

//   Future<void> cacheRate(String pair, RateModel r) async {
//     final prefs = await SharedPreferences.getInstance();
//     prefs.setString('$cacheKeyPrefix\_$pair', json.encode(r.toJson()));
//     prefs.setInt('$cacheTimestampKeyPrefix\_$pair', r.timestamp);
//   }

//   Future<RateModel?> getCachedRate(String pair) async {
//     final prefs = await SharedPreferences.getInstance();
//     final s = prefs.getString('$cacheKeyPrefix\_$pair');
//     if (s == null) return null;
//     final m = json.decode(s) as Map<String, dynamic>;
//     return RateModel(
//         rate: (m['rate'] as num).toDouble(), timestamp: m['timestamp'] as int);
//   }

//   // returns pair name (USD<TO>) and computed rate from from->to
//   Future<double> getBestRate(String from, String to) async {
//     // If from == to -> 1.0
//     if (from == to) return 1.0;

//     final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

//     // We'll try to fetch USD->to and USD->from (if needed). Strategy:
//     // - If from == USD: fetch USDto
//     // - If to == USD: fetch USDfrom (and invert)
//     // - Otherwise: fetch USDto and USDfrom and compute rate = USD_to / USD_from

//     final List<String> pairsToFetch = [];
//     if (from != 'USD')
//       pairsToFetch.add('USD$from'); // USD<from> to get USD->from
//     pairsToFetch.add('USD$to');

//     // Try cached-first logic: if cached and fresh (<5min) reuse instead of calling API.
//     final Map<String, RateModel?> cached = {};
//     for (final p in pairsToFetch) {
//       cached[p] = await getCachedRate(p);
//     }

//     // check if we can avoid API call (all available and <5min old)
//     final bool allFresh = cached.values.every((r) {
//       if (r == null) return false;
//       return (now - r.timestamp) <= (5 * 60);
//     });

//     Map<String, RateModel> rates = {};

//     try {
//       if (allFresh) {
//         // use cached
//         cached.forEach((k, v) {
//           if (v != null) rates[k] = v;
//         });
//       } else {
//         // call API
//         final fetched = await fetchRatesForPairs(pairsToFetch);
//         rates = fetched;
//         // cache results
//         for (final e in fetched.entries) {
//           await cacheRate(e.key, e.value);
//         }

//         // merge with cached for any missing pair
//         for (final p in pairsToFetch) {
//           if (!rates.containsKey(p) && cached[p] != null) {
//             // fallback to cached (could be older)
//             rates[p] = cached[p]!;
//           }
//         }
//       }
//     } catch (e) {
//       // network/api error => fallback to cached if available and within 30 minutes
//       final bool cachedWithin30Min = cached.values
//           .any((r) => r != null && (now - r!.timestamp) <= (30 * 60));
//       if (!cachedWithin30Min) {
//         throw Exception('Rate unavailable and no usable cache.');
//       } else {
//         // use cached values (prefer fresher ones if multiple)
//         cached.forEach((k, v) {
//           if (v != null) rates[k] = v;
//         });
//       }
//     }

//     // Now compute final conversion from -> to
//     // cases:
//     // - from == USD => rate = USDto
//     // - to == USD => rate = 1 / USDfrom
//     // - otherwise => rate = USDto / USDfrom

//     if (from == 'USD') {
//       final p = 'USD$to';
//       final r = rates[p];
//       if (r == null) throw Exception('Missing rate $p');
//       return r.rate;
//     } else if (to == 'USD') {
//       final p = 'USD$from';
//       final r = rates[p];
//       if (r == null) throw Exception('Missing rate $p');
//       return 1.0 / r.rate;
//     } else {
//       final pTo = 'USD$to';
//       final pFrom = 'USD$from';
//       final rTo = rates[pTo];
//       final rFrom = rates[pFrom];
//       if (rTo == null || rFrom == null) {
//         throw Exception('Missing intermediate USD rates');
//       }
//       return rTo.rate / rFrom.rate;
//     }
//   }

//   // small helper to check freshness of cached pair
//   Future<int?> cachedTimestamp(String pair) async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('$cacheTimestampKeyPrefix\_$pair');
//   }
// }

// // import 'package:equatable/equatable.dart';

// abstract class CurrencyEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class LoadCurrencies extends CurrencyEvent {}

// class ConvertRequested extends CurrencyEvent {
//   final String from;
//   final String to;
//   final double amount;

//   ConvertRequested(
//       {required this.from, required this.to, required this.amount});

//   @override
//   List<Object?> get props => [from, to, amount];
// }

// // import 'package:equatable/equatable.dart';

// class CurrencyState extends Equatable {
//   final List<String> currencies;
//   final bool loading;
//   final String? error;
//   final double convertedAmount;
//   final double rate;
//   final int? rateTimestamp;
//   final bool isCached; // true if used cached value

//   const CurrencyState({
//     this.currencies = const ['USD', 'INR', 'EUR', 'AED'],
//     this.loading = false,
//     this.error,
//     this.convertedAmount = 0.0,
//     this.rate = 0.0,
//     this.rateTimestamp,
//     this.isCached = false,
//   });

//   CurrencyState copyWith({
//     List<String>? currencies,
//     bool? loading,
//     String? error,
//     double? convertedAmount,
//     double? rate,
//     int? rateTimestamp,
//     bool? isCached,
//   }) {
//     return CurrencyState(
//       currencies: currencies ?? this.currencies,
//       loading: loading ?? this.loading,
//       error: error,
//       convertedAmount: convertedAmount ?? this.convertedAmount,
//       rate: rate ?? this.rate,
//       rateTimestamp: rateTimestamp ?? this.rateTimestamp,
//       isCached: isCached ?? this.isCached,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         currencies,
//         loading,
//         error,
//         convertedAmount,
//         rate,
//         rateTimestamp,
//         isCached
//       ];
// }

// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'currency_event.dart';
// // import 'currency_state.dart';
// // import '../../data/currency_repository.dart';

// class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
//   final CurrencyRepository repo;

//   CurrencyBloc({required this.repo}) : super(const CurrencyState()) {
//     on<LoadCurrencies>(_onLoad);
//     on<ConvertRequested>(_onConvert);
//   }

//   Future<void> _onLoad(
//       LoadCurrencies event, Emitter<CurrencyState> emit) async {
//     // In this test we provide a static currency list; could fetch from remote
//     emit(state.copyWith(loading: false, error: null));
//   }

//   Future<void> _onConvert(
//       ConvertRequested event, Emitter<CurrencyState> emit) async {
//     emit(state.copyWith(loading: true, error: null));
//     try {
//       final rate = await repo.getBestRate(event.from, event.to);
//       // check if this rate came from cache: look up cached timestamp and compare to now
//       final pair = (event.to == 'USD' ? 'USD${event.from}' : 'USD${event.to}');
//       final ts = await repo.cachedTimestamp(pair);
//       final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
//       bool isCached = false;
//       if (ts != null && (now - ts) > 0) {
//         // determine if it is older than 5min
//         isCached = (now - ts) > 5 * 60;
//       }
//       final converted = event.amount * rate;
//       emit(state.copyWith(
//         loading: false,
//         convertedAmount: converted,
//         rate: rate,
//         rateTimestamp: ts,
//         isCached: isCached,
//       ));
//     } catch (e) {
//       emit(state.copyWith(loading: false, error: e.toString()));
//     }
//   }
// }

// abstract class AuthEvent extends Equatable {
//   @override
//   List<Object?> get props => [];
// }

// class AuthSignIn extends AuthEvent {
//   final String email, password;
//   AuthSignIn(this.email, this.password);
//   @override
//   List<Object?> get props => [email, password];
// }

// class AuthSignOut extends AuthEvent {}

// // import 'package:equatable/equatable.dart';

// class AuthState extends Equatable {
//   final bool loading;
//   final String? userId;
//   final String? error;

//   const AuthState({this.loading = false, this.userId, this.error});

//   AuthState copyWith({bool? loading, String? userId, String? error}) {
//     return AuthState(
//         loading: loading ?? this.loading,
//         userId: userId ?? this.userId,
//         error: error);
//   }

//   @override
//   List<Object?> get props => [loading, userId ?? '', error ?? ''];
// }

// // import 'auth_event.dart';
// // import 'auth_state.dart';
// // import 'package:firebase_auth/firebase_auth.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   AuthBloc() : super(const AuthState()) {
//     on<AuthSignIn>(_onSignIn);
//     on<AuthSignOut>(_onSignOut);
//   }

//   Future<void> _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
//     emit(state.copyWith(loading: true, error: null));
//     try {
//       final cred = await _auth.signInWithEmailAndPassword(
//           email: event.email, password: event.password);
//       emit(state.copyWith(loading: false, userId: cred.user?.uid));
//     } catch (e) {
//       emit(state.copyWith(loading: false, error: e.toString()));
//     }
//   }

//   Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
//     await _auth.signOut();
//     emit(const AuthState());
//   }
// }

// // // import 'package:flutter_bloc/flutter_bloc.dart';

// // class AuthBloc extends Bloc<AuthEvent, AuthState> {
// //   final FirebaseAuth _auth = FirebaseAuth.instance;

// //   AuthBloc(): super(const AuthState()) {
// //     on<AuthSignIn>(_onSignIn);
// //     on<AuthSignOut>(_onSignOut);
// //   }

// //   Future<void> _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
// //     emit(state.copyWith(loading: true, error: null));
// //     try {
// //       final cred = await _auth.signInWithEmailAndPassword(email: event.email, password: event.password);
// //       emit(state.copyWith(loading: false, userId: cred.user?.uid));
// //     } catch (e) {
// //       emit(state.copyWith(loading: false, error: e.toString()));
// //     }
// //   }

// //   Future<void> _onSignOut(AuthSignOut event, Emitter<AuthState> emit) async {
// //     await _auth.signOut();
// //     emit(const AuthState());
// //   }
// // }

// // import 'package:flutter/material.dart';

// Route createRoute(Widget page) {
//   return PageRouteBuilder(
//     transitionDuration: const Duration(milliseconds: 600),
//     pageBuilder: (context, animation, secondaryAnimation) => page,
//     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//       final rotate = Tween(begin: 0.0, end: 1.0).animate(animation);
//       final offset = Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
//           .animate(animation);
//       return SlideTransition(
//         position: offset,
//         child: RotationTransition(turns: rotate, child: child),
//       );
//     },
//   );
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../blocs/auth/auth_bloc.dart';
// // import '../blocs/auth/auth_event.dart';
// // import '../blocs/auth/auth_state.dart';

// class LoginPage extends StatelessWidget {
//   LoginPage({super.key});
//   final _email = TextEditingController();
//   final _pass = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Login')),
//       body: BlocConsumer<AuthBloc, AuthState>(
//         listener: (context, state) {
//           if (state.userId != null) {
//             Navigator.of(context).pushReplacementNamed('/converter');
//           }
//           if (state.error != null) {
//             ScaffoldMessenger.of(context)
//                 .showSnackBar(SnackBar(content: Text(state.error!)));
//           }
//         },
//         builder: (context, state) {
//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 TextField(
//                     controller: _email,
//                     decoration: const InputDecoration(labelText: 'Email')),
//                 const SizedBox(height: 8),
//                 TextField(
//                     controller: _pass,
//                     decoration: const InputDecoration(labelText: 'Password'),
//                     obscureText: true),
//                 const SizedBox(height: 16),
//                 ElevatedButton(
//                   onPressed: state.loading
//                       ? null
//                       : () {
//                           context.read<AuthBloc>().add(AuthSignIn(
//                               _email.text.trim(), _pass.text.trim()));
//                         },
//                   child: state.loading
//                       ? const CircularProgressIndicator()
//                       : const Text('Login'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../blocs/currency/currency_bloc.dart';
// // import '../blocs/currency/currency_event.dart';
// // import '../widgets/animated_route.dart';
// // import 'amount_input_page.dart';

// class CurrencySelectorPage extends StatelessWidget {
//   const CurrencySelectorPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final bloc = context.read<CurrencyBloc>();
//     final defaultFrom = 'USD';
//     final defaultTo = 'INR';

//     return Scaffold(
//       appBar: AppBar(title: const Text('Select Currencies')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             const Text('From', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             _CurrencyTabs(initial: defaultFrom),
//             const SizedBox(height: 16),
//             const Text('To', style: TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             _CurrencyTabs(initial: defaultTo),
//             const Spacer(),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).push(createRoute(AmountInputPage()));
//               },
//               child: const Text('Next: Enter Amount'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _CurrencyTabs extends StatefulWidget {
//   final String initial;
//   const _CurrencyTabs({required this.initial});
//   @override
//   State<_CurrencyTabs> createState() => _CurrencyTabsState();
// }

// class _CurrencyTabsState extends State<_CurrencyTabs> {
//   late String selected;
//   final List<String> items = ['USD', 'INR', 'EUR', 'AED'];

//   @override
//   void initState() {
//     super.initState();
//     selected = widget.initial;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Wrap(
//       spacing: 8,
//       children: items.map((c) {
//         final isSelected = c == selected;
//         return ChoiceChip(
//           label: Text(c),
//           selected: isSelected,
//           onSelected: (v) {
//             setState(() => selected = c);
//             // store selection in some shared place: here we can use a simple approach:
//             // store in Navigator arguments or better: store in CurrencyBloc via an event (omitted for brevity)
//             // For this example, we'll save into shared_preferences or pass via route arguments; to keep code short, pass via Inherited route:
//             // We'll use a very simple approach: Save selections into SharedPreferences (demo only)
//             // (Implementation detail left to full project)
//           },
//         );
//       }).toList(),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import '../blocs/currency/currency_bloc.dart';
// // import '../blocs/currency/currency_event.dart';
// // import '../widgets/animated_route.dart';
// // import 'result_page.dart';

// class AmountInputPage extends StatefulWidget {
//   AmountInputPage({super.key});
//   final TextEditingController _amountController = TextEditingController();

//   @override
//   State<AmountInputPage> createState() => _AmountInputPageState();
// }

// class _AmountInputPageState extends State<AmountInputPage> {
//   String from = 'USD';
//   String to = 'INR';

//   @override
//   Widget build(BuildContext context) {
//     // In a full app, read from CurrencyBloc or route args. Here kept simple:
//     return Scaffold(
//       appBar: AppBar(title: const Text('Enter Amount')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             TextField(
//               controller: widget._amountController,
//               keyboardType: TextInputType.numberWithOptions(decimal: true),
//               decoration: const InputDecoration(
//                   labelText: 'Amount', border: OutlineInputBorder()),
//             ),
//             const SizedBox(height: 12),
//             ElevatedButton(
//               onPressed: () {
//                 final val = double.tryParse(widget._amountController.text);
//                 if (val == null || val <= 0) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                       content: Text('Enter a valid positive amount')));
//                   return;
//                 }
//                 if (val >= 100000) {
//                   ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                       content: Text('Amount must be < 100,000')));
//                   return;
//                 }
//                 // trigger conversion - we use CurrencyBloc with assumed from/to
//                 context
//                     .read<CurrencyBloc>()
//                     .add(ConvertRequested(from: from, to: to, amount: val));
//                 Navigator.of(context).push(
//                     createRoute(ResultPage(amount: val, from: from, to: to)));
//               },
//               child: const Text('Convert'),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// // import 'package:flutter/material.dart';
// // import 'package:flutter_bloc/flutter_bloc.dart';
// // import 'package:intl/intl.dart';
// // import '../blocs/currency/currency_state.dart';
// // import '../blocs/currency/currency_bloc.dart';
// // import 'package:fl_chart/fl_chart.dart';

// class ResultPage extends StatelessWidget {
//   final double amount;
//   final String from;
//   final String to;
//   const ResultPage(
//       {required this.amount, required this.from, required this.to, super.key});

//   // mock trend data for last 5 days
//   Map<String, double> _mockTrend() {
//     final today = DateTime.now().toUtc();
//     return {
//       DateFormat('MM-dd').format(today.subtract(const Duration(days: 4))): 82.8,
//       DateFormat('MM-dd').format(today.subtract(const Duration(days: 3))): 83.0,
//       DateFormat('MM-dd').format(today.subtract(const Duration(days: 2))):
//           83.15,
//       DateFormat('MM-dd').format(today.subtract(const Duration(days: 1))):
//           83.05,
//       DateFormat('MM-dd').format(today): 83.1,
//     };
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Result')),
//       body: BlocBuilder<CurrencyBloc, CurrencyState>(
//         builder: (context, state) {
//           if (state.loading)
//             return const Center(child: CircularProgressIndicator());
//           if (state.error != null)
//             return Center(child: Text('Error: ${state.error}'));
//           final converted = state.convertedAmount;
//           final rate = state.rate;
//           final ts = state.rateTimestamp;
//           final formattedTs = ts != null
//               ? DateTime.fromMillisecondsSinceEpoch(ts * 1000)
//                   .toLocal()
//                   .toString()
//               : 'N/A';

//           // check freshness label
//           String freshness = '';
//           if (ts != null) {
//             final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
//             final diff = now - ts;
//             if (diff > 30 * 60)
//               freshness = 'Very old';
//             else if (diff > 5 * 60)
//               freshness = 'Old (cached)';
//             else
//               freshness = 'Fresh';
//           }

//           return Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 // animated numeric display
//                 TweenAnimationBuilder<double>(
//                   tween: Tween(begin: 0.0, end: converted),
//                   duration: const Duration(milliseconds: 800),
//                   builder: (context, value, child) {
//                     return Text(
//                       '${value.toStringAsFixed(2)} $to',
//                       style: const TextStyle(
//                           fontSize: 32, fontWeight: FontWeight.bold),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 12),
//                 Text('Rate: 1 $from = ${rate.toStringAsFixed(6)} $to'),
//                 Text(
//                     'Fetched: $formattedTs ${state.isCached ? ' • Cached' : ''}'),
//                 if (freshness.isNotEmpty) Text('Status: $freshness'),
//                 const SizedBox(height: 20),

//                 // Trend chart (mock)
//                 Expanded(
//                   child: Card(
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Column(
//                         children: [
//                           const Text('5-day trend (mock)'),
//                           const SizedBox(height: 8),
//                           Expanded(child: _buildTrendChart(_mockTrend())),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildTrendChart(Map<String, double> data) {
//     final entries = data.entries.toList();
//     final spots = List.generate(
//         entries.length, (i) => FlSpot(i.toDouble(), entries[i].value));
//     return LineChart(
//       LineChartData(
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
//           bottomTitles: AxisTitles(
//             sideTitles: SideTitles(
//                 showTitles: true,
//                 getTitlesWidget: (v, meta) {
//                   final idx = v.toInt();
//                   if (idx < 0 || idx >= entries.length)
//                     return const SizedBox.shrink();
//                   return Text(entries[idx].key);
//                 }),
//           ),
//         ),
//         lineBarsData: [
//           LineChartBarData(
//               spots: spots, isCurved: true, dotData: FlDotData(show: false)),
//         ],
//       ),
//     );
//   }
// }
