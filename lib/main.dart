import 'package:flutter/material.dart';
import 'package:musify/pages/home_page.dart';
import 'package:musify/style/appColors.dart';

void main() => runApp(new Musify());

class Musify extends StatefulWidget {
  @override
  MusifyAppState createState() {
    return new MusifyAppState();
  }
}

class MusifyAppState extends State<Musify> {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "DMSans",
        accentColor: accent,
        primaryColor: accent,
        canvasColor: Colors.transparent,
      ),
      home: new HomePage(),
    );
  }
}