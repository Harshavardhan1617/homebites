import 'package:flutter/material.dart';
import 'package:home_bites/models/response_model.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:provider/provider.dart';

class ResponsesFormScreen extends StatelessWidget {
  final String requestID;

  const ResponsesFormScreen({super.key, required this.requestID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Response'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: ResponsesForm(requestID: requestID),
        ),
      ),
    );
  }
}

class ResponsesForm extends StatefulWidget {
  final String requestID;
  const ResponsesForm({super.key, required this.requestID});

  @override
  State<ResponsesForm> createState() => _ResponsesFormState();
}

class _ResponsesFormState extends State<ResponsesForm> {
  final _formKey = GlobalKey<FormState>();
  final _responseToController = TextEditingController();
  final _noteController = TextEditingController();
  final _priceController = TextEditingController();

  Future<void> _responseSubmit(ResponseModel responseData) async {
    final PocketBaseService pbService =
        Provider.of<PocketBaseService>(context, listen: false);

    if (pbService.pb.authStore.record == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User is not authenticated')),
      );
      return;
    }

    try {
      await pbService.createResponse(
        response: responseData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Response submitted successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit response')),
      );
    }
  }

  @override
  void dispose() {
    _responseToController.dispose();
    _noteController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _noteController,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a note';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                border: OutlineInputBorder(),
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final note = _noteController.text;
                  final price = _priceController.text;

                  final data = ResponseModel(
                    responseTo: widget.requestID,
                    note: note,
                    price: price,
                  );

                  _responseSubmit(data);
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Submit Response'),
            ),
          ],
        ),
      ),
    );
  }
}
