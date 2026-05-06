import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_fasum/screens/add_post_screen.dart';
import 'package:flutter_application_fasum/screens/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  String formatTime(dynamic createdAtData) {
    if (createdAtData == null) return "Baru saja";

    DateTime dateTime;
    if (createdAtData is Timestamp) {
      dateTime = createdAtData.toDate();
    } else if (createdAtData is String) {
      dateTime = DateTime.parse(createdAtData);
    } else {
      return "Format salah";
    }

    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: const Color(0xFFE1BEE7),
        actions: [
          IconButton(
            onPressed: () => signOut(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return const Center(child: Text('Terjadi kesalahan'));
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());

          final posts = snapshot.data!.docs;

          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final data = posts[index].data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tampilan Gambar
                    if (data['image'] != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        child: Image.memory(
                          base64Decode(data['image']),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 220,
                        ),
                      ),

                    // Bagian Teks (Nama, Tanggal, Deskripsi)
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatTime(data['createdAt']),
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            data['fullName'] ?? 'Anonim',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            data['description'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        backgroundColor: const Color(0xFFF3E5F5),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
