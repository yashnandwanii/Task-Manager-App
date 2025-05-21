import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/core/services/shared_pref_service.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';
import 'package:frontend/models/user.models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRemoteRepository {
  final SharedPrefService sharedPrefService = SharedPrefService();
  final AuthLocalRepository authLocalRepository =
      AuthLocalRepository();

  Future<UserModel> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/signup'),
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
          'name': name,
        }),
      );

      if (res.statusCode != 201) {
        throw jsonDecode(res.body)['error'];
      }
      return UserModel.fromMap(jsonDecode(res.body));
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${Constants.backendUri}/auth/login'),
        headers: {
          'Content-type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (res.statusCode != 200) {
        throw jsonDecode(res.body)['error'];
      }
      return UserModel.fromMap(jsonDecode(res.body));
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final token = await sharedPrefService.getToken();
      if (token == null) {
        return null;
      }

      final res = await http.get(
        Uri.parse(
          '${Constants.backendUri}/auth',
        ),
        headers: {
          'Content-type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (res.statusCode != 200 || jsonDecode(res.body) == false) {
        return null;
      }

      final userResponse = await http.get(
        Uri.parse(
          '${Constants.backendUri}/auth',
        ),
        headers: {
          'Content-type': 'application/json',
          'x-auth-token': token,
        },
      );
      if (userResponse.statusCode != 200) {
        throw jsonDecode(userResponse.body)['error'];
      }

      return UserModel.fromJson(res.body);
    } catch (e) {
      final user = await authLocalRepository.getUser();
      return user;
    }
  }
}
