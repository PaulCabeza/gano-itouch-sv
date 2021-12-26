import 'dart:math';

import 'package:flutter/material.dart';
import '../screens/order_detail.dart';
import 'package:intl/intl.dart';

import '../providers/orders.dart' as ord;

class OrderItem extends StatefulWidget {
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  //var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(
                '\$${widget.order.amount.toStringAsFixed(2)}\n ${DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)} '),
            subtitle: Text(
              "${DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime)} \n ",
            ),
            trailing: FlatButton(
                onPressed: () {                  
                  Navigator.of(context).pushNamed(OrderDetail.routeName, arguments: widget.order);
            },
                  /*showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text('Titulo de la ventana'),
                      content: 
                      SingleChildScrollView(
              //padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              //height: min(widget.order.products.length * 20.0 + 100, 180),
              child: ListView(
                children: widget.order.products
                    .map(
                      (prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                prod.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${prod.quantity} x \$${prod.price}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                    )
                    .toList(),
                                        
              ),             
            )
                      ,
                      actions: <Widget>[
                        FlatButton(
                          child: Text('Okay'),
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                        )
                      ],
                    ),
                  );*/
                
                child: Text(
                  'Detalles',
                  style: TextStyle(color: Theme.of(context).accentColor),
                )),
            /*IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },*/
          ),
          /*if (_expanded)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: min(widget.order.products.length * 20.0 + 10, 100),
              child: ListView(
                children: widget.order.products
                    .map(
                      (prod) => Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                prod.title,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${prod.quantity} x \$${prod.price}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                    )
                    .toList(),                    
              ),             
            )*/
        ],
      ),
    );
  }
}
