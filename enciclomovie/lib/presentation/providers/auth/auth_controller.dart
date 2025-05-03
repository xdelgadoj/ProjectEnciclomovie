import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:enciclomovie/domain/services/sign_in_with_email_service.dart';
import 'package:enciclomovie/domain/services/register_with_email_service.dart';
import 'auth_provider.dart';

enum AuthStatus { initial, loading, success, error }

class AuthController extends StateNotifier<AuthStatus> {
  final SignInWithEmailService signInService;
  final RegisterWithEmailService registerService;

  AuthController({
    required this.signInService,
    required this.registerService,
  }) : super(AuthStatus.initial);

  String? errorMessage;

  Future<void> signIn(String email, String password) async {
    state = AuthStatus.loading;
    try {
      await signInService.execute(email: email, password: password);
      state = AuthStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      state = AuthStatus.error;
    }
  }

  Future<void> register(String email, String password) async {
    state = AuthStatus.loading;
    try {
      await registerService.execute(email: email, password: password);
      state = AuthStatus.success;
    } catch (e) {
      errorMessage = e.toString();
      state = AuthStatus.error;
    }
  }

  Future<void> signOut() async {
    state = AuthStatus.loading;
    try {
      await signInService.repository.signOut();
      state = AuthStatus.initial;
    } catch (e) {
      errorMessage = e.toString();
      state = AuthStatus.error;
    }
  }

  void reset() {
    errorMessage = null;
    state = AuthStatus.initial;
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthStatus>((ref) {
  final signIn = ref.watch(signInWithEmailProvider);
  final register = ref.watch(registerWithEmailProvider);

  return AuthController(
    signInService: signIn,
    registerService: register,
  );
});
