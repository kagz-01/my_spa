import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text("Notifications", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.black),
            onPressed: () {
              // Logic to clear all notifications
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text("Clear Notifications"),
                    content: const Text(
                        "Are you sure you want to clear all notifications?"),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          // Clear notifications logic here
                          Navigator.of(context).pop(); // Close dialog
                        },
                        child: const Text("Clear"),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildNotificationCard(
              "Appointment Reminder",
              "Don't forget your appointment tomorrow at 4 PM.",
              "2 hours ago",
            ),
            buildNotificationCard(
              "New Offers",
              "Check out our new offers on skin care products!",
              "4 hours ago",
            ),
            buildNotificationCard(
              "Feedback Request",
              "Please provide feedback on your recent visit.",
              "1 day ago",
            ),
            buildNotificationCard(
              "Booking Confirmation",
              "Your booking for 'Full Body Massage' is confirmed.",
              "2 days ago",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildNotificationCard(String title, String message, String timestamp) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            SizedBox(height: 4),
            Text(timestamp, style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
