class MatrixEdgeUser {
  final String uid;
  final String email;
  final String name;

  MatrixEdgeUser({required this.uid, required this.email, required this.name});

  Map<String, dynamic> toJson() {
    return {"uid": uid, "email": email, "name": name};
  }

  factory MatrixEdgeUser.fromJson(Map<String, dynamic> json) {
    return MatrixEdgeUser(
      uid: json["uid"],
      email: json["email"],
      name: json["name"],
    );
  }
}
