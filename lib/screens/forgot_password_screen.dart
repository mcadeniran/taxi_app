import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool loading = false;
  String? message;
  String? error;

  void submitEmail() async {
    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    final res = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': emailController.text.trim()}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      setState(() => message = data['message']);
    } else {
      setState(() => error = data['error'] ?? 'Something went wrong');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Your Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : submitEmail,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Send Reset Link'),
            ),
            if (message != null)
              Text(message!, style: const TextStyle(color: Colors.green)),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
          ],
        ),
      ),
    );
  }
}
