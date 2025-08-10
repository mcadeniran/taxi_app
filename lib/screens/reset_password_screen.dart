import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final passwordController = TextEditingController();
  bool loading = false;
  String? message;
  String? error;

  void resetPassword() async {
    setState(() {
      loading = true;
      message = null;
      error = null;
    });

    final res = await http.post(
      Uri.parse('http://10.0.2.2:5000/api/auth/reset-password/${widget.token}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'newPassword': passwordController.text}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode == 200) {
      setState(() => message = data['message']);
    } else {
      setState(() => error = data['error'] ?? 'Failed to reset password');
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: loading ? null : resetPassword,
              child: loading
                  ? const CircularProgressIndicator()
                  : const Text('Reset Password'),
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
