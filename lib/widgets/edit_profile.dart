import 'package:cloud_kitchen/helpers/error.dart';
import 'package:cloud_kitchen/services/users.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
