import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_bloc.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_event.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_state.dart';
import 'package:thoughtbox/view/Auth/signin.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const SignOutEvent());
            },
          ),
        ],
      ),
      body: Center(
        child: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthUnauthenticated) {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => EmailPasswordLoginPage(),
                ),
                (route) => false,
              );
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return Text('Welcome, ${state.user.email}!');
            }
            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
