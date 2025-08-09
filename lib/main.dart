import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbox/const/auth_datasourse.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_bloc.dart';
import 'package:thoughtbox/controller/currency/bloc/currency_bloc.dart';
import 'package:thoughtbox/services/currency_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:thoughtbox/view/auth/signin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
        BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
                  firebaseDataSource: FirebaseDataSource(
                    firebaseAuth: FirebaseAuth.instance,
                  ),
                )),
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          pageTransitionsTheme: const PageTransitionsTheme(
            builders: {
              TargetPlatform.android: CupertinoPageTransitionsBuilder(),
              TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            },
          ),
        ),
        // home: CurrencyConverterPage(),
        home: EmailPasswordLoginPage(),
      ),
    );
  }
}
