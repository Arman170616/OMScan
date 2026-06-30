import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/cart_item.dart';
import '../models/product.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _db;

  DatabaseHelper._();
  static DatabaseHelper get instance => _instance ??= DatabaseHelper._();

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'omscan_v1.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await _createProductsTable(db);
        await _createOrdersTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createOrdersTable(db);
        }
      },
    );
  }

  Future<void> _createProductsTable(Database db) async {
    await db.execute('''
      CREATE TABLE products (
        id          TEXT PRIMARY KEY,
        name        TEXT NOT NULL,
        description TEXT NOT NULL DEFAULT '',
        price       REAL NOT NULL,
        category    TEXT NOT NULL DEFAULT 'all',
        emoji       TEXT NOT NULL DEFAULT '📦',
        barcode     TEXT UNIQUE,
        stock       INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createOrdersTable(Database db) async {
    await db.execute('''
      CREATE TABLE orders (
        id             TEXT PRIMARY KEY,
        total          REAL NOT NULL,
        subtotal       REAL NOT NULL,
        payment_method TEXT NOT NULL,
        created_at     TEXT NOT NULL,
        items_json     TEXT NOT NULL DEFAULT '[]'
      )
    ''');
  }

  // ── Products ─────────────────────────────────────────────────────────────

  Future<void> insertProduct(Product p) async {
    final db = await database;
    await db.insert('products', _productToMap(p),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateProduct(Product p) async {
    final db = await database;
    await db.update('products', _productToMap(p),
        where: 'id = ?', whereArgs: [p.id]);
  }

  Future<void> deleteProduct(String id) async {
    final db = await database;
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  Future<Product?> getByBarcode(String barcode) async {
    final db = await database;
    final rows = await db.query('products',
        where: 'barcode = ?', whereArgs: [barcode], limit: 1);
    return rows.isEmpty ? null : _productFromMap(rows.first);
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final rows = await db.query('products', orderBy: 'name ASC');
    return rows.map(_productFromMap).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final rows = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return rows.map(_productFromMap).toList();
  }

  Future<void> deductStock(String productId, int quantity) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE products SET stock = MAX(0, stock - ?) WHERE id = ?
    ''', [quantity, productId]);
  }

  Future<void> restockProduct(String productId, int quantity) async {
    final db = await database;
    await db.rawUpdate('''
      UPDATE products SET stock = stock + ? WHERE id = ?
    ''', [quantity, productId]);
  }

  // ── Orders ───────────────────────────────────────────────────────────────

  Future<void> insertOrder(Order order) async {
    final db = await database;
    final itemsJson = jsonEncode(order.items.map((i) => {
          'name': i.product.name,
          'emoji': i.product.emoji,
          'price': i.product.price,
          'qty': i.quantity,
          'subtotal': i.subtotal,
        }).toList());

    await db.insert('orders', {
      'id': order.id,
      'total': order.total,
      'subtotal': order.subtotal,
      'payment_method': order.paymentMethod,
      'created_at': order.createdAt.toIso8601String(),
      'items_json': itemsJson,
    });
  }

  Future<List<OrderRecord>> getRecentOrders({int limit = 15}) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT id, total, payment_method, created_at
      FROM orders
      ORDER BY created_at DESC
      LIMIT ?
    ''', [limit]);
    return rows.map(_orderFromMap).toList();
  }

  Future<List<OrderRecord>> getOrdersForPeriod(
      DateTime from, DateTime to) async {
    final db = await database;
    final rows = await db.rawQuery('''
      SELECT id, total, payment_method, created_at
      FROM orders
      WHERE created_at >= ? AND created_at <= ?
      ORDER BY created_at DESC
    ''', [from.toIso8601String(), to.toIso8601String()]);
    return rows.map(_orderFromMap).toList();
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  Map<String, dynamic> _productToMap(Product p) => {
        'id': p.id,
        'name': p.name,
        'description': p.description,
        'price': p.price,
        'category': p.category.name,
        'emoji': p.emoji,
        'barcode': p.barcode,
        'stock': p.stock,
      };

  Product _productFromMap(Map<String, dynamic> m) => Product(
        id: m['id'] as String,
        name: m['name'] as String,
        description: m['description'] as String? ?? '',
        price: (m['price'] as num).toDouble(),
        category: ProductCategory.values.firstWhere(
          (c) => c.name == m['category'],
          orElse: () => ProductCategory.all,
        ),
        emoji: m['emoji'] as String? ?? '📦',
        barcode: m['barcode'] as String?,
        stock: m['stock'] as int? ?? 0,
      );

  OrderRecord _orderFromMap(Map<String, dynamic> m) => OrderRecord(
        id: m['id'] as String,
        total: (m['total'] as num).toDouble(),
        paymentMethod: m['payment_method'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
      );
}
