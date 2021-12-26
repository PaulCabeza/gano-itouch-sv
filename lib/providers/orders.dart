import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/date_time_patterns.dart';
import 'package:uuid/uuid.dart';
import 'package:mailer2/mailer.dart';

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  final String imageUrl;
  final String nombres;
  final String apellidos;
  final int numDistribuidor;
  final int tarjeta;
  final String vencimiento;
  final int cvv;
  final int aplicarA;
  final String direccion;
  final String recibira;
  final int recibiraTel;
  final String comentarios;

  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.products,
      @required this.dateTime,
      this.imageUrl,
      @required this.nombres,
      @required this.apellidos,
      @required this.numDistribuidor,
      this.tarjeta,
      this.vencimiento,
      this.cvv,
      this.aplicarA,
      @required this.direccion,
      @required this.recibira,
      @required this.recibiraTel,
      this.comentarios});
}

class AdditionalOrderInfo {
  final String id;
  final String creatorId;
  final String nombres;
  final String apellidos;
  final int numDistribuidor;
  final int tarjeta;
  final String vencimiento;
  final int cvv;
  final int aplicarA;
  final String direccion;
  final String recibira;
  final int recibiraTel;
  final String comentarios;

  AdditionalOrderInfo({
    @required this.id,
    @required this.creatorId,
    @required this.nombres,
    @required this.apellidos,
    @required this.numDistribuidor,
    this.tarjeta,
    this.vencimiento,
    this.cvv,
    this.aplicarA,
    @required this.direccion,
    @required this.recibira,
    @required this.recibiraTel,
    this.comentarios,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://gano-pedidos.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;

    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          imageUrl: orderData['imageUrl'],
          nombres: orderData['nombres'],
          apellidos: orderData['apellidos'],
          numDistribuidor: orderData['numDistribuidor'],
          tarjeta: orderData['tarjeta'],
          vencimiento: orderData['vencimiento'],
          cvv: orderData['cvv'],
          aplicarA: orderData['aplicarA'],
          direccion: orderData['direccion'],
          recibira: orderData['recibira'],
          recibiraTel: orderData['recibiraTel'],
          comentarios: orderData['comentarios'],
          products: (orderData['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title'],
                ),
              )
              .toList(),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total, AdditionalOrderInfo pedido, String email, [File pickedImage]) async {  

    String productos = '';
    String productoActual = '';
    String imageUrl;
    String aplicarA;

    if(pedido.aplicarA != 0 && pedido.aplicarA != null ){//sino se indica el distribuidor se inserta una linea en blanco en el correo
      aplicarA = "Aplicar compra a distribuidor: ${pedido.aplicarA}<br>";      
    } else {
      aplicarA = "<br>";
    }

    cartProducts.forEach((element) {
        productoActual = "${element.title} " + "\$${element.price.toStringAsFixed(2)} X " + "${element.quantity} = " + "\$${(element.price*element.quantity).toStringAsFixed(2)}, <br>";
        productos = productos + productoActual;
     });         

    final url =
        'https://gano-pedidos.firebaseio.com/orders/$userId.json?auth=$authToken';
    final id = Uuid().v1();

    DateTime timestamp = DateTime.now();
    var response;

    if (pedido.tarjeta == 0 && pickedImage != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('/orders/$userId')
          .child('$id.jpg');
      //final ref2 = FirebaseStorage.instance.ref().
      await ref.putFile(pickedImage).onComplete;
      imageUrl = await ref.getDownloadURL();

      response = await http.post(
        url,
        body: json.encode({
          'id': id,
          'creatorId': userId,
          'nombres': pedido.nombres,
          'apellidos': pedido.apellidos,
          'numDistribuidor': pedido.numDistribuidor,
          'imageUrl': imageUrl,
          'aplicarA': pedido.aplicarA,
          'direccion': pedido.direccion,
          'recibira': pedido.recibira,
          'recibiraTel': pedido.recibiraTel,
          'comentarios': pedido.comentarios,
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList(),
        }),
      );

      
    } else {

      if(pedido.tarjeta != 0){
        print('dentro de tarjeta');
        response = await http.post(
        url,
        body: json.encode({
          'id': id,
          'creatorId': userId,
          'nombres': pedido.nombres,
          'apellidos': pedido.apellidos,
          'numDistribuidor': pedido.numDistribuidor,
          'tarjeta': pedido.tarjeta,
          'vencimiento': pedido.vencimiento,
          'cvv': pedido.cvv,
          'aplicarA': pedido.aplicarA,
          'direccion': pedido.direccion,
          'recibira': pedido.recibira,
          'recibiraTel': pedido.recibiraTel,
          'comentarios': pedido.comentarios,
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts.map((cp) => {'id': cp.id,'title': cp.title,'quantity': cp.quantity,'price': cp.price,}).toList(),
        }),
      );

      } else {//sino hay tarjeta ni comprobante de deposito
      //dentro de ni tarjeta ni foto
      print('dentro de ni tarjeta ni foto');
        response = await http.post(
        url,
        body: json.encode({
          'id': id,
          'creatorId': userId,
          'nombres': pedido.nombres,
          'apellidos': pedido.apellidos,
          'numDistribuidor': pedido.numDistribuidor,
          'tarjeta': 0,
          'vencimiento': '',
          'cvv': 0,
          'aplicarA': pedido.aplicarA,
          'direccion': pedido.direccion,
          'recibira': pedido.recibira,
          'recibiraTel': pedido.recibiraTel,
          'comentarios': pedido.comentarios,
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts.map((cp) => {'id': cp.id,'title': cp.title,'quantity': cp.quantity,'price': cp.price,}).toList(),
        }),
      );

      }
      
    }
    _orders.insert(0,OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        dateTime: timestamp,
        products: cartProducts,
        nombres: pedido.nombres,
        apellidos: pedido.apellidos,
        numDistribuidor: pedido.numDistribuidor,
        tarjeta: pedido.tarjeta,
        vencimiento: pedido.vencimiento,
        cvv: pedido.cvv,
        aplicarA: pedido.aplicarA,
        direccion: pedido.aplicarA.toString(),
        recibira: pedido.recibira,
        recibiraTel: pedido.recibiraTel,
      ),
    );    

