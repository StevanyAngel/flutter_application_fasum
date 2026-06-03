import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_fasum/screens/add_post_screen.dart';
import 'package:flutter_application_fasum/screens/detail_screen.dart';
import 'package:flutter_application_fasum/screens/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 1. Tambahkan variabel state untuk melacak kategori yang dipilih
  String? selectedCategory;

  final List<String> categories = [
    'Jalan Rusak',
    'Marka Pudar',
    'Lampu Mati',
    'Trotoar Rusak',
    'Rambu Rusak',
    'Jembatan Rusak',
    'Sampah Menumpuk',
    'Saluran Tersumbat',
    'Sungai Tercemar',
    'Sampah Sungai',
    'Pohon Tumbang',
    'Taman Rusak',
    'Fasilitas Rusak',
    'Pipa Bocor',
    'Vandalisme',
    'Banjir',
    'Lainnya',
  ];

  // 2. Tambahkan fungsi untuk memunculkan Bottom Sheet Filter
  void _showCategoryFilter() async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                ListTile(
                  leading: const Icon(Icons.clear),
                  title: const Text('Semua Kategori'),
                  onTap: () => Navigator.pop(context, null), // Menghasilkan null jika pilih semua
                ),
                const Divider(),
                ...categories.map(
                  (category) => ListTile(
                    title: Text(category),
                    trailing: selectedCategory == category
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () => Navigator.pop(context, category), // Mengembalikan string kategori
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Update status kategori yang dipilih berdasarkan respons bottom sheet
    if (result != null) {
      setState(() {
        selectedCategory = result;
      });
    } else {
      setState(() {
        selectedCategory = null; // Menampilkan seluruh kategori
      });
    }
  }

  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SignInScreen()),
    );
  }

  String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds} secs ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} mins ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} hrs ago';
    } else if (diff.inHours < 48) {
      return '1 day ago';
    }
    return DateFormat('dd/MM/yyyy').format(dateTime);
  }

  Future<void> _refreshPosts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          // 3. Tambahkan tombol Filter di sebelah kiri tombol Sign Out
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showCategoryFilter,
            tooltip: 'Filter Kategori',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => signOut(context),
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPosts,
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('posts')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // 4. Lakukan penyaringan (filtering) data postingan sebelum masuk ke ListView
            final filteredPosts = snapshot.data!.docs.where((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final postCategory = data['category'] ?? 'Lainnya';
              
              // Jika selectedCategory kosong (null), tampilkan semua. Jika tidak null, samakan nilainya.
              return selectedCategory == null || postCategory == selectedCategory;
            }).toList();

            // Berikan penanda visual jika hasil filter ternyata kosong
            if (filteredPosts.isEmpty) {
              return const Center(
                child: Text(
                  'Tidak ada laporan untuk kategori ini.',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final data = filteredPosts[index].data() as Map<String, dynamic>;
                final imageBase64 = data['image'];
                final description = data['description'] ?? '';
                final fullName = data['fullName'] ?? 'Anonim';
                final category = data['category'] ?? 'Lainnya';
                final createdAtValue = data['createdAt'];
                DateTime createdAt = DateTime.now();

                if (createdAtValue is Timestamp) {
                  createdAt = createdAtValue.toDate();
                } else if (createdAtValue is DateTime) {
                  createdAt = createdAtValue;
                } else if (createdAtValue is String) {
                  createdAt =
                      DateTime.tryParse(createdAtValue) ?? DateTime.now();
                }

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(
                          imageBase64: imageBase64 ?? '',
                          description: description,
                          createdAt: createdAt,
                          fullName: fullName,
                          latitude: data['latitude'] ?? 0.0,
                          longitude: data['longitude'] ?? 0.0,
                          category: category,
                          heroTag: 'post_$index',
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 1,
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    shadowColor: Theme.of(context).colorScheme.shadow,
                    margin: const EdgeInsets.all(10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (imageBase64 != null)
                          Hero(
                            tag: 'post_$index',
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(10),
                              ),
                              child: Image.memory(
                                base64Decode(imageBase64),
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                formatTime(createdAt),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                fullName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                description,
                                style: const TextStyle(fontSize: 16),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.blueGrey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPostScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}