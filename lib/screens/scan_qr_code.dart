import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanQrCodeScreen extends StatefulWidget {
  const ScanQrCodeScreen({super.key});

  @override
  State<ScanQrCodeScreen> createState() => _ScanQrCodeScreenState();
}

class _ScanQrCodeScreenState extends State<ScanQrCodeScreen> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: "Qr");
  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  Future<void> _launchUrl(String? url) async {
    final Uri url0 = Uri.parse(url!);
    await launchUrl(url0).catchError((_) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sorry, we couldn't load this url")));
    });
  }

  bool cam = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 253, 216, 53),
      body: Column(children: [
        Expanded(
          flex: 4,
          child: _buildQrView(context),
        ),
        Flexible(
            child: result != null
                ? Center(
                    child: TextButton(
                        onPressed: () {
                          _launchUrl(result!.code);
                        },
                        child: Text(
                          "${result!.code}",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500),
                        )),
                  )
                : const Center(
                    child: Text(
                    "Scan a code",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  )))
      ]),
    );
  }

  Widget _buildQrView(BuildContext context) {
    return Stack(children: [
      QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Colors.white,
          borderRadius: 12,
          borderLength: 30,
          borderWidth: 10,
        ),
        onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
              onPressed: () async {
                await controller?.toggleFlash();
                setState(() {
                  if (cam == false) {
                    cam = true;
                  } else if (cam == true) {
                    cam = false;
                  }
                });
              },
              icon: Icon(
                cam == false ? Icons.flash_off : Icons.flash_on,
                color: cam == false ? Colors.grey : Colors.white,
              )),
          Container(
            margin: const EdgeInsets.all(8),
            child: IconButton(
                onPressed: () async {
                  await controller?.flipCamera();
                  setState(() {});
                },
                icon: const Icon(
                  Icons.cameraswitch_sharp,
                  color: Colors.grey,
                )),
          )
        ],
      ),
    ]);
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log("${DateTime.now().toIso8601String()} _onPermissionSet$p");
    if (!p) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("no permission")));
    }
  }
}
