import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appbansach/models/book.dart';
import 'shared_app_bar.dart';
import 'book_detail_screen.dart';

class SearchCategoryScreen extends StatelessWidget {
  final String categoryName;

  const SearchCategoryScreen({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    final Stream<List<Book>> booksStream = FirebaseFirestore.instance
        .collection('books')
        .where('category', isEqualTo: categoryName)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              final data = doc.data();
              return Book.fromFirestore(data, doc.id);
            }).toList());

    return Scaffold(
      appBar: const SharedAppBar(title: "Search Books"),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<List<Book>>(
          stream: booksStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return const Center(child: Text('Error loading books'));
            }

            final books = snapshot.data ?? [];

            if (books.isEmpty) {
              return const Center(
                child: Text(
                  'No books available in this category.',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: book.getImageBytes() != null
                    ? Image.memory(
                        book.getImageBytes()!,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        'assets/images/placeholder_image.jpg',
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(book.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('Price: ${book.price} VND'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BookDetailScreen(book: book),
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
    );
  }
}
