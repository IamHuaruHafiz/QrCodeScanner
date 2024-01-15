import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:screenshot/screenshot.dart';
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
      body: Column(children: [
        Flexible(
            flex: 1,
            child: Row(
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
                    icon:
                        Icon(cam == false ? Icons.flash_off : Icons.flash_on)),
                Container(
                  margin: const EdgeInsets.all(8),
                  child: IconButton(
                      onPressed: () async {
                        await controller?.flipCamera();
                        setState(() {});
                        controller?.getCameraInfo();
                      },
                      icon: const Icon(Icons.cameraswitch_sharp)),
                )
              ],
            )),
        Expanded(
          flex: 4,
          child: _buildQrView(context),
        ),
        Flexible(
            child: result != null
                ? TextButton(
                    onPressed: () {
                      _launchUrl(result!.code);
                    },
                    child: Text("${result!.code}"))
                : const Center(child: Text("Scan a code")))
      ]),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 12,
        borderLength: 30,
        borderWidth: 10,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
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
