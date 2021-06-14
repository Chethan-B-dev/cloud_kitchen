import 'package:cloud_kitchen/helpers/error.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: const BoxDecoration(
              color: Colors.black,
              image: DecorationImage(
                image: NetworkImage(
                  'https://i.pinimg.com/originals/25/19/2f/25192f4eda302e18aece7516878ae9e5.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Cloud ',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 45,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            'Kitchen ',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 45,
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final AuthService authService = AuthService();
  UserModel user;

  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
    'username': '',
    'phone': '',
    'address': ''
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -1.5),
      end: Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );
    // _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      return;
    }

    _formKey.currentState.save();

    setState(() {
      _isLoading = true;
    });

    try {
      if (_authMode == AuthMode.Login) {
        user = await authService.signInWithEmailAndPassword(
            _authData['email'], _authData['password']);
        if (user == null) {
          ShowError.showError('Failed To Authenticate', context);
        }
      } else {
        user = await authService.registerWithEmailAndPassword(
          _authData['email'],
          _authData['password'],
          _authData['username'],
          _authData['phone'],
          _authData['address'],
        );
        if (user == null) {
          ShowError.showError('Failed To Authenticate', context);
        }
      }
    } catch (err) {
      ShowError.showError(err.toString(), context);
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      // color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  style: TextStyle(color: Colors.orange),
                  decoration: const InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    bool emailValid = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                        .hasMatch(value);
                    if (value.isEmpty || !value.contains('@') || !emailValid) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  style: TextStyle(color: Colors.orange),
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Password is too short!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        style: TextStyle(color: Colors.orange),
                        enabled: _authMode == AuthMode.Signup,
                        decoration: const InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value != _passwordController.text &&
                                    value.isNotEmpty) {
                                  return 'Passwords do not match!';
                                }
                                return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                        style: TextStyle(color: Colors.orange),
                        enabled: _authMode == AuthMode.Signup,
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        keyboardType: TextInputType.text,
                        validator: _authMode == AuthMode.Signup
                            ? (value) {
                                if (value.isEmpty || value.length < 4) {
                                  return 'Please enter valid Username!';
                                }
                                return null;
                              }
                            : null,
                        onSaved: (value) {
                          _authData['username'] = value;
                        },
                      ),
                    ),
                  ),
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                          style: TextStyle(color: Colors.orange),
                          enabled: _authMode == AuthMode.Signup,
                          decoration:
                              const InputDecoration(labelText: 'Phone Number'),
                          keyboardType: TextInputType.number,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  bool numberValid =
                                      RegExp(r"^[0-9]+$").hasMatch(value);
                                  if (value.isEmpty ||
                                      value.length != 10 ||
                                      !numberValid) {
                                    return 'Please enter valid phone number!';
                                  }
                                  return null;
                                }
                              : null,
                          onSaved: (value) {
                            _authData['phone'] = value;
                          }),
                    ),
                  ),
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: TextFormField(
                          style: TextStyle(color: Colors.orange),
                          enabled: _authMode == AuthMode.Signup,
                          decoration:
                              const InputDecoration(labelText: 'Address'),
                          keyboardType: TextInputType.text,
                          validator: _authMode == AuthMode.Signup
                              ? (value) {
                                  if (value.isEmpty || value.length < 10) {
                                    return 'Please enter your complete address';
                                  }
                                  return null;
                                }
                              : null,
                          onSaved: (value) {
                            _authData['address'] = value;
                          }),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  RaisedButton(
                    child: Text(
                      _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30.0,
                      vertical: 8.0,
                    ),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton(
                  child: Text(
                    '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: _switchAuthMode,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
