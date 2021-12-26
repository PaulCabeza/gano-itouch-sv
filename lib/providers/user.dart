import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class User { //with ChangeNotifier {
 //List<User> _users = [];

  final String id;
  final String nombres;
  final String apellidos;
  final String email;
  final int numDistribuidor;
  final String direccion;
  //final int tarjeta;
  //final String vencimiento;
  //final int cvc;
  //final int aplicarA;
  final String recibira;
  final String recibiraTel;

  

  User({
    @required this.id,
    @required this.nombres,
    @required this.apellidos,
    @required this.email,
    @required this.numDistribuidor,
    @required this.direccion,
    //@required this.tarjeta,
    //@required this.vencimiento,
    //@required this.cvc,
    //@required this.aplicarA,    
    @required this.recibira,
    @required this.recibiraTel
  });

}

class Users with ChangeNotifier {
  List<User> _users = [];
  User _user;
  User userInfo;
  final String authToken;
  final String userId;

  Users(this.authToken, this.userId, this._users);

  List<User> get users {
    return [..._users];    
  }

  User getUserInfo(){
    return _user;
  }

  Future<void> loadUserInfo() async {
  final url = 'https://gano-pedidos.firebaseio.com/users.json?auth=$authToken&orderBy="id"&equalTo="$userId"';
  try{
  final response = await http.get(url);
  final extractedUser2 = json.decode(response.body) as Map<String, dynamic>;

  Map<String, dynamic> extractedUser = {};
  extractedUser2.removeWhere((key, value) {
  if (value is Map) {
  extractedUser.addAll(value);
  }
    return value is Map;
  });

  extractedUser.addAll(extractedUser2);  

  final User userInformation = User(
  id: extractedUser['id'],
  nombres: extractedUser['nombres'],
  apellidos: extractedUser['apellidos'],
  email: extractedUser['email'],
  numDistribuidor: extractedUser['numDistribuidor'],
  direccion: extractedUser['direccion'],  
  recibira: extractedUser['recibira'],
  recibiraTel: extractedUser['recibiraTel']
  );
  
  _user = userInformation;
  notifyListeners();
    
  } catch(e){
  print(e);
  throw(e);
  }
    
  }

  Future<void> addUserInformation(User user) async{
    //final url = 'https://gano-pedidos.firebaseio.com/users/$userId.json?auth=$authToken';
    final url = 'https://gano-pedidos.firebaseio.com/users.json?auth=$authToken';
   try {
    final response = await http.post(url, body: json.encode({
      'id': userId,
      'nombres': user.nombres,
      'apellidos': user.apellidos,
      'email': user.email,
      'numDistribuidor': user.numDistribuidor,
      'direccion': user.direccion,
      //'tarjeta': user.tarjeta,
      //'vencimiento': user.vencimiento,
      //'cvc': user.cvc,
      //'aplicarA': user.aplicarA,
      'recibira': user.recibira,
      'recibiraTel': user.recibiraTel
    }));
    } catch(e){
      print(e);
      throw(e);
    }
  }

  Future<void> updateUserInformation(String id, User newUser) async {        
    if (id == _user.id) {
      print(newUser.apellidos);
      //final url = 'https://gano-pedidos.firebaseio.com/users.json?auth=$authToken&orderBy="id"&equalTo="$userId"';
      final url ='https://gano-pedidos.firebaseio.com/users/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'nombres': newUser.nombres,
            'apellidos': newUser.apellidos,
            'email': newUser.email,
            'numDistribuidor': newUser.numDistribuidor,
            'direccion': newUser.direccion,
            //'tarjeta': newUser.tarjeta,
            //'vencimiento': newUser.vencimiento,
            //'cvc': newUser.cvc,
            //'aplicarA': newUser.aplicarA,
            'recibira': newUser.recibira,
            'recibiraTel': newUser.recibiraTel
          }));
      //_items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  } 

}