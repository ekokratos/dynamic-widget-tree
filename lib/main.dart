import 'package:flutter/material.dart';
import 'dynamic_page.dart';

void main() => runApp(Home());

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DynamicPage(),
    );
  }
}
