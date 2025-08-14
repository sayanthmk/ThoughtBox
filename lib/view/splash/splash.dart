import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbox/const/colors.dart';
import 'package:thoughtbox/view/auth/signin.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_bloc.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_event.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_state.dart';
import 'package:thoughtbox/widgets/bottom_nav.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Trigger login check immediately
    Future.microtask(() {
      context.read<AuthBloc>().add(CheckUserLoginEvent());
    });

    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const BottomNav()),
            );
          } else if (state is AuthUnauthenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => EmailPasswordLoginPage()),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.grey,
                  ),
                  child: Icon(
                    Icons.currency_rupee,
                    size: 40,
                    color: AppColors.buttonColor,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'ThoughtBox',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  'Connecting you with trusted professionals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
