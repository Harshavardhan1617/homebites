import 'dart:io';
import 'package:flutter/material.dart';
import 'package:home_bites/models/request_model.dart';
import 'package:home_bites/presentation/screens/Forms/Components/record_comp.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:provider/provider.dart';

class RequestsForm extends StatefulWidget {
  const RequestsForm({super.key});

  @override
  State<RequestsForm> createState() => _RequestsFormState();
}

class _RequestsFormState extends State<RequestsForm> {
  final _formKey = GlobalKey<FormState>();
  String _mealType = 'Breakfast';
  bool _isVegetarian = false;
  String _note = '';
  File? _audioFile;
  bool _hasRecording = false;

  void _handleAudioFileChanged(File? file, String? path) {
    setState(() {
      _audioFile = file;
      _hasRecording = file != null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final PocketBaseService pbService =
          Provider.of<PocketBaseService>(context, listen: false);

      if (pbService.pb.authStore.record == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not authenticated')),
        );
        return;
      }

      try {
        final request = RequestModel(
          mealType: _mealType,
          requestedUser: pbService.pb.authStore.record!.id,
          vegetarian: _isVegetarian,
          textNote: _note,
        );

        await pbService.createRequest(
          request: request,
          file: _audioFile,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('success')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting request: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Food Request'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            value: _mealType,
                            decoration: const InputDecoration(
                              labelText: 'Meal Type',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            items: ['Breakfast', 'Lunch', 'Dinner']
                                .map((meal) => DropdownMenuItem(
                                      value: meal,
                                      child: Text(meal),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _mealType = value!;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          SwitchListTile(
                            title: const Text('Vegetarian'),
                            value: _isVegetarian,
                            onChanged: (value) {
                              setState(() {
                                _isVegetarian = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // const SizedBox(height: 16),
                          TextFormField(
                            decoration: const InputDecoration(
                              hintText: 'Add any special instructions...',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                            ),
                            maxLines: 2,
                            onChanged: (value) {
                              setState(() {
                                _note = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // const Text(
                          //   'Voice Note',
                          //   style: TextStyle(
                          //     fontSize: 18,
                          //     fontWeight: FontWeight.bold,
                          //   ),
                          // ),
                          // const SizedBox(height: 16),
                          RecordComp(onFileChanged: _handleAudioFileChanged),
                          if (_hasRecording)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.green),
                                  SizedBox(width: 8),
                                  Text(
                                    'Voice note recorded',
                                    style: TextStyle(color: Colors.green),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
