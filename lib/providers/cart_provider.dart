import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/product.dart';
import '../models/cart_item.dart';
import '../utils/database_helper.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];
  Order? _lastOrder;
  static const double _taxRate = 0.0;

  List<CartItem> get items => List.unmodifiable(_items);
  Order? get lastOrder => _lastOrder;
  bool get isEmpty => _items.isEmpty;
  int get totalCount => _items.fold(0, (sum, i) => sum + i.quantity);

  double get subtotal => _items.fold(0.0, (sum, i) => sum + i.subtotal);
  double get tax => subtotal * _taxRate;
  double get total => subtotal + tax;

  void addProduct(Product product) {
    final index = _items.indexWhere((i) => i.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  void removeProduct(String productId) {
    _items.removeWhere((i) => i.product.id == productId);
    notifyListeners();
  }

  void increment(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  void decrement(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity <= 1) {
        _items.removeAt(index);
      } else {
        _items[index].quantity--;
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  int quantityOf(String productId) {
    final index = _items.indexWhere((i) => i.product.id == productId);
    return index >= 0 ? _items[index].quantity : 0;
  }

  Order createOrder(String paymentMethod) {
    final order = Order.fromCart(
      id: const Uuid().v4().substring(0, 8).toUpperCase(),
      items: _items,
      paymentMethod: paymentMethod,
      taxRate: _taxRate,
    );
    _lastOrder = order;
    return order;
  }

  Future<void> confirmPayment() async {
    if (_lastOrder != null) {
      // Persist order to DB
      await DatabaseHelper.instance.insertOrder(_lastOrder!);
      // Deduct stock for each sold item
      for (final item in _lastOrder!.items) {
        await DatabaseHelper.instance.deductStock(
            item.product.id, item.quantity);
      }
    }
    _lastOrder?.isPaid = true;
    clear();
    notifyListeners();
  }
}
