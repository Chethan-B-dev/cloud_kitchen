import 'package:flutter/material.dart';
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
  var _isLoading = false;

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
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text(
          'Become a Seller',
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
            Container(
              padding: const EdgeInsets.all(10),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 8.0,
                child: Container(
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(40),
                    ),
                  ),
                  child: FutureBuilder(
                    future: Kitchens().sellerDetails,
                    builder: (ctx, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Something Went Wrong',
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person),
                              title: const Text('Name'),
                              subtitle: Text(
                                snapshot.data['username'],
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.email),
                              title: const Text('Email'),
                              subtitle: Text(
                                snapshot.data['email'],
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.location_city),
                              title: const Text('Location'),
                              subtitle: Text(
                                snapshot.data['address'],
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone_android),
                              title: const Text('Phone number'),
                              subtitle: Text(
                                snapshot.data['phone'],
                              ),
                            ),
                          ],
                        );
                      }
                      return const Center(
                        child: const CircularProgressIndicator(),
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
      floatingActionButton: _isLoading
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
          : Tooltip(
              message: "Add Menu",
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 10),
                child: FloatingActionButton(
                  child: const Icon(
                    Icons.menu_book_sharp,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.yellow,
                  onPressed: () async {
                    try {
                      setState(() {
                        _isLoading = true;
                      });

                      if (_pickedImage == null) {
                        disp.ShowError.showError(
                            'Please pick an image', context);
                        return;
                      }
                      final docId = await Kitchens()
                          .addKitchen(_controller.text, isNonVeg, _pickedImage);
                      Navigator.of(context).pushReplacementNamed(
                          '/add-menu-items',
                          arguments: docId);
                    } catch (err) {
                      disp.ShowError.showError(err.toString(), context);
                    }

                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ),
            ),
    );
  }
}
