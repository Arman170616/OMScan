import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import '../models/cart_item.dart';
import '../utils/formatter.dart';

class PrinterService {
  static Future<List<BluetoothInfo>> scanDevices() async {
    final paired = await PrintBluetoothThermal.pairedBluetooths;
    return paired;
  }

  static Future<bool> connect(String macAddress) async {
    return PrintBluetoothThermal.connect(macPrinterAddress: macAddress);
  }

  static Future<bool> disconnect() async {
    return PrintBluetoothThermal.disconnect;
  }

  static Future<bool> get isConnected async {
    return PrintBluetoothThermal.connectionStatus;
  }

  static Future<void> printReceipt(Order order) async {
    final connected = await isConnected;
    if (!connected) return;

    final List<int> bytes = [];

    // ESC/POS commands
    // Initialize
    bytes.addAll([0x1B, 0x40]);
    // Center align
    bytes.addAll([0x1B, 0x61, 0x01]);
    // Bold + double size
    bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll([0x1D, 0x21, 0x11]);
    bytes.addAll(_encodeText('KARISMA POS\n'));
    // Normal size
    bytes.addAll([0x1D, 0x21, 0x00]);
    bytes.addAll([0x1B, 0x45, 0x00]);
    bytes.addAll(_encodeText('Modern Retail Solution\n'));
    bytes.addAll(_encodeText('================================\n'));

    // Left align
    bytes.addAll([0x1B, 0x61, 0x00]);
    bytes.addAll(_encodeText('Order  : ${formatOrderId(order.id)}\n'));
    bytes.addAll(_encodeText('Date   : ${formatDateTime(order.createdAt)}\n'));
    bytes.addAll(_encodeText('Payment: ${order.paymentMethod}\n'));
    bytes.addAll(_encodeText('--------------------------------\n'));

    for (final item in order.items) {
      bytes.addAll(_encodeText('${item.product.name}\n'));
      final qty = '${item.quantity} x ${formatCurrency(item.product.price)}';
      final subtotal = formatCurrency(item.subtotal);
      bytes.addAll(_encodeText(_padLine(qty, subtotal)));
    }

    bytes.addAll(_encodeText('================================\n'));
    bytes.addAll(_encodeText(_padLine('Subtotal', formatCurrency(order.subtotal))));
    bytes.addAll(_encodeText(_padLine('Tax (11%)', formatCurrency(order.tax))));
    bytes.addAll(_encodeText('--------------------------------\n'));
    // Bold total
    bytes.addAll([0x1B, 0x45, 0x01]);
    bytes.addAll(_encodeText(_padLine('TOTAL', formatCurrency(order.total))));
    bytes.addAll([0x1B, 0x45, 0x00]);
    bytes.addAll(_encodeText('================================\n'));

    // Center
    bytes.addAll([0x1B, 0x61, 0x01]);
    bytes.addAll(_encodeText('\nThank you for your purchase!\n'));
    bytes.addAll(_encodeText('Powered by Karisma POS\n'));
    // Feed and cut
    bytes.addAll([0x1B, 0x64, 0x04]);
    bytes.addAll([0x1D, 0x56, 0x41, 0x00]);

    await PrintBluetoothThermal.writeBytes(bytes);
  }

  static List<int> _encodeText(String text) {
    return text.codeUnits;
  }

  static String _padLine(String left, String right, {int width = 32}) {
    final spaces = width - left.length - right.length;
    if (spaces <= 0) return '$left $right\n';
    return '$left${' ' * spaces}$right\n';
  }
}

class PrinterState extends ChangeNotifier {
  List<BluetoothInfo> _devices = [];
  BluetoothInfo? _connected;
  bool _isScanning = false;
  bool _isPrinting = false;
  String? _error;

  List<BluetoothInfo> get devices => _devices;
  BluetoothInfo? get connected => _connected;
  bool get isScanning => _isScanning;
  bool get isPrinting => _isPrinting;
  String? get error => _error;
  bool get hasConnection => _connected != null;

  Future<void> scan() async {
    _isScanning = true;
    _error = null;
    notifyListeners();
    try {
      _devices = await PrinterService.scanDevices();
    } catch (e) {
      _error = 'Failed to scan: $e';
    } finally {
      _isScanning = false;
      notifyListeners();
    }
  }

  Future<void> connect(BluetoothInfo device) async {
    _error = null;
    notifyListeners();
    try {
      final ok = await PrinterService.connect(device.macAdress);
      if (ok) {
        _connected = device;
      } else {
        _error = 'Could not connect to ${device.name}';
      }
    } catch (e) {
      _error = 'Connection error: $e';
    }
    notifyListeners();
  }

  Future<void> disconnect() async {
    await PrinterService.disconnect();
    _connected = null;
    notifyListeners();
  }

  Future<bool> printReceipt(Order order) async {
    _isPrinting = true;
    _error = null;
    notifyListeners();
    try {
      await PrinterService.printReceipt(order);
      return true;
    } catch (e) {
      _error = 'Print failed: $e';
      return false;
    } finally {
      _isPrinting = false;
      notifyListeners();
    }
  }
}
