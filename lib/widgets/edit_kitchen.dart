import 'dart:io';
import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

class EditKitchen extends StatefulWidget {
  final String kname;
  final bool isVeg;
  final String imageUrl;

  const EditKitchen({this.kname, this.isVeg, this.imageUrl});

  @override
  _EditKitchenState createState() => _EditKitchenState();
}

class _EditKitchenState extends State<EditKitchen> {
  final _controller = TextEditingController();
  bool isNonVeg;
  File _pickedImage;
  final picker = ImagePicker();
  var _isLoading = false;
  String existingImageUrl;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleSwitch(bool value) {
    setState(() {
      isNonVeg = !isNonVeg;
    });
  }

  Future<File> urlToFile(String image) async {
    var rng = new Random();
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.jpg');
    var url = Uri.parse(image);
    http.Response response = await http.get(url);
    await file.writeAsBytes(response.bodyBytes);
    return file;
  }

  void _pickImage(String source) async {
    final pickedFile = await picker.getImage(
      source: source == 'Gallery' ? ImageSource.gallery : ImageSource.camera,
      // imageQuality: 50,
      // maxWidth: 150,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    urlToFile(widget.imageUrl).then((value) {
      setState(() {
        _pickedImage = value;
      });
    });
    isNonVeg = !widget.isVeg;
    _controller.text = widget.kname;
    existingImageUrl = widget.imageUrl;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Edit Kitchen'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _isLoading
          ? Container(
              margin: const EdgeInsets.only(bottom: 25, left: 10),
              alignment: Alignment.center,
              width: 40.0,
              height: 20.0,
              child: SizedBox(
                height: 15,
                width: 15,
                child: CircularProgressIndicator(
                  color: Colors.yellow,
                ),
              ),
            )
          : Tooltip(
              message: "Edit kitchen",
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 10),
                child: FloatingActionButton(
                  child: const Icon(
                    Icons.save,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.yellow,
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      await Kitchens().editKitchen(
                        _controller.text.trim(),
                        isNonVeg,
                        _pickedImage,
                        existingImageUrl,
                      );
                      Navigator.of(context).pop(true);
                    } catch (err) {
                      ShowError.showError(err.toString(), context);
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),
            ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: deviceSize.width * 0.65,
                  padding: const EdgeInsets.all(10),
                  child: TextField(
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: false,
                    enableSuggestions: true,
                    decoration: InputDecoration(labelText: 'Kitchen Name'),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isNonVeg) const Text('Veg'),
                      Container(
                        alignment: Alignment.center,
                        child: Switch(
                          value: isNonVeg,
                          onChanged: toggleSwitch,
                          activeTrackColor: Colors.redAccent,
                          activeColor: Colors.redAccent,
                          inactiveThumbColor: Colors.green,
                          inactiveTrackColor: Colors.green,
                        ),
                      ),
                      if (isNonVeg) const Text('Non Veg'),
                    ],
                  ),
                ),
              ],
            ),
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey,
              backgroundImage:
                  _pickedImage != null ? FileImage(_pickedImage) : null,
            ),
            FlatButton.icon(
              textColor: Colors.white,
              onPressed: () => showDialog<String>(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  title: const Text(
                    'File Upload',
                    style: const TextStyle(
                      color: Colors.yellow,
                    ),
                  ),
                  content: const Text(
                    'Where do you want the image to be taken from?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pickImage('Camera');
                      },
                      child: const Text('Camera'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        _pickImage('Gallery');
                      },
                      child: const Text('Gallery'),
                    ),
                  ],
                ),
              ),
              icon: const Icon(Icons.image),
              label: const Text('Add Image'),
            ),
          ],
        ),
      ),
    );
  }
}
