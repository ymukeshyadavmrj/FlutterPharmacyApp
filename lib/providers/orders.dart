import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final int quantity;
  final DateTime dateTime;
  final int order_status;

  OrderItem({
    @required this.id,
    @required this.quantity,
    @required this.dateTime,
    @required this.order_status,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchById(String id) async{

  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://ymukeshyadavmrj.pythonanywhere.com/orders/';
    final response = await http.get(url,headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken',
    });
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as List<dynamic>;
    print("$extractedData==========In the Order===================================");
    if (extractedData == null) {
      return;
    }
    extractedData.forEach(( orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderData['product'],
          dateTime:  DateTime.parse(orderData['dateTime']),
          quantity: orderData['quantity'],
          order_status: orderData['order_status']
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://ymukeshyadavmrj.pythonanywhere.com/orders/';
    final timestamp = DateTime.now();
    cartProducts.forEach((cp) async {
      final response = await http.post(
        url,headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $authToken',
    },
        body: json.encode({
          'dateTime': timestamp.toIso8601String(),
          'product': cp.id,
          'quantity': cp.quantity,
          'order_status': 0,
        }),
      );
      _orders.add(
        OrderItem(
          id: cp.id,
          dateTime: timestamp,
          quantity: cp.quantity,
          order_status: 0,
        ),
      );
    });

    notifyListeners();
  }
}
