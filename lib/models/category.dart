class Category {
  final String id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  // Tạo từ Firebase snapshot
  factory Category.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Category(
      id: documentId,
      name: data['name'],
    );
  }

  // Chuyển sang Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}