import '../../../../data/base_vm.dart';
import '../../../../services/market_data_service.dart';
import '../../../../data/model/body/supported_chain_model.dart';

class ChainMarketVM extends BaseVM {
  String _selectedTimeframe = "24H";
  bool _isLoading = true;
  String? _error;
  bool _disposed = false;
  
  // Real-time data
  double? _currentPrice;
  double? _priceChange24h;
  double? _marketCap;
  double? _volume24h;
  List<Map<String, dynamic>>? _historicalData;
  
  // Chain data
  SupportedChainModel? _chain;
  bool _initialized = false;
  
  // Prevent multiple simultaneous calls
  bool _isLoadingHistorical = false;
  
  String get selectedTimeframe => _selectedTimeframe;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  // Formatted getters
  String get chainPrice => _currentPrice != null 
      ? MarketDataService.formatPrice(_currentPrice!) 
      : "Loading...";
      
  String get chainChange => _priceChange24h != null 
      ? MarketDataService.formatPercentageChange(_priceChange24h!) 
      : "Loading...";
      
  String get chainChangeValue => _priceChange24h != null 
      ? "${_priceChange24h! >= 0 ? '↗' : '↘'} ${MarketDataService.formatPercentageChange(_priceChange24h!)}" 
      : "Loading...";
      
  String get currentValue => _currentPrice != null 
      ? MarketDataService.formatPrice(_currentPrice!) 
      : "Loading...";
      
  String get marketCap => _marketCap != null 
      ? MarketDataService.formatLargeNumber(_marketCap!) 
      : "Loading...";
      
  String get volume24h => _volume24h != null 
      ? MarketDataService.formatLargeNumber(_volume24h!) 
      : "Loading...";
      
  String get totalValue => _currentPrice != null && _chain != null
      ? MarketDataService.formatPrice(_currentPrice! * 1000) // Mock total value
      : "Loading...";

  List<String> get timeframes => ["24H", "7D", "1M", "6M", "1Y", "ALL"];
  
  List<Map<String, dynamic>>? get historicalData => _historicalData;

  void selectTimeframe(String timeframe) {
    _selectedTimeframe = timeframe;
    _loadHistoricalData();
    notifyListeners();
  }
  
  /// Initialize with chain data and load market data
  void initializeWithChain(SupportedChainModel chain) {
    if (_initialized && _chain?.chainId == chain.chainId) {
      return; // Already initialized with the same chain
    }
    
    _chain = chain;
    _initialized = true;
    _loadMarketData();
  }
  
  /// Load real-time market data
  Future<void> _loadMarketData() async {
    if (_chain == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      // Get basic price data
      final priceData = await MarketDataService.getChainPriceData(_chain!.chainId);
      
      if (priceData != null) {
        _currentPrice = priceData['price'];
        _priceChange24h = priceData['priceChange24h'];
        _marketCap = priceData['marketCap'];
        _volume24h = priceData['volume24h'];
        
        // Load historical data for chart
        await _loadHistoricalData();
      } else {
        _error = "Failed to load market data";
      }
    } catch (e) {
      _error = "Error loading market data: $e";
      print('❌ Error loading market data: $e');
    } finally {
      _isLoading = false;
      if (!_disposed) {
        notifyListeners();
      }
    }
  }
  
  /// Load historical data for chart
  Future<void> _loadHistoricalData() async {
    if (_chain == null || _isLoadingHistorical) return;
    
    _isLoadingHistorical = true;
    
    try {
      int days = 1; // Default to 1 day
      
      switch (_selectedTimeframe) {
        case "24H":
          days = 1;
          break;
        case "7D":
          days = 7;
          break;
        case "1M":
          days = 30;
          break;
        case "6M":
          days = 180;
          break;
        case "1Y":
          days = 365;
          break;
        case "ALL":
          days = 365;
          break;
      }
      
      _historicalData = await MarketDataService.getHistoricalData(_chain!.chainId, days);
      if (!_disposed) {
        notifyListeners();
      }
    } catch (e) {
      print('❌ Error loading historical data: $e');
    } finally {
      _isLoadingHistorical = false;
    }
  }
  
  /// Refresh market data
  Future<void> refreshData() async {
    await _loadMarketData();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
