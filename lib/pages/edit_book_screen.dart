import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:appbansach/models/book.dart';
import 'package:appbansach/services/book_service.dart';
import 'package:image_picker_web/image_picker_web.dart';

class EditBookScreen extends StatefulWidget {
  final Book book;
  const EditBookScreen({super.key, required this.book});

  @override
  _EditBookScreenState createState() => _EditBookScreenState();
}

class _EditBookScreenState extends State<EditBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final BookService _bookService = BookService();
  late String title;
  late String authorName;
  late String description;
  late double price;
  late int quantity;
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    title = widget.book.title;
    authorName = widget.book.authorName;
    description = widget.book.description;
    price = widget.book.price;
    quantity = widget.book.quantity;
    _imageBytes = widget.book.getImageBytes();
  }

  Future<void> _pickImage() async {
    final result = await ImagePickerWeb.getImageAsBytes();
    if (result != null) {
      setState(() {
        _imageBytes = result;
      });
    }
  }

  void _saveBook() async {
    if (_formKey.currentState?.validate() ?? false) {
      final updatedBook = Book(
        id: widget.book.id,
        title: title,
        authorName: authorName,
        description: description,
        price: price,
        quantity: quantity,
        image: _imageBytes != null ? base64Encode(_imageBytes!) : null,
        categoryId: widget.book.categoryId,
      );
      await _bookService.updateBook(widget.book.id, updatedBook.toMap(), imageBytes: _imageBytes);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sách đã được cập nhật')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sửa sách')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _imageBytes != null
                    ? Image.memory(
                        _imageBytes!,
                        height: 200,
                        width: 200,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.add_a_photo, size: 100),
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: title,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tiêu đề sách';
                  }
                  return null;
                },
                onChanged: (value) => title = value,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: authorName,
                decoration: const InputDecoration(labelText: 'Tác giả'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên tác giả';
                  }
                  return null;
                },
                onChanged: (value) => authorName = value,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: description,
                decoration: const InputDecoration(labelText: 'Mô tả'),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mô tả sách';
                  }
                  return null;
                },
                onChanged: (value) => description = value,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: price.toString(),
                decoration: const InputDecoration(labelText: 'Giá'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá sách';
                  }
                  return null;
                },
                onChanged: (value) => price = double.parse(value),
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: quantity.toString(),
                decoration: const InputDecoration(labelText: 'Số lượng'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số lượng sách';
                  }
                  return null;
                },
                onChanged: (value) => quantity = int.parse(value),
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _saveBook,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
