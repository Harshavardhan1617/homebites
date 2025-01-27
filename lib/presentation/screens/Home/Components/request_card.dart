import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

class ReqCard extends StatelessWidget {
  final RecordModel request;

  const ReqCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    // Check if there's a requested user first
    final String? requestedUserId = request.get('requested_user');
    if (requestedUserId?.isEmpty ?? true) {
      return Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.person_off)),
          title: const Text('No User Assigned'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meal Type: ${request.get('meal_type') ?? 'Not specified'}'),
              Text(
                  'Vegetarian: ${request.get('vegetarian') == true ? 'Yes' : 'No'}'),
              const Text('Location: Not available'),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    // If we have a requested user, try to get their expanded data
    final expandData = request.get('expand');
    final userData = expandData?['requested_user'] as Map<String, dynamic>?;

    // Handle case where expansion failed or returned no data
    if (userData == null) {
      return Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon(Icons.error)),
          title: const Text('User data unavailable'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Meal Type: ${request.get('meal_type') ?? 'Not specified'}'),
              Text(
                  'Vegetarian: ${request.get('vegetarian') == true ? 'Yes' : 'No'}'),
              const Text('Location: Not available'),
              const SizedBox(height: 10),
            ],
          ),
        ),
      );
    }

    // Construct avatar URL if avatar exists
    String? avatarUrl;
    if (userData['avatar'] != null &&
        userData['avatar'].toString().isNotEmpty) {
      avatarUrl =
          'http://127.0.0.1:8090/api/files/${userData['collectionId']}/${userData['id']}/${userData['avatar']}';
    }

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(userData['name']?.toString() ?? 'Unknown User'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meal Type: ${request.get('meal_type') ?? 'Not specified'}'),
            Text(
                'Vegetarian: ${request.get('vegetarian') == true ? 'Yes' : 'No'}'),
            if (userData['location'] != null)
              Text(
                  'Location: ${userData['location']['latitude']}, ${userData['location']['longitude']}')
            else
              const Text('Location: Not available'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
