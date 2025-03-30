import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:appbansach/models/book.dart';
import 'package:appbansach/services/book_service.dart';
import 'package:appbansach/services/category_service.dart';

class AddBookScreen extends StatefulWidget {
  const AddBookScreen({super.key});

  @override
  _AddBookScreenState createState() => _AddBookScreenState();
}

class _AddBookScreenState extends State<AddBookScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController authorController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  String? selectedCategory;
  Uint8List? selectedImage;

  final BookService bookService = BookService();
  final CategoryService categoryService = CategoryService();

  String? titleError, authorError, priceError, imageError;

  Future<void> _pickImage() async {
    final result = await ImagePickerWeb.getImageAsBytes();
    if (result != null) {
      setState(() {
        selectedImage = result;
        imageError = null;
      });
    }
  }

  bool _validateInputs() {
    setState(() {
      titleError = titleController.text.trim().isEmpty ? 'Tiêu đề không được để trống.' : null;
      authorError = authorController.text.trim().isEmpty ? 'Tác giả không được để trống.' : null;
      priceError = double.tryParse(priceController.text) == null || double.parse(priceController.text) < 0
          ? 'Giá tiền phải là số lớn hơn hoặc bằng 0.'
          : null;
      imageError = selectedImage == null ? 'Vui lòng chọn ảnh.' : null;
    });
    return titleError == null && authorError == null && priceError == null && imageError == null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm sách mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Tiêu đề sách',
                errorText: titleError,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: authorController,
              decoration: InputDecoration(
                labelText: 'Tác giả',
                errorText: authorError,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 16.0),
            StreamBuilder<List<String>>(
              stream: categoryService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final categories = snapshot.data!;
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300), // Hạn chế kích thước DropdownButtonFormField
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
                    hint: const Text('Chọn thể loại'),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    items: categories.map<DropdownMenuItem<String>>((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(
                          category,
                          // style: const TextStyle(fontSize: 14.0), // Giảm kích thước chữ
                        ),
                      );
                    }).toList(),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Giá tiền (VND)',
                errorText: priceError,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Mô tả',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số lượng',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
            ),
            const SizedBox(height: 20.0),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: selectedImage != null
                    ? Image.memory(selectedImage!, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          imageError ?? 'Nhấn để chọn ảnh',
                          style: TextStyle(color: imageError != null ? Colors.red : Colors.grey),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20.0),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 193, 216, 255),
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                onPressed: () async {
                  if (_validateInputs()) {
                    final quantity = int.tryParse(quantityController.text) ?? 1;
                    final base64Image = selectedImage != null ? base64Encode(selectedImage!) : null;

                    final newBook = Book(
                      id: '',
                      title: titleController.text.trim(),
                      authorName: authorController.text.trim(),
                      categoryId: selectedCategory!,
                      price: double.parse(priceController.text),
                      description: descriptionController.text.trim(),
                      quantity: quantity,
                      image: base64Image,
                    );

                    await bookService.createBook(newBook, selectedImage);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thêm sách mới thành công!')),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text(
                  'Thêm sách mới',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
