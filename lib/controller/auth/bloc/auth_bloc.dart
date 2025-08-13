import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:thoughtbox/services/auth_service.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_event.dart';
import 'package:thoughtbox/controller/auth/bloc/auth_state.dart';
import 'package:thoughtbox/model/user_model.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseService firebaseDataSource;

  AuthBloc({required this.firebaseDataSource}) : super(AuthInitial()) {
    on<SignInEmailPasswordEvent>(_onSignInWithEmailAndPassword);
    on<SignUpEmailPasswordEvent>(_onSignUpWithEmailAndPassword);
    on<SignOutEvent>(_onSignOut);
  }

  void _onSignInWithEmailAndPassword(
    SignInEmailPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await firebaseDataSource.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        final userModel = UserModel(id: user.uid, email: user.email);
        emit(AuthAuthenticated(userModel));
      } else {
        emit(const AuthError('Sign-in failed. Please check your credentials.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown error occurred.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onSignUpWithEmailAndPassword(
    SignUpEmailPasswordEvent event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await firebaseDataSource.signUpWithEmailAndPassword(
        event.email,
        event.password,
      );
      if (user != null) {
        final userModel = UserModel(id: user.uid, email: user.email);
        emit(AuthAuthenticated(userModel));
      } else {
        emit(const AuthError('Sign-up failed. Please try again.'));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'An unknown error occurred.'));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onSignOut(
    SignOutEvent event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await firebaseDataSource.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
