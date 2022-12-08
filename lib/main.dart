import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barcode reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: 'Barcode reader',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ImagePicker _imagePicker = ImagePicker();

  Uint8List? _image;
  Barcode? _barcode;

  void _restoreData() {
    setState(() {
      _image = null;
      _barcode = null;
    });
  }

  void _switchImage(Uint8List? image) {
    setState(() => _image = image);
  }

  void _switchBarcode(Barcode? barcode) {
    setState(() => _barcode = barcode);
  }

  Future<void> _takePhoto() async {
    _restoreData();

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
    );

    if (image != null) {
      final Uint8List uint8list = await image.readAsBytes();

      _switchImage(uint8list);
      _scanBarcode(image.path);
    }
  }

  Future<void> _pickImage() async {
    _restoreData();

    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (image != null) {
      final Uint8List uint8list = await image.readAsBytes();

      _switchImage(uint8list);
      _scanBarcode(image.path);
    }
  }

  Future<void> _scanBarcode(String path) async {
    final List<BarcodeFormat> formats = [BarcodeFormat.all];
    final BarcodeScanner barcodeScanner = BarcodeScanner(formats: formats);

    final InputImage image = InputImage.fromFilePath(path);
    final List<Barcode> barcodes = await barcodeScanner.processImage(image);

    if (barcodes.isNotEmpty) {
      _switchBarcode(barcodes.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_image != null) ...[
              SizedBox(
                width: 200,
                height: 200,
                child: Image.memory(
                  _image!,
                ),
              ),
            ],
            const SizedBox(
              height: 20.0,
            ),
            if (_barcode != null) ...[
              Row(
                children: [
                  const SizedBox(
                    width: 60.0,
                    child: Text(
                      'Format: ',
                    ),
                  ),
                  Text(
                    _barcode!.format.name,
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              Row(
                children: [
                  const SizedBox(
                    width: 60.0,
                    child: Text(
                      'Value: ',
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${_barcode!.displayValue}',
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _takePhoto,
                  child: const Text(
                    'Photo',
                  ),
                ),
                TextButton(
                  onPressed: _pickImage,
                  child: const Text(
                    'Gallery',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
