import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';

abstract class AuthRepo {
  Future<MatrixEdgeUser?> loginWithEmailPassword(String email, String password);
  Future<MatrixEdgeUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  );
  Future<void> logout();
  Future<MatrixEdgeUser?> getCurrentUser();
}
