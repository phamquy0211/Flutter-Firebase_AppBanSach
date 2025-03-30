import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appbansach/services/cart_service.dart';
import 'package:appbansach/models/order.dart';  
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;  
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appbansach/models/cart_item.dart';  

class CartPage extends StatelessWidget {
  final String userId;

  const CartPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context);

    // Lấy userId từ Firebase Authentication
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Giỏ Hàng'),
        ),
        body: const Center(
          child: Text('Vui lòng đăng nhập để xem giỏ hàng'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Giỏ Hàng'),
      ),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: cartService.getCartStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Giỏ hàng trống'));
          }

          final cartData = snapshot.data!.data() ?? {};
          final itemsData = List<Map<String, dynamic>>.from(cartData['items'] ?? []);

          final items = itemsData.map((itemData) => CartItem.fromFirestore(itemData)).toList();

          if (items.isEmpty) {
            return const Center(child: Text('Giỏ hàng trống'));
          }

          double totalAmount = items.fold(
            0,
            (total, item) => total + (item.price * item.quantity),
          );

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];

                    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: FirebaseFirestore.instance
                          .collection('books')
                          .doc(item.bookId)
                          .get(),
                      builder: (context, bookSnapshot) {
                        if (bookSnapshot.connectionState == ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Đang tải...'),
                          );
                        }

                        final bookData = bookSnapshot.data?.data();
                        final bookTitle = bookData?['title'] ?? 'Không xác định';

                        return ListTile(
                          title: Text(bookTitle),
                          subtitle: Text('Số lượng: ${item.quantity}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () {
                                  if (item.quantity > 1) {
                                    cartService.updateItemQuantity(userId, item.bookId, false);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Số lượng không thể nhỏ hơn 1')),
                                    );
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () async {
                                  final bookRef = FirebaseFirestore.instance.collection('books').doc(item.bookId);
                                  final bookSnapshot = await bookRef.get();
                                  final bookData = bookSnapshot.data();

                                  if (bookData != null) {
                                    final availableQuantity = bookData['quantity'] ?? 0;
                                    if (item.quantity < availableQuantity) {
                                      cartService.updateItemQuantity(userId, item.bookId, true);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Số lượng sách trong kho không đủ')),
                                      );
                                    }
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  cartService.removeItem(userId, item.bookId);
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Tổng tiền: ${totalAmount.toStringAsFixed(2)} VND'),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () async {
                    final order = Order(
                      userId: userId,
                      items: items.map((item) => item.toMap()).toList(),
                      orderDate: Timestamp.now(),
                      status: 'pending',
                    );
                    await _saveOrderToFirestore(order, context);
                    await cartService.updateBookQuantityAfterOrder(items);
                    await cartService.clearCart(userId);
                    Navigator.pop(context);
                  },
                  child: const Text('Thanh Toán'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
Future<void> _saveOrderToFirestore(Order order, BuildContext context) async {
  try {
    final orderRef = FirebaseFirestore.instance
        .collection('orders')
        .doc(order.userId)
        .collection('user_orders')
        .doc();
    await orderRef.set(order.toMap());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đơn hàng đã được lưu thành công!')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Lỗi khi lưu đơn hàng: $e')),
    );
  }
}


