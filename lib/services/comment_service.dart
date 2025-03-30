import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  final CollectionReference comments =
      FirebaseFirestore.instance.collection('comments');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Tạo bình luận mới
  Future<void> createComment(Map<String, dynamic> commentData) async {
    try {
      await comments.add(commentData);
    } catch (e) {
      print("Error creating comment: $e");
    }
  }

  // Đọc bình luận theo bookId
   Stream<List<Map<String, dynamic>>> getComments(String bookId) {
  try {
    return FirebaseFirestore.instance
        .collection('comments')
        .where('bookId', isEqualTo: bookId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return {
                'id': doc.id,
                ...doc.data(), // Bảo đảm casting đúng
              };
            }).toList());
  } catch (e) {
    print("Lỗi khi lấy dữ liệu Firestore: $e");
    return Stream.error('Không thể tải bình luận.');
  }
}

  // Cập nhật bình luận
  Future<void> updateComment(String commentId, Map<String, dynamic> updatedData) async {
    try {
      await comments.doc(commentId).update(updatedData);
    } catch (e) {
      print("Error updating comment: $e");
    }
  }

  // Xóa bình luận
  Future<void> deleteComment(String commentId) async {
    await _firestore.collection('comments').doc(commentId).delete();
  }
}
