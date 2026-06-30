import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../utils/database_helper.dart';
import '../utils/formatter.dart';
import '../utils/l10n.dart';
import '../widgets/glass_container.dart';
import 'checkout_screen.dart';
import 'dashboard_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scanCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _torchOn = false;
  String? _detectedName;
  bool _showTag = false;
  bool _processing = false;
  Timer? _tagTimer;
  late AnimationController _lineCtrl;

  @override
  void initState() {
    super.initState();
    _lineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanCtrl.dispose();
    _tagTimer?.cancel();
    _lineCtrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture, CartProvider cart) async {
    if (_processing) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;

    _processing = true;

    final product = await DatabaseHelper.instance.getByBarcode(raw);

    if (!mounted) return;

    if (product != null) {
      cart.addProduct(product);
      _showAddedTag(product.name);
      await Future.delayed(1500.ms);
      _processing = false;
    } else {
      HapticFeedback.mediumImpact();
      await _showAddProductSheet(raw, cart);
      _processing = false;
    }
  }

  void _showAddedTag(String name) {
    setState(() {
      _detectedName = name;
      _showTag = true;
    });
    _tagTimer?.cancel();
    _tagTimer = Timer(1600.ms, () {
      if (mounted) setState(() => _showTag = false);
    });
  }

  Future<void> _showAddProductSheet(String barcode, CartProvider cart) async {
    final product = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddProductSheet(barcode: barcode),
    );

    if (product != null && mounted) {
      await DatabaseHelper.instance.insertProduct(product);
      cart.addProduct(product);
      _showAddedTag(product.name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isAr = context.watch<AppLanguage>().isArabic;
    final s = L10n(isAr);
    final camH = MediaQuery.of(context).size.height * 0.50;

    return Scaffold(
      backgroundColor: AppTheme.bgPage,
      body: Column(
        children: [
          // ── Camera ──────────────────────────────────────────────────
          SizedBox(
            height: camH,
            child: Stack(
              children: [
                // LTR wrapper isolates camera from global RTL direction
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(28)),
                    child: MobileScanner(
                      controller: _scanCtrl,
                      onDetect: (c) => _onDetect(c, cart),
                    ),
                  ),
                ),
                // gradient overlay
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(28)),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.45),
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.25),
                        ],
                        stops: const [0, 0.25, 0.75, 1],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
                // Top bar
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        _CamBtn(
                          icon: Icons.bar_chart_rounded,
                          onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const DashboardScreen())),
                        ),
                        const SizedBox(width: 8),
                        _LangToggle(isAr: isAr),
                        const Spacer(),
                        const Text('OMScan',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                letterSpacing: 0.5)),
                        const Spacer(),
                        _CamBtn(
                          icon: _torchOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          onTap: () {
                            _scanCtrl.toggleTorch();
                            setState(() => _torchOn = !_torchOn);
                          },
                          active: _torchOn,
                        ),
                      ],
                    ),
                  ),
                ),
                // Scan frame
                Center(child: _ScanFrame(lineCtrl: _lineCtrl)),
                // Tag popup or hint
                if (_showTag && _detectedName != null)
                  Positioned(
                    bottom: 28,
                    left: 24,
                    right: 24,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.secondary.withValues(alpha: 0.4),
                            blurRadius: 16,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_rounded,
                              color: Colors.white, size: 18),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              s.addedToCart(_detectedName!),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 200.ms).slideY(begin: 0.3),
                  )
                else
                  Positioned(
                    bottom: 28,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(s.scanPrompt,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13)),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Cart panel ───────────────────────────────────────────────
          Expanded(child: _CartPanel(cart: cart)),
        ],
      ),
    );
  }
}

// ─── Language Toggle ─────────────────────────────────────────────────────────

