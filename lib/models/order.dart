import 'package:cloud_firestore/cloud_firestore.dart';

class Order {
  final String userId;
  final List<Map<String, dynamic>> items;
  final Timestamp orderDate;
  final String status;

  Order({
    required this.userId,
    required this.items,
    required this.orderDate,
    required this.status,
  });

  // Phương thức chuyển đổi Order thành Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items,
      'orderDate': orderDate,
      'status': status,
    };
  }
}
