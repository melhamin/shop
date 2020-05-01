import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';
import '../models/http_exception.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime date;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.date,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userID;
  Orders(this.authToken, this._orders, this.userID);

  static const databaseURL = 'https://flutter-shopapp-8a17f.firebaseio.com/';

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> add(List<CartItem> cartProducts, double total) async {
    final url = '$databaseURL/orders/$userID.json?auth=$authToken';
    final timeStamp = DateTime.now();
    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'amount': total,
            'date': timeStamp.toIso8601String(),
            'products': cartProducts
                .map((item) => {
                      'id': item.id,
                      'title': item.title,
                      'quantity': item.quantity,
                      'price': item.price,
                    })
                .toList(),            
          },
        ),
      );
      _orders.insert(
        0,
        OrderItem(
          id: json.decode(response.body)['name'],
          amount: total,
          date: timeStamp,
          products: cartProducts,
        ),
      );
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSelectData() async {
    final url = '$databaseURL/orders/$userID.json?auth=$authToken';
    final response = await http.get(url);
    final loadedData = json.decode(response.body) as Map<String, dynamic>;
    final List<OrderItem> loadedOrders = [];

    if (loadedData == null) return;

    loadedData.forEach((orderID, orderData) {
      loadedOrders.add(OrderItem(
        id: orderID,
        amount: orderData['amount'],
        date: DateTime.parse(orderData['date']),
        products: (orderData['products'] as List<dynamic>)
            .map(
              (item) => CartItem(
                id: item['id'],
                price: item['price'],
                quantity: item['quantity'],
                title: item['title'],
              ),
            )
            .toList(),
      ));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    final url = '$databaseURL/orders/$userID/$id.json?auth=$authToken';
    final existingOrderIndex = _orders.indexWhere((order) => order.id == id);
    final existingOrder = _orders.elementAt(existingOrderIndex);

    _orders.removeAt(existingOrderIndex);
    notifyListeners();

    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _orders.insert(existingOrderIndex, existingOrder);
      notifyListeners();
      throw HttpException('Oops! something went wrong.');
    }
  }

  void clear() {
    _orders = [];
    notifyListeners();
  }
}