    var options = new GmailSmtpOptions()
      ..username = 'notificaciones.gano.itouch.sv@gmail.com'
      ..password =
          'villO7164'; // Note: if you have Google's "app specific passwords" enabled,

    var emailTransport = new SmtpTransport(options);

    if(pedido.tarjeta == 0 && pickedImage != null) {// si hay foto pero no datos de tarjeta

    var envelope = new Envelope()
      ..from = 'notificaciones.gano.itouch.sv@gmail.com'
      ..recipients.add('daniel.sanchez@ganoitouch.com.sv')
      //..recipients.add('ovidio.cabeza@gmail.com')
      ..bccRecipients.add('danielsanbo23@gmail.com')
      ..bccRecipients.add('geovanny.moreno@ganoitouch.com.sv')
      ..bccRecipients.add('isis.gonzalez@ganoitouch.com.sv')
      ..bccRecipients.add('luis.perez@ganoitouch.com.sv')      
      ..bccRecipients.add('ovidio.cabeza@gmail.com')
      ..subject =
          '***Notificación de Nuevo Pedido de ${pedido.apellidos}, ${pedido.nombres}***'
      ..attachments.add(new Attachment(file: new File(pickedImage.path)))
      //..text = 'This is a cool email message. Whats up?'      
      ..html =
          '<h2>Se ha ingresado un nuevo pedido por el monto de \$ ${total.toStringAsFixed(2)} </h2><p>Se ha generado un nuevo pedido con la siguiente información:<br>Distribuidor: ${pedido.apellidos}, ${pedido.nombres}<br>Email: $email<br>Número de Distribuidor: ${pedido.numDistribuidor}<br>${aplicarA}Monto total de la transacción: \$${total.toStringAsFixed(2)}<br>Productos:<br> $productos<br><h4>DETALLES DEL PAGO</h4>Ver comprobante de depósito: adjunto<h4>DATOS DE ENVÍO</h4>Direccion de envío: ${pedido.direccion}<br>Persona que recibirá: ${pedido.recibira}<br>Teléfono: ${pedido.recibiraTel}<br>Comentarios: ${pedido.comentarios}</p>';
      
      emailTransport
        .send(envelope)
        .then((envelope) => print('Email sent!'))
        .catchError((e) => print('Error occurred: $e'));
    
    }else{

      if(pedido.tarjeta != 0 && pickedImage == null){//si hay tarjeta

        var envelope = new Envelope()
      ..from = 'notificaciones.gano.itouch.sv@gmail.com'      
      ..recipients.add('daniel.sanchez@ganoitouch.com.sv')
      //..recipients.add('ovidio.cabeza@gmail.com')
      ..bccRecipients.add('danielsanbo23@gmail.com')
      ..bccRecipients.add('geovanny.moreno@ganoitouch.com.sv')
      ..bccRecipients.add('isis.gonzalez@ganoitouch.com.sv')
      ..bccRecipients.add('luis.perez@ganoitouch.com.sv')      
      ..bccRecipients.add('ovidio.cabeza@gmail.com')
      ..subject =
          '***Notificación de Nuevo Pedido de ${pedido.apellidos}, ${pedido.nombres}***'
      //..attachments.add(new Attachment(file: new File('path/to/file')))
      //..text = 'This is a cool email message. Whats up?'      
      ..html =
          '<h2>Se ha ingresado un nuevo pedido por el monto de \$ ${total.toStringAsFixed(2)} </h2><p>Se ha generado un nuevo pedido con la siguiente información:<br>Distribuidor: ${pedido.apellidos}, ${pedido.nombres}<br>Email: $email<br>Número de Distribuidor: ${pedido.numDistribuidor}<br>${aplicarA}Monto total de la transacción: \$${total.toStringAsFixed(2)}<br>Productos:<br> $productos<br><h4>DETALLES DEL PAGO</h4>Número de tarjeta: ${pedido.tarjeta}<br>Fecha de vencimiento: ${pedido.vencimiento}<br>Código de Seguridad: ${pedido.cvv}<h4>DATOS DE ENVÍO</h4>Direccion de envío: ${pedido.direccion}<br>Persona que recibirá: ${pedido.recibira}<br>Teléfono: ${pedido.recibiraTel}<br>Comentarios: ${pedido.comentarios}</p>';

      emailTransport
        .send(envelope)
        .then((envelope) => print('Email sent!'))
        .catchError((e) => print('Error occurred: $e'));

      }
      else {
        
        var envelope = new Envelope()
      ..from = 'notificaciones.gano.itouch.sv@gmail.com'
      ..recipients.add('daniel.sanchez@ganoitouch.com.sv')
      //..recipients.add('ovidio.cabeza@gmail.com')
      ..bccRecipients.add('danielsanbo23@gmail.com')
      ..bccRecipients.add('geovanny.moreno@ganoitouch.com.sv')
      ..bccRecipients.add('isis.gonzalez@ganoitouch.com.sv')
      ..bccRecipients.add('luis.perez@ganoitouch.com.sv')      
      ..bccRecipients.add('ovidio.cabeza@gmail.com')
      ..subject =
          '***Notificación de Nuevo Pedido de ${pedido.apellidos}, ${pedido.nombres}***'
      //..attachments.add(new Attachment(file: new File(pickedImage.path)))
      //..text = 'This is a cool email message. Whats up?'      
      ..html =
          '<h2>Se ha ingresado un nuevo pedido por el monto de \$ ${total.toStringAsFixed(2)} </h2><p>Se ha generado un nuevo pedido con la siguiente información:<br>Distribuidor: ${pedido.apellidos}, ${pedido.nombres}<br>Email: $email<br>Número de Distribuidor: ${pedido.numDistribuidor}<br>${aplicarA}Monto total de la transacción: \$${total.toStringAsFixed(2)}<br>Productos:<br> $productos<br><h4>ESTE DISTRIBUIDOR NO HA INDICADO UN METODO DE PAGO</h4><h4>DATOS DE ENVÍO</h4>Direccion de envío: ${pedido.direccion}<br>Persona que recibirá: ${pedido.recibira}<br>Teléfono: ${pedido.recibiraTel}<br>Comentarios: ${pedido.comentarios}</p>';

      emailTransport
        .send(envelope)
        .then((envelope) => print('Email sent!'))
        .catchError((e) => print('Error occurred: $e'));

      }     
    }          

    notifyListeners();
  }
}
