import 'package:enciclomovie/domain/repositories/auth_repository.dart';

class SignInWithEmailService {
  final AuthRepository repository;

  SignInWithEmailService(this.repository);

  Future<void> execute({required String email, required String password}) {
    return repository.signInWithEmail(email: email, password: password);
  }
}
