import 'package:frontend/core/constants/constants.dart';
import 'package:frontend/models/user.models.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRemoteRepository {
  static Future<UserModel> signUp({
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

  static Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      print('39');
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

      print(res.body);
      
      return UserModel.fromMap(jsonDecode(res.body));
    } catch (e) {
      throw (e.toString());
    }
  }
}
