import 'package:flutter/material.dart';
import 'Pages/HomePage.dart';

void main() => runApp(PdfConvertor());

class PdfConvertor extends StatefulWidget {
  @override
  _PdfConvertorState createState() => _PdfConvertorState();
}

class _PdfConvertorState extends State<PdfConvertor> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark),
      home: HomePage(),
    );
  }
}
