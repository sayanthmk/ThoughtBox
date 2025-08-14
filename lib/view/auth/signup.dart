import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbox/const/colors.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_bloc.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_event.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_state.dart';
import 'package:thoughtbox/view/auth/signin.dart';
import 'package:thoughtbox/view/convert/convert_page.dart';
import 'package:thoughtbox/widgets/custom_button.dart';
import 'package:thoughtbox/widgets/custom_textformfield.dart';

class SignUpPage extends StatelessWidget {
  SignUpPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondary,
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => CurrencyConverterPage()),
              (route) => false,
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: AppColors.primary,
                      child: Icon(
                        Icons.person_outline_outlined,
                        color: AppColors.secondary,
                        size: 50,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Hello User !',
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    SizedBox(
                      width: 230,
                      child: Text(
                        'Sign Up For Better Experience',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.hintText,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'E-Mail ID',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: emailController,
                            prefixIcon: Icons.email,
                            hintText: 'Enter Email',
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter Email';
                              }
                              if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(value)) {
                                return 'Enter valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Enter Password',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: passwordController,
                            hintText: 'Enter Password',
                            prefixIcon: Icons.lock,
                            obscureText: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter Password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),
                          Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Confirm Password',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.grey),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomTextFormField(
                            controller: confirmPasswordController,
                            hintText: 'Enter Password',
                            prefixIcon: Icons.lock,
                            obscureText: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Re-enter password';
                              }
                              if (value != passwordController.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 60),
                          CustomButton(
                            width: 400,
                            borderRadius: 15,
                            text: 'Sign Up',
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                final email = emailController.text.trim();
                                final password = passwordController.text.trim();
                                context.read<AuthBloc>().add(
                                      SignUpEmailPasswordEvent(
                                        email: email,
                                        password: password,
                                      ),
                                    );
                              }
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                    RichText(
                      text: TextSpan(
                        text: 'Already have an account?',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: ' Log In',
                            style: TextStyle(
                              color: AppColors.buttonColor,
                              decoration: TextDecoration.underline,
                              fontStyle: FontStyle.italic,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          EmailPasswordLoginPage()),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
