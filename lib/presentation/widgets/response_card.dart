import 'package:flutter/material.dart';
import 'package:home_bites/constants.dart';
import 'package:home_bites/models/recieved_response_model.dart';

class ResponseCard extends StatelessWidget {
  final ReceivedResponseModel response;

  const ResponseCard({super.key, required this.response});

  @override
  Widget build(BuildContext context) {
    String? avatarUrl = (response.expand['avatar'] != null &&
            response.expand['avatar'].toString().isNotEmpty)
        ? '$kPocketbaseHostUrl/api/files/${response.expand['collectionId']}/${response.expand['id']}/${response.expand['avatar']}'
        : null;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(response.expand['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile: ${response.expand['mobile_number']}'),
            const SizedBox(height: 4),
            Text('Note: ${response.note}'),
            const SizedBox(height: 4),
            Text('Price: ${response.price}'),
          ],
        ),
        isThreeLine: true,
      ),
    );
  }
}
