import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/user_products_screen.dart';
import '../screens/orders_screen.dart';
import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  List<Widget> buildListTiles(
      String title, IconData icon, Function tapHandler) {
    return [
      ListTile(
        leading: Icon(
          icon,
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        onTap: tapHandler,
      ),
      Divider(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          AppBar(
            title: Text('Shopii'),
            automaticallyImplyLeading: false,
          ),
          ...buildListTiles('Shop', Icons.shop, () {
            Navigator.of(context).pushReplacementNamed('/');
          }),
          ...buildListTiles('Orders', Icons.payment, () {
            Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
          }),
          ...buildListTiles('Manage Products', Icons.edit, () {
            Navigator.of(context)
                .pushReplacementNamed(UserProductsScreen.routeName);
          }),
          ...buildListTiles('Logout', Icons.exit_to_app, () {
            Navigator.of(context).pop();
            Provider.of<Auth>(context, listen: false).logout();
          })
        ],
      ),
    );
  }
}
