import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Sample ride data
    final List<Map<String, String>> rides = [
      {
        'date': 'July 3, 2025',
        'time': '2:30 PM',
        'pickup': '123 Main St',
        'dropoff': '456 Market Ave',
        'status': 'Completed',
      },
      {
        'date': 'July 2, 2025',
        'time': '10:00 AM',
        'pickup': '789 Park Rd',
        'dropoff': '222 Sunset Blvd',
        'status': 'Cancelled',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF00009A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00009A),
        elevation: 0,
        title: Text(
          'RIDE HISTORY',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: ListView.builder(
          itemCount: rides.length,
          itemBuilder: (context, index) {
            final ride = rides[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 10),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${ride['date']} • ${ride['time']}',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 18, color: Colors.indigo),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ride['pickup'] ?? '')),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.flag, size: 18, color: Colors.redAccent),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ride['dropoff'] ?? '')),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          ride['status'] ?? '',
                          style: TextStyle(
                            color: ride['status'] == 'Completed' ? Colors.green : Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
