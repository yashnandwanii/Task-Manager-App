import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/services/shared_pref_service.dart';
import 'package:frontend/features/auth/repository/auth_local_repository.dart';
import 'package:frontend/features/auth/repository/auth_remote_repository.dart';
import 'package:frontend/models/user.models.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthUserInitial());
  final AuthRemoteRepository authRemoteRepository = AuthRemoteRepository();
  final SharedPrefService sharedPrefService = SharedPrefService();
  final AuthLocalRepository authLocalRepository = AuthLocalRepository();

  void getUserData() async {
    try {
      emit(AuthLoading());
      final usermodel = await authRemoteRepository.getUserData();

      if (usermodel != null) {
        await authLocalRepository.insertUser(usermodel);
        emit(AuthLoggedIn(usermodel));
        return;
      }
      emit(AuthUserInitial());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());
      await authRemoteRepository.signUp(
        name: name,
        email: email,
        password: password,
      );

      emit(AuthSignUp());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void login({
    required String email,
    required String password,
  }) async {
    try {
      emit(AuthLoading());

      final userModel = await authRemoteRepository.login(
        email: email,
        password: password,
      );
      if (userModel.token.isEmpty) {
        emit(AuthError('Invalid credentials'));
        return;
      }
      await sharedPrefService.setToken(userModel.token);

      await authLocalRepository.insertUser(userModel);

      emit(AuthLoggedIn(userModel));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
