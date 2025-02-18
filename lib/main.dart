import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:home_bites/constants.dart';
import 'package:home_bites/presentation/providers/vars_provider.dart';
import 'package:home_bites/presentation/screens/Home/home_screen.dart';
import 'package:home_bites/presentation/screens/Welcome/welcome_page.dart';
import 'package:home_bites/services/pocketbase/pbase.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';

late String initialAuthData;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = FlutterSecureStorage();

  // Prefetch secure data
  initialAuthData = await storage.read(key: "pb_auth") ?? '';

  final store = AsyncAuthStore(
    save: (String data) async =>
        await storage.write(key: "pb_auth", value: data),
    initial: initialAuthData,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider(
          create: (_) =>
              PocketBaseService(store: store, baseUrl: kPocketbaseHostUrl),
        ),
        ChangeNotifierProvider(create: (_) => MyIntProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: Provider.of<PocketBaseService>(context, listen: false)
          .checkAuthStatus(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        if (snapshot.hasError || snapshot.data == null) {
          return const MaterialApp(home: _TimeoutWidget());
        }

        final bool isReachable = !snapshot.data!["serverTimeout"];
        final bool isAuthenticated = snapshot.data!["isAuthenticated"];

        return MaterialApp(
          title: 'Home Bites',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: isReachable
              ? (isAuthenticated ? const HomeScreen() : const WelcomePage())
              : const _TimeoutWidget(),
        );
      },
    );
  }
}

class _TimeoutWidget extends StatelessWidget {
  const _TimeoutWidget();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          "Unable to reach server",
          style: TextStyle(fontSize: 18, color: Colors.red),
        ),
      ),
    );
  }
}
