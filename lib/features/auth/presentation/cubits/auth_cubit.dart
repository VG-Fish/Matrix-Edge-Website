import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';
import 'package:matrix_edge_website/features/auth/domain/repositories/auth.dart';
import 'package:matrix_edge_website/features/auth/presentation/cubits/auth_states.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo authRepo;
  MatrixEdgeUser? _currentUser;

  AuthCubit({required this.authRepo}) : super(AuthInitial());

  void checkAuth() async {
    final MatrixEdgeUser? user = await authRepo.getCurrentUser();

    if (user != null) {
      _currentUser = user;
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  MatrixEdgeUser? get currentUser => _currentUser;

  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.loginWithEmailPassword(email, password);

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> register(String name, String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await authRepo.registerWithEmailPassword(
        name,
        email,
        password,
      );

      if (user != null) {
        _currentUser = user;
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (error) {
      emit(AuthError(error.toString()));
    }
  }

  Future<void> logout() async {
    authRepo.logout();
    emit(Unauthenticated());
  }
}
