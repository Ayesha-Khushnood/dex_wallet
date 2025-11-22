import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../util/color_resources.dart';
import '../../../../util/size_extension.dart';
import '../../../../helper/sb_helper.dart';
import '../../../../theme/theme_manager.dart';
import '../../../../data/model/body/supported_chain_model.dart';
import 'chain_market_vm.dart';

class ChainMarketScreen extends StatefulWidget {
  final SupportedChainModel chain;
  
  const ChainMarketScreen({super.key, required this.chain});

  @override
  State<ChainMarketScreen> createState() => _ChainMarketScreenState();
}

class _ChainMarketScreenState extends State<ChainMarketScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ChainMarketVM>();
    final themeManager = Provider.of<ThemeManager>(context);
    
    // Initialize VM with chain data only once when screen loads
    if (!_initialized) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        vm.initializeWithChain(widget.chain);
        _initialized = true;
      });
    }

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
          "${widget.chain.chainName} Market",
          style: TextStyle(
            color: themeManager.currentTheme.colorScheme.onSurface,
            fontFamily: "Rubik",
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: AppColors.primary,
              size: 24,
            ),
            onPressed: () => vm.refreshData(),
          ),
        ],
      ),
      body: SafeArea(
        child: vm.isLoading
            ? _buildLoadingState(themeManager)
            : vm.error != null
                ? _buildErrorState(vm, themeManager)
                : _buildContent(vm, themeManager),
      ),
    );
  }

  Widget _buildLoadingState(ThemeManager themeManager) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppColors.primary,
          ),
          SB.h(2.h),
          Text(
            "Loading market data...",
            style: TextStyle(
              color: themeManager.currentTheme.colorScheme.onSurface,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ChainMarketVM vm, ThemeManager themeManager) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            SB.h(2.h),
            Text(
              "Failed to load market data",
              style: TextStyle(
                color: themeManager.currentTheme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SB.h(1.h),
            Text(
              vm.error ?? "Unknown error occurred",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: themeManager.currentTheme.colorScheme.onSurface.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            SB.h(3.h),
            ElevatedButton(
              onPressed: () => vm.refreshData(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              ),
              child: Text(
                "Retry",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ChainMarketVM vm, ThemeManager themeManager) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      child: Column(
        children: [
          SB.h(2.h),

          // Chain Overview Card
          _buildChainOverviewCard(vm, themeManager),

          SB.h(2.h),

          // Total Value Card
          _buildTotalValueCard(vm, themeManager),

          SB.h(2.h),

          // Market Data Card
          _buildMarketDataCard(vm, themeManager),

          SB.h(2.h),

          // Send/Receive Buttons
          _buildActionButtons(themeManager),
        ],
      ),
    );
  }

  Widget _buildChainOverviewCard(ChainMarketVM vm, ThemeManager themeManager) {
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
          // Header with chain info and percentage
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Chain icon
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: Color(int.parse(widget.chain.color.replaceFirst('#', '0xFF'))),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        widget.chain.nativeCurrencySymbol.substring(0, 1),
                        style: const TextStyle(
                          color: Colors.white,
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
                        widget.chain.nativeCurrencySymbol,
                        style: themeManager.currentTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        widget.chain.chainName,
                        style: themeManager.currentTheme.textTheme.bodySmall?.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                vm.chainChange,
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

  Widget _buildChartArea(ChainMarketVM vm, ThemeManager themeManager) {
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
              painter: ChartLinePainter(
                chainColor: widget.chain.color,
                historicalData: vm.historicalData,
              ),
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
                    vm.chainPrice,
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
                        vm.chainChangeValue,
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

          // Chain color dot indicator
          Positioned(
            top: 3.5.h,
            right: 6.w,
            child: Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: Color(int.parse(widget.chain.color.replaceFirst('#', '0xFF'))),
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

  Widget _buildTimeframeSelector(ChainMarketVM vm, ThemeManager themeManager) {
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

  Widget _buildTotalValueCard(ChainMarketVM vm, ThemeManager themeManager) {
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

  Widget _buildMarketDataCard(ChainMarketVM vm, ThemeManager themeManager) {
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
                "24h Volume (USD)",
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

  Widget _buildActionButtons(ThemeManager themeManager) {
    return Builder(
      builder: (context) => Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _navigateToSend(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Send ${widget.chain.nativeCurrencySymbol}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SB.w(2.w),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _navigateToReceive(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: BorderSide(color: AppColors.primary, width: 2),
                padding: EdgeInsets.symmetric(vertical: 2.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Receive ${widget.chain.nativeCurrencySymbol}",
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToSend(BuildContext context) {
    print('🔍 ChainMarketScreen - Navigating to send with chain: ${widget.chain.chainName}');
    Navigator.pushNamed(context, "/send", arguments: widget.chain);
  }

  void _navigateToReceive(BuildContext context) {
    print('🔍 ChainMarketScreen - Navigating to receive with chain: ${widget.chain.chainName}');
    Navigator.pushNamed(context, "/receive_crypto", arguments: widget.chain);
  }
}

class ChartLinePainter extends CustomPainter {
  final String chainColor;
  final List<Map<String, dynamic>>? historicalData;
  
  ChartLinePainter({
    required this.chainColor,
    this.historicalData,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;
    
    // Use real historical data if available, otherwise fallback to mock data
    List<Offset> points = _generatePointsFromHistoricalData(size);
    
    if (points.isEmpty) {
      // Fallback to mock data if no historical data
      points = _generateMockPoints(size);
    }
    
    // Create the area fill path
    final fillPath = Path();
    fillPath.moveTo(0, height);
    fillPath.lineTo(points.first.dx, points.first.dy);
    
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
          Color(int.parse(chainColor.replaceFirst('#', '0xFF'))).withOpacity(0.8),
          Color(int.parse(chainColor.replaceFirst('#', '0xFF'))).withOpacity(0.4),
          Color(int.parse(chainColor.replaceFirst('#', '0xFF'))).withOpacity(0.1),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, width, height));
    
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw the line
    final linePath = Path();
    linePath.moveTo(points.first.dx, points.first.dy);
    
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
      ..color = Color(int.parse(chainColor.replaceFirst('#', '0xFF')))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;
    
    canvas.drawPath(linePath, linePaint);
  }
  
  /// Generate points from real historical data
  List<Offset> _generatePointsFromHistoricalData(Size size) {
    if (historicalData == null || historicalData!.isEmpty) {
      return [];
    }
    
    final width = size.width;
    final height = size.height;
    
    // Find min and max prices for scaling
    double minPrice = double.infinity;
    double maxPrice = double.negativeInfinity;
    
    for (final data in historicalData!) {
      final price = data['price'] as double? ?? 0.0;
      if (price < minPrice) minPrice = price;
      if (price > maxPrice) maxPrice = price;
    }
    
    // If all prices are the same, add some padding
    if (minPrice == maxPrice) {
      minPrice = minPrice * 0.95;
      maxPrice = maxPrice * 1.05;
    }
    
    final priceRange = maxPrice - minPrice;
    
    // Generate points from historical data
    List<Offset> points = [];
    for (int i = 0; i < historicalData!.length; i++) {
      final data = historicalData![i];
      final price = data['price'] as double? ?? 0.0;
      
      // Calculate x position (time)
      final x = (i / (historicalData!.length - 1)) * width;
      
      // Calculate y position (price, inverted because y=0 is top)
      final normalizedPrice = (price - minPrice) / priceRange;
      final y = height - (normalizedPrice * height);
      
      points.add(Offset(x, y));
    }
    
    return points;
  }
  
  /// Generate mock points as fallback
  List<Offset> _generateMockPoints(Size size) {
    final width = size.width;
    final height = size.height;
    
    return [
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
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    if (oldDelegate is ChartLinePainter) {
      return oldDelegate.historicalData != historicalData;
    }
    return true;
  }
}
