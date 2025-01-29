import 'package:flutter/material.dart';

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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Process the form data
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
