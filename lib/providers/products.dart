import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import './product.dart';
import '../models/http_exception.dart';

class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageURL:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageURL:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageURL:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageURL:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String authToken;
  final String userID;
  Products(this.authToken, this._items, this.userID);

  static const databaseURL = 'https://flutter-shopapp-8a17f.firebaseio.com';

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((product) => product.isFavorite).toList();
  }

  Product findByID(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> fetchAndSelectData([bool filter = false]) async {
    String filterString = filter ? 'orderBy="creatorID"&equalTo="$userID"' : '';
    var url = '$databaseURL/products.json?auth=$authToken&$filterString';
    // print('URL ----> $url');
    try {
      final response = await http.get(url);
      final loadedData = json.decode(response.body) as Map<String, dynamic>;
      print('--------------------------------\n$loadedData');
      final List<Product> loadedList = [];

      print('loadedData : $loadedData');

      url = '$databaseURL/userFavorites/$userID.json?auth=$authToken';
      final favoritesResponse = await http.get(url);
      final responseData = json.decode(favoritesResponse.body);
      print('responseData: $responseData');

      if (loadedData == null) return;

      loadedData.forEach((productID, productData) {
        loadedList.add(Product(
          id: productID,
          title: productData['title'],
          price: productData['price'],
          description: productData['description'],
          imageURL: productData['imageURL'],
          isFavorite:
              responseData == null ? false : responseData[productID] ?? false,
        ));
      });
      _items = loadedList;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> add(Product product) async {
    final url = '$databaseURL/products.json?auth=$authToken';
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'title': product.title,
            'price': product.price,
            'description': product.description,
            'imageURL': product.imageURL,
            'creatorID': userID,
          },
        ),
      );
      final newProduct = Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        price: product.price,
        description: product.description,
        imageURL: product.imageURL,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> update(String id, Product newProduct) async {
    final oldIndex = _items.indexWhere((product) => product.id == id);
    if (oldIndex >= 0) {
      final url = '$databaseURL/products/$id.json?auth=$authToken';
      http.patch(url,
          body: json.encode({
            'id': id,
            'title': newProduct.title,
            'price': newProduct.price,
            'description': newProduct.description,
            'imageURL': newProduct.imageURL,
          }));
      _items[oldIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> remove(String id) async {
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items.elementAt(existingProductIndex);
    _items.removeAt(existingProductIndex);
    notifyListeners();

    final url = '$databaseURL/products/$id.json?auth=$authToken';
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Error deleting item.');
    }
    existingProduct = null;
  }
}
