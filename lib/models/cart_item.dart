class CartItem {
  final String bookId;
  int quantity;  // Đổi từ final sang biến có thể thay đổi
  final double price;
  final String title;

  CartItem({
    required this.bookId,
    required this.quantity,
    required this.price,
    required this.title,
  });

  factory CartItem.fromFirestore(Map<String, dynamic> data) {
    return CartItem(
      bookId: data['bookId'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      title: data['title'] ?? 'Unknown Title',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookId': bookId,
      'quantity': quantity,
      'price': price,
      'title': title,
    };
  }

  // Phương thức cập nhật số lượng trong giỏ hàng
  void updateQuantity(bool increase) {
    if (increase) {
      quantity++;
    } else {
      quantity--;
    }
  }
}
