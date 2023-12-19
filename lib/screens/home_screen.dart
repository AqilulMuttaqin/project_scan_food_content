import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});

  @override
  State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  File? imageFile;
  bool isCameraSelected = true;
  String ocrResult = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        backgroundColor: const Color(0xFF674AEF),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            color: Color(0xFF674AEF),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height / 10,
                  decoration: BoxDecoration(
                    color: Color(0xFF674AEF),
                  ),
                  child: Center(
                    child: Text(
                      "Scan your food content here!",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                        wordSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context)
                            .size
                            .height, // Sesuaikan dengan kebutuhan
                        padding: EdgeInsets.only(top: 40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(50),
                            topRight: Radius.circular(50),
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              Text(
                                "Choose your image",
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                              SizedBox(height: 20),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: IconButton(
                                      icon:
                                          const Icon(Icons.camera_alt_outlined),
                                      onPressed: () async {
                                        await _imgFromCamera();
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.amber,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.photo_outlined),
                                      onPressed: () async {
                                        await _imgFromGallery();
                                      },
                                    ),
                                  ),
                                  Container(
                                    margin: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF674AEF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () async {
                                          await _uploadImage();
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12, horizontal: 50),
                                          child: const Text(
                                            "Scan",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Container(
                                height: 200, // Sesuaikan dengan kebutuhan
                                child: imageFile == null
                                    ? const Text('\nNo photo selected yet')
                                    : Image.file(
                                        imageFile!,
                                        fit: BoxFit
                                            .contain, // Sesuaikan dengan kebutuhan
                                      ),
                              ),
                              const SizedBox(
                                height: 20.0,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 20, right: 20, bottom: 150),
                                child: Text(
                                  ocrResult,
                                  style: TextStyle(
                                    fontSize: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  final picker = ImagePicker();

  _imgFromGallery() async {
    await picker.pickImage(source: ImageSource.gallery, imageQuality: 50).then(
      (value) {
        if (value != null) {
          _cropImage(File(value.path));
        }
      },
    );
  }

  _imgFromCamera() async {
    await picker.pickImage(source: ImageSource.camera, imageQuality: 50).then(
      (value) {
        if (value != null) {
          _cropImage(File(value.path));
        }
      },
    );
  }

  _cropImage(File imgFile) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imgFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      uiSettings: [
        AndroidUiSettings(
            toolbarTitle: "Image Cropper",
            toolbarColor: Color(0xFF674AEF),
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        IOSUiSettings(
          title: "Image Cropper",
        )
      ],
    );

    if (croppedFile != null) {
      imageCache.clear();
      setState(
        () {
          imageFile = File(croppedFile.path);
        },
      );
      // reload();
    }
  }

  Future<void> _uploadImage() async {
    if (imageFile == null) {
      print('gagal');
      return;
    }
    var request = http.MultipartRequest(
        'POST', Uri.parse('http://10.0.2.2:5000/api/ocr'));
    request.files
        .add(await http.MultipartFile.fromPath('image', imageFile!.path));
    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var responseBody = await response.stream.toBytes();
        var resultJson = json.decode(utf8.decode(responseBody));
        var resultText = resultJson['result'];
        setState(() {
          ocrResult = resultText;
        });
        print(resultText);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending request: $e');
    }
  }
}
