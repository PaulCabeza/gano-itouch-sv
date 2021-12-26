import 'package:flutter/material.dart';
import './screens/checkout_screen.dart';
import 'package:provider/provider.dart';

import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/product_detail_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';
import './providers/user.dart';
import './screens/orders_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/user_information_screen.dart';
import './screens/order_detail.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {  
  
  @override
  Widget build(BuildContext context) {    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(


          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, Products>(          
          update: (ctx, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items,
              ),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProxyProvider<Auth, Orders>(
          update: (ctx, auth, previousOrders) => Orders(
                auth.token,
                auth.userId,
                previousOrders == null ? [] : previousOrders.orders,
              ),
        ),
        ChangeNotifierProxyProvider<Auth, Users>(          
          update: (ctx, auth, previousUsers) => Users(
                auth.token,
                auth.userId,
                previousUsers == null ? [] : previousUsers.users,
              ),
        ),
      ],      
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
              title: 'Mi Gano Itouch',
              theme: ThemeData(
                primarySwatch: Colors.purple,
                accentColor: Colors.deepOrange,
                fontFamily: 'Lato',
              ),
              home: auth.isAuth
                  ? ProductsOverviewScreen()
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? SplashScreen()
                              : AuthScreen(),
                    ),
              routes: {
                ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
                CartScreen.routeName: (ctx) => CartScreen(),
                OrdersScreen.routeName: (ctx) => OrdersScreen(),
                UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
                EditProductScreen.routeName: (ctx) => EditProductScreen(),
                UserInformation.routeName: (ctx) => UserInformation(),
                CheckOut.routeName: (ctx) => CheckOut(),                
                OrderDetail.routeName: (ctx) => OrderDetail(),
              },
            ),
      ),
    );
  }
}
