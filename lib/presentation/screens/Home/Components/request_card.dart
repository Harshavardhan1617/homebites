import 'package:flutter/material.dart';
import 'package:home_bites/constants.dart';
import 'package:home_bites/presentation/screens/PublicResponses/public_responses.dart';
import 'package:pocketbase/pocketbase.dart';

class ReqCard extends StatelessWidget {
  final RecordModel request;

  const ReqCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final expandData = request.get('expand');
    final userData = expandData?['requested_user'] as Map<String, dynamic>?;

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
          '$kPocketbaseHostUrl/api/files/${userData['collectionId']}/${userData['id']}/${userData['avatar']}';
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
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PublicResponses(requestID: request.id),
            ),
          );
        },
      ),
    );
  }
}
