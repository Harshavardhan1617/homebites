import 'package:flutter/material.dart';
import 'package:home_bites/constants.dart';
import 'package:pocketbase/pocketbase.dart';

class ReqCard extends StatelessWidget {
  final RecordModel request;

  const ReqCard({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final user = request.data['expand']['requested_user'];
    print('Request Data: ${request.data}');
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: user['avatar'] != null
              ? NetworkImage(
                  '$kPocketbaseHostUrl/api/files/${user['collectionId']}/${user['id']}/${user['avatar']}')
              : null,
          child: user['avatar'] == null ? Icon(Icons.person) : null,
        ),
        title: Text(user['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Meal Type: ${request.data['meal_type']}'),
            Text('Vegetarian: ${request.data['vegetarian'] ? 'Yes' : 'No'}'),
            if (user['location'] != null)
              Text(
                  'Location: ${user['location']['latitude']}, ${user['location']['longitude']}'),
            if (user['location'] == null) Text('Location: Not available'),
            SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
