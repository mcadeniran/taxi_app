import 'package:flutter/material.dart';
import 'package:taxi_app/screens/customer_home.dart';
import 'package:taxi_app/utils/colors.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();

    // show dialog after first build
    Future.microtask(() => _showRideCompletedDialog(context));
  }

  Future<void> _showRideCompletedDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false, // user must tap the button
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(
            context,
          ).scaffoldBackgroundColor, // custom color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Ride Completed",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              // color: AppColors.primary,
            ),
          ),
          content: const Text(
            "Your ride has ended successfully.\n\nDo you want to return to the home screen?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // close dialog
              },
              child: Text("Stay", style: TextStyle(color: AppColors.tertiary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context); // close dialog
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (c) => const CustomerHome()),
                  (route) => false,
                );
              },
              child: const Text("Go Home"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text("Test Screen")));
  }
}
