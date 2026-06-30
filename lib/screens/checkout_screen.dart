import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatter.dart';
import '../utils/invoice_service.dart';
import '../utils/l10n.dart';
import '../utils/printer_service.dart';
import '../widgets/glass_container.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen>
    with SingleTickerProviderStateMixin {
  String _paymentMethod = 'QRIS';
  bool _paid = false;
  bool _printSuccess = false;
  Order? _order;
  late AnimationController _pulseCtrl;

  // Internal keys stay English (stored in DB); labels are localized via L10n

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  String get _qrData => _order == null
      ? ''
      : 'OMSCAN|ORDER:${_order!.id}|AMOUNT:${_order!.total.toStringAsFixed(3)}|METHOD:$_paymentMethod';

  void _generateOrder(CartProvider cart) {
    if (_order != null) return;
    setState(() => _order = cart.createOrder(_paymentMethod));
  }

  void _confirmPayment(CartProvider cart, PrinterState printer) async {
    if (_paid) return;
    setState(() => _paid = true);
    await cart.confirmPayment();
    if (printer.hasConnection && _order != null) {
      final ok = await printer.printReceipt(_order!);
      if (mounted) setState(() => _printSuccess = ok);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final printer = context.watch<PrinterState>();
    final s = L10n(context.watch<AppLanguage>().isArabic);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_order == null && !cart.isEmpty) _generateOrder(cart);
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, s),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      _buildItemsTable(cart, s),
                      const SizedBox(height: 14),
                      if (_order != null) _buildQrSection(s),
                      const SizedBox(height: 14),
                      _buildPaymentMethod(s),
                      const SizedBox(height: 14),
                      _buildPrinterRow(printer, s),
                      const SizedBox(height: 14),
                      if (!_paid) _buildConfirmButton(cart, printer, s),
                      if (_paid) _buildSuccessBanner(printer, s),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, L10n s) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withValues(alpha: 0.04),
          padding: const EdgeInsets.fromLTRB(12, 12, 16, 12),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 18, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.checkout,
                      style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w700,
                          fontSize: 17)),
                  if (_order != null)
                    Text(formatOrderId(_order!.id),
                        style: const TextStyle(
                            color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildItemsTable(CartProvider cart, L10n s) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 16,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                    flex: 4,
                    child: Text(s.productCol,
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4))),
                SizedBox(
                    width: 64,
                    child: Text(s.priceCol,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4))),
                SizedBox(
                    width: 64,
                    child: Text(s.totalCol,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            color: AppTheme.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.4))),
              ],
            ),
          ),
          const Divider(height: 1),
          ...cart.items.asMap().entries.map((e) {
            final item = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: item.product.category.color
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item.product.category.icon,
                            color: item.product.category.color, size: 16),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.product.name,
                                style: const TextStyle(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text('× ${item.quantity}',
                                style: const TextStyle(
                                    color: AppTheme.textMuted,
                                    fontSize: 11)),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(formatCurrency(item.product.price),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11)),
                      ),
                      SizedBox(
                        width: 64,
                        child: Text(formatCurrency(item.subtotal),
                            textAlign: TextAlign.right,
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ],
                  ),
                ),
                if (e.key < cart.items.length - 1)
                  const Divider(height: 1, indent: 16),
              ],
            );
          }),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.total,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 15)),
                Text(formatCurrency(cart.total),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 50.ms);
  }

  Widget _buildQrSection(L10n s) {
    return GlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.qr_code_rounded,
                    color: AppTheme.primary, size: 18),
              ),
              const SizedBox(width: 12),
              Text(s.scanToPay,
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15)),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, child) => Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(
                        alpha: 0.08 + 0.08 * _pulseCtrl.value),
                    blurRadius: 16 + 8 * _pulseCtrl.value,
                  ),
                ],
              ),
              child: child,
            ),
            child: QrImageView(
              data: _qrData,
              version: QrVersions.auto,
              size: 168,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppTheme.textPrimary),
              dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppTheme.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          Text(formatCurrency(_order!.total),
              style: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 20)),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: 100.ms);
  }

  Widget _buildPaymentMethod(L10n s) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.paymentMethod,
              style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: L10n.methodKeys.asMap().entries.map((e) {
              final key = e.value;
              final label = s.paymentMethods[e.key];
              final sel = key == _paymentMethod;
              return GestureDetector(
                onTap: () => setState(() {
                  _paymentMethod = key;
                  _order = null;
                }),
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel
                        ? AppTheme.primary
                        : Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: sel
                            ? AppTheme.primary
                            : Colors.white.withValues(alpha: 0.15)),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          color: sel ? Colors.white : AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 150.ms);
  }

  Widget _buildPrinterRow(PrinterState printer, L10n s) {
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: 16,
      child: Row(
        children: [
          Icon(
            printer.hasConnection
                ? Icons.print_rounded
                : Icons.print_disabled_rounded,
            color: printer.hasConnection
                ? AppTheme.secondary
                : AppTheme.textMuted,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              printer.hasConnection
                  ? s.printerReady(printer.connected!.name)
                  : s.noPrinter,
              style: TextStyle(
                  color: printer.hasConnection
                      ? AppTheme.textPrimary
                      : AppTheme.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
          if (!printer.hasConnection)
            TextButton(
              onPressed: printer.isScanning ? null : printer.scan,
              child: printer.isScanning
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: AppTheme.primary))
                  : Text(s.connect,
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 13)),
            )
          else
            TextButton(
              onPressed: printer.disconnect,
              child: Text(s.disconnect,
                  style: const TextStyle(
                      color: AppTheme.textMuted, fontSize: 12)),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 200.ms);
  }

  Widget _buildConfirmButton(
      CartProvider cart, PrinterState printer, L10n s) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: () => _confirmPayment(cart, printer),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.secondary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 20),
            const SizedBox(width: 10),
            Text(s.confirmPayment,
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 250.ms).slideY(begin: 0.2);
  }

  Widget _buildSuccessBanner(PrinterState printer, L10n s) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: 16,
      borderColor: AppTheme.secondary,
      color: AppTheme.secondary.withValues(alpha: 0.06),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle_rounded,
                  color: AppTheme.secondary, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.paymentConfirmed,
                        style: const TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    Text(
                      _printSuccess
                          ? s.printSuccess
                          : s.connectPrinterMsg,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Bluetooth devices list
          if (!printer.hasConnection && printer.devices.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...printer.devices.map((d) => GestureDetector(
                  onTap: () => printer.connect(d),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.bgInput,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bluetooth_rounded,
                            color: AppTheme.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                            child: Text(d.name,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500))),
                        Text(s.connect,
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12)),
                      ],
                    ),
                  ),
                )),
          ],
          if (printer.hasConnection && !_printSuccess && _order != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: printer.isPrinting
                    ? null
                    : () async {
                        final ok = await printer.printReceipt(_order!);
                        if (mounted) setState(() => _printSuccess = ok);
                      },
                icon: printer.isPrinting
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppTheme.primary))
                    : const Icon(Icons.print_rounded, size: 16),
                label: Text(
                    printer.isPrinting ? s.printing : s.printReceipt),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (_order != null)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => InvoiceService.downloadInvoice(_order!),
                icon: const Icon(Icons.download_rounded, size: 17),
                label: Text(s.downloadInvoice,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).popUntil((r) => r.isFirst),
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
              label: Text(s.newTransaction,
                  style: const TextStyle(fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0);
  }
}
