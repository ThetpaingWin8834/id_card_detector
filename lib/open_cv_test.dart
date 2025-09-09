import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:opencv_core/opencv.dart' as ocv;

class OpenCvTest extends StatefulWidget {
  const OpenCvTest({super.key});

  @override
  State<OpenCvTest> createState() => _OpenCvTestState();
}

class _OpenCvTestState extends State<OpenCvTest> {
  XFile? pickedImage;
  Uint8List? processedImg;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: double.maxFinite),
            if (processedImg != null) Image.memory(processedImg!),
            Divider(),
            if (pickedImage != null) Image.file(File(pickedImage!.path)),
            FilledButton.tonal(
              onPressed: () async {
                final res = await ImagePicker().pickImage(
                  source: ImageSource.gallery,
                );
                if (res != null) {
                  setState(() {
                    processedImg = null;
                    pickedImage = res;
                  });
                  performGreyScale(res);
                }
              },
              child: Text('PICK'),
            ),
          ],
        ),
      ),
    );
  }

  performGreyScale(XFile file) async {
    final bytes = await file.readAsBytes();
    final coloredImg = await ocv.imdecodeAsync(bytes, ocv.IMREAD_COLOR);
    final decoded = await ocv.cvtColorAsync(coloredImg, ocv.COLOR_BGR2GRAY);
    final encoded = await ocv.imencodeAsync('.jpg', decoded);
    print(encoded.$1);
    setState(() {
      processedImg = encoded.$2;
    });
  }
}
