import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:aplikasi_scan_plat_nomor/model/plat_model.dart';
import 'package:aplikasi_scan_plat_nomor/services/api.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var pickedImage;
  late String textResult;
  static String hasilScan = '';
  bool klik = false;

  bool isImageLoaded = false;
  @override
  void initState() {
    super.initState();
    print(klik);
  }

  Future pickImageCamera() async {
    var tempStorage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      textResult = "Hasil Text";
      pickedImage = tempStorage;
      isImageLoaded = true;
      readText();
    });
  }

  Future pickImageGallery() async {
    var tempStorage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      textResult = "Hasil";
      pickedImage = tempStorage;
      isImageLoaded = true;
      readText();
    });
  }

  Future readText() async {
    FirebaseVisionImage ourImage = FirebaseVisionImage.fromFile(pickedImage);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(ourImage);
    print(readText.text);
    setState(() {
      hasilScan = readText.text.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Aplikasi Scan Plat Nomor"),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                (pickedImage != null)
                    ? Center(
                  child: Container(
                    height: 200.0,
                    width: 200.0,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: FileImage(pickedImage),
                            fit: BoxFit.fill)),
                  ),
                )
                    : Text("No Image"),
                SizedBox(
                  height: 16.0,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          klik = true;
                          pickImageCamera();
                        });
                      },
                      child: Icon(Icons.camera_alt),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          klik = true;
                          pickImageGallery();
                        });
                      },
                      child: Icon(Icons.photo),
                    ),
                    // RaisedButton(
                    //   onPressed: readText,
                    //   child: Text("Baca"),
                    // ),
                  ],
                ),
                SizedBox(
                  height: 16.0,
                ),
                (klik == false)
                    ? Text("Hasil Scan")
                    : FutureBuilder(
                  future: getPlatData(),
                  builder: (BuildContext context, AsyncSnapshot snap) {
                    if (snap.hasError) {
                      return Center(
                        child: Text("Error"),
                      );
                    } else if (snap.connectionState ==
                        ConnectionState.done) {
                      List<Plat> plat = snap.data;
                      return _buildListView(plat);
                    } else {
                      return (textResult == null || pickedImage == null)
                          ? Text("Hasil Scan")
                          : CircularProgressIndicator();
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(List<Plat> plat) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: plat.length,
      itemBuilder: (context, index) {
        if (hasilScan.contains(plat[index].noPlat) == null) {
          return Center(
            child: Container(
              child: Text("Hasil scan"),
            ),
          );
        }
        if (hasilScan.contains(plat[index].noPlat)) {
          return Center(
            child: Container(
              child: Text(
                plat[index].noPlat + " dengan pemilik : " + plat[index].nama,
                style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              ),
            ),
          );
        }
        if (!hasilScan.contains(plat[index].noPlat)) {
          return SizedBox.shrink();
        }
        return Center(
          child: Container(
            child: Text(
              "Plat nomor tidak cocok/tidak ada di database",
              style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.red,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
        ;
      },
    );
  }
}

RaisedButton({required Null Function() onPressed, required Icon child}) {
}