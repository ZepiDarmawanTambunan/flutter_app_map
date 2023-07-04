import 'package:flutter/material.dart';
import 'package:flutter_app_map/views/home_screen.dart';
import 'package:provider/provider.dart';
import 'view_model/location_view_model.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => LocationViewModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jogging App',
      home: HomeScreen(),
    );
  }
}