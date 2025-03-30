import 'dart:typed_data'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appbansach/models/book.dart';
import 'dart:convert';

class BookService {
  final CollectionReference books = FirebaseFirestore.instance.collection('books');

    // Tạo sách mới
  Future<void> createBook(Book book, Uint8List? imageBytes) async {
    try {
      // Nếu có ảnh, mã hóa thành Base64 và lưu vào thuộc tính `image`
      if (imageBytes != null) {
        book.setImageFromBytes(imageBytes);
      }

      await books.add(book.toMap());
      print("Book created successfully");
    } catch (e) {
      print("Error creating book: $e");
    }
  }

  // Cập nhật sách
// Updated BookService to handle image as a parameter
Future<void> updateBook(String bookId, Map<String, dynamic> updatedData, {Uint8List? imageBytes}) async {
  try {
    if (imageBytes != null) {
      updatedData['image'] = base64Encode(imageBytes);
    }

    await books.doc(bookId).update(updatedData);
    print("Book updated successfully");
  } catch (e) {
    print("Error updating book: $e");
  }
}


  // Đọc tất cả sách
  Stream<List<Map<String, dynamic>>> getBooks() {
    return books.snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
        .toList());
  }

  

  // Xóa sách
  Future<void> deleteBook(String bookId) async {
    try {
      await books.doc(bookId).delete();
      print("Book deleted successfully");
    } catch (e) {
      print("Error deleting book: $e");
    }
  }

  // Lấy sách theo tên tác giả
  Stream<List<Map<String, dynamic>>> getBooksByAuthorName(String authorName) {
    return books
        .where('authorName', isEqualTo: authorName)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
            .toList());
  }

  // Lấy sách theo ID
  Future<Map<String, dynamic>> getBookById(String bookId) async {
    final doc = await books.doc(bookId).get();
    return doc.exists ? {...doc.data() as Map<String, dynamic>, 'id': doc.id} : {};
  }

  // Cập nhật số lượng sách trong Firestore
  Future<void> updateBookQuantity(String bookId, int quantity) async {
    try {
      if (quantity <= 0) {
        // Nếu quantity <= 0, xóa sách
        await deleteBook(bookId);
      } else {
        // Nếu quantity > 0, cập nhật lại sách với số lượng mới
        await books.doc(bookId).update({'quantity': quantity});
        print("Book quantity updated successfully");
      }
    } catch (e) {
      print("Error updating book quantity: $e");
    }
  }
  
  
}
