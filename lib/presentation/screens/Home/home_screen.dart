import 'package:flutter/material.dart';
import 'package:home_bites/presentation/screens/Home/Tabs/requests_tab.dart';
import 'package:home_bites/presentation/screens/Home/Tabs/my_requests_tab.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Home Bites'),
            bottom: TabBar(
              tabs: [
                Tab(text: 'Requests'),
                Tab(text: 'My Requests'),
                // Tab(text: 'Offerings'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              RequestsTab(),
              MyRequestsTab()
              // ProfileTab(),
            ],
          ),
        ));
  }
}
