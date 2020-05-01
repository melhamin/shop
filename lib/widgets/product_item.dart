import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:toast/toast.dart';

import '../providers/cart.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageURL;

  // ProductItem({
  //   this.id,
  //   this.title,
  //   this.imageURL,
  // });

  // void showToastMessage(BuildContext context, String message) {
  //   Toast.show(
  //     message,
  //     context,
  //     duration: Toast.LENGTH_LONG,
  //     gravity: Toast.BOTTOM,
  //     backgroundColor: Colors.grey,
  //     textColor: Colors.white,
  //   );
  // }

  SnackBar showSnackBar(Cart cart, Product product) {
    return SnackBar(
      content: Text(
        'Added item to cart!',
      ),
      action: SnackBarAction(
        label: 'UNDO',
        onPressed: () {
          cart.removeSingleItem(product.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    final scaffold = Scaffold.of(context);
    final authData = Provider.of<Auth>(context);
    return ClipRRect(    
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(          
          onTap: () {
            Navigator.of(context).pushNamed(
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          child: Hero(
            tag: product.id,
            child: Image.network(
              product.imageURL,
              fit: BoxFit.cover,
            ),
          ),
        ),
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: Consumer<Product>(
            builder: (ctx, product, child) => IconButton(
              icon: Icon(
                product.isFavorite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: () async {
                try {
                  await product.toggleFavoriteStatus(
                      authData.token, authData.userID);
                } catch (error) {
                  scaffold.removeCurrentSnackBar();
                  scaffold.showSnackBar(SnackBar(
                    content: Text('Oops! something went wrong.'),
                  ));
                }
                // product.isFavorite
                //     ? showToastMessage(context, 'Added to favorites')
                //     : showToastMessage(context, 'Removed from favorites');
              },
              color: Theme.of(context).accentColor,
            ),
          ),
          title: Center(
            child: Text(product.title),
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.title, product.price);
              // showToastMessage(context, 'Added item to cart');
              Scaffold.of(context).removeCurrentSnackBar();
              Scaffold.of(context).showSnackBar(showSnackBar(cart, product));
            },
            color: Theme.of(context).accentColor,
          ),
        ),
      ),
    );
  }
}
