import 'dart:convert'; // Để xử lý Base64
import 'dart:typed_data';

class Book {
  final String id;
  final String title;
  final String authorName;
  final String categoryId;
  final double price;
  final String description;
  int quantity;
  String? image; // Thuộc tính hình ảnh dưới dạng Base64

  // Constructor với các tham số yêu cầu
  Book({
    required this.id,
    required this.title,
    required this.authorName,
    required this.categoryId,
    required this.price,
    required this.description,
    this.quantity = 1,
    this.image, // Hình ảnh có thể null
  });

  // Factory method để tạo Book từ Firestore
  factory Book.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Book(
      id: documentId,
      title: data['title'] ?? 'Unknown Title',
      authorName: data['authorName'] ?? 'Unknown Author',
      categoryId: data['category'] ?? 'Unknown Category', // Lấy category từ Firestore
      price: (data['price'] ?? 0).toDouble(),
      description: data['description'] ?? '',
      quantity: data['quantity'] ?? 1,
      image: data['image'], // Đọc dữ liệu ảnh Base64 từ Firestore
    );
  }

  // Chuyển đối tượng Book thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'authorName': authorName,
      'category': categoryId,
      'price': price,
      'description': description,
      'quantity': quantity,
      'image': image, // Lưu ảnh dưới dạng chuỗi Base64
    };
  }

  // Hàm mã hóa ảnh từ Uint8List sang Base64
  void setImageFromBytes(Uint8List imageBytes) {
    image = base64Encode(imageBytes);
  }

  // Hàm giải mã ảnh từ Base64 về Uint8List
  Uint8List? getImageBytes() {
    return image != null ? base64Decode(image!) : null;
  }

  // Hàm kiểm tra và xóa sách nếu số lượng <= 0
  bool shouldDelete() {
    return quantity <= 0;
  }
}
