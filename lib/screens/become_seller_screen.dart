import 'package:flutter/material.dart';
import '../helpers/hex_color.dart';
import '../services/kitchens.dart';
import '../helpers/error.dart' as disp;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class BecomeSeller extends StatefulWidget {
  const BecomeSeller({Key key}) : super(key: key);

  static String routeName = '/seller';

  @override
  _BecomeSellerState createState() => _BecomeSellerState();
}

class _BecomeSellerState extends State<BecomeSeller> {
  final _controller = TextEditingController();
  bool isNonVeg = false;
  File _pickedImage;
  final picker = ImagePicker();

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
        title: FutureBuilder(
          future: Kitchens().isSeller(),
          builder: (ctx, snapshot) {
            if (snapshot.hasError) {
              return Text('Kitchen');
            }
            if (snapshot.connectionState == ConnectionState.done) {
              return snapshot.data ? Text('Kitchen') : Text('Become a Seller');
            }
            return LinearProgressIndicator();
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              print('clicked button');
            },
            icon: Icon(Icons.add),
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
                    controller: _controller,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: false,
                    enableSuggestions: true,
                    decoration: InputDecoration(labelText: 'Kitchen Name'),
                    onChanged: (value) {
                      print(_controller.text);
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
              padding: const EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 8.0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                  ),
                  child: FutureBuilder(
                    future: Kitchens().sellerDetails,
                    builder: (ctx, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Something Went Wrong'));
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.person),
                              title: Text('Name'),
                              subtitle: Text(
                                snapshot.data['username'],
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.email),
                              title: Text('Email'),
                              subtitle: Text(
                                snapshot.data['email'],
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.location_city),
                              title: Text('Location'),
                              subtitle: Text(
                                snapshot.data['address'],
                              ),
                            ),
                            ListTile(
                              leading: Icon(Icons.phone_android),
                              title: Text('Phone number'),
                              subtitle: Text(
                                snapshot.data['phone'],
                              ),
                            ),
                          ],
                        );
                      }
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Tooltip(
        message: "Add Menu",
        child: Padding(
          padding: EdgeInsets.only(bottom: 30, right: 10),
          child: FloatingActionButton(
            child: Icon(Icons.menu_book_sharp),
            backgroundColor: HexColor('#424242'),
            onPressed: () async {
              try {
                if (_pickedImage == null) {
                  disp.ShowError.showError('Please pick an image', context);
                  return;
                }
                final docId = await Kitchens()
                    .addKitchen(_controller.text, isNonVeg, _pickedImage);
                Navigator.of(context)
                    .pushNamed('/add-menu-items', arguments: docId);
              } catch (err) {
                disp.ShowError.showError(err.toString(), context);
                print(err.toString());
              }
            },
          ),
        ),
      ),
    );
  }
}
