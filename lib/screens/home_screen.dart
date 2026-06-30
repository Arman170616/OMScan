import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../utils/database_helper.dart';
import '../utils/formatter.dart';
import '../utils/l10n.dart';
import '../widgets/glass_container.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> _products = [];
  List<Product> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(_filter);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final list = await DatabaseHelper.instance.getAllProducts();
    if (mounted) {
      setState(() {
        _products = list;
        _filtered = list;
        _loading = false;
      });
    }
  }

  void _filter() {
    final q = _searchCtrl.text.toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _products
          : _products
              .where((p) =>
                  p.name.toLowerCase().contains(q) ||
                  (p.barcode ?? '').contains(q))
              .toList();
    });
  }

  Future<void> _deleteProduct(Product p) async {
    await DatabaseHelper.instance.deleteProduct(p.id);
    _load();
  }

  Future<void> _editProduct(Product p) async {
    final updated = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditSheet(product: p),
    );
    if (updated != null) {
      await DatabaseHelper.instance.updateProduct(updated);
      _load();
    }
  }

  Future<void> _restockProduct(Product p) async {
    final qty = await showDialog<int>(
      context: context,
      builder: (_) => _RestockDialog(product: p),
    );
    if (qty != null && qty > 0) {
      await DatabaseHelper.instance.restockProduct(p.id, qty);
      _load();
    }
  }

  Color _stockColor(int stock) {
    if (stock == 0) return AppTheme.accent;
    if (stock <= 5) return AppTheme.warning;
    return AppTheme.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final s = L10n(context.watch<AppLanguage>().isArabic);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(s),
              if (!_loading && _products.isNotEmpty) _buildStockSummary(s),
              _buildSearchBar(s),
              Expanded(child: _buildList(s)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(L10n s) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          color: Colors.white.withValues(alpha: 0.04),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      color: AppTheme.textPrimary, size: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(s.inventory,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.3)),
                ),
                child: Text(s.itemCount(_products.length),
                    style: const TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStockSummary(L10n s) {
    final outOfStock = _products.where((p) => p.stock == 0).length;
    final lowStock =
        _products.where((p) => p.stock > 0 && p.stock <= 5).length;
    final inStock = _products.where((p) => p.stock > 5).length;
    return Container(
      color: Colors.white.withValues(alpha: 0.03),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          _StockChip(
              label: s.inStock, count: inStock, color: AppTheme.secondary),
          const SizedBox(width: 8),
          _StockChip(
              label: s.lowStock, count: lowStock, color: AppTheme.warning),
          const SizedBox(width: 8),
          _StockChip(
              label: s.outStock, count: outOfStock, color: AppTheme.accent),
        ],
      ),
    );
  }

  Widget _buildSearchBar(L10n s) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: TextField(
        controller: _searchCtrl,
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: InputDecoration(
          hintText: s.searchHint,
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppTheme.textMuted, size: 20),
          suffixIcon: _searchCtrl.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppTheme.textMuted),
                  onPressed: () {
                    _searchCtrl.clear();
                    _filter();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildList(L10n s) {
    if (_loading) {
      return const Center(
          child: CircularProgressIndicator(color: AppTheme.primary));
    }
    if (_filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 56,
                color: AppTheme.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 14),
            Text(
              _products.isEmpty ? s.noProducts : s.noResults,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
      separatorBuilder: (ctx, i) => const SizedBox(height: 8),
      itemCount: _filtered.length,
      itemBuilder: (ctx, i) {
        final p = _filtered[i];
        return _ProductRow(
          product: p,
          stockColor: _stockColor(p.stock),
          onEdit: () => _editProduct(p),
          onRestock: () => _restockProduct(p),
          onDelete: () => _confirmDelete(ctx, p),
        ).animate(delay: 40.ms * i).fadeIn(duration: 220.ms);
      },
    );
  }

  void _confirmDelete(BuildContext ctx, Product p) {
    final s = L10n(context.read<AppLanguage>().isArabic);
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(s.deleteProduct),
        content: Text(s.deleteConfirm(p.name)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(s.cancel)),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _deleteProduct(p);
            },
            child: Text(s.delete,
                style: const TextStyle(color: AppTheme.accent)),
          ),
        ],
      ),
    );
  }
}

