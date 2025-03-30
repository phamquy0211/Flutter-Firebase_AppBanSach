import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String bookId;
  final String userId;
  final String content;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.content,
    required this.createdAt,
  });

  // Tạo Book từ Firebase snapshot
  factory Comment.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Comment(
      id: documentId,
      bookId: data['bookId'],
      userId: data['userId'],
      content: data['content'],
      createdAt: (data['createdAt'] as Timestamp).toDate(), // Correct casting
    );
  }

  // Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'userId': userId,
      'content': content,
      'createdAt': createdAt,
    };
  }
}