import 'package:flutter/material.dart';
import 'package:home_bites/constants.dart';
import 'package:home_bites/models/exchange_model.dart';
import 'package:home_bites/models/recieved_response_model.dart';
import 'package:home_bites/presentation/screens/Exchange/exchange_status.dart';
import 'package:home_bites/presentation/widgets/not_my_response.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'dart:developer';

class ResponseCard extends StatefulWidget {
  final ReceivedResponseModel response;

  const ResponseCard({super.key, required this.response});

  @override
  State<ResponseCard> createState() => _ResponseCardState();
}

class _ResponseCardState extends State<ResponseCard> {
  bool _isExpanded = false;

  String? _getAvatarUrl(Map<String, dynamic> userData) {
    if (userData['avatar'] != null &&
        userData['avatar'].toString().isNotEmpty) {
      return '$kPocketbaseHostUrl/api/files/${userData['collectionId']}/${userData['id']}/${userData['avatar']}';
    }
    return null;
  }

  Future<void> _handleAcceptResponse(
      ReceivedResponseModel response, PocketBaseService pbProvider) async {
    try {
      final newExchange =
          await pbProvider.createExchange(ExchangeModel(isAccepted: true));

      await _updateResponseWithExchange(response, newExchange.id, pbProvider);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ExchangeStatus(exchangeID: newExchange.id),
          ),
        );
      }
    } on ClientException catch (e) {
      log("Error handling accept response: $e");
      _showErrorSnackBar('Failed to accept response');
    }
  }

  Future<void> _updateResponseWithExchange(
    ReceivedResponseModel response,
    String exchangeId,
    PocketBaseService pbProvider,
  ) async {
    try {
      final updatedResponse = await pbProvider.pb
          .collection(response.collectionName.toString())
          .update(
            response.id,
            body: {
              'status': 'accepted',
              'exchange_id': exchangeId,
            },
            expand: 'response_to',
          );

      final expandedResponseTo = updatedResponse.get('expand')['response_to'];
      await pbProvider.pb
          .collection(expandedResponseTo['collectionName'].toString())
          .update(
        expandedResponseTo['id'].toString(),
        body: {"exchange_id": exchangeId},
      );
    } catch (e) {
      log("Error updating response with exchange: $e");
      throw Exception('Failed to update response');
    }
  }

  Future<void> _handleIgnoreResponse(
      ReceivedResponseModel response, PocketBaseService pbProvider) async {
    try {
      await pbProvider.updateRecord(
        'responses',
        response.id,
        {"status": "ignored"},
      );
      if (mounted) {
        _showSuccessSnackBar('Response ignored successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to ignore response');
    }
  }

  Future<void> _handleDeleteResponse(
      ReceivedResponseModel response, PocketBaseService pbProvider) async {
    try {
      await pbProvider.deleteRecord(collection: 'responses', id: response.id);
      if (mounted) {
        _showSuccessSnackBar('Response deleted successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to delete response');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildActionButtons(
      ReceivedResponseModel response,
      PocketBaseService pbProvider,
      bool isResponseToMe,
      bool isAccepted,
      bool isMyResponse) {
    if (!isResponseToMe && !isAccepted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () {},
            child: const Text('Edit'),
          ),
          ElevatedButton(
            onPressed: () => _handleDeleteResponse(response, pbProvider),
            child: const Text('Delete'),
          ),
        ],
      );
    }

    if (((isResponseToMe || isMyResponse) && isAccepted)) {
      return TextButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ExchangeStatus(exchangeID: response.exchangeID),
            ),
          );
        },
        child: const Text("View Exchange Status"),
      );
    }

    if (isResponseToMe && !isAccepted) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton(
            onPressed: () => _handleAcceptResponse(response, pbProvider),
            child: const Text('Accept'),
          ),
          ElevatedButton(
            onPressed: () => _handleIgnoreResponse(response, pbProvider),
            child: const Text('Ignore'),
          ),
        ],
      );
    }

    return Container();
  }

  @override
  Widget build(BuildContext context) {
    final response = widget.response;
    final responseToData = response.expand['response_to'];
    final responseByData = response.expand['response_by'];
    final avatarUrl = _getAvatarUrl(responseByData);

    final pbProvider = Provider.of<PocketBaseService>(context, listen: false);
    final myID = pbProvider.pb.authStore.record!.id;

    final isMyResponse = responseByData['id'] == myID;
    final isResponseToMe = responseToData['requested_user'] == myID;
    final isAccepted = response.status == 'accepted';

    if (!isMyResponse && !isResponseToMe) {
      return NotMyResponse(avatarUrl: avatarUrl, response: response);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
          child: avatarUrl == null ? const Icon(Icons.person) : null,
        ),
        title: Text(responseByData['name']),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mobile: ${responseByData['mobile_number']}'),
            const SizedBox(height: 4),
            Text('Note: ${response.note}'),
            const SizedBox(height: 4),
            Text('Price: ${response.price}'),
            const SizedBox(height: 4),
          ],
        ),
        onExpansionChanged: (bool expanded) {
          setState(() => _isExpanded = expanded);
        },
        children: _isExpanded
            ? [
                _buildActionButtons(response, pbProvider, isResponseToMe,
                    isAccepted, isMyResponse)
              ]
            : [],
      ),
    );
  }
}
