import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:enciclomovie/domain/repositories/auth_repository.dart';
import 'package:enciclomovie/domain/services/register_with_email_service.dart';
import 'package:enciclomovie/domain/services/sign_in_with_email_service.dart';
import 'package:enciclomovie/infrastructure/repositories/firebase_auth_repository_impl.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return FirebaseAuthRepositoryImpl(firebaseAuth);
});

final signInWithEmailProvider = Provider<SignInWithEmailService>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithEmailService(repository);
});

final registerWithEmailProvider = Provider<RegisterWithEmailService>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return RegisterWithEmailService(repository);
});

final authStateProvider = StreamProvider<bool>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});
