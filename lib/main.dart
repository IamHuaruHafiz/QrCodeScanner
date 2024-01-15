import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scanqr/screens/create_qr_code.dart';
import 'package:scanqr/screens/scan_qr_code.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ScanQr',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                "QrCode",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              backgroundColor: Colors.yellow.shade600,
              bottom: const TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  indicatorColor: Colors.white,
                  overlayColor:
                      MaterialStatePropertyAll<Color>(Colors.transparent),
                  unselectedLabelColor: Colors.white,
                  labelColor: Colors.black,
                  labelStyle:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  tabs: [
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
