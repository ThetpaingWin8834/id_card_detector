import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

class OcrScreen extends StatefulWidget {
  const OcrScreen({super.key});

  @override
  State<OcrScreen> createState() => _OcrScreenState();
}

class _OcrScreenState extends State<OcrScreen> {
  XFile? image;
  String? text;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test OCR')),
      body: SingleChildScrollView(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: double.maxFinite),
            if (text != null) Text(text!),
            if (image != null) Image.file(File(image!.path)),
            FilledButton.tonal(
              onPressed: () async {
                final res = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (res != null) {
                  setState(() {
                    image = res;
                  });
                  _performOcr(res.path);
                }
              },
              child: Text('PICK'),
            ),
          ],
        ),
      ),
    );
  }

  String extractId(String s) {
    // RegExp nidRegex = RegExp(r'\b\d{1,2}/[A-Z]+?\([A-Z]\)\d{6}\b');
    RegExp nidRegex = RegExp(r'\b\d{1,2}/[A-Z\u1000-\u109F]+?\([A-Z]\)\d{6}\b');
    Iterable<RegExpMatch> matches = nidRegex.allMatches(s);

    for (var match in matches) {
      final id = match.group(0);
      if (id != null) {
        return id;
      }
    }
    return '';
  }

  Future<void> _performOcr(String imagePath) async {
    try {
      final tesseractConfig = OCRConfig(
        language: 'mya',
        engine: OCREngine.tesseract,
      );
      String extractedTextTesseract = await TesseractOcr.extractText(
        imagePath,
        config: tesseractConfig,
      );
      print(extractedTextTesseract);
      // print('Extracted Text (Tesseract): $extractedTextTesseract');
      setState(() {
        text = extractId(extractedTextTesseract);
      });

      final visionConfig = OCRConfig(engine: OCREngine.vision, language: 'eng');
      if (Platform.isIOS) {
        String extractedTextVision = await TesseractOcr.extractText(
          imagePath,
          config: visionConfig,
        );
        print('Extracted Text (Vision): $extractedTextVision');
      }
    } catch (e) {
      print('Error performing OCR: $e');
    }
  }
}
