/// Represents one order in the Order Management application.
class Order {
  final String item;
  final String itemName;
  final double price;
  final String currency;
  final int quantity;

  const Order({
    required this.item,
    required this.itemName,
    required this.price,
    required this.currency,
    required this.quantity,
  });

  /// Creates an Order object from a decoded JSON map.
  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      item: (json['Item'] ?? '').toString(),
      itemName: (json['ItemName'] ?? '').toString(),
      price: _toDouble(json['Price']),
      currency: (json['Currency'] ?? 'USD').toString(),
      quantity: _toInt(json['Quantity']),
    );
  }

  /// Converts this Order object into the exam's required JSON structure.
  Map<String, dynamic> toJson() {
    return {
      'Item': item,
      'ItemName': itemName,
      'Price': price,
      'Currency': currency,
      'Quantity': quantity,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
