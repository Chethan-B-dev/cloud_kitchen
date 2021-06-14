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
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Food',
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
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        barrierDismissible: false,
                      );
                    } on FormatException catch (err) {
                      ShowError.showError(
                          'Please Enter a valid price', context);
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
                      color: Colors.pink,
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
