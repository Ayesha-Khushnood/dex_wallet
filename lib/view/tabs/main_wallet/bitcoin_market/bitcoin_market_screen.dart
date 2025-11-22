import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../util/color_resources.dart';
import '../../../../util/size_extension.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import 'bitcoin_market_vm.dart';

class BitcoinMarketScreen extends StatelessWidget {
  const BitcoinMarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<BitcoinMarketVM>();
    final themeManager = Provider.of<ThemeManager>(context);

    return Scaffold(
      backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: themeManager.currentTheme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.primary,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Market Statistics",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontFamily: "Rubik",
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
          child: Column(
            children: [
              SB.h(2.h),

              // Bitcoin Overview Card
              _buildBitcoinOverviewCard(vm, themeManager),

              SB.h(2.h),

              // Total Value Card
              _buildTotalValueCard(vm, themeManager),

              SB.h(2.h),

              // Market Data Card
              _buildMarketDataCard(vm, themeManager),

              SB.h(2.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBitcoinOverviewCard(BitcoinMarketVM vm, ThemeManager themeManager) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with BTC info and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Bitcoin icon (using a yellow circle with B)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: Colors.yellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        "B",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  SB.w(2.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "BTC",
                        style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        "Bitcoin",
                        style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                vm.btcChange,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),

          SB.h(3.h),

          // Chart area (simplified representation)
          _buildChartArea(vm, themeManager),

          SB.h(2.h),

          // Timeframe selector
          _buildTimeframeSelector(vm, themeManager),
        ],
      ),
    );
  }

  Widget _buildChartArea(BitcoinMarketVM vm, ThemeManager themeManager) {
    return Container(
      height: 15.h,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Chart line and area fill
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(double.infinity, 12.h),
              painter: ChartLinePainter(),
            ),
          ),

          // Tooltip
          Positioned(
            top: 1.5.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vm.btcPrice,
                    style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.red,
                        size: 12,
                      ),
                      Text(
                        vm.btcChangeValue,
                        style: const TextStyle(
                          color: Colors.red,
                          fontFamily: "Rubik",
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Orange dot indicator
          Positioned(
            top: 3.5.h,
            right: 6.w,
            child: Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeframeSelector(BitcoinMarketVM vm, ThemeManager themeManager) {
    return Row(
      children: vm.timeframes.map((timeframe) {
        final isSelected = vm.selectedTimeframe == timeframe;
        return Expanded(
          child: GestureDetector(
            onTap: () => vm.selectTimeframe(timeframe),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 0.5.w),
              padding: EdgeInsets.symmetric(vertical: 1.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                timeframe,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? themeManager.currentTheme.colorScheme.onSurface : themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.6),
                  fontFamily: "Rubik",
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTotalValueCard(BitcoinMarketVM vm, ThemeManager themeManager) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Total",
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SB.h(0.5.h),
              Text(
                vm.totalValue,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Current Value",
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SB.h(0.5.h),
              Text(
                vm.currentValue,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarketDataCard(BitcoinMarketVM vm, ThemeManager themeManager) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: themeManager.currentTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: themeManager.currentTheme.dividerTheme.color ?? Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Market Cap (USD)",
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SB.h(0.5.h),
              Text(
                vm.marketCap,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "24th Volume (USD)",
                style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SB.h(0.5.h),
              Text(
                vm.volume24h,
                style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ChartLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Create the area fill path
    final fillPath = Path();
    fillPath.moveTo(0, height);
    fillPath.lineTo(0, height * 0.75);
    
    // Create realistic price movement points
    final points = [
      Offset(0, height * 0.75),
      Offset(width * 0.1, height * 0.7),
      Offset(width * 0.2, height * 0.65),
      Offset(width * 0.3, height * 0.6),
      Offset(width * 0.4, height * 0.55),
      Offset(width * 0.5, height * 0.5),
      Offset(width * 0.6, height * 0.45),
      Offset(width * 0.7, height * 0.4),
      Offset(width * 0.8, height * 0.35),
      Offset(width * 0.9, height * 0.3),
      Offset(width, height * 0.25),
    ];
    
    // Create smooth curve through points
    for (int i = 0; i < points.length - 1; i++) {
      if (i == 0) {
        fillPath.lineTo(points[i].dx, points[i].dy);
      } else {
        final controlPoint1 = Offset(
          points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2,
          points[i - 1].dy,
        );
        final controlPoint2 = Offset(
          points[i].dx - (points[i].dx - points[i - 1].dx) / 2,
          points[i].dy,
        );
        fillPath.cubicTo(
          controlPoint1.dx, controlPoint1.dy,
          controlPoint2.dx, controlPoint2.dy,
          points[i].dx, points[i].dy,
        );
      }
    }
    
    // Complete the area fill
    fillPath.lineTo(width, height);
    fillPath.close();
    
    // Draw the area fill with gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          AppColors.primary.withOpacity(0.8),
          AppColors.primary.withOpacity(0.4),
          AppColors.primary.withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw the line
    final linePath = Path();
    linePath.moveTo(points[0].dx, points[0].dy);
    
    for (int i = 1; i < points.length; i++) {
      final controlPoint1 = Offset(
        points[i - 1].dx + (points[i].dx - points[i - 1].dx) / 2,
        points[i - 1].dy,
      );
      final controlPoint2 = Offset(
        points[i].dx - (points[i].dx - points[i - 1].dx) / 2,
        points[i].dy,
      );
      linePath.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        points[i].dx, points[i].dy,
      );
    }
    
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
