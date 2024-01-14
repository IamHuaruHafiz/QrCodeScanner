import 'package:flutter/material.dart';
import 'package:scanqr/screens/create_qr_code.dart';
import 'package:scanqr/screens/scan_qr_code.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              bottom: const TabBar(tabs: [
                Tab(
                  text: "Scan",
                ),
                Tab(
                  text: "Create",
                )
              ]),
            ),
            body: const TabBarView(children: [
              ScanQrCodeScreen(),
              CreateQrCodeScreen(),
            ]),
          )),
    );
  }
}
