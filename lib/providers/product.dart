import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token) async {
    isFavorite = !isFavorite;
    notifyListeners();
    final url = 'https://ymukeshyadavmrj.pythonanywhere.com/favourites/$id';
    final response = await http.patch(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(
        {
          'isFavourite': isFavorite,
        },
      ),
    ) ;
    Map<String,dynamic> extractedData = json.decode(response.body) as Map<String,dynamic>;
    print(extractedData['Message']);
    print("checking=============================");
    if (extractedData['Message'] == 'failed') {
      final response2 = await http.post(
        url,
        body: json.encode(
          {
            'isFavourite': isFavorite,
          },
        ),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
extractedData = json.decode(response2.body) as Map<String,dynamic>;
    }
    print(extractedData['Message']);
  }
}
