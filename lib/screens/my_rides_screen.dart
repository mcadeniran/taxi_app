import 'package:flutter/material.dart';

class MyRidesScreen extends StatelessWidget {
  const MyRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00009A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00009A),
        elevation: 0,
        title: const Text(
          'My Rides',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: 5, // demo data
          itemBuilder: (context, index) {
            return Card(
              elevation: 3,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: const Icon(Icons.directions_car, color: Color(0xFF00009A)),
                title: Text('Ride #${index + 1}'),
                subtitle: const Text('From: Location A\nTo: Location B'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // TODO: show ride details
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
