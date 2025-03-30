import 'cart_item.dart';

class Cart {
  final String userId;
  final List<CartItem> items;

  Cart({
    required this.userId,
    required this.items,
  });

  factory Cart.fromFirestore(Map<String, dynamic> data) {
    final items = (data['items'] as List<dynamic>?)
        ?.map((item) => CartItem.fromFirestore(item))
        .toList() ?? [];

    return Cart(
      userId: data['userId'] ?? '',
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
    };
  }

  double getTotal() {
    return items.fold(0, (total, item) => total + (item.price * item.quantity));
  }
}