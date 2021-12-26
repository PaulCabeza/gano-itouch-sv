import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
 
/*   if (title == "ESP3") {
     cajas = quantity * 43;
     print(cajas);          
   }*/
   
  

  CartItem(
    this.id,
    this.productId,
    this.price,
    this.quantity,
    this.title,
  );



  @override
  Widget build(BuildContext context) {

    /*if(Provider.of<Cart>(context).cajas==null){
      Provider.of<Cart>(context).cajas = 0;
    }

    if (title == "ESP3") {
     Provider.of<Cart>(context).cajas += quantity * 43;
     print(Provider.of<Cart>(context).cajas);          
   }
   if(title=='ESP2'){
     Provider.of<Cart>(context).cajas += quantity * 20;
     print(Provider.of<Cart>(context).cajas);
   }
   if(title=='ESP1'){
     Provider.of<Cart>(context).cajas += quantity * 8;
     print(Provider.of<Cart>(context).cajas);
   }
   if(title=='3 en 1'){
     Provider.of<Cart>(context).cajas += quantity * 1;
     print(Provider.of<Cart>(context).cajas);
   }
   if(title=='Classic'){
     Provider.of<Cart>(context).cajas += quantity * 1;
     print(Provider.of<Cart>(context).cajas);
   }
   if(title=='Hazelnut'){
     Provider.of<Cart>(context).cajas += quantity * 1;
     print(Provider.of<Cart>(context).cajas);
   }
   if(title=='Schokol'){
     Provider.of<Cart>(context).cajas += quantity * 1;
     print(Provider.of<Cart>(context).cajas);
   }*/

    return Dismissible(
      key: ValueKey(id),
      background: Container(
        color: Theme.of(context).errorColor,
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
                title: Text('Estas seguro?'),
                content: Text(
                  'Quieres eliminar el producto de tu pedido?',
                ),
                actions: <Widget>[
                  FlatButton(
                    child: Text('No'),
                    onPressed: () {
                      Navigator.of(ctx).pop(false);
                    },
                  ),
                  FlatButton(
                    child: Text('Si'),
                    onPressed: () {
                      Navigator.of(ctx).pop(true);
                    },
                  ),
                ],
              ),
        );
      },
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      
      child: Card(
        margin: EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding(
          padding: EdgeInsets.all(8),          
          child:           
          ListTile(
            leading: CircleAvatar(
              child: Padding(
                padding: EdgeInsets.all(5),
                child: FittedBox(
                  child: Text('\$$price'),
                ),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity).toStringAsFixed(2)}'),
            trailing: Text('x $quantity'),
          ),
        ),
      ),
    );
  }
}
