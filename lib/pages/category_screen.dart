import 'package:flutter/material.dart';
import 'package:appbansach/services/category_service.dart';
import 'package:appbansach/pages/search_category_screen.dart';
import 'shared_app_bar.dart';

class CategoryScreen extends StatelessWidget {
  final CategoryService categoryService = CategoryService();

  CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(title: "Danh mục thể loại"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<List<Map<String, dynamic>>>(
          stream: categoryService.getCategoriesWithIds(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final categories = snapshot.data!;
            if (categories.isEmpty) {
              return const Center(
                child: Text(
                  'Không có thể loại có sẵn.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            categories.sort((a, b) => a['name'].compareTo(b['name']));

            return ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final categoryId = category['id'];
                final categoryName = category['name'];
                final categoryDescription = category['description'] ?? '';

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    title: Text(categoryName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(categoryDescription),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => EditCategoryDialog(
                                categoryService: categoryService,
                                categoryId: categoryId,
                                initialName: categoryName,
                                initialDescription: categoryDescription,
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) => AlertDialog(
                                title: const Text("Xác nhận"),
                                content: const Text("Bạn có chắc chắn muốn xóa thể loại này không?"),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Hủy"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      await categoryService.deleteCategory(categoryId);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Thể loại đã được xóa.')),
                                      );
                                    },
                                    child: const Text("Xóa"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SearchCategoryScreen(
                            categoryName: categoryName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) => AddCategoryDialog(categoryService: categoryService),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddCategoryDialog extends StatefulWidget {
  final CategoryService categoryService;

  const AddCategoryDialog({super.key, required this.categoryService});

  @override
  _AddCategoryDialogState createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Thêm thể loại"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Tên thể loại", errorText: errorText),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: "Mô tả"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Hủy"),
        ),
        TextButton(
          onPressed: () async {
            final newName = _nameController.text.trim().toLowerCase();
            if (newName.isEmpty) {
              setState(() {
                errorText = "Tên thể loại không được để trống.";
              });
              return;
            }

            final existingCategories = await widget.categoryService.getCategories().first;
            if (existingCategories.any((name) => name.toLowerCase() == newName)) {
              setState(() {
                errorText = "Tên thể loại đã tồn tại.";
              });
              return;
            }

            widget.categoryService.createCategory({
              'name': _nameController.text.trim(),
              'description': _descriptionController.text.trim(),
            });
            Navigator.pop(context);
          },
          child: const Text("Thêm"),
        ),
      ],
    );
  }
}

class EditCategoryDialog extends StatefulWidget {
  final CategoryService categoryService;
  final String categoryId;
  final String initialName;
  final String initialDescription;

  const EditCategoryDialog({super.key, 
    required this.categoryService,
    required this.categoryId,
    required this.initialName,
    required this.initialDescription,
  });

  @override
  _EditCategoryDialogState createState() => _EditCategoryDialogState();
}

class _EditCategoryDialogState extends State<EditCategoryDialog> {
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String? errorText;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _descriptionController = TextEditingController(text: widget.initialDescription);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Chỉnh sửa thể loại"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Tên thể loại", errorText: errorText),
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: "Mô tả"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Hủy"),
        ),
        TextButton(
          onPressed: () async {
            final newName = _nameController.text.trim().toLowerCase();
            if (newName.isEmpty) {
              setState(() {
                errorText = "Tên thể loại không được để trống.";
              });
              return;
            }

            final existingCategories = await widget.categoryService.getCategories().first;
            if (existingCategories.any((name) => name.toLowerCase() == newName && name != widget.initialName)) {
              setState(() {
                errorText = "Tên thể loại đã tồn tại.";
              });
              return;
            }

            widget.categoryService.updateCategory(widget.categoryId, {
              'name': _nameController.text.trim(),
              'description': _descriptionController.text.trim(),
            });
            Navigator.pop(context);
          },
          child: const Text("Lưu"),
        ),
      ],
    );
  }
}
