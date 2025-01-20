import 'package:flutter/material.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:home_bites/presentation/screens/Home/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final PocketBaseClient pbClient = PocketBaseClient();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  Future<void> _register() async {
    final mobileNumber = mobileNumberController.text;
    final password = passwordController.text;
    final name = nameController.text;

    await pbClient.register(mobileNumber, password, name);
    //delay to allow the user to be registered before authenticating
    await Future.delayed(Duration(milliseconds: 500));
    await pbClient.authenticate(mobileNumber, password);

    if (pbClient.checkAuth()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      // Handle authentication failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
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
                controller: nameController,
                decoration: InputDecoration(
                  hintText: 'Name',
                  icon: Icon(Icons.person),
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
                onPressed: _register,
                child: Text('Register'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
