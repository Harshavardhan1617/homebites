import 'package:flutter/material.dart';
import 'package:home_bites/presentation/widgets/requests_tab.dart';
import 'package:home_bites/presentation/widgets/responses_tab.dart';

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
                Tab(text: 'Responses'),
                // Tab(text: 'Offerings'),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              RequestsTab(),
              ResponsesTab()
              // ProfileTab(),
            ],
          ),
        ));
  }
}
