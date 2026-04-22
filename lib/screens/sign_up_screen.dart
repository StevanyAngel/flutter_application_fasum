import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fasum/screens/home_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isPasswordVisible = true; // Set true untuk mulai dengan tersembunyi
  bool _isConfirmPasswordVisible = true;

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'createdAt': Timestamp.now(),
      });

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      _showErrorMessage(e.message ?? "Terjadi kesalahan");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper untuk membuat dekorasi input agar mirip gambar
  InputDecoration _inputStyle(String hint, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey[700]),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start, // Agar teks ke kiri
              children: [
                const SizedBox(height: 40),
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const SizedBox(height: 40),
                
                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: _inputStyle('Full Name', Icons.person_outline),
                  validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  decoration: _inputStyle('Email', Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => !value!.contains('@') ? 'Invalid email' : null,
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _isPasswordVisible,
                  decoration: _inputStyle(
                    'Password',
                    Icons.lock_outline,
                    suffix: IconButton(
                      icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                    ),
                  ),
                  validator: (value) => value!.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _isConfirmPasswordVisible,
                  decoration: _inputStyle(
                    'Confirm Password',
                    Icons.lock_reset_outlined,
                    suffix: IconButton(
                      icon: Icon(_isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                    ),
                  ),
                  validator: (value) => value != _passwordController.text ? 'Not match' : null,
                ),
                const SizedBox(height: 32),

                // Button Sign Up
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: 150, // Lebar tombol sesuai gambar
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3E5F5), // Warna ungu muda
                              foregroundColor: const Color(0xFF7B1FA2), // Warna teks ungu
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}