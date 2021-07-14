import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

// todo: copy .init.example.dart to init.dart
import 'init.dart';

class MultiImagePickerExample extends StatefulWidget {
  @override
  _MultiImagePickerExampleState createState() =>
      _MultiImagePickerExampleState();
}

class _MultiImagePickerExampleState extends State<MultiImagePickerExample> {
  List<Asset> images = <Asset>[];
  String _error = 'No Error Detected';
  bool _uploading = false;

  Widget buildGridView() {
    return GridView.count(
      crossAxisCount: 3,
      children: List.generate(images.length, (index) {
        Asset asset = images[index];
        return AssetThumb(
          asset: asset,
          width: 300,
          height: 300,
        );
      }),
    );
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      images = resultList;
      _error = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Multi Image Picker Example'),
        ),
        body: Column(
          children: <Widget>[
            Center(child: Text('Error: $_error')),
            ElevatedButton(
              child: Text("Pick images"),
              onPressed: loadAssets,
            ),
            Expanded(
              child: buildGridView(),
            ),
            if (images.length > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 100),
                child: ElevatedButton(
                  onPressed: _uploading ? null : _upload,
                  child: _uploading ? Text('Uploading...') : Text('Upload'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _upload() async {
    setState(() {
      _uploading = true;
    });

    List<CloudinaryResponse> uploadedImages = await cloudinary.multiUpload(
      images
          .map(
            (image) => CloudinaryFile.fromFutureByteData(
              image.getByteData(),
              identifier: image.identifier,
            ),
          )
          .toList(),
    );

    setState(() {
      _uploading = false;
    });

    print(uploadedImages[0].secureUrl);
  }
}
