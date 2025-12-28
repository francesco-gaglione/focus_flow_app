import 'package:dio/dio.dart';
import '../../domain/repositories/auth_repository.dart';
import '../dtos/auth_dtos.dart';

class HttpAuthRepository implements AuthRepository {
  final Dio _dio;
  final String baseUrl;

  HttpAuthRepository({required Dio dio, required this.baseUrl}) : _dio = dio;

  @override
  Future<String> login(String username, String password) async {
    final dto = LoginDto(username: username, password: password);
    final response = await _dio.post('$baseUrl/api/auth/login', data: dto.toJson());
    final responseDto = LoginResponseDto.fromJson(response.data);
    return responseDto.token;
  }
}
