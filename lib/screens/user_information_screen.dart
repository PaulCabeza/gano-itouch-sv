import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../widgets/app_drawer.dart';
import '../providers/user.dart';
import '../providers/auth.dart';
import '../main.dart';

class UserInformation extends StatefulWidget {
  static const routeName = 'edit-personalInformation';
  @override
  _UserInformationState createState() => _UserInformationState();
}

class _UserInformationState extends State<UserInformation> {
  final _focusNode = FocusNode();
  final _focusNode2 = FocusNode();
  final _form = GlobalKey<FormState>();
  var _isLoading = false;
  var _editedUser = User(
      id: null,
      nombres: '',
      apellidos: '',
      email: '',
      numDistribuidor: 0,
      direccion: '',
      recibira: '',
      recibiraTel: '');
  var _initValues = {
    'id': '',
    'nombres': '',
    'apellidos': '',
    'email': '',
    'numDistribuidor': '',
    'direccion': '',
    'recibira': '',
    'recibiraTel': '',
  };

  @override
  void dispose() {
    _focusNode.dispose();
    _focusNode2.dispose();
    super.dispose();
  }

  void initState() {
    
    super.initState();
  }

  void didChangeDependencies() {
    _editedUser = Provider.of<Users>(context).getUserInfo();
    final String userEmail = Provider.of<Auth>(context).email;
    /*String nombres = _editedUser.nombres;
    if(nombres == null)
    print('no se encontró un usuario');
    else
    print('si se encontró un usuario');*/

    //print(userEmail);
    if (_editedUser != null)
      _initValues = {
        'id': _editedUser.id,
        'nombres': _editedUser.nombres,
        'apellidos': _editedUser.apellidos,
        'email': userEmail==null ? '' : userEmail,
        'numDistribuidor': _editedUser.numDistribuidor!=null ? _editedUser.numDistribuidor.toString() : '' ,
        'direccion': _editedUser.direccion,
        'recibira': _editedUser.recibira,
        'recibiraTel': _editedUser.recibiraTel,
      };

    //if (_editedUser == null)
    else
      _initValues = {
        'id': '',
        'nombres': '',
        'apellidos': '',
        'email': userEmail,
        'numDistribuidor': '',
        'direccion': '',
        'recibira': '',
        'recibiraTel': '',
      };
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();

    setState(() {
      _isLoading = true;
    });
    if (_editedUser.id != null) {
      await Provider.of<Users>(context, listen: false)
          .updateUserInformation(_editedUser.id, _editedUser);
    } else {
      try {
        await Provider.of<Users>(context, listen: false)
            .addUserInformation(_editedUser);
      } catch (error) {
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Ocurrio un error!'),
            content: Text('No se pudo guardar su perfil'),
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
    }
    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pushNamed('/');
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información Personal'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Form(
          key: _form,
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      initialValue: _initValues['nombres'],
                      decoration: InputDecoration(labelText: "Nombres"),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Ingrese su nombre';
                        }                        
                        return null;
                      },
                      onSaved: (value) {
                        _editedUser = User(
                            id: _editedUser.id,
                            nombres: value,
                            apellidos: _editedUser.apellidos,
                            email: _editedUser.email,
                            numDistribuidor: _editedUser.numDistribuidor,
                            direccion: _editedUser.direccion,
                            recibira: _editedUser.recibira,
                            recibiraTel: _editedUser.recibiraTel);
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: _initValues['apellidos'],
                      decoration: InputDecoration(labelText: "Apellidos"),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Ingrese su apellido';
                        }                        
                        return null;
                      },
                      onSaved: (value) {
                        _editedUser = User(
                            id: _editedUser.id,
                            nombres: _editedUser.nombres,
                            apellidos: value,
                            email: _editedUser.email,
                            numDistribuidor: _editedUser.numDistribuidor,
                            direccion: _editedUser.direccion,
                            recibira: _editedUser.recibira,
                            recibiraTel: _editedUser.recibiraTel);
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(
                enabled: false,
                initialValue: _initValues['email'],
                decoration: InputDecoration(labelText: "Email"),
                textInputAction: TextInputAction.next,
                onSaved: (value) {
                  _editedUser = User(
                      id: _editedUser.id,
                      nombres: _editedUser.nombres,
                      apellidos: _editedUser.apellidos,
                      email: value,
                      numDistribuidor: _editedUser.numDistribuidor,
                      direccion: _editedUser.direccion,
                      recibira: _editedUser.recibira,
                      recibiraTel: _editedUser.recibiraTel);
                },
              ),
              TextFormField(
                initialValue: _initValues['numDistribuidor'],
                decoration: InputDecoration(labelText: "Distribuidor #"),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Por favor ingrese su numero de distribuidor';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Por favor ingrese un numero de distribuidor válido';
                  }
                  if (value.length != 7) {
                    return 'El numero de distribuidor debe contener 7 digitos';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedUser = User(
                      id: _editedUser.id,
                      nombres: _editedUser.nombres,
                      apellidos: _editedUser.apellidos,
                      email: _editedUser.email,
                      numDistribuidor: int.parse(value),
                      direccion: _editedUser.direccion,
                      recibira: _editedUser.recibira,
                      recibiraTel: _editedUser.recibiraTel);
                },
              ),
              TextFormField(
                initialValue: _initValues['direccion'],
                decoration: InputDecoration(
                    labelText: "Dirección(incluya municipio y departamento)"),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Por favor ingrese la dirección de envío';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedUser = User(
                      id: _editedUser.id,
                      nombres: _editedUser.nombres,
                      apellidos: _editedUser.apellidos,
                      email: _editedUser.email,
                      numDistribuidor: _editedUser.numDistribuidor,
                      direccion: value,
                      recibira: _editedUser.recibira,
                      recibiraTel: _editedUser.recibiraTel);
                },
              ),
              TextFormField(
                initialValue: _initValues['recibira'],
                decoration: InputDecoration(
                    labelText: "Nombre de la persona que recibirá"),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Por favor ingrese la persona que recibirá';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedUser = User(
                      id: _editedUser.id,
                      nombres: _editedUser.nombres,
                      apellidos: _editedUser.apellidos,
                      email: _editedUser.email,
                      numDistribuidor: _editedUser.numDistribuidor,
                      direccion: _editedUser.direccion,
                      recibira: value,
                      recibiraTel: _editedUser.recibiraTel);
                },
              ),
              TextFormField(
                initialValue: _initValues['recibiraTel'],
                decoration: InputDecoration(
                    labelText: "Teléfono(s) de la persona que recibirá"),
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Por favor ingrese el telefono de la persona que recibirá';
                  }
                  if (int.tryParse(value) == null) {
                    return 'El telefono no debe contener guiones o letras';
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedUser = User(
                    id: _editedUser.id,
                    nombres: _editedUser.nombres,
                    apellidos: _editedUser.apellidos,
                    email: _editedUser.email,
                    numDistribuidor: _editedUser.numDistribuidor,
                    direccion: _editedUser.direccion,
                    recibira: _editedUser.recibira,
                    recibiraTel: value,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
