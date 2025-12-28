import '../repositories/auth_repository.dart';

class LoginUser {
  final AuthRepository repository;

  LoginUser(this.repository);

  Future<String> call(String username, String password) {
    return repository.login(username, password);
  }
}
