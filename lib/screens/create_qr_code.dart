import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class CreateQrCodeScreen extends StatefulWidget {
  const CreateQrCodeScreen({super.key});

  @override
  State<CreateQrCodeScreen> createState() => _CreateQrCodeScreenState();
}

class _CreateQrCodeScreenState extends State<CreateQrCodeScreen> {
  TextEditingController controller = TextEditingController();

  ScreenshotController screenShotController = ScreenshotController();

  void shareShot() async {
    Uint8List imageFile;

    try {
      await screenShotController.capture().then((image) async {
        setState(() {
          imageFile = image!;
        });
        if (image != null) {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File("${directory.path}/image.png").create();
          await imagePath.writeAsBytes(image);

          await Share.shareXFiles([XFile(imagePath.path)]);
        }
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Screenshot(
              controller: screenShotController,
              child: QrImageView(
                size: 300,
                data: controller.text,
              ),
            ),
            TextFormField(
              onChanged: (val) {
                setState(() {
                  controller.text = val;
                });
              },
              controller: controller,
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.purple)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.purple.shade700)),
                  errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.red.shade600))),
            ),
            ElevatedButton(
                onPressed: () {
                  shareShot();
                },
                child: const Text("Share"))
          ],
        ),
      ),
    );
  }
}
