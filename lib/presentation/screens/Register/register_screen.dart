import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        body: Center(
      //login form
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(20),
            width: size.width * 0.8,
            child: TextField(
              decoration: InputDecoration(
                  hintText: 'Mobile Number',
                  icon: Icon(Icons.phone),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(20),
            width: size.width * 0.8,
            child: TextField(
              obscureText: true,
              decoration: InputDecoration(
                  hintText: 'Password',
                  icon: Icon(Icons.lock),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
          ),
          Container(
            alignment: Alignment.center,
            margin: EdgeInsets.all(20),
            width: size.width * 0.8,
            child: ElevatedButton(
              onPressed: () {
                //login action
              },
              child: Text('Register'),
            ),
          ),
        ],
      ),
    ));
  }
}
