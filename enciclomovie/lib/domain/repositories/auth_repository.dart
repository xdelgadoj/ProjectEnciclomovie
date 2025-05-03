abstract class AuthRepository {
  Future<void> signInWithEmail({required String email, required String password});
  Future<void> registerWithEmail({required String email, required String password});
  Future<void> signOut();
  Stream<bool> get authStateChanges;
}
