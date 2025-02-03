import 'package:flutter/material.dart';
import 'package:home_bites/presentation/providers/vars_provider.dart';
import 'package:home_bites/presentation/screens/Forms/requests_form.dart';
import 'package:home_bites/presentation/screens/Home/Tabs/requests_tab.dart';
import 'package:home_bites/presentation/screens/Home/Tabs/my_requests_tab.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: AppBar(
              title: Text('Home Bites'),
              bottom: TabBar(
                onTap: (value) => setState(() => _selectedIndex = value),
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
            floatingActionButton: _selectedIndex == 1 &&
                    context.watch<MyIntProvider>().myInt <= 1
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestsForm(),
                          ));
                    },
                    child: const Icon(Icons.add),
                  )
                : null)); // Important: Return null if the condition is false));
  }
}
