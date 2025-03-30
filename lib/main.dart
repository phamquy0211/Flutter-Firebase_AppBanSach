import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appbansach/widget_tree.dart';
import 'firebase_options.dart';
import 'package:appbansach/services/cart_service.dart';
import 'pages/category_screen.dart';
import 'pages/login_register_screen.dart';
import 'pages/home_screen.dart';
import 'pages/add_book_screen.dart';
import 'package:appbansach/pages/cart_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.orange,
        ),
        home: WidgetTree(),
        routes: {
          '/home': (context) => HomeScreen(),
          '/category': (context) => CategoryScreen(),
          '/login': (context) => LoginPage(),
          '/addbook': (context) => AddBookScreen(),
          '/cart': (context) {
            // Lấy userId từ FirebaseAuth
            final userId = FirebaseAuth.instance.currentUser?.uid;
            if (userId != null) {
              return CartPage(userId: userId);
            } else {
              
              return LoginPage();
            }
          },
        },
      ),
    );
  }
}
