import 'package:enciclomovie/domain/repositories/auth_repository.dart';

class RegisterWithEmailService {
  final AuthRepository repository;

  RegisterWithEmailService(this.repository);

  Future<void> execute({required String email, required String password}) {
    return repository.registerWithEmail(email: email, password: password);
  }
}
