import 'package:flutter/material.dart';
import 'package:iris_app/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WarehouseProductsScreen extends StatefulWidget {
  const WarehouseProductsScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseProductsScreen> createState() =>
      _WarehouseProductsScreenState();
}

class _WarehouseProductsScreenState extends State<WarehouseProductsScreen>
    with SingleTickerProviderStateMixin {
  String _selectedSection = 'Warehouse';
  DateTime _selectedDate = DateTime.now();
  late TabController _tabController;
  
  List<Map<String, dynamic>> _warehouseProducts = [];
  List<Map<String, dynamic>> _groceryProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this); // Changed to 1 since you only have warehouse

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setState(() => _selectedSection = 'Warehouse');
      }
    });
    
    _fetchProducts();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Format selected date as YYYY-MM-DD
      final selectedDateStr = 
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';

      // Fetch products with category information filtered by date
      final response = await supabase
          .from('product_count')
          .select('''
            scanning_count,
            scanning_date,
            category_id,
            categories (
              id,
              name,
              total_counts
            )
          ''')
          .eq('scanning_date', selectedDateStr); // Filter by selected date

      // Group products by category_id to avoid duplicates and sum counts
      final Map<int, Map<String, dynamic>> productMap = {};

      for (var item in response) {
        final category = item['categories'];
        if (category != null) {
          final categoryId = item['category_id'] as int;
          final scanningCount = item['scanning_count'] as int? ?? 0;
          final actualCount = category['total_counts'] as int? ?? 0;

          // If category already exists, add to scanning count
          if (productMap.containsKey(categoryId)) {
            productMap[categoryId]!['scanningCount'] += scanningCount;
          } else {
            productMap[categoryId] = {
              'name': category['name'],
              'actualCount': actualCount,
              'scanningCount': scanningCount,
              'scanningDate': item['scanning_date'],
              'categoryId': categoryId,
            };
          }
        }
      }

      // Convert map to list
      final warehouse = productMap.values.toList();

      setState(() {
        _warehouseProducts = warehouse;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading products: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(), // Don't allow future dates
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      // Fetch products for the new date
      _fetchProducts();
    }
  }

  // Calculate dynamic totals based on current products
  int _getTotalProducts() {
    final products = _selectedSection == 'Warehouse' 
        ? _warehouseProducts 
        : _groceryProducts;
    return products.length;
  }

  int _getTotalActual() {
    final products = _selectedSection == 'Warehouse' 
        ? _warehouseProducts 
        : _groceryProducts;
    return products.fold<int>(0, (sum, product) => 
        sum + (product['actualCount'] as int? ?? 0));
  }

  int _getTotalScanned() {
    final products = _selectedSection == 'Warehouse' 
        ? _warehouseProducts 
        : _groceryProducts;
    return products.fold<int>(0, (sum, product) => 
        sum + (product['scanningCount'] as int? ?? 0));
  }

  int _getDiscrepancy() {
    return _getTotalActual() - _getTotalScanned();
  }

  @override
  Widget build(BuildContext context) {
    final totalProducts = _getTotalProducts();
    final totalActual = _getTotalActual();
    final totalScanned = _getTotalScanned();
    final discrepancy = _getDiscrepancy();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Products'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchProducts,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(
              color: AppColors.primaryBlue,
            ))
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, 
                          size: 48, color: AppColors.error),
                      const SizedBox(height: 16),
                      Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                        ),
                        child: const Text('Retry',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Tab Bar Section
                    Container(
                      margin: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.grey.shade300, width: 1),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: AppColors.primaryBlue,
                        indicatorWeight: 3,
                        labelColor: AppColors.primaryBlue,
                        unselectedLabelColor: Colors.grey,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.warehouse_outlined, size: 18),
                            text: 'Warehouse',
                          ),
                        ],
                      ),
                    ),

                    // Date Picker
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.mediumGrey),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    color: AppColors.primaryBlue,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: AppColors.primaryBlue,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Summary Cards - Now Dynamic
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Products',
                                  totalProducts.toString(),
                                  Icons.inventory_2,
                                  AppColors.info,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Discrepancy',
                                  discrepancy.abs().toString(),
                                  Icons.warning,
                                  discrepancy == 0
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Actual',
                                  totalActual.toString(),
                                  Icons.check_circle,
                                  AppColors.primaryBlue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Scanned',
                                  totalScanned.toString(),
                                  Icons.qr_code_scanner,
                                  AppColors.success,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // TabBarView (product lists)
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildProductList(_warehouseProducts),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildProductList(List<Map<String, dynamic>> products) {
    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, 
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No products found for selected date',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedDate = DateTime.now();
                });
                _fetchProducts();
              },
              icon: const Icon(Icons.today),
              label: const Text('Show Today'),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final actualCount = product['actualCount'] as int? ?? 0;
        final scanningCount = product['scanningCount'] as int? ?? 0;
        final scanningDate = product['scanningDate'] as String? ?? 'N/A';
        final difference = actualCount - scanningCount;
        final hasDiscrepancy = difference != 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product['name'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (hasDiscrepancy)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          difference > 0 ? '+$difference' : '$difference',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Match',
                          style: TextStyle(
                            color: AppColors.success,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Product Counts
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Actual Count',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            actualCount.toString(),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.mediumGrey,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Scanning Count',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scanningCount.toString(),
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: hasDiscrepancy
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      scanningDate,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
      String label, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}