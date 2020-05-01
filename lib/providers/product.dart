import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageURL;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageURL,
    this.isFavorite = false,
  });

  static const databaseURL = 'https://flutter-shopapp-8a17f.firebaseio.com'; 

  Future<void> toggleFavoriteStatus(String token, userID) async {
    var url =
        '$databaseURL/userFavorites/$userID/$id.json?auth=$token';
    isFavorite = !isFavorite;
    notifyListeners();
    final response = await http.put(
      url,
      body: json.encode(
        isFavorite,
      ),
    );
    print(response.statusCode);
    if (response.statusCode >= 400) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw HttpException('Oops! something went wrong.');
    }
  }
}
