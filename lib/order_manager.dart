import 'dart:convert';
import 'dart:io';

import 'order.dart';

/// Handles loading, storing, searching, adding, and deleting orders.
class OrderManager {
  final List<Order> orders = [];

  static const String initialJson = '''
[
  {
    "Item": "A1000",
    "ItemName": "Iphone 15",
    "Price": 1200,
    "Currency": "USD",
    "Quantity": 1
  },
  {
    "Item": "A1001",
    "ItemName": "Iphone 16",
    "Price": 1500,
    "Currency": "USD",
    "Quantity": 1
  }
]
''';

  final String dataFilePath =
      '${Directory.current.path}${Platform.pathSeparator}order.json';

  /// Loads order.json when it exists; otherwise loads the exam JSON string
  /// and creates order.json from it.
  Future<void> initialize() async {
    final file = File(dataFilePath);

    if (await file.exists()) {
      final content = await file.readAsString();
      if (content.trim().isNotEmpty) {
        _loadFromJsonString(content);
        return;
      }
    }

    _loadFromJsonString(initialJson);
    await saveToFile();
  }

  /// Decodes a JSON string and stores the resulting objects in [orders].
  void _loadFromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      throw const FormatException('The JSON root must be a list of orders.');
    }

    orders
      ..clear()
      ..addAll(decoded.map((entry) {
        if (entry is! Map<String, dynamic>) {
          throw const FormatException('Each order must be a JSON object.');
        }
        return Order.fromJson(entry);
      }));
  }

  List<Order> getAllOrders() => List.unmodifiable(orders);

  List<Order> searchByItemName(String keyword) {
    final normalized = keyword.trim().toLowerCase();
    if (normalized.isEmpty) return getAllOrders();

    return orders
        .where((order) => order.itemName.toLowerCase().contains(normalized))
        .toList();
  }

  String? validate(Order order) {
    if (order.item.trim().isEmpty) return 'Item code is required.';
    if (order.itemName.trim().isEmpty) return 'Item name is required.';
    if (order.price <= 0) return 'Price must be greater than zero.';
    if (order.quantity <= 0) return 'Quantity must be greater than zero.';
    if (order.currency.trim().isEmpty) return 'Currency is required.';
    if (orders.any((o) => o.item.toLowerCase() == order.item.toLowerCase())) {
      return 'An order with this item code already exists.';
    }
    return null;
  }

  Future<void> addOrder(Order order) async {
    orders.add(order);
    try {
      await saveToFile();
    } catch (_) {
      orders.removeLast();
      rethrow;
    }
  }

  Future<bool> deleteOrder(String itemCode) async {
    final index = orders.indexWhere(
      (order) => order.item.toLowerCase() == itemCode.toLowerCase(),
    );
    if (index == -1) return false;

    final removed = orders.removeAt(index);
    try {
      await saveToFile();
      return true;
    } catch (_) {
      orders.insert(index, removed);
      rethrow;
    }
  }

  /// Writes the current order list to order.json in JSON format.
  Future<void> saveToFile() async {
    final file = File(dataFilePath);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(
      '${encoder.convert(orders.map((order) => order.toJson()).toList())}\n',
      flush: true,
    );
  }
}
