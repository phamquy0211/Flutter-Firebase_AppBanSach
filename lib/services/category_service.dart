import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryService {
  final CollectionReference categories = FirebaseFirestore.instance.collection('categories');

  // Tạo thể loại mới
  Future<void> createCategory(Map<String, dynamic> categoryData) async {
    try {
      await categories.add(categoryData);
    } catch (e) {
      print("Error creating category: $e");
    }
  }

  Stream<List<String>> getCategories() {
    return categories.snapshots().map((snapshot) {
      // Lọc các tên thể loại từ các Map trong snapshot
      return snapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> getCategoriesWithIds() {
    return categories.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    });
  }

  // Xóa thể loại
  Future<void> deleteCategory(String categoryId) async {
    try {
      await categories.doc(categoryId).delete();
    } catch (e) {
      print("Error deleting category: $e");
    }
  }
  
  // Cập nhật thể loại
  Future<void> updateCategory(String categoryId, Map<String, dynamic> updatedData) async {
    try {
      await categories.doc(categoryId).update(updatedData);
    } catch (e) {
      print("Error updating category: $e");
    }
  }
}