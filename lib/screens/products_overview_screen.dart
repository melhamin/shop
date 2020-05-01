import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products.dart';
import '../widgets/app_drawer.dart';
import '../widgets/badge.dart.dart';
import '../widgets/products_grid.dart';
import '../screens/cart_screen.dart';

enum PopUpOptions {
  Favorites,
  All,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showFavoriteOnly = false;
  var _isInitLoaded = true;
  var _isFetchingData = false;

  // @override
  // void initState() {
  //   // fetch data from firebase
  //   // this approach would work only if listen is set to false
  //   // Provider.of<Products>(context, listen: false).fetchAndSelectData();

  //   // Another approach
  //   Future.delayed(Duration.zero).then((_) {
  //     Provider.of<Products>(context).fetchAndSelectData();
  //   });
  //   super.initState();
  // }

  @override
  void didChangeDependencies() {
    // another approach to fetch data from firebase
    if (_isInitLoaded) {
      setState(() {
        _isFetchingData = true;
      });
      Provider.of<Products>(context).fetchAndSelectData().then((_) {
        setState(() {
          _isFetchingData = false;
        });
      });
    }
    _isInitLoaded = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (PopUpOptions selectedValue) {
              setState(() {
                if (selectedValue == PopUpOptions.All) {
                  _showFavoriteOnly = false;
                } else if (selectedValue == PopUpOptions.Favorites) {
                  _showFavoriteOnly = true;
                }
              });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Show Favorites'),
                value: PopUpOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: PopUpOptions.All,
              ),
            ],
          ),
          Consumer<Cart>(
            builder: (ctx, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
        ],
      ),
      drawer: AppDrawer(),
      body: _isFetchingData
          ? Center(child: CircularProgressIndicator())
          : ProductsGrid(_showFavoriteOnly),
    );
  }
}
