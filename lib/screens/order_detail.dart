import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderDetail extends StatelessWidget {
  static const routeName = '/order-detail';
  //final ord.OrderItem order;
  //OrderDetail(this.order);

  @override
  Widget build(BuildContext context) {
    final ord.OrderItem order = ModalRoute.of(context).settings.arguments;
    print(order.aplicarA);

    return Scaffold(
      appBar: AppBar(
        title: Text('Detalles de mi pedido'),
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (order.imageUrl != null)
                Container(
                  //height: 00,
                  width: double.infinity,
                  child: Image.network(
                    order.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              if (order.imageUrl == null)
                Card(
                  margin: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      child: Text(
                        'Método de pago: Tarjeta de débito/crédito\nTarjeta número: *************${order.tarjeta.toString().substring(13)}',
                        //textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16),
                        //softWrap: true,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      child: Text(
                        'Vencimiento: ${order.vencimiento}',
                        //textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 16),
                        //softWrap: true,
                      ),
                    ),
                    SizedBox(height: 4),
                  ]),
                ),
              Card(
                margin: EdgeInsets.all(10),
                child: Column(children: <Widget>[
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    child: Text(
                      'Monto:  \$ ${order.amount.toStringAsFixed(2)}\nProductos:',
                      //textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 16),
                      //softWrap: true,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    height: min(order.products.length * 50.0 + 10, 120),
                    child: ListView(
                      children: order.products
                          .map(
                            (prod) => Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  '${prod.title}  ->  ${prod.quantity} x \$${prod.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    //color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ]),
              ),
              SizedBox(
                height: 4,
              ),
              SizedBox(height: 4),
              Card(
                  margin: EdgeInsets.all(10),
                  child: Column(children: <Widget>[
                    if (order.aplicarA != null && order.aplicarA != 0)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        width: double.infinity,
                        child: Text(
                          'Aplicar compra a: ${order.aplicarA}',
                          textAlign: TextAlign.left,
                          style: TextStyle(fontSize: 16),
                          softWrap: true,
                        ),
                      ),
                      SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      width: double.infinity,
                      //width: double.infinity,
                      child: Text(
                        'Dirección:  ${order.direccion}',
                        //textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                        softWrap: true,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      //width: double.infinity,
                      child: Text(
                        'Persona que recibirá y teléfono:  ${order.recibira}(${order.recibiraTel})',
                        //textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                        softWrap: true,
                      ),
                    ),
                    SizedBox(height: 10),
                  ])),
            ],
          ),
        ),
      ),
    );
  }
}
