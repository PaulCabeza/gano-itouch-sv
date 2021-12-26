import 'package:flutter/material.dart';
import '../screens/user_information_screen.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';
import '../providers/user.dart';
import '../main.dart';
import '../screens/checkout_screen.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    Provider.of<Cart>(context).cajas = 0;

    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi pedido'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        color:
                            Theme.of(context).primaryTextTheme.bodyText1.color,
                      ),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  /*Consumer<Cart>(
                    builder: (_, cartt, child) => FlatButton(  
                      child: Text('SIGUIENTE'),
                      onPressed: (){ 
                        (cartt.totalAmount <= 0) ? null : Navigator.of(context).pushNamed(CheckOut.routeName);
                        },
                       //
                      //() {Navigator.of(context).pushNamed(CartScreen.routeName);},
                    ),
                  ),*/
                  OrderButton(cart: cart),
                ],
              ),
            ),
          ),
          Card(
            margin: EdgeInsets.symmetric(horizontal: 15),
            child: Padding(
              padding: EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    child: Expanded(
                      child: Text(
                        'El precio base del envío es \$ 4.00 hasta 20 cajas, de 21 cajas en delante se cobrará \$ 0.18 por cada caja extra.',
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  ),                  
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (ctx, i) => CartItem(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title,
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  _OrderButtonState createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: _isLoading ? CircularProgressIndicator() : Text('SIGUIENTE'),
      onPressed: () {
        (widget.cart.totalAmount <= 0 || _isLoading)
            ? null
            : Navigator.of(context).pushNamed(CheckOut.routeName);
        //fin del if
      },
      textColor: Theme.of(context).primaryColor,
    );
  }
}
