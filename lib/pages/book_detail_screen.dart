import 'dart:convert'; // Để xử lý Base64
import 'cart_screen.dart'; 
import 'edit_book_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appbansach/models/book.dart';
import 'package:appbansach/models/cart_item.dart';
import 'package:appbansach/models/comment.dart';
import 'package:appbansach/services/cart_service.dart';
import 'package:appbansach/services/comment_service.dart';
import 'package:appbansach/auth.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;
  const BookDetailScreen({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    final cartService = Provider.of<CartService>(context, listen: false);
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditBookScreen(book: book),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: book.image != null && book.image!.isNotEmpty
                    ? Image.memory(
                        base64Decode(book.image!),
                        width: 200,
                        height: 300,
                        fit: BoxFit.cover,
                      )
                    : const Icon(
                        Icons.book,
                        size: 100,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  book.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  'Tác giả: ${book.authorName}',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Danh mục: ${book.categoryId}',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                'Giá: ${book.price.toStringAsFixed(2)} VND',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Số lượng còn lại: ${book.quantity}',
                style: TextStyle(
                  fontSize: 18,
                  color: book.quantity > 0 ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Mô tả:',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              if (book.quantity > 0) ...[
                ElevatedButton(
                  onPressed: () async {
                    final cartItem = CartItem(
                      bookId: book.id,
                      quantity: 1,
                      price: book.price,
                      title: book.title,
                    );
                    final userId = currentUser!.uid;

                    await cartService.addItem(userId, cartItem);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                    );

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartPage(userId: userId),
                      ),
                    );
                  },
                  child: const Text('Thêm vào giỏ hàng'),
                ),
              ] else ...[
                const Text(
                  'Sách này đã hết hàng.',
                  style: TextStyle(fontSize: 16, color: Colors.red),
                ),
              ],
              const Divider(height: 32, thickness: 2),
              const Text(
                'Bình luận',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              // Tích hợp phần bình luận (CommentSection)
              CommentSection(bookId: book.id),
            ],
          ),
        ),
      ),
    );
  }
}

class CommentSection extends StatefulWidget {
  final String bookId;
  const CommentSection({super.key, required this.bookId});

  @override
  CommentSectionState createState() => CommentSectionState();
}

class CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final CommentService commentService = CommentService();
  final Auth auth = Auth();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<List<Map<String, dynamic>>>( 
          stream: commentService.getComments(widget.bookId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              debugPrint("Lỗi khi tải bình luận: ${snapshot.error}");
              return const Text('Lỗi xảy ra khi tải bình luận');
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Text('Chưa có bình luận nào.', style: TextStyle(fontSize: 16));
            }
            final comments = snapshot.data!.map((data) {
              return Comment.fromFirestore(data, data['id']);
            }).toList();

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return FutureBuilder<Map<String, dynamic>?>( 
                  future: auth.getUser(comment.userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (userSnapshot.hasError) {
                      return const Text('Lỗi khi lấy thông tin người dùng');
                    }

                    final email = userSnapshot.data?['email'] ?? 'Người dùng ẩn danh';

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              comment.content,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Người dùng: $email',
                                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                                ),
                                Text(
                                  _formatTimestamp(comment.createdAt),
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                                if (comment.userId == FirebaseAuth.instance.currentUser?.uid)
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await commentService.deleteComment(comment.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Đã xóa bình luận')),
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _commentController,
                decoration: const InputDecoration(
                  hintText: 'Nhập bình luận...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () async {
                if (_commentController.text.trim().isEmpty) return;

                final newComment = Comment(
                  id: '',
                  bookId: widget.bookId,
                  userId: FirebaseAuth.instance.currentUser?.uid ?? '',
                  content: _commentController.text.trim(),
                  createdAt: DateTime.now(),
                );

                await commentService.createComment(newComment.toMap());
                _commentController.clear();

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã thêm bình luận')),
                );
              },
              child: const Text('Gửi'),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) return 'Vừa xong';
    if (difference.inMinutes < 60) return '${difference.inMinutes} phút trước';
    if (difference.inHours < 24) return '${difference.inHours} giờ trước';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

