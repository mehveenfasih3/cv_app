import 'package:flutter/material.dart';
import 'package:iris_app/app_colors.dart';
import 'package:iris_app/product_class.dart';

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

  final Map<String, List<Product>> _products = {
    'Warehouse': [
      Product(
        name: 'Ketchup',
        actualCount: 25,
        scanningCount: 23,
        date: DateTime(2025, 10, 24),
        section: 'Warehouse',
      ),
      Product(
        name: 'Mayonnaise',
        actualCount: 30,
        scanningCount: 30,
        date: DateTime(2025, 10, 24),
        section: 'Warehouse',
      ),
      Product(
        name: 'Mustard',
        actualCount: 20,
        scanningCount: 18,
        date: DateTime(2025, 10, 24),
        section: 'Warehouse',
      ),
    ],
    'Grocery': [
      Product(
        name: 'Rice',
        actualCount: 100,
        scanningCount: 98,
        date: DateTime(2025, 10, 24),
        section: 'Grocery',
      ),
      Product(
        name: 'Flour',
        actualCount: 75,
        scanningCount: 75,
        date: DateTime(2025, 10, 24),
        section: 'Grocery',
      ),
      Product(
        name: 'Sugar',
        actualCount: 50,
        scanningCount: 47,
        date: DateTime(2025, 10, 24),
        section: 'Grocery',
      ),
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index == 0) {
        setState(() => _selectedSection = 'Warehouse');
      } else {
        setState(() => _selectedSection = 'Grocery');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final products = _products[_selectedSection]!;
    final totalProducts = products.length;
    final totalActual =
        products.fold(0, (sum, product) => sum + product.actualCount);
    final totalScanned =
        products.fold(0, (sum, product) => sum + product.scanningCount);
    final discrepancy = totalActual - totalScanned;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Warehouse Products'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Column(
        children: [
          // ✅ Tab Bar Section
          Container(
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1),
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
                Tab(
                  icon: Icon(Icons.storefront_outlined, size: 18),
                  text: 'Grocery',
                ),
              ],
            ),
          ),

          // ✅ Date Picker
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

          // ✅ Summary Cards
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: Row(
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
                    discrepancy.toString(),
                    Icons.warning,
                    discrepancy > 0 ? AppColors.error : AppColors.success,
                  ),
                ),
              ],
            ),
          ),

          // ✅ TabBarView (product lists)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildProductList(_products['Warehouse']!),
                _buildProductList(_products['Grocery']!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final hasDiscrepancy = product.actualCount != product.scanningCount;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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
                        child: const Text(
                          'Mismatch',
                          style: TextStyle(
                            color: AppColors.error,
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
                            product.actualCount.toString(),
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
                            product.scanningCount.toString(),
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
                Text(
                  'Date: ${product.date.day}/${product.date.month}/${product.date.year}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
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
