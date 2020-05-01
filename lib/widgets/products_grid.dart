import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final  bool showFavoritesOnly;
  ProductsGrid(this.showFavoritesOnly);
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products = showFavoritesOnly ? productsData.favoriteItems : productsData.items;
    return GridView.builder(      
      padding: const EdgeInsets.all(10),
      itemCount: products.length, 
      itemBuilder: (context, index) {        
        return ChangeNotifierProvider.value(
          // builder: (ctx) => products[index],          
          value: products[index],
          child: ProductItem(            
            // id: item.id,
            // title: item.title,
            // imageURL: item.imageURL,
          ),
        );
      },
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
