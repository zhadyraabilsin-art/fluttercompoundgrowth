import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const CompoundGrowthApp());
}

class CompoundGrowthApp extends StatelessWidget {
  const CompoundGrowthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Compound Growth Studio',
      theme: ThemeData.dark(useMaterial3: true),
      home: const InvestmentScreen(),
    );
  }
}

class YearlyPoint {
  final int year;
  final double principal;
  final double interest;

  const YearlyPoint({
    required this.year,
    required this.principal,
    required this.interest,
  });

  double get total => principal + interest;
}

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({super.key});

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  double _initialDeposit = 2000;
  double _monthlyContribution = 250;
  double _annualRate = 9.0;
  int _years = 15;

  List<YearlyPoint> _calculateSchedule() {
    final points = <YearlyPoint>[];
    final monthlyRate = (_annualRate / 100) / 12;
    double balance = _initialDeposit;
    double totalPrincipal = _initialDeposit;

    for (int y = 1; y <= _years; y++) {
      for (int m = 0; m < 12; m++) {
        balance = (balance + _monthlyContribution) * (1 + monthlyRate);
        totalPrincipal += _monthlyContribution;
      }
      points.add(
        YearlyPoint(
          year: y,
          principal: totalPrincipal,
          interest: max(0, balance - totalPrincipal),
        ),
      );
    }
    return points;
  }

  String _formatMoney(double value) {
    if (value >= 1000000) {
      return '\$${(value / 1000000).toStringAsFixed(2)}M';
    }
    final rounded = value.round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < rounded.length; i++) {
      if (i > 0 && (rounded.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(rounded[i]);
    }
    return '\$$buffer';
  }

  @override
  Widget build(BuildContext context) {
    final schedule = _calculateSchedule();
    final finalPoint = schedule.last;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'Compound Growth Studio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF131926),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.teal.withValues(alpha: 0.35)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Projected Future Value',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatMoney(finalPoint.total),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.greenAccent,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statBadge(
                        'Contributions',
                        _formatMoney(finalPoint.principal),
                        Colors.cyanAccent,
                      ),
                      _statBadge(
                        'Compound Gains',
                        _formatMoney(finalPoint.interest),
                        Colors.greenAccent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              height: 175,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 10),
              decoration: BoxDecoration(
                color: const Color(0xFF131926),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white12),
              ),
              child: CustomPaint(
                painter: _GrowthChartPainter(points: schedule),
                size: Size.infinite,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _sliderControl(
                      'Initial Deposit',
                      _formatMoney(_initialDeposit),
                      _initialDeposit,
                      0,
                      25000,
                      50,
                      (v) => setState(() => _initialDeposit = v),
                    ),
                    _sliderControl(
                      'Monthly Savings',
                      '${_formatMoney(_monthlyContribution)}/mo',
                      _monthlyContribution,
                      50,
                      3000,
                      59,
                      (v) => setState(() => _monthlyContribution = v),
                    ),
                    _sliderControl(
                      'Annual Return',
                      '${_annualRate.toStringAsFixed(1)}%',
                      _annualRate,
                      1.0,
                      20.0,
                      38,
                      (v) => setState(() => _annualRate = v),
                    ),
                    _sliderControl(
                      'Time Horizon',
                      '$_years yrs',
                      _years.toDouble(),
                      3,
                      35,
                      32,
                      (v) => setState(() => _years = v.round()),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(String label, String amount, Color color) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          amount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: color,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _sliderControl(
    String title,
    String valueLabel,
    double value,
    double min,
    double max,
    int divisions,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 13, color: Colors.white70),
            ),
            Text(
              valueLabel,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Colors.greenAccent,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _GrowthChartPainter extends CustomPainter {
  final List<YearlyPoint> points;

  _GrowthChartPainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final maxTotal = points.last.total;
    if (maxTotal <= 0) return;

    final barSlotWidth = size.width / points.length;
    final barWidth = (barSlotWidth * 0.65).clamp(4.0, 26.0);

    final principalPaint = Paint()
      ..color = Colors.cyanAccent.withValues(alpha: 0.75);
    final interestPaint = Paint()..color = Colors.greenAccent;

    for (int i = 0; i < points.length; i++) {
      final p = points[i];
      final x = i * barSlotWidth + (barSlotWidth - barWidth) / 2;

      final totalHeight = (p.total / maxTotal) * size.height;
      final principalHeight = (p.principal / maxTotal) * size.height;
      final interestHeight = totalHeight - principalHeight;

      final principalRect = RRect.fromRectAndCorners(
        Rect.fromLTWH(
          x,
          size.height - principalHeight,
          barWidth,
          principalHeight,
        ),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
      );
      canvas.drawRRect(principalRect, principalPaint);

      if (interestHeight > 0.5) {
        final interestRect = RRect.fromRectAndCorners(
          Rect.fromLTWH(x, size.height - totalHeight, barWidth, interestHeight),
          topLeft: const Radius.circular(4),
          topRight: const Radius.circular(4),
        );
        canvas.drawRRect(interestRect, interestPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GrowthChartPainter oldDelegate) => true;
}
