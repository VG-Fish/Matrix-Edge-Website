import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String amount;
  final String imageUrl;
  final DateTime timestamp;

  Post({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.amount,
    required this.imageUrl,
    required this.timestamp,
  });

  Post copyWith({String? imageUrl}) {
    return Post(
      id: id,
      userId: userId,
      userName: userName,
      text: text,
      amount: amount,
      imageUrl: imageUrl ?? this.imageUrl,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "userId": userId,
      "userName": userName,
      "amount": amount,
      "text": text,
      "imageUrl": imageUrl,
      "timestamp": timestamp,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      userId: json["userId"],
      userName: json["userName"],
      text: json["text"],
      amount: json["amount"],
      imageUrl: json["imageUrl"],
      timestamp: (json["timestamp"] as Timestamp).toDate(),
    );
  }
}
