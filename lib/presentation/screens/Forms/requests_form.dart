import 'package:flutter/material.dart';
import 'package:home_bites/models/request_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Requests Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DropdownButtonFormField<String>(
                value: _mealType,
                decoration: InputDecoration(labelText: 'Meal Type'),
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
              CheckboxListTile(
                title: Text('Vegetarian'),
                value: _isVegetarian,
                onChanged: (value) {
                  setState(() {
                    _isVegetarian = value!;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Note'),
                maxLines: 3,
                onChanged: (value) {
                  setState(() {
                    _note = value;
                  });
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final PocketBaseService pbService =
                        Provider.of<PocketBaseService>(context, listen: false);
                    if (pbService.pb.authStore.record != null) {
                      final request = RequestModel(
                        mealType: _mealType,
                        requestedUser: pbService.pb.authStore.record!.id,
                        vegetarian: _isVegetarian,
                        textNote: _note,
                      );
                      await pbService.createRequest(request);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('User is not authenticated')),
                      );
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
