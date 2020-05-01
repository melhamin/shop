import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/edit_product_screen.dart';
import '../providers/products.dart';

class UserProductItem extends StatelessWidget {
  final String id;
  final String title;
  final String imageURL;

  UserProductItem({this.id, this.title, this.imageURL});

  // void showRemoveItemDialog(BuildContext context) {
  //   // bool res = false;
  //   showDialog(
  //     context: context,
  //     builder: (ctx) => AlertDialog(
  //       title: Text('Warning!'),
  //       content: Text('Delete item?'),
  //       actions: <Widget>[
  //         FlatButton(
  //           child: Text('Yes'),
  //           onPressed: () {
  //             res = true;
  //             // print('show: res = $res');
  //             Navigator.of(context).pop(true);
  //             // return true;
  //           },
  //         ),
  //         FlatButton(
  //           child: Text('No'),
  //           onPressed: () {
  //             res = false;
  //             Navigator.of(context).pop(false);
  //             // return false;
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  //   // print('show: res = $res');
  //   // return res;
  // }

  // Future<void> removeItem(BuildContext context, dynamic scaffold) async {
  //   showRemoveItemDialog(context);
  //   print('in remove: res = $res');
  //   if (res) {
  //     print('in res');
  //     try {
  //       await Provider.of<Products>(context, listen: false).remove(id);
  //     } catch (error) {
  //       scaffold.removeCurrentSnackBar();
  //       scaffold.showSnackBar(SnackBar(
  //         content: Text('Oops! deletion failed.'),
  //       ));
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return ListTile(
      title: Text(title),
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imageURL),
      ),
      trailing: Container(
        width: 100,
        child: Row(
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context)
                    .pushNamed(EditProductScreen.routeName, arguments: id);
              },
              color: Theme.of(context).primaryColor,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                try {
                  await Provider.of<Products>(context, listen: false)
                      .remove(id);
                } catch (error) {
                  scaffold.removeCurrentSnackBar();
                  scaffold.showSnackBar(SnackBar(
                    content: Text('Oops! deletion failed.'),
                  ));
                }
              },
              color: Theme.of(context).errorColor,
            )
          ],
        ),
      ),
    );
  }
}

/*
async {
                try {
                await Provider.of<Products>(context, listen: false).remove(id);
                } catch (error) {                  
                  scaffold.removeCurrentSnackBar();
                  scaffold.showSnackBar(SnackBar(
                    content: Text('Oops! deletion failed.'),
                  ));
                }
              },*/
