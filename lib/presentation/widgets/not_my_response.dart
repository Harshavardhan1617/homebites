import 'package:flutter/material.dart';
import 'package:home_bites/models/recieved_response_model.dart';
import 'package:home_bites/presentation/widgets/response_dashboard.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:provider/provider.dart';

class NotMyResponse extends StatelessWidget {
  const NotMyResponse({
    super.key,
    required this.avatarUrl,
    required this.response,
  });

  final String? avatarUrl;
  final ReceivedResponseModel response;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
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
        onTap: () {
          bool isMyResponse = response.expand['id'] ==
              Provider.of<PocketBaseService>(context, listen: false)
                  .pb
                  .authStore
                  .record!
                  .id;

          isMyResponse
              ? Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ResponseDashboard(responseID: response.expand['id'])))
              : print("not ur response");
        },
      ),
    );
  }
}
