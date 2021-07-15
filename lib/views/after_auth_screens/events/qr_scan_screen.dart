import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScanScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanScreenState();
}

class _QRScanScreenState extends State<QRScanScreen> {
  Barcode? result;
  QRViewController? controller;
  bool scanDone = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        centerTitle: true,
        key: const Key("qrCodeAppBar"),
        title: Text(
          'Attendee Scanner',
          style: Theme.of(context).textTheme.headline6!.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
        ),
      ),
      body: Column(
        children: <Widget>[
          const Divider(),
          const Text('Scan Attendees Unique QR Code'),
          const Divider(),
          Expanded(
              flex: 4,
              child: scanDone ? _displayResult() : _buildQrView(context)),
          Container(
            margin: EdgeInsets.all(8),
            child: ElevatedButton(
                onPressed: () async {
                  await controller?.toggleFlash();
                  setState(() {});
                },
                child: FutureBuilder(
                  future: controller?.getFlashStatus(),
                  builder: (context, snapshot) {
                    bool flashOn = snapshot.data.toString() == 'true';
                    return Icon(
                      flashOn ? Icons.flash_off : Icons.flash_on,
                    );
                  },
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 250.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: const Color(0xfffabc57),
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) async {
    this.controller = controller;
    result = await controller.scannedDataStream.first;
    print('scanData.code : ${result!.code}');
    scanDone = true;
    setState(() {});
  }

  Widget _displayResult() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 160,
          child: const Center(child: const Text('Attendee Details here')),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
                onPressed: () {
                  //TODO:Update Checkin on Server

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Attendee Checked-in'),
                  ));
                  setState(() {
                    scanDone = false;
                  });
                },
                child: const Text('Verify & Check-in')),
            IconButton(
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xfffabc57),
                  size: 42,
                ),
                onPressed: () {
                  setState(() {
                    scanDone = false;
                  });
                }),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
