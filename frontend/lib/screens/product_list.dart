import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import 'edit_product.dart';
import 'add_product.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String? _sortBy = 'none';
  int _visibleCount = 10;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadData() async {
    await Provider.of<ProductProvider>(context, listen: false).fetchProducts();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _visibleCount = 10);
      final keyword = _searchController.text;
      Provider.of<ProductProvider>(context, listen: false).fetchProducts(search: keyword);
    });
  }

  void _sortProducts(String? type) {
    final provider = Provider.of<ProductProvider>(context, listen: false);
    if (type == 'price') {
      provider.products.sort((a, b) => a.price.compareTo(b.price));
    } else if (type == 'stock') {
      provider.products.sort((a, b) => a.stock.compareTo(b.stock));
    }
    setState(() => _sortBy = type);
  }

  Future<void> _confirmDelete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirm == true) {
      await Provider.of<ProductProvider>(context, listen: false).deleteProduct(id);
    }
  }

  Future<void> exportToPdf(List<Product> products) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final status = await Permission.storage.request();
      if (!status.isGranted) return;
    }

    final PdfDocument document = PdfDocument();
    final page = document.pages.add();

    page.graphics.drawString(
      'Product List',
      PdfStandardFont(PdfFontFamily.helvetica, 18),
    );

    double y = 40;
    for (var p in products) {
      page.graphics.drawString(
        '${p.name} - \$${p.price.toStringAsFixed(2)} - Stock: ${p.stock}',
        PdfStandardFont(PdfFontFamily.helvetica, 12),
        bounds: Rect.fromLTWH(0, y, 500, 20),
      );
      y += 20;
    }

    final bytes = await document.save();
    document.dispose();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/products_${DateTime.now().toIso8601String()}.pdf');
    await file.writeAsBytes(bytes, flush: true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ PDF saved to ${file.path}')),
    );

    await OpenFile.open(file.path);
  }

  Future<void> exportToCsv(List<Product> products) async {
    final csvBuffer = StringBuffer();
    csvBuffer.writeln('Product Name,Price,Stock');

    for (var p in products) {
      csvBuffer.writeln('"${p.name}",${p.price},${p.stock}');
    }

    final timestamp = DateTime.now().toIso8601String().split('T').first;
    final fileName = 'products_$timestamp.csv';

    final dir = Platform.isAndroid || Platform.isMacOS
        ? Directory('/storage/emulated/0/Download')
        : await getApplicationDocumentsDirectory();

    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvBuffer.toString());

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ CSV saved to ${file.path}')),
    );

    await OpenFile.open(file.path);
  }

  void shareFile(File file) async {
    await Share.shareFiles([file.path], text: 'Here is your exported file');
  }

  @override
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Product List'),
      actions: [
    DropdownButtonHideUnderline(
  child: DropdownButton<String>(
    value: _sortBy,
    onChanged: _sortProducts,
    icon: const Icon(Icons.sort, color: Colors.white),
    dropdownColor: Colors.white,
    style: const TextStyle(color: Colors.black),
    items: const [
      DropdownMenuItem(
        value: 'none',
        child: Row(
          children: [Icon(Icons.cancel, color: Colors.red), SizedBox(width: 8), Text('No Sort')],
        ),
      ),
      DropdownMenuItem(
        value: 'price',
        child: Row(
          children: [Icon(Icons.attach_money, color: Colors.green), SizedBox(width: 8), Text('Sort by Price')],
        ),
      ),
      DropdownMenuItem(
        value: 'stock',
        child: Row(
          children: [Icon(Icons.storage, color: Colors.orange), SizedBox(width: 8), Text('Sort by Stock')],
        ),
      ),
    ],
  ),
),

        IconButton(
          icon: const Icon(Icons.picture_as_pdf),
          tooltip: "Export PDF",
          onPressed: () {
            final products = Provider.of<ProductProvider>(context, listen: false).products;
            exportToPdf(products);
          },
        ),
        IconButton(
          icon: const Icon(Icons.table_chart),
          tooltip: "Export CSV",
          onPressed: () {
            final products = Provider.of<ProductProvider>(context, listen: false).products;
            exportToCsv(products);
          },
        ),
      ],
    ),
    body: Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final isSearching = _searchController.text.isNotEmpty;
        final displayed = isSearching
            ? provider.products
            : provider.products.take(_visibleCount).toList();

        if (displayed.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.inventory_2_outlined, size: 60, color: Colors.grey),
                const SizedBox(height: 10),
                const Text('No products found'),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    _searchController.clear();
                    _loadData();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Back to full list'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadData,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadData();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scroll) {
                    if (!isSearching &&
                        scroll.metrics.pixels == scroll.metrics.maxScrollExtent &&
                        _visibleCount < provider.products.length) {
                      setState(() {
                        _visibleCount += 10;
                      });
                    }
                    return false;
                  },
                  child: ListView.builder(
                      padding: const EdgeInsets.only(bottom: 100),
                    itemCount: displayed.length,
                    itemBuilder: (context, index) {
                      final product = displayed[index];
                      return Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('\$${product.price}    Stock: ${product.stock}'),
                          trailing: Wrap(
                            spacing: 10,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.orange),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => EditProductScreen(product: product),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(product.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        );
      },
      icon: const Icon(Icons.add),
      label: const Text("Add Product"),
    ),
  );
}
}