// ─── Product Row ──────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  final Product product;
  final Color stockColor;
  final VoidCallback onEdit;
  final VoidCallback onRestock;
  final VoidCallback onDelete;

  const _ProductRow({
    required this.product,
    required this.stockColor,
    required this.onEdit,
    required this.onRestock,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final s = L10n(context.watch<AppLanguage>().isArabic);
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: 14,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: product.category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                  color: product.category.color.withValues(alpha: 0.3),
                  width: 1),
            ),
            child: Icon(product.category.icon,
                color: product.category.color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(formatCurrency(product.price),
                        style: TextStyle(
                            color: product.category.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12)),
                    if (product.barcode != null) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.qr_code_rounded,
                          size: 11, color: AppTheme.textMuted),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(product.barcode!,
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 10),
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stockColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: stockColor.withValues(alpha: 0.35), width: 1),
                ),
                child: Text(
                  product.stock == 0 ? s.outOfStock : '${product.stock}',
                  style: TextStyle(
                      color: stockColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 11),
                ),
              ),
              const SizedBox(height: 2),
              Text(s.pcs,
                  style:
                      const TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(width: 4),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'edit') onEdit();
              if (v == 'restock') onRestock();
              if (v == 'delete') onDelete();
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    const Icon(Icons.edit_rounded,
                        size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                    Text(s.edit),
                  ])),
              PopupMenuItem(
                  value: 'restock',
                  child: Row(children: [
                    const Icon(Icons.add_box_rounded,
                        size: 16, color: AppTheme.secondary),
                    const SizedBox(width: 8),
                    Text(s.restock),
                  ])),
              PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    const Icon(Icons.delete_outline_rounded,
                        size: 16, color: AppTheme.accent),
                    const SizedBox(width: 8),
                    Text(s.delete,
                        style: const TextStyle(color: AppTheme.accent)),
                  ])),
            ],
            icon: const Icon(Icons.more_vert_rounded,
                color: AppTheme.textMuted, size: 20),
          ),
        ],
      ),
    );
  }
}

class _StockChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _StockChip(
      {required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration:
                  BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text('$count $label',
              style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Restock Dialog ───────────────────────────────────────────────────────────

class _RestockDialog extends StatefulWidget {
  final Product product;
  const _RestockDialog({required this.product});

  @override
  State<_RestockDialog> createState() => _RestockDialogState();
}

class _RestockDialogState extends State<_RestockDialog> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = L10n(context.watch<AppLanguage>().isArabic);
    return AlertDialog(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: widget.product.category.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.product.category.icon,
                color: widget.product.category.color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(widget.product.name,
                style: const TextStyle(fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(s.currentStock,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              Text('${widget.product.stock} ${s.pcs}',
                  style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13)),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _ctrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: s.qtyToAdd,
              hintText: '0',
              prefixIcon:
                  const Icon(Icons.add_rounded, color: AppTheme.secondary),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel,
              style: const TextStyle(color: AppTheme.textSecondary)),
        ),
        ElevatedButton.icon(
          onPressed: () {
            final qty = int.tryParse(_ctrl.text.trim()) ?? 0;
            Navigator.pop(context, qty);
          },
          icon: const Icon(Icons.add_rounded, size: 16),
          label: Text(s.addStock),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.secondary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

// ─── Edit Sheet ───────────────────────────────────────────────────────────────

class _EditSheet extends StatefulWidget {
  final Product product;
  const _EditSheet({required this.product});

  @override
  State<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends State<_EditSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _priceCtrl;
  late TextEditingController _stockCtrl;
  late ProductCategory _category;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _priceCtrl =
        TextEditingController(text: widget.product.price.toStringAsFixed(3));
    _stockCtrl =
        TextEditingController(text: widget.product.stock.toString());
    _category = widget.product.category == ProductCategory.all
        ? ProductCategory.snacks
        : widget.product.category;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _save(L10n s) {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(
      context,
      widget.product.copyWith(
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        category: _category,
        stock: int.tryParse(_stockCtrl.text.trim()) ?? widget.product.stock,
      ),
    );
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
                      borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 16),
            Text(s.editProduct,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _category.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: _category.color.withValues(alpha: 0.3)),
                  ),
                  child: Icon(_category.icon,
                      color: _category.color, size: 26),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.categoryHint,
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                    Text(_category.localLabel(isAr),
                        style: TextStyle(
                            color: _category.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: AppTheme.textPrimary),
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(labelText: s.productNameLabel),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? s.required : null,
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
                    decoration: InputDecoration(labelText: s.priceLabel),
                    validator: (v) =>
                        double.tryParse(v ?? '') == null ? s.invalid : null,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _stockCtrl,
                    style: const TextStyle(color: AppTheme.textPrimary),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly
                    ],
                    decoration: InputDecoration(labelText: s.stockLabel),
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
                      ])))
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
                    onPressed: () => _save(s),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(s.saveChanges,
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
