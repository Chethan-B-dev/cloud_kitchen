import 'dart:math';

import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cool_alert/cool_alert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class EditFood extends StatefulWidget {
  final String name;
  final String foodId;
  final String imageUrl;
  final bool isVeg;
  final num price;

  const EditFood({
    this.name,
    this.foodId,
    this.imageUrl,
    this.isVeg,
    this.price,
  });

  @override
  _EditFoodState createState() => _EditFoodState();
}

class _EditFoodState extends State<EditFood> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool isNonVeg;
  String existingUrl;

  var _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void toggleSwitch(bool value) {
    setState(() {
      isNonVeg = !isNonVeg;
    });
  }

  File _pickedImage;
  final picker = ImagePicker();

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
      // imageQuality: 100,
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

    _nameController.text = widget.name;
    _priceController.text = widget.price.toStringAsFixed(2);
    isNonVeg = !widget.isVeg;
    existingUrl = widget.imageUrl;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Food - ${widget.name}",
        ),
        actions: [
          _isLoading
              ? Container(
                  alignment: Alignment.center,
                  width: 40.0,
                  height: 10.0,
                  child: SizedBox(
                    height: 15,
                    width: 15,
                    child: CircularProgressIndicator(
                      color: Colors.yellow,
                    ),
                  ),
                )
              : IconButton(
                  onPressed: () async {
                    setState(() {
                      _isLoading = true;
                    });

                    if (_pickedImage == null ||
                        _nameController.text.trim() == "" ||
                        _priceController.text.trim() == "") {
                      ShowError.showError(
                        'Please pick an image and fill all the details',
                        context,
                      );
                      setState(() {
                        _isLoading = false;
                      });
                      return;
                    }
                    try {
                      await Kitchens().editFood(
                        fname: _nameController.text.trim(),
                        price: double.parse(_priceController.text.trim()),
                        image: _pickedImage,
                        existingUrl: existingUrl,
                        foodId: widget.foodId,
                        isNonVeg: isNonVeg,
                      );
                      CoolAlert.show(
                        context: context,
                        type: CoolAlertType.success,
                        text: "Your Food item has been Edited!",
                        onConfirmBtnTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        barrierDismissible: false,
                      );
                    } on FormatException catch (err) {
                      ShowError.showError(
                        'Please Enter a valid price',
                        context,
                      );
                    } catch (err) {
                      ShowError.showError(err.toString(), context);
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  },
                  icon: const Icon(
                    Icons.save,
                    color: Colors.yellow,
                  ),
                )
        ],
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
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: false,
                    enableSuggestions: true,
                    decoration: const InputDecoration(labelText: 'Food Name'),
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
                          activeTrackColor: Colors.red.shade400,
                          activeColor: Colors.red.shade400,
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
              textColor: Theme.of(context).primaryColor,
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
              icon: const Icon(
                Icons.image,
                color: Colors.white,
              ),
              label: const Text(
                'Add Image',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              width: deviceSize.width,
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                autocorrect: false,
                enableSuggestions: true,
                decoration: const InputDecoration(labelText: 'Price'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
