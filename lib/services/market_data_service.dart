import 'package:dio/dio.dart';

class MarketDataService {
  static const String _baseUrl = 'https://api.coingecko.com/api/v3';
  static final Dio _dio = Dio();
  
  // Cache to avoid rate limiting
  static final Map<String, Map<String, dynamic>> _priceCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 15); // Cache for 15 minutes
  
  // Historical data cache
  static final Map<String, List<Map<String, dynamic>>> _historicalCache = {};
  static final Map<String, DateTime> _historicalCacheTimestamps = {};
  static const Duration _historicalCacheExpiry = Duration(hours: 2); // Cache for 2 hours
  
  // Alternative API endpoints
  static const String _alternativeApiUrl = 'https://api.coinlore.net/api';

  // Map chain IDs to CoinGecko IDs
  static const Map<String, String> _chainIdToCoinGeckoId = {
    'ethereum': 'ethereum',
    'bsc': 'binancecoin',
    'polygon': 'matic-network',
    'arbitrum': 'ethereum', // Arbitrum uses ETH
    'optimism': 'ethereum', // Optimism uses ETH
  };

  // Map chain IDs to CoinLore IDs
  static const Map<String, String> _chainIdToCoinLoreId = {
    'ethereum': '80', // Ethereum ID in CoinLore
    'bsc': '1839', // BNB ID in CoinLore
    'polygon': '3890', // MATIC ID in CoinLore
    'arbitrum': '80', // Arbitrum uses ETH
    'optimism': '80', // Optimism uses ETH
  };

  // Fallback data for when API fails
  static const Map<String, Map<String, dynamic>> _fallbackData = {
    'ethereum': {
      'price': 2500.0,
      'priceChange24h': 2.5,
      'marketCap': 300000000000.0,
      'volume24h': 15000000000.0,
    },
    'bsc': {
      'price': 300.0,
      'priceChange24h': 1.8,
      'marketCap': 45000000000.0,
      'volume24h': 2000000000.0,
    },
    'polygon': {
      'price': 0.85,
      'priceChange24h': -1.2,
      'marketCap': 8000000000.0,
      'volume24h': 500000000.0,
    },
    'arbitrum': {
      'price': 2500.0,
      'priceChange24h': 2.5,
      'marketCap': 300000000000.0,
      'volume24h': 15000000000.0,
    },
    'optimism': {
      'price': 2500.0,
      'priceChange24h': 2.5,
      'marketCap': 300000000000.0,
      'volume24h': 15000000000.0,
    },
  };

  /// Get real-time price data for a chain
  static Future<Map<String, dynamic>?> getChainPriceData(String chainId) async {
    // Check cache first
    if (_isCacheValid(chainId)) {
      print('📦 Using cached data for $chainId');
      return _priceCache[chainId];
    }

    // Try to get real data from multiple APIs
    Map<String, dynamic>? result = await _tryGetRealData(chainId);
    
    if (result != null) {
      // Cache the real data
      _priceCache[chainId] = result;
      _cacheTimestamps[chainId] = DateTime.now();
      print('✅ Successfully fetched and cached real data for $chainId');
      return result;
    }
    
    // If all APIs fail, use fallback data
    print('🔄 All APIs failed, using fallback data for $chainId');
    return _getFallbackData(chainId);
  }

  /// Try to get real data from multiple APIs
  static Future<Map<String, dynamic>?> _tryGetRealData(String chainId) async {
    // Try CoinGecko first
    Map<String, dynamic>? result = await _tryCoinGecko(chainId);
    if (result != null) return result;
    
    // Try CoinLore as backup
    result = await _tryCoinLore(chainId);
    if (result != null) return result;
    
    return null;
  }

  /// Try CoinGecko API
  static Future<Map<String, dynamic>?> _tryCoinGecko(String chainId) async {
    try {
      final coinGeckoId = _chainIdToCoinGeckoId[chainId];
      if (coinGeckoId == null) return null;

      print('🌐 Trying CoinGecko for $chainId...');
      final response = await _dio.get(
        '$_baseUrl/simple/price',
        queryParameters: {
          'ids': coinGeckoId,
          'vs_currencies': 'usd',
          'include_24hr_change': 'true',
          'include_market_cap': 'true',
          'include_24hr_vol': 'true',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data[coinGeckoId];
        if (data != null) {
          return {
            'price': data['usd']?.toDouble() ?? 0.0,
            'priceChange24h': data['usd_24h_change']?.toDouble() ?? 0.0,
            'marketCap': data['usd_market_cap']?.toDouble() ?? 0.0,
            'volume24h': data['usd_24h_vol']?.toDouble() ?? 0.0,
          };
        }
      }
    } catch (e) {
      print('❌ CoinGecko failed for $chainId: $e');
      if (e is DioException && e.response?.statusCode == 429) {
        print('⚠️ CoinGecko rate limited, will try alternative API');
      }
    }
    return null;
  }

  /// Try CoinLore API
  static Future<Map<String, dynamic>?> _tryCoinLore(String chainId) async {
    try {
      final coinLoreId = _chainIdToCoinLoreId[chainId];
      if (coinLoreId == null) return null;

      print('🌐 Trying CoinLore for $chainId...');
      final response = await _dio.get(
        '$_alternativeApiUrl/ticker/?id=$coinLoreId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as List;
        if (data.isNotEmpty) {
          final coinData = data[0];
          return {
            'price': double.tryParse(coinData['price_usd']?.toString() ?? '0') ?? 0.0,
            'priceChange24h': double.tryParse(coinData['percent_change_24h']?.toString() ?? '0') ?? 0.0,
            'marketCap': double.tryParse(coinData['market_cap_usd']?.toString() ?? '0') ?? 0.0,
            'volume24h': double.tryParse(coinData['volume24']?.toString() ?? '0') ?? 0.0,
          };
        }
      }
    } catch (e) {
      print('❌ CoinLore failed for $chainId: $e');
    }
    return null;
  }

  /// Check if cache is valid
  static bool _isCacheValid(String chainId) {
    final timestamp = _cacheTimestamps[chainId];
    if (timestamp == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference < _cacheExpiry && _priceCache.containsKey(chainId);
  }

  /// Get fallback data when API fails
  static Map<String, dynamic>? _getFallbackData(String chainId) {
    final fallback = _fallbackData[chainId];
    if (fallback != null) {
      print('🔄 Using fallback data for $chainId');
      return Map<String, dynamic>.from(fallback);
    }
    return null;
  }

  /// Get detailed market data for a chain
  static Future<Map<String, dynamic>?> getDetailedMarketData(String chainId) async {
    try {
      final coinGeckoId = _chainIdToCoinGeckoId[chainId];
      if (coinGeckoId == null) {
        print('❌ No CoinGecko ID found for chain: $chainId');
        return null;
      }

      final response = await _dio.get(
        '$_baseUrl/coins/$coinGeckoId',
        queryParameters: {
          'localization': 'false',
          'tickers': 'false',
          'market_data': 'true',
          'community_data': 'false',
          'developer_data': 'false',
          'sparkline': 'false',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final marketData = response.data['market_data'];
        if (marketData != null) {
          return {
            'currentPrice': marketData['current_price']?['usd']?.toDouble() ?? 0.0,
            'priceChange24h': marketData['price_change_24h']?.toDouble() ?? 0.0,
            'priceChangePercentage24h': marketData['price_change_percentage_24h']?.toDouble() ?? 0.0,
            'marketCap': marketData['market_cap']?['usd']?.toDouble() ?? 0.0,
            'totalVolume': marketData['total_volume']?['usd']?.toDouble() ?? 0.0,
            'high24h': marketData['high_24h']?['usd']?.toDouble() ?? 0.0,
            'low24h': marketData['low_24h']?['usd']?.toDouble() ?? 0.0,
            'circulatingSupply': marketData['circulating_supply']?.toDouble() ?? 0.0,
            'totalSupply': marketData['total_supply']?.toDouble() ?? 0.0,
          };
        }
      }
    } catch (e) {
      print('❌ Error fetching detailed market data for $chainId: $e');
    }
    return null;
  }

  /// Get historical price data for chart
  static Future<List<Map<String, dynamic>>?> getHistoricalData(
    String chainId, 
    int days
  ) async {
    final cacheKey = '${chainId}_$days';
    
    // Check cache first
    if (_isHistoricalCacheValid(cacheKey)) {
      print('📦 Using cached historical data for $chainId ($days days)');
      return _historicalCache[cacheKey];
    }
    
    // Try to get real historical data
    List<Map<String, dynamic>>? result = await _tryGetRealHistoricalData(chainId, days);
    
    if (result != null) {
      // Cache the real data
      _historicalCache[cacheKey] = result;
      _historicalCacheTimestamps[cacheKey] = DateTime.now();
      print('✅ Successfully fetched and cached real historical data for $chainId');
      return result;
    }
    
    // If all APIs fail, use fallback historical data
    print('🔄 All APIs failed, using fallback historical data for $chainId');
    return _getFallbackHistoricalData(chainId, days);
  }

  /// Try to get real historical data from multiple APIs
  static Future<List<Map<String, dynamic>>?> _tryGetRealHistoricalData(String chainId, int days) async {
    // Try CoinGecko first
    List<Map<String, dynamic>>? result = await _tryCoinGeckoHistorical(chainId, days);
    if (result != null) return result;
    
    // For now, only use CoinGecko for historical data
    // CoinLore doesn't have good historical data API
    return null;
  }

  /// Try CoinGecko historical data
  static Future<List<Map<String, dynamic>>?> _tryCoinGeckoHistorical(String chainId, int days) async {
    try {
      final coinGeckoId = _chainIdToCoinGeckoId[chainId];
      if (coinGeckoId == null) return null;

      print('📈 Trying CoinGecko historical data for $chainId ($days days)...');
      final response = await _dio.get(
        '$_baseUrl/coins/$coinGeckoId/market_chart',
        queryParameters: {
          'vs_currency': 'usd',
          'days': days.toString(),
          'interval': days <= 1 ? 'hourly' : 'daily',
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final prices = response.data['prices'] as List?;
        if (prices != null) {
          return prices.map((price) => {
            'timestamp': price[0],
            'price': price[1]?.toDouble() ?? 0.0,
          }).toList();
        }
      }
    } catch (e) {
      print('❌ CoinGecko historical failed for $chainId: $e');
    }
    return null;
  }


  /// Check if historical cache is valid
  static bool _isHistoricalCacheValid(String cacheKey) {
    final timestamp = _historicalCacheTimestamps[cacheKey];
    if (timestamp == null) return false;
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    return difference < _historicalCacheExpiry && _historicalCache.containsKey(cacheKey);
  }


  /// Generate fallback historical data
  static List<Map<String, dynamic>>? _getFallbackHistoricalData(String chainId, int days) {
    final fallback = _fallbackData[chainId];
    if (fallback == null) return null;
    
    print('🔄 Using fallback historical data for $chainId');
    
    final basePrice = fallback['price'] as double;
    final dataPoints = days <= 1 ? 24 : days; // Hourly for 1 day, daily for others
    final now = DateTime.now();
    
    List<Map<String, dynamic>> historicalData = [];
    
    for (int i = dataPoints; i >= 0; i--) {
      final timestamp = now.subtract(Duration(
        hours: days <= 1 ? i : i * 24,
      ));
      
      // Generate some price variation
      final variation = (i % 3 - 1) * 0.05; // -5%, 0%, +5% variation
      final price = basePrice * (1 + variation);
      
      historicalData.add({
        'timestamp': timestamp.millisecondsSinceEpoch,
        'price': price,
      });
    }
    
    return historicalData;
  }

  /// Format price for display
  static String formatPrice(double price) {
    if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(2)}k';
    } else if (price >= 1) {
      return '${price.toStringAsFixed(2)}';
    } else {
      return '${price.toStringAsFixed(6)}';
    }
  }

  /// Format large numbers (market cap, volume)
  static String formatLargeNumber(double number) {
    if (number >= 1e12) {
      return '${(number / 1e12).toStringAsFixed(2)}T';
    } else if (number >= 1e9) {
      return '${(number / 1e9).toStringAsFixed(2)}B';
    } else if (number >= 1e6) {
      return '${(number / 1e6).toStringAsFixed(2)}M';
    } else if (number >= 1e3) {
      return '${(number / 1e3).toStringAsFixed(2)}K';
    } else {
      return '${number.toStringAsFixed(2)}';
    }
  }

  /// Format percentage change
  static String formatPercentageChange(double change) {
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(2)}%';
  }
}
