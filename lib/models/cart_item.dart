import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  String? note;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.note,
  });

  double get subtotal => product.price * quantity;

  CartItem copyWith({int? quantity, String? note}) {
    return CartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final DateTime createdAt;
  final double subtotal;
  final double tax;
  final double total;
  final String paymentMethod;
  bool isPaid;

  Order({
    required this.id,
    required this.items,
    required this.createdAt,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.paymentMethod,
    this.isPaid = false,
  });

  factory Order.fromCart({
    required String id,
    required List<CartItem> items,
    required String paymentMethod,
    double taxRate = 0.0,
  }) {
    final subtotal = items.fold(0.0, (sum, i) => sum + i.subtotal);
    final tax = subtotal * taxRate;
    return Order(
      id: id,
      items: List.from(items),
      createdAt: DateTime.now(),
      subtotal: subtotal,
      tax: tax,
      total: subtotal + tax,
      paymentMethod: paymentMethod,
    );
  }
}

// Lightweight model for reading saved orders back from DB
class OrderRecord {
  final String id;
  final double total;
  final String paymentMethod;
  final DateTime createdAt;

  const OrderRecord({
    required this.id,
    required this.total,
    required this.paymentMethod,
    required this.createdAt,
  });
}
