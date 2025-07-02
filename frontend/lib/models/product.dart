class Product {
  final int id;
  final String name;
  final double price;
  final int stock;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });

  // Convert JSON from backend to Product object
factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['PRODUCTID'] ?? 0,
    name: json['PRODUCTNAME'] ?? '',
    price: (json['PRICE'] as num?)?.toDouble() ?? 0.0,
    stock: json['STOCK'] ?? 0,
  );
}


  // Convert Product object to JSON (for POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'PRODUCTNAME': name,
      'PRICE': price,
      'STOCK': stock,
    };
  }
}
