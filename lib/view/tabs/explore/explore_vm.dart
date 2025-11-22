import 'package:flutter/material.dart';
import '../../../data/base_vm.dart';
import '../../../services/dapp_service.dart';

class ExploreVM extends BaseVM {
  // Controller for search bar — fixes reversed text issue
  final TextEditingController searchController = TextEditingController();

  List<DAppItem> _topDApps = [];
  List<DAppItem> _latestDApps = [];
  List<DAppItem> _allDApps = [];
  List<DAppItem> _searchResults = [];
  String _searchQuery = '';
  bool _isSearching = false;
  String _selectedFilter = 'Trending dApp'; // Default filter
  
  // Removed automatic browser opening callback

  List<DAppItem> get topDApps => _topDApps;
  List<DAppItem> get latestDApps => _latestDApps;
  List<DAppItem> get allDApps => _allDApps;
  List<DAppItem> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isSearching => _isSearching;
  bool get hasSearchResults => _searchResults.isNotEmpty;
  String get selectedFilter => _selectedFilter;

  ExploreVM() {
    _loadDAppData();

    // Clear any previous search state
    _searchQuery = '';
    _isSearching = false;
    _searchResults.clear();

    // Listen for controller changes so we always sync query
    searchController.addListener(() {
      searchDApps(searchController.text);
    });
  }

  void _loadDAppData() {
    final popularDApps = DAppService.getPopularDApps();
    final gamingDApps = DAppService.getGamingDApps();
    final allDAppsFromService = DAppService.getAllDApps();

    _topDApps = popularDApps
        .map((dapp) => DAppItem(
      name: dapp.name,
      image: dapp.imagePath,
      url: dapp.url,
    ))
        .toList();

    _latestDApps = gamingDApps
        .map((dapp) => DAppItem(
      name: dapp.name,
      image: dapp.imagePath,
      url: dapp.url,
    ))
        .toList();

    _allDApps = allDAppsFromService
        .map((dapp) => DAppItem(
      name: dapp.name,
      image: dapp.imagePath,
      url: dapp.url,
    ))
        .toList();
  }

  void refreshData() {
    _loadDAppData();
    notifyListeners();
  }

  /// Search dApps by query - provides search suggestions and options
  void searchDApps(String query) {
    _searchQuery = query.trim();
    _isSearching = _searchQuery.isNotEmpty;

    if (_isSearching) {
      _searchResults.clear();
      
      // Add search suggestions based on query
      List<DAppItem> suggestions = [];
      
      // If query looks like a URL, provide direct visit option
      if (query.startsWith('http://') || 
          query.startsWith('https://') ||
          (query.contains('.') && !query.contains(' ') && query.length > 3)) {
        // It's a URL - create a direct browser entry
        final finalUrl = query.startsWith('http') ? query : 'https://$query';
        suggestions.add(DAppItem(
          name: 'Visit: $query',
          image: 'assets/svgs/main_wallet/top_dApp/browser.png',
          url: finalUrl,
          isUrl: true,
        ));
      }
      
      // Always provide Google search option
      final searchUrl = 'https://www.google.com/search?q=${Uri.encodeComponent(query)}';
      suggestions.add(DAppItem(
        name: 'Search Google: $query',
        image: 'assets/svgs/main_wallet/top_dApp/search.png',
        url: searchUrl,
        isSearch: true,
      ));
      
      // Add popular dApp suggestions if query matches
      final matchingDApps = _allDApps.where((dapp) => 
        dapp.name.toLowerCase().contains(query.toLowerCase()) ||
        dapp.url.toLowerCase().contains(query.toLowerCase())
      ).take(3).toList();
      
      suggestions.addAll(matchingDApps);
      
      _searchResults = suggestions;
    } else {
      _searchResults.clear();
    }

    notifyListeners();
  }

  /// Clear search
  void clearSearch() {
    searchController.clear();
    _searchQuery = '';
    _isSearching = false;
    _searchResults.clear();
    notifyListeners();
  }

  /// Select filter
  void selectFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  /// Get filtered dApps based on selected filter
  List<DAppItem> getFilteredDApps() {
    if (_isSearching) {
      return _searchResults;
    }
    
    switch (_selectedFilter) {
      case 'Trending dApp':
        return _topDApps;
      case 'Latest dApp':
        return _latestDApps;
      case 'New dApp':
        // For now, return latest dApps as new dApps
        // You can implement separate new dApps logic later
        return _latestDApps;
      default:
        return _topDApps;
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}

class DAppItem {
  final String name;
  final String image;
  final String url;
  final bool isUrl;
  final bool isSearch;

  DAppItem({
    required this.name,
    required this.image,
    required this.url,
    this.isUrl = false,
    this.isSearch = false,
  });
}
