import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Đăng nhập người dùng
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Đăng ký người dùng và lưu thông tin vào Firestore
  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    
  }) async {
    // Tạo người dùng mới
    UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Lấy userId từ FirebaseAuth
    User? user = userCredential.user;

    if (user != null) {
      // Lưu thông tin người dùng vào Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'email': email,
      });

      print("Tạo tài khoản thành công và lưu vào Firestore!");
    }
  }
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      // Truy vấn tài liệu người dùng từ Firestore theo userId
      final snapshot = await _firestore.collection('users').doc(userId).get();

      // Kiểm tra nếu tài liệu người dùng tồn tại
      if (snapshot.exists) {
        return snapshot.data() ?? {}; // Trả về dữ liệu nếu tồn tại
      } else {
        return {'account': 'Người dùng ẩn danh'}; // Trả về tài khoản mặc định nếu không tìm thấy dữ liệu
      }
    } catch (e) {
      print('Lỗi khi lấy thông tin người dùng: $e');
      return {'account': 'Người dùng ẩn danh'}; // Trả về tài khoản mặc định nếu có lỗi
    }
  }
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
