import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:provider/provider.dart';
import 'package:home_bites/presentation/screens/Home/home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _login() async {
    final mobileNumber = mobileNumberController.text;
    final password = passwordController.text;

    final pocketBaseProvider =
        Provider.of<PocketBaseService>(context, listen: false);

    try {
      pocketBaseProvider.pb.authStore.clear();
      await pocketBaseProvider.signIn(mobileNumber, password);
    } on ClientException catch (e) {
      log(e.response["message"]);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
      passwordController.clear();
      pocketBaseProvider.pb.authStore.clear();
    }

    if (pocketBaseProvider.isAuthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              width: size.width * 0.8,
              child: TextField(
                controller: mobileNumberController,
                decoration: InputDecoration(
                  hintText: 'Mobile Number',
                  icon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              width: size.width * 0.8,
              child: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Password',
                  icon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.all(20),
              width: size.width * 0.8,
              child: ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