class _LangToggle extends StatelessWidget {
  final bool isAr;
  const _LangToggle({required this.isAr});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<AppLanguage>().toggleLanguage(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'AR',
                style: TextStyle(
                  color: isAr ? Colors.white : Colors.white38,
                  fontWeight:
                      isAr ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const TextSpan(
                text: ' | ',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
              TextSpan(
                text: 'EN',
                style: TextStyle(
                  color: !isAr ? Colors.white : Colors.white38,
                  fontWeight:
                      !isAr ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Scan frame ─────────────────────────────────────────────────────────────

class _ScanFrame extends StatelessWidget {
  final AnimationController lineCtrl;
  const _ScanFrame({required this.lineCtrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      height: 175,
      child: Stack(
        children: [
          CustomPaint(size: const Size(220, 175), painter: _FramePainter()),
          AnimatedBuilder(
            animation: lineCtrl,
            builder: (ctx, child) => Positioned(
              top: 4 + 167 * lineCtrl.value,
              left: 4,
              right: 4,
              child: Container(
                height: 2,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.transparent,
                      AppTheme.secondary,
                      AppTheme.secondary,
                      Colors.transparent,
                    ],
                    stops: [0, 0.2, 0.8, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondary.withValues(alpha: 0.6),
                      blurRadius: 6,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = AppTheme.secondary
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const len = 26.0;
    const r = 7.0;
    final w = size.width;
    final h = size.height;

    canvas.drawLine(const Offset(r, 0), const Offset(len, 0), p);
    canvas.drawLine(const Offset(0, r), const Offset(0, len), p);
    canvas.drawArc(
        const Rect.fromLTWH(0, 0, r * 2, r * 2), 3.14159, 3.14159 / 2, false, p);
    canvas.drawLine(Offset(w - len, 0), Offset(w - r, 0), p);
    canvas.drawLine(Offset(w, r), Offset(w, len), p);
    canvas.drawArc(Rect.fromLTWH(w - r * 2, 0, r * 2, r * 2),
        3 * 3.14159 / 2, 3.14159 / 2, false, p);
    canvas.drawLine(Offset(r, h), Offset(len, h), p);
    canvas.drawLine(Offset(0, h - len), Offset(0, h - r), p);
    canvas.drawArc(Rect.fromLTWH(0, h - r * 2, r * 2, r * 2),
        3.14159 / 2, 3.14159 / 2, false, p);
    canvas.drawLine(Offset(w - len, h), Offset(w - r, h), p);
    canvas.drawLine(Offset(w, h - len), Offset(w, h - r), p);
    canvas.drawArc(Rect.fromLTWH(w - r * 2, h - r * 2, r * 2, r * 2),
        0, 3.14159 / 2, false, p);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ─── Cart panel ──────────────────────────────────────────────────────────────

class _CartPanel extends StatelessWidget {
  final CartProvider cart;
  const _CartPanel({required this.cart});

  @override
  Widget build(BuildContext context) {
    final s = L10n(context.watch<AppLanguage>().isArabic);
    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              const Icon(Icons.shopping_cart_rounded,
                  color: AppTheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(s.cartHeader,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: AppTheme.textPrimary)),
              if (cart.totalCount > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('${cart.totalCount}',
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
              const Spacer(),
              if (!cart.isEmpty)
                Text(formatCurrency(cart.total),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 17)),
            ],
          ),
        ),
        const Divider(height: 1),

        // Items
        Expanded(
          child: cart.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_scanner_rounded,
                          size: 48,
                          color: AppTheme.textMuted.withValues(alpha: 0.4)),
                      const SizedBox(height: 10),
                      Text(s.scanEmpty,
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  separatorBuilder: (ctx, i) => const SizedBox(height: 6),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    return _CartRow(item: item)
                        .animate(delay: 40.ms * i)
                        .fadeIn(duration: 220.ms)
                        .slideX(begin: 0.08, end: 0);
                  },
                ),
        ),

        // Review Order button
        if (!cart.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
            child: GlassButton(
              height: 52,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.receipt_long_rounded,
                      color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(s.reviewOrder,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15)),
                  const SizedBox(width: 16),
                  Text(formatCurrency(cart.total),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 14)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
                      color: Colors.white70, size: 18),
                ],
              ),
            ),
          ).animate().slideY(begin: 1, end: 0, duration: 280.ms),
      ],
    );
  }
}

class _CartRow extends StatelessWidget {
  final CartItem item;
  const _CartRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      borderRadius: 12,
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.product.category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(item.product.category.icon,
                color: item.product.category.color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
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
                Text(formatCurrency(item.product.price),
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          _QBtn(
              icon: Icons.remove_rounded,
              color: AppTheme.accent,
              onTap: () => cart.decrement(item.product.id)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('${item.quantity}',
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
          ),
          _QBtn(
              icon: Icons.add_rounded,
              color: AppTheme.secondary,
              onTap: () => cart.addProduct(item.product)),
          const SizedBox(width: 10),
          Text(formatCurrency(item.subtotal),
              style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13)),
        ],
      ),
    );
  }
}

class _QBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _QBtn({required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }
}

class _CamBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _CamBtn(
      {required this.icon, required this.onTap, this.active = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: active
              ? AppTheme.warning.withValues(alpha: 0.25)
              : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: active
                  ? AppTheme.warning.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.2)),
        ),
        child: Icon(icon,
            color: active ? AppTheme.warning : Colors.white, size: 20),
      ),
    );
  }
}

// ─── Add Product Bottom Sheet ────────────────────────────────────────────────

class _AddProductSheet extends StatefulWidget {
  final String barcode;
  const _AddProductSheet({required this.barcode});

  @override
  State<_AddProductSheet> createState() => _AddProductSheetState();
}

class _AddProductSheetState extends State<_AddProductSheet> {
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController(text: '0');
  final _formKey = GlobalKey<FormState>();
  ProductCategory _category = ProductCategory.snacks;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final product = Product.create(
      name: _nameCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      category: _category,
      barcode: widget.barcode,
      initialStock: int.tryParse(_stockCtrl.text.trim()) ?? 0,
    );
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    final isAr = context.watch<AppLanguage>().isArabic;
    final s = L10n(isAr);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: const Color(0xFF0F2340),
        borderRadius: const BorderRadius.all(Radius.circular(24)),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: _category.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(_category.icon,
                      color: _category.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.newProduct,
                          style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16)),
                      Text(widget.barcode,
                          style: const TextStyle(
                              color: AppTheme.textMuted, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                  labelText: s.productNameRequired,
                  hintText: s.productNameHint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? s.nameRequired : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                        labelText: s.priceRequired, hintText: '0.000'),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return s.required;
                      if (double.tryParse(v.trim()) == null) return s.invalid;
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(
                        labelText: s.initialStock, hintText: '0'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<ProductCategory>(
              initialValue: _category,
              dropdownColor: const Color(0xFF0F2340),
              style: const TextStyle(color: AppTheme.textPrimary),
              decoration: InputDecoration(labelText: s.categoryLabel),
              items: ProductCategory.values
                  .where((c) => c != ProductCategory.all)
                  .map((c) => DropdownMenuItem(
                        value: c,
                        child: Row(children: [
                          Icon(c.icon, color: c.color, size: 16),
                          const SizedBox(width: 8),
                          Text(c.localLabel(isAr),
                              style: const TextStyle(fontSize: 13)),
                        ]),
                      ))
                  .toList(),
              onChanged: (v) =>
                  setState(() => _category = v ?? _category),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textSecondary,
                      side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.2)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(s.cancel),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(s.saveAndAdd,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
