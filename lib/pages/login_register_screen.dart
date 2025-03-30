import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String? errorMessage = '';
  bool isLogin = true;
  bool _isPasswordHidden = true;

  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  final TextEditingController _controllerConfirmPassword = TextEditingController(); // Controller cho "Nhập lại mật khẩu"

  Future<void> signInWithEmailAndPassword() async {
    try {
      if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty) {
        setState(() {
          errorMessage = "Vui lòng nhập đầy đủ thông tin.";
        });
        return;
      }
      await Auth().signInWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Future<void> createUserWithEmailAndPassword() async {
    try {
      if (_controllerEmail.text.isEmpty || _controllerPassword.text.isEmpty || _controllerConfirmPassword.text.isEmpty) {
        setState(() {
          errorMessage = "Vui lòng nhập đầy đủ thông tin.";
        });
        return;
      }

      if (_controllerPassword.text != _controllerConfirmPassword.text) {
        setState(() {
          errorMessage = "Mật khẩu không khớp với nhau.";
        });
        return;
      }

      if (_controllerPassword.text.length < 6) {
        setState(() {
          errorMessage = "Mật khẩu phải có ít nhất 6 ký tự.";
        });
        return;
      }

      await Auth().createUserWithEmailAndPassword(
        email: _controllerEmail.text,
        password: _controllerPassword.text,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  Widget _entryField(String title, TextEditingController controller,
      {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword && _isPasswordHidden,
      decoration: InputDecoration(
        labelText: title,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0)),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _isPasswordHidden ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isPasswordHidden = !_isPasswordHidden;
                  });
                },
              )
            : null,
      ),
    );
  }

  Widget _errorMessage() {
    return Text(
      errorMessage == '' ? '' : 'Oops! $errorMessage',
      style: const TextStyle(color: Colors.red),
      textAlign: TextAlign.center,
    );
  }

  Widget _submitButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      onPressed:
          isLogin ? signInWithEmailAndPassword : createUserWithEmailAndPassword,
      child: Text(
        isLogin ? 'Đăng nhập' : 'Đăng ký',
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
    );
  }

  Widget _loginOrRegisterButton() {
    return TextButton(
      onPressed: () {
        setState(() {
          // Đổi chế độ giữa đăng nhập và đăng ký
          isLogin = !isLogin;

          // Reset thông báo lỗi
          errorMessage = '';

          // Làm mới các ô nhập liệu
          _controllerEmail.clear();
          _controllerPassword.clear();
          _controllerConfirmPassword.clear();
        });
      },
      child: Text(
        isLogin ? 'Bạn mới đến sao? Đăng ký' : 'Đã có tài khoản? Đăng nhập',
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Image.network(
                  'assets/images/book1.jpg',
                  width: 1500,
                  height: 350,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome to Book Store',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              _entryField('Email', _controllerEmail),
              const SizedBox(height: 15),
              _entryField('Mật khẩu', _controllerPassword, isPassword: true),
              if (!isLogin)
                const SizedBox(height: 15),
              if (!isLogin)
                _entryField('Nhập lại mật khẩu', _controllerConfirmPassword,
                    isPassword: true),
              const SizedBox(height: 10),
              _errorMessage(),
              const SizedBox(height: 20),
              _submitButton(),
              const SizedBox(height: 10),
              _loginOrRegisterButton(),
            ],
          ),
        ),
      ),
    );
  }
}
