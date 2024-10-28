import 'package:flutter/material.dart';

class Winner extends StatelessWidget {
  const Winner({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage('assets/andrii_kurtenko.png'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Kurtenko Andrii',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.emoji_events, color: Colors.orange, size: 24),
                  SizedBox(width: 8),
                  Text(
                    'Men. Night1',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Mexico',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const Divider(thickness: 1, height: 32),
              Text(
                '2024-10-28',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
