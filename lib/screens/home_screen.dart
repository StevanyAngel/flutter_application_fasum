import 'package:flutter/material.dart';

// Ubah nama dari MyWidget menjadi HomeScreen
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      body: const Center(
        child: Text("Selamat Datang di Home Screen!"),
      ),
    );
  }
}