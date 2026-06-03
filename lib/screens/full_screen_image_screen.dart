import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

// Import universal_html untuk menjembatani manipulasi unduhan di Web & Mobile tanpa crash
import 'package:universal_html/html.dart' as html;

class FullScreenImageScreen extends StatefulWidget {
  final String imageBase64;
  const FullScreenImageScreen({super.key, required this.imageBase64});

  @override
  State<FullScreenImageScreen> createState() => _FullScreenImageScreenState();
}

class _FullScreenImageScreenState extends State<FullScreenImageScreen> {
  bool _isDownloading = false;

  Future<void> _downloadImage() async {
    if (_isDownloading) return;

    setState(() {
      _isDownloading = true;
    });

    try {
      final filename = "Fasum_Report_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // KONDISI 1: JIKA JALAN DI WEB BROWSER (LOCALHOST)
      if (kIsWeb) {
        // Membuat elemen jangkar (anchor) HTML tiruan untuk memicu unduhan lokal browser
        final anchor = html.AnchorElement(href: 'data:image/jpeg;base64,${widget.imageBase64}')
          ..setAttribute("download", filename)
          ..click();
          
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto berhasil diunduh ke folder Downloads perangkat!'), 
              backgroundColor: Colors.green
            ),
          );
        }
      } 
      // KONDISI 2: JIKA JALAN DI MOBILE (ANDROID / IOS EMULATOR)
      else {
        PermissionStatus status = await Permission.storage.request();
        if (status.isDenied) {
          status = await Permission.photos.request();
        }

        if (!status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin penyimpanan ditolak.')),
            );
          }
          setState(() => _isDownloading = false);
          return;
        }

        final Uint8List imageBytes = base64Decode(widget.imageBase64);
        final result = await ImageGallerySaver.saveImage(
          imageBytes,
          quality: 100,
          name: filename.replaceAll('.jpg', ''),
        );

        if (result != null && (result['isSuccess'] == true || result != "")) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto berhasil disimpan ke galeri ponsel!'), 
                backgroundColor: Colors.green
              ),
            );
          }
        } else {
          throw Exception("Gagal menyimpan ke galeri.");
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan saat mengunduh: $e'), 
            backgroundColor: Colors.redAccent
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Konten Utama: Komponen Zoom & Geser Gambar
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.memory(
                  base64Decode(widget.imageBase64),
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),

          // Lapisan Tombol Kontrol Atas
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  CircleAvatar(
                    backgroundColor: Colors.black54,
                    child: _isDownloading
                        ? const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : IconButton(
                            icon: const Icon(Icons.download, color: Colors.white),
                            onPressed: _downloadImage,
                            tooltip: 'Unduh Gambar',
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}