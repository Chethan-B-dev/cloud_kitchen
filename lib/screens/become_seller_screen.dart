import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/users.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: Kitchens().sellerDetailsStream,
                    builder: (ctx, snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            'Something Went Wrong',
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: const CircularProgressIndicator(
                            color: Colors.yellow,
                          ),
                        );
                      }

                      return Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.person),
                            title: const Text('Name'),
                            subtitle: Text(
                              snapshot.data['username'],
                            ),
                            trailing: IconButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (BuildContext context) =>
                                        FullScreenDialog(
                                      name: snapshot.data['username'],
                                      email: snapshot.data['email'],
                                      phone: snapshot.data['phone'],
                                      address: snapshot.data['address'],
                                    ),
                                    fullscreenDialog: true,
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit_outlined),
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
              margin: const EdgeInsets.only(bottom: 15, left: 10),
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
                          'Please pick an image',
                          context,
                        );
                        setState(() {
                          _isLoading = false;
                        });
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

class FullScreenDialog extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  const FullScreenDialog({this.name, this.address, this.phone, this.email});

  @override
  _FullScreenDialogState createState() => _FullScreenDialogState();
}

class _FullScreenDialogState extends State<FullScreenDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Map<String, String> _authData = {'username': '', 'phone': '', 'address': ''};
  var _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<Users>(context, listen: false).editProfile(
        _authData['username'],
        _authData['phone'],
        _authData['address'],
      );

      Navigator.of(context).pop();
    } catch (err) {
      ShowError.showError(err.toString(), context);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Edit profile'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _isLoading
          ? Container(
              margin: const EdgeInsets.only(bottom: 15, left: 10),
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
              message: "Edit profile",
              child: Padding(
                padding: const EdgeInsets.only(bottom: 30, right: 10),
                child: FloatingActionButton(
                  child: const Icon(
                    Icons.save,
                    color: Colors.black,
                  ),
                  backgroundColor: Colors.yellow,
                  onPressed: _submit,
                ),
              ),
            ),
      body: Container(
        padding: const EdgeInsets.all(10),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: widget.name,
                decoration: const InputDecoration(
                  labelText: 'Username',
                ),
                validator: (String value) {
                  if (value.trim().isEmpty || value.trim().length < 4) {
                    return 'username is required';
                  }
                },
                onSaved: (value) {
                  _authData['username'] = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: widget.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
                keyboardType: TextInputType.number,
                validator: (String value) {
                  bool numberValid = RegExp(r"^[0-9]+$").hasMatch(value);
                  if (value.isEmpty || value.length != 10 || !numberValid) {
                    return 'Please enter valid phone number!';
                  }
                  return null;
                },
                onSaved: (value) {
                  _authData['phone'] = value;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                initialValue: widget.address,
                decoration: const InputDecoration(
                  labelText: 'Address',
                ),
                validator: (String value) {
                  if (value.trim().isEmpty || value.trim().length < 10) {
                    return 'Please Enter full address';
                  }
                },
                onSaved: (value) {
                  _authData['address'] = value;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
