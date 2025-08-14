import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class SignInEmailPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  const SignInEmailPasswordEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpEmailPasswordEvent extends AuthEvent {
  final String email;
  final String password;

  const SignUpEmailPasswordEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignOutEvent extends AuthEvent {
  const SignOutEvent();
}

class CheckUserLoginEvent extends AuthEvent {} // New event

