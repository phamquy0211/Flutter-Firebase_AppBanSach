import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SharedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;

  const SharedAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
  });

  Future<void> signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      leading: showBackButton
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          : null,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart),
          tooltip: 'Giỏ hàng',
          onPressed: () {
            Navigator.pushNamed(context, '/cart'); // CartPage()
          },
        ),
        IconButton(
          icon: const Icon(Icons.category),
          tooltip: 'Danh mục thể loại',
          onPressed: () {
            Navigator.pushNamed(context, '/category'); // CategoryScreen()
          },
        ),
        IconButton(
          icon: const Icon(Icons.add),
          tooltip: 'Thêm sách',
          onPressed: () {
            Navigator.pushNamed(context, '/addbook'); // AddBookScreen()
          },
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Đăng xuất',
          onPressed: () => signOut(context),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
