import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taxi_app/controllers/user_provider.dart';
import 'package:taxi_app/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
  }

  void _logout() async {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00009A),
      appBar: AppBar(
        title: const Text(
          'MY PROFILE',
          style: TextStyle(
            color: Colors.white, // White color
            fontSize: 20, // Font size
            fontWeight: FontWeight.bold, // Bold text
          ),
        ),
        backgroundColor: const Color(0xFF00009A),
        elevation: 0,
        centerTitle: true,
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, userProvider, _) {
          if (userProvider.isLoading) {
            return CircularProgressIndicator();
          }
          final profile = userProvider.profile;

          return SafeArea(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Name: ${profile?.displayName}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Email: ${profile?.phone}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Role: ${profile?.role}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (profile?.role == 'driver') ...[
                    const SizedBox(height: 8),
                    Text(
                      "Car Model: ${profile?.model}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Car Year: ${profile?.colour}",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ],
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00009A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Log Out"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
