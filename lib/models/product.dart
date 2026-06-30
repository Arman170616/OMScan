import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

enum ProductCategory {
  all,
  food,
  beverages,
  snacks,
  electronics,
  clothing,
  health,
}

extension ProductCategoryExt on ProductCategory {
  String get label {
    switch (this) {
      case ProductCategory.all:         return 'All';
      case ProductCategory.food:        return 'Food';
      case ProductCategory.beverages:   return 'Drinks';
      case ProductCategory.snacks:      return 'Snacks';
      case ProductCategory.electronics: return 'Electronics';
      case ProductCategory.clothing:    return 'Clothing';
      case ProductCategory.health:      return 'Health';
    }
  }

  String get labelAr {
    switch (this) {
      case ProductCategory.all:         return 'الكل';
      case ProductCategory.food:        return 'طعام';
      case ProductCategory.beverages:   return 'مشروبات';
      case ProductCategory.snacks:      return 'وجبات خفيفة';
      case ProductCategory.electronics: return 'إلكترونيات';
      case ProductCategory.clothing:    return 'ملابس';
      case ProductCategory.health:      return 'صحة';
    }
  }

  String localLabel(bool ar) => ar ? labelAr : label;

  IconData get icon {
    switch (this) {
      case ProductCategory.all:        return Icons.grid_view_rounded;
      case ProductCategory.food:       return Icons.restaurant_rounded;
      case ProductCategory.beverages:  return Icons.local_cafe_rounded;
      case ProductCategory.snacks:     return Icons.cookie_rounded;
      case ProductCategory.electronics:return Icons.devices_rounded;
      case ProductCategory.clothing:   return Icons.checkroom_rounded;
      case ProductCategory.health:     return Icons.health_and_safety_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ProductCategory.all:        return const Color(0xFF1D4ED8);
      case ProductCategory.food:       return const Color(0xFFDC2626);
      case ProductCategory.beverages:  return const Color(0xFF059669);
      case ProductCategory.snacks:     return const Color(0xFFF59E0B);
      case ProductCategory.electronics:return const Color(0xFF0891B2);
      case ProductCategory.clothing:   return const Color(0xFFDB2777);
      case ProductCategory.health:     return const Color(0xFF16A34A);
    }
  }
}

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final ProductCategory category;
  final String emoji;
  final int stock;
  final bool isFeatured;
  final String? barcode;

  const Product({
    required this.id,
    required this.name,
    this.description = '',
    required this.price,
    this.category = ProductCategory.all,
    this.emoji = '📦',
    this.stock = 100,
    this.isFeatured = false,
    this.barcode,
  });

  // Create a new product with a generated ID
  factory Product.create({
    required String name,
    required double price,
    String description = '',
    ProductCategory category = ProductCategory.all,
    String emoji = '📦',
    String? barcode,
    int initialStock = 0,
  }) {
    return Product(
      id: const Uuid().v4(),
      name: name,
      description: description,
      price: price,
      category: category,
      emoji: emoji,
      barcode: barcode,
      stock: initialStock,
    );
  }

  Product copyWith({
    String? name,
    String? description,
    double? price,
    ProductCategory? category,
    String? emoji,
    String? barcode,
    int? stock,
  }) {
    return Product(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      emoji: emoji ?? this.emoji,
      stock: stock ?? this.stock,
      barcode: barcode ?? this.barcode,
    );
  }
}
