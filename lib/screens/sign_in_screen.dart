import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_fasum/screens/home_screen.dart';
import 'package:flutter_application_fasum/screens/sign_up_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  bool _isPasswordVisible = true;

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "An error occurred";
      if (e.code == 'user-not-found') message = "No user found for that email.";
      else if (e.code == 'wrong-password') message = "Wrong password provided.";
      else message = e.message ?? message;
      
      _showErrorMessage(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 60),
                const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                const Text(
                  'Welcome back! Please enter your details.',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: _inputStyle('Email', Icons.email_outlined),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter your email' : null,
                ),
                const SizedBox(height: 16),

                // Password Field
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
                  validator: (value) => (value == null || value.isEmpty) ? 'Enter your password' : null,
                ),
                const SizedBox(height: 32),

                // Login Button
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : SizedBox(
                          width: double.infinity, // Tombol penuh untuk Sign In
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _signIn,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B1FA2), // Ungu lebih tua untuk Sign In
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Sign In', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                ),
                
                const SizedBox(height: 20),

                // Navigate to Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text('Sign Up', style: TextStyle(color: Color(0xFF7B1FA2), fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}