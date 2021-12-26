//import 'dart:html';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';
import 'package:http/http.dart' as http;

import '../providers/auth.dart';
import '../models/http_exception.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              color: Colors.white54,
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
                    child: Container(
                      child: Image.asset('images/4pilares.jpg'),
                      height: 220.0,
                      margin: EdgeInsets.symmetric(horizontal: 48),
                      padding:
                          EdgeInsets.symmetric(vertical: 4.0, horizontal: 4.0),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 3 : 2,
                    child: AuthCard(),
                  ),
                  Flexible(
                    child: Container(
                      height: 100,
                      padding: EdgeInsets.symmetric(
                          vertical: 25.0, horizontal: 65.0),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  'Al registrarme y usar esta aplicación afirmo que acepto las ',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text:
                                  'Políticas de Privacidad de Gano Itouch SV App.',
                              style: TextStyle(color: Colors.blue),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url =
                                      'http://www.ganoitouch.com.sv/aviso-de-privacidad-de-la-aplicacion-gano-itouch-sv/';
                                  if (await canLaunch(url)) {
                                    await launch(
                                      url,
                                      forceSafariVC: true,
                                      forceWebView: true,
                                      enableJavaScript: true,
                                    );
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
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
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  AnimationController _controller;
  Animation<Size> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(
        milliseconds: 300,
      ),
    );
    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 260), end: Size(double.infinity, 320))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.fastOutSlowIn,
      ),
    );
    _heightAnimation.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Ocurrió un error!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in

        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (error) {
      var errorMessage = 'Autenticación fallida';
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'Esta correo electrónico ya esta en uso.';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'Verifique su correo y/o su contraseña ';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'Esta contraseña es muy insegura.';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email incorrecto.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Contraseña incorrecta.';
      }
      _showErrorDialog(errorMessage);
    } catch (error) {
      const errorMessage =
          'No fue posible autenticarse. Por favor pruebe mas tarde.';
      _showErrorDialog(errorMessage);
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
    //String fechaVencimiento = "2020–07–15";
    //DateTime fechaVencimiento2 = DateTime.parse(fechaVencimiento);
    //print(fechaVencimiento2);
    //DateFormat('yyyy-MM-dd').format( DateTime.parse('2020-07-17'));

    //DateTime fechaVencimiento = DateTime.parse('2020-07-12');

    //if(DateTime.now().isBefore(fechaVencimiento))
    //print('Todavia tiene licencia');
    //else
    //final deviceSize = MediaQuery.of(context).size;

    //if (DateTime.now().isBefore(fechaVencimiento)) {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: Container(
          // height: _authMode == AuthMode.Signup ? 320 : 260,
          height: _heightAnimation.value.height,
          constraints: BoxConstraints(minHeight: _heightAnimation.value.height),
          //width: deviceSize.width * 0.75,
          width: MediaQuery.of(context).size.width * 0.75,
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value.isEmpty || !value.contains('@')) {
                        return 'Email inválido!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['email'] = value;
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value.isEmpty || value.length < 5) {
                        return 'La contraseña es muy corta!';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _authData['password'] = value;
                    },
                  ),
                  if (_authMode == AuthMode.Signup)
                    TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'Confirme su contraseña'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Las contraseñas no coinciden!';
                              }
                              return null;
                            }
                          : null,
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  //if(DateTime.now()  ){          }

                  if (_isLoading)
                    CircularProgressIndicator()
                  else
                    RaisedButton(
                      child: Text(_authMode == AuthMode.Login
                          ? 'INGRESAR'
                          : 'REGISTRARSE'),
                      onPressed: _submit,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                      color: Theme.of(context).primaryColor,
                      textColor:
                          Theme.of(context).primaryTextTheme.button.color,
                    ),
                  FlatButton(
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'REGISTRARSE' : 'INGRESAR'}'),
                    onPressed: _switchAuthMode,
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    textColor: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    /*} else {
      return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        elevation: 8.0,
        child: Flexible(
          child: Container(
            height: 100,
            width: 300,
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            margin: EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
            child: Text(
              'El período de prueba ha terminado, para seguir usando la aplicación, por favor descárguela de la Play Store.',
              textAlign: TextAlign.justify,
              style: TextStyle(fontSize: 17),
            ),
          ),
        ),
      );
    }*/
  }
}
