import 'dart:async'; // Thêm import này
import 'dart:convert';
import 'shared_app_bar.dart';
import 'book_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appbansach/models/book.dart';
import 'package:diacritic/diacritic.dart';
import 'package:appbansach/services/book_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CollectionReference books = FirebaseFirestore.instance.collection('books');
  final BookService bookService = BookService();
  
  final TextEditingController _searchController = TextEditingController();
  List<DocumentSnapshot> _searchResults = [];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounce; // Thêm biến Timer

  void _searchBooks(String query) {
    // Hủy Timer cũ nếu có
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    // Thiết lập Timer mới
    _debounce = Timer(const Duration(milliseconds: 300), () async { // Thay đổi thời gian delay nếu cần
      if (query.isEmpty) {
        setState(() {
          _searchResults.clear();
        });
        _hideOverlay();
        return;
      }

      final QuerySnapshot results = await books.get();
      List<DocumentSnapshot> matchedBooks = results.docs.where((doc) {
        String title = removeDiacritics(doc['title']?.toString().toLowerCase() ?? '');
        String searchTerm = removeDiacritics(query.toLowerCase());
        return title.contains(searchTerm);
      }).toList();

      setState(() {
        _searchResults = matchedBooks;
      });

      _showOverlay();
    });
  }

  void _showOverlay() {
    _hideOverlay();
    if (_searchResults.isEmpty) return;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 50),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> data =
                    _searchResults[index].data() as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['title'] ?? 'Untitled'),
                  subtitle: Text(data['authorName'] ?? 'Unknown author'),
                  onTap: () {
                    _hideOverlay();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BookDetailScreen(
                          book: Book.fromFirestore(data, _searchResults[index].id),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void dispose() {
    _hideOverlay();
    _searchController.dispose();
    _debounce?.cancel(); // Hủy Timer khi dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SharedAppBar(
        title: "Boku's Store",
        showBackButton: false,
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: books.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Có lỗi xảy ra'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                return _buildBookGrid(snapshot.data!.docs);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: TextField(
          controller: _searchController,
          onChanged: _searchBooks,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sách...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: const BorderSide(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookGrid(List<DocumentSnapshot> bookDocs) {
    int crossAxisCount = MediaQuery.of(context).size.width > 300 ? 2 : 1;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 10.0,
        childAspectRatio: 0.7,
      ),
      itemCount: bookDocs.length,
      itemBuilder: (context, index) {
        Map<String, dynamic> data =
            bookDocs[index].data() as Map<String, dynamic>;

        return _buildBookCard(data, bookDocs[index].id);
      },
    );
  }

  Widget _buildBookCard(Map<String, dynamic> data, String id) {
    Widget bookImage;
    String? image = data['image'];
    
    if (image != null && image.isNotEmpty) {
      try {
        final base64Decoded = base64Decode(image);
        bookImage = Image.memory(
          base64Decoded,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        );
      } catch (e) {
        bookImage = Image.network(
          image,
          fit: BoxFit.cover,
          height: 150,
          width: double.infinity,
        );
      }
    } else {
      bookImage = const Icon(
        Icons.book,
        size: 100,
        color: Colors.grey,
      );
    }

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      elevation: 8.0,
      color: Colors.blueGrey[50],
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailScreen(
                book: Book.fromFirestore(data, id),
              ),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12.0),
                  topRight: Radius.circular(12.0),
                ),
                image: DecorationImage(
                  image: (bookImage is Image) ? bookImage.image : AssetImage(''),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['title'] ?? 'Untitled',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data['authorName'] ?? 'Unknown author',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${data['price'] ?? 0.0} VND',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
