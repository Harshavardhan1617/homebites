import 'package:flutter/material.dart';
import 'package:home_bites/constants.dart';
import 'package:home_bites/models/recieved_response_model.dart';
import 'package:home_bites/presentation/widgets/not_my_response.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:provider/provider.dart';

class ResponseCard extends StatefulWidget {
  final ReceivedResponseModel response;

  const ResponseCard({super.key, required this.response});

  @override
  State<ResponseCard> createState() => _ResponseCardState();
}

class _ResponseCardState extends State<ResponseCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String? avatarUrl = (widget.response.expand['avatar'] != null &&
            widget.response.expand['avatar'].toString().isNotEmpty)
        ? '$kPocketbaseHostUrl/api/files/${widget.response.expand['collectionId']}/${widget.response.expand['id']}/${widget.response.expand['avatar']}'
        : null;
    bool isMyResponse = widget.response.expand['id'] ==
        Provider.of<PocketBaseService>(context, listen: false)
            .pb
            .authStore
            .record
            ?.id;

    if (isMyResponse) {
      return Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          title: Text(widget.response.expand['name']),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mobile: ${widget.response.expand['mobile_number']}'),
              const SizedBox(height: 4),
              Text('Note: ${widget.response.note}'),
              const SizedBox(height: 4),
              Text('Price: ${widget.response.price}'),
            ],
          ),
          onExpansionChanged: (bool expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          children: _isExpanded
              ? [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Edit'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ]
              : [],
        ),
      );
    }
    return NotMyResponse(avatarUrl: avatarUrl, response: widget.response);
  }
}
