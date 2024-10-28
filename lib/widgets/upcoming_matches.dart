import 'package:flutter/material.dart';

class UpcomingMatches extends StatelessWidget {
  final List<Map<String, String>> matches = const [
    {
      'date': '2024-10-28, 11:35',
      'location': 'America',
      'match': 'Smyk Vasyl - Kurtenko Andrii',
      'status': 'red'
    },
    {
      'date': '2024-10-28, 11:35',
      'location': 'Beijing',
      'match': 'Ivasiv Volodymyr - Slozka Mykola',
      'status': 'green'
    },
    {
      'date': '2024-10-28, 11:50',
      'location': 'Australia',
      'match': 'Telezhynska Olena - Yureneva Svitlana',
      'status': 'green'
    },
  ];

  const UpcomingMatches({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return buildMatchItem(matches[index]);
        },
      ),
    );
  }

  Widget buildMatchItem(Map<String, String> match) {
    Color statusColor = match['status'] == 'red' ? Colors.red : Colors.green;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            match['date']!,
            style: const TextStyle(color: Colors.grey),
          ),
          Row(
            children: [
              Icon(Icons.circle, color: statusColor, size: 10),
              const SizedBox(width: 8),
              Text(
                match['location']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            match['match']!,
            style: const TextStyle(fontSize: 16),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
