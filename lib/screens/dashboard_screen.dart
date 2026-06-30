import 'dart:math';
import 'dart:ui';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/cart_item.dart';
import '../providers/language_provider.dart';
import '../theme/app_theme.dart';
import '../utils/database_helper.dart';
import '../utils/formatter.dart';
import '../utils/l10n.dart';
import '../widgets/glass_container.dart';
import 'home_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _periodIndex = 0;
  bool _isAr = true;

  List<OrderRecord> _periodOrders = [];
  List<OrderRecord> _recentOrders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final now = DateTime.now();
    late DateTime from;
    late DateTime to;

    switch (_periodIndex) {
      case 0:
        final wd = now.weekday;
        from = DateTime(now.year, now.month, now.day - (wd - 1));
        to = from.add(
            const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
        break;
      case 1:
        from = DateTime(now.year, now.month, 1);
        to = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 2:
        from = DateTime(now.year, 1, 1);
        to = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }

    final results = await Future.wait([
      DatabaseHelper.instance.getOrdersForPeriod(from, to),
      DatabaseHelper.instance.getRecentOrders(limit: 10),
    ]);

    if (mounted) {
      setState(() {
        _periodOrders = results[0];
        _recentOrders = results[1];
        _loading = false;
      });
    }
  }

  List<_BarData> get _chartData {
    switch (_periodIndex) {
      case 0:
        return _weeklyBars();
      case 1:
        return _monthlyBars();
      default:
        return _yearlyBars();
    }
  }

  List<_BarData> _weeklyBars() {
    final s = L10n(_isAr);
    final map = <int, double>{for (var i = 1; i <= 7; i++) i: 0.0};
    for (final o in _periodOrders) {
      map[o.createdAt.weekday] = (map[o.createdAt.weekday] ?? 0) + o.total;
    }
    final lbl = s.weekLabels;
    return [for (int d = 1; d <= 7; d++) _BarData(lbl[d - 1], map[d]!)];
  }

  List<_BarData> _monthlyBars() {
    final s = L10n(_isAr);
    final map = <int, double>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final o in _periodOrders) {
      final w = ((o.createdAt.day - 1) ~/ 7) + 1;
      map[w] = (map[w] ?? 0) + o.total;
    }
    final now = DateTime.now();
    final days = DateTime(now.year, now.month + 1, 0).day;
    final maxW = ((days - 1) ~/ 7) + 1;
    return [
      for (int w = 1; w <= maxW; w++) _BarData(s.weekPrefix(w), map[w]!)
    ];
  }

  List<_BarData> _yearlyBars() {
    final map = <int, double>{for (int m = 1; m <= 12; m++) m: 0.0};
    for (final o in _periodOrders) {
      map[o.createdAt.month] = (map[o.createdAt.month] ?? 0) + o.total;
    }
    const lbl = [
      '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12'
    ];
    return [for (int m = 1; m <= 12; m++) _BarData(lbl[m - 1], map[m]!)];
  }

  double get _revenue => _periodOrders.fold(0.0, (s, o) => s + o.total);
  int get _orderCount => _periodOrders.length;
  double get _avgOrder => _orderCount == 0 ? 0 : _revenue / _orderCount;

  @override
  Widget build(BuildContext context) {
    _isAr = context.watch<AppLanguage>().isArabic;
    final s = L10n(_isAr);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(s),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(
                            color: AppTheme.primary))
                    : RefreshIndicator(
                        color: AppTheme.primary,
                        backgroundColor: const Color(0xFF0F2340),
                        onRefresh: _load,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding:
                              const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPeriodChips(s),
                              const SizedBox(height: 14),
                              _buildStatsRow(s),
                              const SizedBox(height: 16),
                              _buildChart(s),
                              const SizedBox(height: 20),
                              _buildRecentOrders(s),
                            ],
                          ),
                        ),
                      ),
              ),
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
                child: Text(s.dashboard,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const HomeScreen())),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.35)),
                  ),
                  child: const Icon(Icons.inventory_2_rounded,
                      color: AppTheme.primary, size: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodChips(L10n s) {
    return Row(
      children: s.periods.asMap().entries.map((e) {
        final sel = e.key == _periodIndex;
        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: GestureDetector(
            onTap: () {
              if (_periodIndex != e.key) {
                setState(() => _periodIndex = e.key);
                _load();
              }
            },
            child: AnimatedContainer(
              duration: 200.ms,
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: sel
                    ? AppTheme.primary
                    : Colors.white.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel
                        ? AppTheme.primary
                        : Colors.white.withValues(alpha: 0.15)),
                boxShadow: sel
                    ? [
                        BoxShadow(
                          color: AppTheme.primary.withValues(alpha: 0.35),
                          blurRadius: 12,
                        )
                      ]
                    : [],
              ),
              child: Text(e.value,
                  style: TextStyle(
                      color: sel ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatsRow(L10n s) {
    final lbl = s.periods[_periodIndex];
    return Row(
      children: [
        _StatCard(
          label: s.revenue(lbl),
          value: formatCurrency(_revenue),
          icon: Icons.account_balance_wallet_rounded,
          color: AppTheme.primary,
        ).animate().fadeIn(duration: 250.ms),
        const SizedBox(width: 10),
        _StatCard(
          label: s.orders,
          value: '$_orderCount',
          icon: Icons.receipt_long_rounded,
          color: AppTheme.secondary,
        ).animate(delay: 60.ms).fadeIn(duration: 250.ms),
        const SizedBox(width: 10),
        _StatCard(
          label: s.avgOrder,
          value: formatCurrency(_avgOrder),
          icon: Icons.trending_up_rounded,
          color: AppTheme.warning,
        ).animate(delay: 120.ms).fadeIn(duration: 250.ms),
      ],
    );
  }

  Widget _buildChart(L10n s) {
    final data = _chartData;
    final maxVal =
        data.isEmpty ? 10.0 : data.map((d) => d.amount).reduce(max);
    final maxY = maxVal == 0 ? 10.0 : maxVal * 1.3;
    final barWidth = _periodIndex == 2 ? 14.0 : 22.0;
    final isEmpty = data.every((d) => d.amount == 0);

    return GlassContainer(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      borderRadius: 18,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 4, bottom: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Icon(Icons.bar_chart_rounded,
                      color: AppTheme.primary, size: 16),
                ),
                const SizedBox(width: 10),
                Text(s.salesOverview,
                    style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14)),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart_rounded,
                            size: 48,
                            color: AppTheme.textMuted.withValues(alpha: 0.4)),
                        const SizedBox(height: 10),
                        Text(s.noSales(s.periods[_periodIndex]),
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 13)),
                      ],
                    ),
                  )
                : BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: maxY / 4,
                        getDrawingHorizontalLine: (_) => FlLine(
                            color: Colors.white.withValues(alpha: 0.06),
                            strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            interval: maxY / 4,
                            getTitlesWidget: (v, meta) {
                              if (v == 0) return const Text('');
                              final str = v >= 1000
                                  ? '${(v / 1000).toStringAsFixed(1)}K'
                                  : v.toStringAsFixed(0);
                              return Text(str,
                                  style: const TextStyle(
                                      color: AppTheme.textMuted,
                                      fontSize: 9));
                            },
                          ),
                        ),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: (v, meta) {
                              final i = v.toInt();
                              if (i < 0 || i >= data.length) {
                                return const Text('');
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(data[i].label,
                                    style: const TextStyle(
                                        color: AppTheme.textMuted,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500)),
                              );
                            },
                          ),
                        ),
                      ),
                      barTouchData: BarTouchData(
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (_) => const Color(0xFF0F2340),
                          tooltipRoundedRadius: 8,
                          getTooltipItem: (g, gi, rod, ri) =>
                              BarTooltipItem(
                            formatCurrency(rod.toY),
                            const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 11),
                          ),
                        ),
                      ),
                      barGroups: data.asMap().entries.map((e) {
                        final isToday = _periodIndex == 0 &&
                            e.key == DateTime.now().weekday - 1;
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.amount,
                              width: barWidth,
                              color: isToday
                                  ? AppTheme.secondary
                                  : AppTheme.primary,
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(6)),
                              backDrawRodData: BackgroundBarChartRodData(
                                show: true,
                                toY: maxY,
                                color: Colors.white.withValues(alpha: 0.04),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    duration: 400.ms,
                  ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms);
  }

  Widget _buildRecentOrders(L10n s) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(s.recentOrders,
                style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 15)),
            const Spacer(),
            Text(s.orderCount(_recentOrders.length),
                style: const TextStyle(
                    color: AppTheme.textMuted, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        if (_recentOrders.isEmpty)
          GlassContainer(
            padding: const EdgeInsets.all(24),
            borderRadius: 14,
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 40,
                      color: AppTheme.textMuted.withValues(alpha: 0.4)),
                  const SizedBox(height: 8),
                  Text(s.noOrders,
                      style: const TextStyle(
                          color: AppTheme.textMuted, fontSize: 13)),
                ],
              ),
            ),
          )
        else
          ...(_recentOrders.asMap().entries.map((e) {
            final o = e.value;
            final now = DateTime.now();
            final isToday = o.createdAt.year == now.year &&
                o.createdAt.month == now.month &&
                o.createdAt.day == now.day;
            final timeStr = isToday
                ? formatTime(o.createdAt)
                : formatDate(o.createdAt);

            return GlassContainer(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              borderRadius: 12,
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: _methodColor(o.paymentMethod)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: _methodColor(o.paymentMethod)
                              .withValues(alpha: 0.3)),
                    ),
                    child: Icon(_methodIcon(o.paymentMethod),
                        color: _methodColor(o.paymentMethod), size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(formatOrderId(o.id),
                            style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                        Text('${o.paymentMethod}  •  $timeStr',
                            style: const TextStyle(
                                color: AppTheme.textMuted, fontSize: 11)),
                      ],
                    ),
                  ),
                  Text(formatCurrency(o.total),
                      style: const TextStyle(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ],
              ),
            ).animate(delay: (40 * e.key).ms).fadeIn(duration: 220.ms);
          })),
      ],
    );
  }

  IconData _methodIcon(String m) {
    switch (m.toLowerCase()) {
      case 'cash':
        return Icons.payments_rounded;
      case 'card':
        return Icons.credit_card_rounded;
      case 'qris':
        return Icons.qr_code_rounded;
      default:
        return Icons.account_balance_rounded;
    }
  }

  Color _methodColor(String m) {
    switch (m.toLowerCase()) {
      case 'cash':
        return AppTheme.secondary;
      case 'card':
        return AppTheme.primary;
      case 'qris':
        return AppTheme.warning;
      default:
        return AppTheme.accent;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.all(12),
        borderRadius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _BarData {
  final String label;
  final double amount;
  const _BarData(this.label, this.amount);
}
