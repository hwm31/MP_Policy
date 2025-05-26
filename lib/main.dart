import 'package:flutter/material.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '청년 일자리 커뮤니티',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'NotoSansKR',
      ),
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}