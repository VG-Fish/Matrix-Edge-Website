import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:matrix_edge_website/features/auth/domain/repositories/auth.dart';
import 'package:matrix_edge_website/features/auth/domain/entities/user.dart';

class FirebaseAuthRepo implements AuthRepo {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Future<MatrixEdgeUser?> loginWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);

      DocumentSnapshot userDoc = await firebaseFirestore
          .collection("users")
          .doc(userCredential.user!.uid)
          .get();

      MatrixEdgeUser user = MatrixEdgeUser(
        uid: userCredential.user!.uid,
        email: email,
        name: userDoc["name"],
      );

      return user;
    } catch (error) {
      throw Exception("Login failed: ${error.toString()}");
    }
  }

  @override
  Future<MatrixEdgeUser?> registerWithEmailPassword(
    String name,
    String email,
    String password,
  ) async {
    try {
      UserCredential userCredential = await firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);

      MatrixEdgeUser user = MatrixEdgeUser(
        uid: userCredential.user!.uid,
        email: email,
        name: name,
      );

      await firebaseFirestore
          .collection("users")
          .doc(user.uid)
          .set(user.toJson());

      return user;
    } catch (error) {
      throw Exception("Login failed: ${error.toString()}");
    }
  }

  @override
  Future<void> logout() async {
    await firebaseAuth.signOut();
  }

  @override
  Future<MatrixEdgeUser?> getCurrentUser() async {
    final firebaseUser = firebaseAuth.currentUser;

    if (firebaseUser == null) {
      return null;
    }

    DocumentSnapshot userDoc = await firebaseFirestore
        .collection("users")
        .doc(firebaseUser.uid)
        .get();

    if (!userDoc.exists) {
      return null;
    }

    return MatrixEdgeUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email!,
      name: userDoc["name"],
    );
  }
}
