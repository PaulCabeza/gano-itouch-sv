import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../providers/orders.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../providers/user.dart';
import '../providers/cart.dart';
import '../main.dart';

class CheckOut extends StatefulWidget {
  //final _scaffoldKey = GlobalKey<ScaffoldState>();
  static const routeName = 'checkout';

  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {
  bool tarjeta = false;
  bool vencimiento = false;
  bool cvv = false;

  final _coForm = GlobalKey<FormState>();  
  //variable tipo File donde se almacenará la imagen a cargar
  File _pickedImage;
  // metodo que abre el cuadro de dialogo donde se selecciona la imagen
  void _pickImage() async {
    final pickedImageFile =
        await ImagePicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 75,
          maxWidth: 800,
          );
    // este set state asigna la imagen cargada al archivo tipo File _pickedImage
    setState(() {
      _pickedImage = pickedImageFile;
    });
  }

  

  var _editedUser = User(
      id: null,
      nombres: '',
      apellidos: '',
      email: '',
      numDistribuidor: 0,
      direccion: '',
      recibira: '',
      recibiraTel: '');

  var _pedido = AdditionalOrderInfo(
      id: '',
      creatorId: '',
      nombres: '',
      apellidos: '',
      numDistribuidor: 0,
      tarjeta: 0,
      vencimiento: '',
      cvv: 0,
      aplicarA: 0,
      direccion: '',
      recibira: '',
      recibiraTel: 0,
      comentarios: ''
      );

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
    super.dispose();
  }

  void initState() {
    //_editedUser = Provider.of<Users>(context, listen: false).userInfo;
    

    super.initState();
  }

  void didChangeDependencies() {
    
    //final userId = Provider.of<Users>(context, listen: false).userId;

    _editedUser = Provider.of<Users>(context, listen: false).getUserInfo();    
    _initValues = {
      'id': _editedUser.id,
      'nombres': _editedUser.nombres,
      'apellidos': _editedUser.apellidos,
      'email': _editedUser.email,
      'numDistribuidor': _editedUser.numDistribuidor.toString(),
      'direccion': _editedUser.direccion,
      'recibira': _editedUser.recibira,
      'recibiraTel': _editedUser.recibiraTel,
    };

    
    // final userId = ModalRoute.of(context).settings.arguments as String;
    
    super.didChangeDependencies();
  }

  Future<void> _saveForm() async {
    //final cart = Provider.of<Cart>(context);
    var _isLoading = false;
    /*if(_pickedImage == null){
      if(_pedido.tarjeta == 0 && _pedido.vencimiento == '' && _pedido.cvv == 0){
        
        //_scaffoldKey.currentState.showSnackBar(SnackBar(content: Text('Debes ingresar una forma de pago')) );
        //Scaffold.of(context).showSnackBar(SnackBar(content: Text('Debes ingresar una forma de pago')) );
        //BaseAlertDialog();
      }
    }*/
    /*final isValid = _form.currentState.validate();
    if(!isValid){
      return;
    }
    _form.currentState.save();    
    try {      
    Provider.of<Users>(context, listen: false).addUserInformation(_editedUser);
    } catch(e){
      
    } */

    final isValid = _coForm.currentState.validate();   


    if (!isValid) {      
      return;
    }
    _coForm.currentState.save();

    setState(() {
      _isLoading = true;
    });    

    /*if (_editedUser.id != null) {
      await Provider.of<Users>(context, listen: false)
          .updateUserInformation(_editedUser.id, _editedUser);
    } else {*/

    try {      

      await Provider.of<Orders>(context, listen: false).addOrder(
        Provider.of<Cart>(context, listen: false).items.values.toList(),
        Provider.of<Cart>(context, listen: false).totalAmount,
        _pedido, _editedUser.email, _pickedImage
        );

    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Ocurrio un error!'),
          content: Text('Algo salió mal, no se pudo enviar el pedido'),
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

  setState(() {
      _isLoading = false;
    });
  Provider.of<Cart>(context, listen: false).clear();
  Navigator.of(context).pushReplacementNamed('/');

  }



  Widget build(BuildContext context) {   

    return Scaffold(
      appBar: AppBar(
        title: Text('Información de Pago'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.payment),
            onPressed: _saveForm,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Form(
          key: _coForm,
          child: ListView(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Container(
                    width: 250,
                    child: TextFormField(
                      maxLength: 16,
                      decoration: InputDecoration(
                          labelText: "# de Tarjeta de débito/crédito"),
                      keyboardType: TextInputType.number,
                      validator: (value) {  

                        if (value.isNotEmpty && int.tryParse(value) == null) {
                          return 'Ingrese un numero de tarjeta válida';
                        }
                        if (value.isNotEmpty && value.length <= 15) {
                          return 'El número debe contener 16 digitos';
                        }
                        if(value.isEmpty){
                          tarjeta = false;
                        } else {
                          tarjeta = true;
                        }
                        
                        return null;
                      },
                      onSaved: (value) {
                        
                        if (value.isNotEmpty) {                          
                          _pedido = AdditionalOrderInfo(
                              id: null,
                              creatorId: _editedUser.id,
                              nombres: _editedUser.nombres,
                              apellidos: _editedUser.apellidos,
                              numDistribuidor: _editedUser.numDistribuidor,
                              direccion: _editedUser.direccion,
                              tarjeta: int.parse(value),                              
                              vencimiento: null,
                              cvv: null,
                              aplicarA: null,
                              recibira: _editedUser.recibira,
                              recibiraTel: int.tryParse(_editedUser.recibiraTel)
                              );
                        }
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      //initialValue: _initValues['vencimiento'],
                      maxLength: 5,
                      decoration: InputDecoration(labelText: "Vencimiento"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value.isNotEmpty && !value.contains('/')) {
                         return 'formato MM/AA';
                        }
                        if(value.isEmpty){
                          vencimiento = false;
                        } else {
                          vencimiento = true;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value.isNotEmpty) {
                          _pedido = AdditionalOrderInfo(
                              id: null,
                              creatorId: _editedUser.id,
                              nombres: _editedUser.nombres,
                              apellidos: _editedUser.apellidos,
                              numDistribuidor: _editedUser.numDistribuidor,
                              direccion: _editedUser.direccion,
                              tarjeta: _pedido.tarjeta,
                              vencimiento: value,
                              cvv: null,
                              aplicarA: null,
                              recibira: _editedUser.recibira,
                              recibiraTel: int.tryParse(_editedUser.recibiraTel)
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      maxLength: 3,
                      //initialValue: _initValues['cvc'] == '0' ? null : _initValues['cvc'],
                      decoration: InputDecoration(
                          labelText: "Código de seguridad de 3 dígitos"),
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        
                        if (value.isNotEmpty && int.tryParse(value) == null) {
                         return 'Ingrese un codigo de seguridad válido';
                        }
                        if (value.isNotEmpty && value.length <= 2) {
                          return 'El número debe contener 3 digitos';
                        }
                        //_pedido.cvv = int.tryParse(value);
                        if(value.isEmpty){
                          cvv = false;
                        } else {
                          cvv = true;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        if (value.isNotEmpty) {

                          _pedido = AdditionalOrderInfo(
                              id: null,
                              creatorId: _editedUser.id,
                              nombres: _editedUser.nombres,
                              apellidos: _editedUser.apellidos,
                              numDistribuidor: _editedUser.numDistribuidor,
                              direccion: _editedUser.direccion,
                              tarjeta: _pedido.tarjeta,
                              vencimiento: _pedido.vencimiento,
                              cvv: int.parse(value),
                              aplicarA: null,
                              recibira: _editedUser.recibira,
                              recibiraTel: int.parse(_editedUser.recibiraTel)
                              );
                        }
                      },
                    ),
                  ),
                ],
              ),
              //Divider(),
              /*Container(
                child: Text('Ó'),
              ),*/
              TextFormField(
                readOnly: true,
                initialValue: "Ó",
                /*validator: (value) {                 

                  if(_pickedImage == null){
                          if(tarjeta == false || vencimiento == false || cvv == false){
                            return "Ingrese un método de pago o complete la información";
                          }
                        }
                  return null;
                },*/

              ),
              Divider(),
              Text('Comprobante del depósito'),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  //Container(child:, child:,)
                  Container(
                    height: 60,
                    child: FlatButton.icon(                      
                      textColor: Colors.grey[700],
                      onPressed: _pickImage,
                      icon: Icon(Icons.image),
                      label: Text('Agregar foto del depósito'),
                    ),
                  ),

                  Container(
                    width: 120,
                    height: 80,
                    margin: EdgeInsets.only(
                      top: 8,
                      right: 10,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 1,
                        color: Colors.grey,
                      ),
                    ),
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 40,
                      backgroundImage:
                          _pickedImage != null ? FileImage(_pickedImage) : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                initialValue: _initValues['aplicarA'],
                decoration: InputDecoration(labelText: "Aplicar compra a:"),
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number, 
                validator: (value) {

                        if (value.isNotEmpty && (int.tryParse(value) == null)) {
                         return 'Ingrese un número de distribuidor válido';
                        }
                        return null;
                      },               
                onSaved: (value) {
                  if (value.isNotEmpty) {
                    _pedido = AdditionalOrderInfo(
                      id: null,
                      creatorId: _editedUser.id,
                      nombres: _editedUser.nombres,
                      apellidos: _editedUser.apellidos,
                      numDistribuidor: _editedUser.numDistribuidor,
                      direccion: _editedUser.direccion,
                      tarjeta: _pedido.tarjeta,
                      vencimiento: _pedido.vencimiento,
                      cvv: _pedido.cvv,
                      aplicarA: int.parse(value),
                      recibira: _editedUser.recibira,
                      recibiraTel: int.parse(_editedUser.recibiraTel)
                      );
                  }                  
                },
              ),
              TextFormField(
                initialValue: _initValues['direccion'],
                decoration: InputDecoration(
                    labelText: "Dirección de envío(incluya municipio y departamento)"),
                maxLines: 2,
                keyboardType: TextInputType.multiline,
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Por favor ingrese la dirección de envío';
                  }
                  return null;
                },
                onSaved: (value) {
                  _pedido = AdditionalOrderInfo(
                      id: null,
                      creatorId: _editedUser.id,
                      nombres: _editedUser.nombres,
                      apellidos: _editedUser.apellidos,
                      numDistribuidor: _editedUser.numDistribuidor,
                      direccion: value,
                      tarjeta: _pedido.tarjeta,
                      vencimiento: _pedido.vencimiento,
                      cvv: _pedido.cvv,
                      aplicarA: _pedido.aplicarA,
                      recibira: _editedUser.recibira,
                      recibiraTel: int.parse(_editedUser.recibiraTel)
                      );
                },
              ),
              Row(
                children: <Widget>[
                  Container(
                    width: 250,
                    child: TextFormField(
                      initialValue: _initValues['recibira'],
                      decoration:
                          InputDecoration(labelText: "Persona que recibirá"),
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Por favor ingrese la persona que recibirá';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _pedido = AdditionalOrderInfo(
                            id: null,
                            creatorId: _editedUser.id,
                            nombres: _editedUser.nombres,
                            apellidos: _editedUser.apellidos,
                            numDistribuidor: _editedUser.numDistribuidor,
                            direccion: _pedido.direccion,
                            tarjeta: _pedido.tarjeta,
                            vencimiento: _pedido.vencimiento,
                            cvv: _pedido.cvv,
                            aplicarA: _pedido.aplicarA,
                            recibira: value,
                            recibiraTel: int.parse(_editedUser.recibiraTel)
                            );
                      },
                    ),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: _initValues['recibiraTel'],
                      decoration: InputDecoration(labelText: "Teléfono"),
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
                        _pedido = AdditionalOrderInfo(
                            id: null,
                            creatorId: _editedUser.id,
                            nombres: _editedUser.nombres,
                            apellidos: _editedUser.apellidos,
                            numDistribuidor: _editedUser.numDistribuidor,
                            direccion: _pedido.direccion,
                            tarjeta: _pedido.tarjeta,
                            vencimiento: _pedido.vencimiento,
                            cvv: _pedido.cvv,
                            aplicarA: _pedido.aplicarA,
                            recibira: _pedido.recibira,
                            recibiraTel: int.parse(value)
                            );
                      },
                    ),
                  ),
                ],
              ),
              TextFormField(                
                decoration: InputDecoration(
                    labelText: "Comentarios"), 
                keyboardType: TextInputType.multiline,                
                onSaved: (value) {
                  _pedido = AdditionalOrderInfo(
                      id: null,
                      creatorId: _editedUser.id,
                      nombres: _editedUser.nombres,
                      apellidos: _editedUser.apellidos,
                      numDistribuidor: _editedUser.numDistribuidor,
                      direccion: _pedido.direccion,
                      tarjeta: _pedido.tarjeta,
                      vencimiento: _pedido.vencimiento,
                      cvv: _pedido.cvv,
                      aplicarA: _pedido.aplicarA,
                      recibira: _pedido.recibira,
                      recibiraTel: _pedido.recibiraTel,
                      comentarios: value
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