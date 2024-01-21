import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scanqr/key.dart';
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
    final imagePath = await File("${directory.path}/image.png");
    imagePath.writeAsBytesSync(imageFile);
    await Share.shareXFiles([XFile(imagePath.path)], text: controller.text);
  }

  int numberOfTimessLoaded = 0;
  InterstitialAd? _ad;
  void loadInterstitialAd() {
    final bannerAdsUnitId = Platform.isAndroid ? androidKey : iosKey;

    InterstitialAd.load(
        adUnitId: bannerAdsUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(onAdLoaded: (ad) {
          _ad = ad;
          loadInterstitialAd();
          numberOfTimessLoaded = 0;
        }, onAdFailedToLoad: (LoadAdError error) {
          numberOfTimessLoaded + 1;
          _ad = null;
          if (numberOfTimessLoaded <= 2) {
            loadInterstitialAd();
          }
          debugPrint("$error occured");
        }));
  }

  void showInterstitialAd() {
    if (_ad == null) return;
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (aD) {
        debugPrint("Ad showed full screen");
      },
      onAdFailedToShowFullScreenContent: (aD, err) async {
        debugPrint("Ad failed to show full screen");

        aD.dispose();
        loadInterstitialAd();
        final image = await screenShotController
            .captureFromWidget(QrImageView(data: controller.text));
        shareShot(image);
      },
      onAdDismissedFullScreenContent: (aD) async {
        debugPrint("Ad has been dismissed");

        aD.dispose();
        final image = await screenShotController
            .captureFromWidget(QrImageView(data: controller.text));
        shareShot(image);
      },
      onAdClicked: (aD) {},
    );
    _ad!.show();
  }

  @override
  void initState() {
    super.initState();
    loadInterstitialAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadInterstitialAd();
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
                  hintText: "Enter link to generate code",
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
                  backgroundColor:
                      MaterialStatePropertyAll<Color>(Colors.yellow.shade500)),
              onPressed: () async {
                controller.text.isEmpty ? null : showInterstitialAd();
              },
              child: Text(
                controller.text.isEmpty ? "Enter link above" : "Share code",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
