import 'package:flutter/material.dart';

class AvailableRidesScreen extends StatelessWidget {
  const AvailableRidesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder list of rides (can be replaced with data from backend)
    final rides = [
      {
        'pickup': 'Downtown Plaza',
        'dropoff': 'Airport Terminal 1',
        'fare': '₦5000',
      },
      {
        'pickup': 'Lekki Phase 1',
        'dropoff': 'Yaba Tech Gate',
        'fare': '₦3500',
      },
      {
        'pickup': 'Ikeja Mall',
        'dropoff': 'University of Lagos',
        'fare': '₦4200',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Available Rides',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00009A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: rides.length,
        itemBuilder: (context, index) {
          final ride = rides[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 3,
            child: ListTile(
              leading: const Icon(Icons.local_taxi, color: Color(0xFF00009A)),
              title: Text(
                '${ride['pickup']} → ${ride['dropoff']}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Fare: ${ride['fare']}'),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00009A),
                ),
                onPressed: () {
                  // TODO: Accept ride logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Accepted ride from ${ride['pickup']}')),
                  );
                },
                child: const Text('Accept'),
              ),
            ),
          );
        },
      ),
    );
  }
}
