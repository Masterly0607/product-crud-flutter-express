import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../models/product.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  bool isLoading = false;

  List<Product> get products => _products;

  final String _baseUrl = 'http://localhost:3000/products';

  // Fetch all products (optionally with search)
  Future<void> fetchProducts({String? search}) async {
    isLoading = true;
    notifyListeners();
    try {
      final url = search != null && search.isNotEmpty
          ? '$_baseUrl?search=$search'
          : _baseUrl;

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
      }
    } catch (e) {
      print('Fetch error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  // Add new product and insert to top
  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      final newProduct = Product.fromJson(data);

      _products.insert(0, newProduct); // Add to top
      notifyListeners();
    }
  }

  // Update product and move to top
  Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/${product.id}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final updated = Product.fromJson(data);

      _products.removeWhere((p) => p.id == updated.id);
      _products.insert(0, updated); // Move to top
      notifyListeners();
    }
  }

  // Delete product
  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse('$_baseUrl/$id'));
    if (response.statusCode == 200) {
      _products.removeWhere((p) => p.id == id);
      notifyListeners();
    }
  }
}
