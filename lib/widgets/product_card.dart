import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatter.dart';
import 'glass_container.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final int index;

  const ProductCard({super.key, required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(product.id);

    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 24,
      onTap: () => cart.addProduct(product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product emoji hero
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    product.category.color.withValues(alpha: 0.3),
                    product.category.color.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      product.emoji,
                      style: const TextStyle(fontSize: 48),
                    ),
                  ),
                  if (product.isFeatured)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.warning.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '⭐ Popular',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Info section
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          formatCurrency(product.price),
                          style: TextStyle(
                            color: product.category.color,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _QuantityControl(product: product, qty: qty),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * index))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOut);
  }
}

class _QuantityControl extends StatelessWidget {
  final Product product;
  final int qty;

  const _QuantityControl({required this.product, required this.qty});

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();

    if (qty == 0) {
      return GestureDetector(
        onTap: () => cart.addProduct(product),
        child: Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, Color(0xFF8B7CF6)],
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Btn(
          icon: Icons.remove_rounded,
          onTap: () => cart.decrement(product.id),
          color: AppTheme.accent,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text(
            '$qty',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
        _Btn(
          icon: Icons.add_rounded,
          onTap: () => cart.addProduct(product),
          color: AppTheme.secondary,
        ),
      ],
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _Btn({required this.icon, required this.onTap, required this.color});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Icon(icon, color: color, size: 14),
      ),
    );
  }
}
