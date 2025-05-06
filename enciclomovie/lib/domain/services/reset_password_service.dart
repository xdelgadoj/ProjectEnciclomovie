import 'package:enciclomovie/domain/repositories/auth_repository.dart';

class ResetPasswordService {
  final AuthRepository repository;

  ResetPasswordService(this.repository);

  Future<void> execute(String email) {
    return repository.sendPasswordReset(email);
  }
}
