import 'dart:async';

import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/kitchens.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:cool_alert/cool_alert.dart';

class FoodItem extends StatefulWidget {
  const FoodItem({Key key}) : super(key: key);

  static String routeName = '/food';

  @override
  _FoodItemState createState() => _FoodItemState();
}

class _FoodItemState extends State<FoodItem> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool isNonVeg = false;

  void toggleSwitch(bool value) {
    setState(() {
      isNonVeg = !isNonVeg;
    });
  }

  File _pickedImage;
  final picker = ImagePicker();

  void _pickImage(String source) async {
    final pickedFile = await picker.getImage(
      source: source == 'Gallery' ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 50,
      maxWidth: 150,
    );
    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    } else {
      print('No image selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Food',
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (_pickedImage == null) {
                ShowError.showError('Please pick an image', context);
                return;
              }
              try {
                await Kitchens().addFood(
                  _nameController.text,
                  isNonVeg,
                  _pickedImage,
                  double.parse(_priceController.text),
                );
                CoolAlert.show(
                  context: context,
                  type: CoolAlertType.success,
                  text: "Your Food item has been added to the menu!",
                  onConfirmBtnTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/add-menu-items');
                  },
                  barrierDismissible: false,
                );
              } catch (err) {
                ShowError.showError(err.toString(), context);
              }
            },
            icon: Icon(Icons.save),
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
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _nameController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: false,
                    enableSuggestions: true,
                    decoration: InputDecoration(labelText: 'Food Name'),
                    onChanged: (value) {
                      print(_nameController.text);
                    },
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isNonVeg) Text('Veg'),
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
                      if (isNonVeg) Text('Non Veg'),
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
                    style: TextStyle(
                      color: Colors.pink,
                    ),
                  ),
                  content: const Text(
                      'Where do you want the image to be taken from?'),
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
              icon: Icon(Icons.image),
              label: Text('Add Image'),
            ),
            Container(
              width: deviceSize.width,
              padding: EdgeInsets.all(10),
              child: TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                autocorrect: false,
                enableSuggestions: true,
                decoration: InputDecoration(labelText: 'Price'),
                onChanged: (value) {
                  print(_priceController.text);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
