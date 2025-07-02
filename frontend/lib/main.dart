import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/product_provider.dart';
import 'screens/product_list.dart';
import 'screens/add_product.dart';
import 'screens/edit_product.dart';
import 'models/product.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProductProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Product CRUD',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        routes: {
          '/': (context) => const ProductListScreen(),
          '/add': (context) => const AddProductScreen(),
        },
        // dynamic route for edit
        onGenerateRoute: (settings) {
          if (settings.name == '/edit') {
            final product = settings.arguments as Product;
            return MaterialPageRoute(
              builder: (_) => EditProductScreen(product: product),
            );
          }
          return null;
        },
      ),
    );
  }
}
