import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarkodOkuyucu extends StatefulWidget {
  final Function(String) onBarkodDetected;

  const BarkodOkuyucu({super.key, required this.onBarkodDetected});

  @override
  State<BarkodOkuyucu> createState() => _BarkodOkuyucuState();
}

class _BarkodOkuyucuState extends State<BarkodOkuyucu> {
  bool isProcessing = false;
  bool isFlashOn = false;
  MobileScannerController? controller;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Future<void> toggleFlash() async {
    try {
      setState(() {
        isFlashOn = !isFlashOn;
      });
      await controller?.toggleTorch();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Flash açma hatası: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Barkod Okuyucu"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isProcessing ? null : () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: toggleFlash,
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (capture) {
          if (isProcessing) return;

          setState(() {
            isProcessing = true;
          });

          try {
            final List<Barcode> barcodes = capture.barcodes;
            if (barcodes.isNotEmpty) {
              final String? code = barcodes.first.rawValue;
              if (code != null && code.isNotEmpty) {
                widget.onBarkodDetected(code);
                Navigator.pop(context, code);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Geçersiz barkod.')),
                );
                setState(() {
                  isProcessing = false;
                });
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Barkod tespit edilemedi.')),
              );
              setState(() {
                isProcessing = false;
              });
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Barkod işleme hatası: $e')),
            );
            setState(() {
              isProcessing = false;
            });
          }
        },
      ),
    );
  }
}