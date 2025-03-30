import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appbansach/models/cart_item.dart';
import 'package:appbansach/models/book.dart';

class CartService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Lấy stream của giỏ hàng của người dùng
  Stream<DocumentSnapshot<Map<String, dynamic>>> getCartStream(String userId) {
    return _firestore.collection('carts').doc(userId).snapshots();
  }

  // Cập nhật số lượng sách trong giỏ hàng
  Future<void> updateItemQuantity(String userId, String bookId, bool isAdd) async {
    final cartRef = FirebaseFirestore.instance.collection('carts').doc(userId);
    final cartSnapshot = await cartRef.get();

    if (!cartSnapshot.exists) {
      // Nếu giỏ hàng chưa tồn tại, không làm gì cả
      return;
    }

    final cartData = cartSnapshot.data();
    final items = List<Map<String, dynamic>>.from(cartData?['items'] ?? []);

    // Tìm item trong giỏ hàng
    final itemIndex = items.indexWhere((item) => item['bookId'] == bookId);
    if (itemIndex == -1) return; // Nếu item không có trong giỏ, thoát

    final item = items[itemIndex];
    final currentQuantity = item['quantity'] ?? 0;

    // Lấy số lượng sách từ Firestore
    final bookRef = FirebaseFirestore.instance.collection('books').doc(bookId);
    final bookSnapshot = await bookRef.get();

    if (!bookSnapshot.exists) return;

    final bookData = bookSnapshot.data();
    final availableQuantity = bookData?['quantity'] ?? 0;

    // Nếu số lượng yêu cầu vượt quá số lượng sách có sẵn, điều chỉnh lại
    if (isAdd && currentQuantity < availableQuantity) {
      item['quantity'] = currentQuantity + 1;
    } else if (!isAdd && currentQuantity > 0) {
      item['quantity'] = currentQuantity - 1;
    }

    // Cập nhật giỏ hàng
    await cartRef.update({
      'items': items,
    });
  }

  Future<void> clearCart(String userId) async {
    final cartRef = _firestore.collection('carts').doc(userId);
    await cartRef.update({'items': []});
  }

  Future<void> addItem(String userId, CartItem newItem) async {
    try {
      final cartRef = _firestore.collection('carts').doc(userId);
      final cartSnapshot = await cartRef.get();

      if (!cartSnapshot.exists) {
        await cartRef.set({'items': []});
      }

      final cartData = cartSnapshot.data() ?? {};
      final List<CartItem> cartItems = (cartData['items'] as List? ?? [])
          .map((item) =>
              CartItem.fromFirestore(item as Map<String, dynamic>? ?? {}))
          .toList();

      // Kiểm tra nếu sách đã có trong giỏ hàng
      final index = cartItems.indexWhere((item) => item.bookId == newItem.bookId);

      if (index != -1) {
        cartItems[index].quantity += newItem.quantity;
      } else {
        cartItems.add(newItem);
      }

      await cartRef.update({
        'items': cartItems.map((item) => item.toMap()).toList(),
      });
    } catch (e) {
      print('Error adding item to cart: $e');
    }
  }

  Future<void> updateBookQuantityAfterOrder(List<CartItem> items) async {
    for (var item in items) {
      final bookRef = _firestore.collection('books').doc(item.bookId);
      final bookSnapshot = await bookRef.get();
      if (!bookSnapshot.exists) continue;

      final bookData = bookSnapshot.data() ?? {};
      final book = Book.fromFirestore(bookData, bookSnapshot.id);

      // Giảm số lượng sách sau khi thanh toán
      await bookRef.update({'quantity': (book.quantity - item.quantity).clamp(0, double.infinity)});
    }
  }
    Future<void> removeItem(String userId, String bookId) async {
    final cartRef = _firestore.collection('carts').doc(userId);
    final cartSnapshot = await cartRef.get();

    if (!cartSnapshot.exists) return;

    final cartData = cartSnapshot.data();
    final items = List<Map<String, dynamic>>.from(cartData?['items'] ?? []);

    items.removeWhere((item) => item['bookId'] == bookId);

    await cartRef.update({
      'items': items,
    });

    notifyListeners();
  }
  

}