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

  Future shareShot(Uint8List imageFile) async {
    final directory = await getApplicationDocumentsDirectory();
    final imagePath = await File("${directory.path}/image.png").create();
    imagePath.writeAsBytesSync(imageFile);
    await Share.shareXFiles([XFile(imagePath.path)], text: controller.text);
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
                data: controller.text,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                cursorColor: Colors.black,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (val) {
                  setState(() {
                    controller.text = val;
                  });
                },
                controller: controller,
                decoration: InputDecoration(
                  hintText: "Enter text to generate code",
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        width: 2,
                      )),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        width: 2,
                      )),
                ),
              ),
            ),
            ElevatedButton(
                style: ButtonStyle(
                    foregroundColor:
                        const MaterialStatePropertyAll<Color>(Colors.black),
                    backgroundColor: MaterialStatePropertyAll<Color>(
                        Colors.yellow.shade500)),
                onPressed: () async {
                  final image = await screenShotController
                      .captureFromWidget(QrImageView(data: controller.text));
                  shareShot(image);
                },
                child: const Text(
                  "Share code",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ))
          ],
        ),
      ),
    );
  }
}
