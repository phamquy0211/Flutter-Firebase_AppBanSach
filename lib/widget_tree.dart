import 'package:appbansach/auth.dart';
import 'package:appbansach/pages/login_register_screen.dart';
import 'package:flutter/material.dart';
import 'pages/home_screen.dart';


class WidgetTree extends StatefulWidget{
  const WidgetTree({super.key});
  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}
class _WidgetTreeState extends State<WidgetTree>{
  @override
  Widget build(BuildContext context){
    return StreamBuilder(
      stream: Auth().authStateChanges,
      builder: (context, snapshot){
        if(snapshot.hasData){
          return HomeScreen();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}