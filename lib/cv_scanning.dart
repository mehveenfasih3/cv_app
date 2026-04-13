import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iris_app/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Map<String, dynamic> staffData;

  const CameraPage({Key? key, required this.cameras, required this.staffData})
    : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  final supabase = Supabase.instance.client;
  get staffData => widget.staffData;

  bool isProcessing = false;
  bool _isCameraInitialized = false;
  Timer? _detectionTimer;

  String? _selectedModelType; // 'entrance_exit' or 'warehouse'
  String? _selectedSection; // 'chocolates', 'snacks', etc.
  String? _movementType; // 'IN' or 'OUT'
  String _modelDisplayName = "";

  // Warehouse mode: class_name → count
  Map<String, int> _detectedObjects = {};

  // Entrance/Exit mode: product_name → full QR field map
  // {
  //   'kitkat_chocolate': {
  //     'qty': 16, 'type': 'IN', 'warehouse_id': 25,
  //     'date': '2026-04-13', 'expiry_date': '2027-10-08',
  //     'cost_price': 70, 'raw': '<original qr string>'
  //   }
  // }
  Map<String, Map<String, dynamic>> _qrDetectedItems = {};

  String resultText = "";

  // ─────────────────────────────────────────────────────────────
  // INIT
  // ─────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showModelSelectionDialog();
    });
  }

  // ─────────────────────────────────────────────────────────────
  // QR TEXT PARSER
  //
  // Handles both ':' and '=' as delimiters so it works with:
  //   product:kitkat_chocolate
  //   quantity:16
  //   type:IN
  //   warehouse_id:25
  //   date:2026-04-13
  //   expiry_date:2027-10-08
  //   cost_price:70          ← or cost_price=70
  // ─────────────────────────────────────────────────────────────
  Map<String, String> _parseQRText(String qrText) {
    final Map<String, String> result = {};
    for (final rawLine in qrText.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty) continue;

      // Try ':' first, then '='
      int idx = line.indexOf(':');
      if (idx == -1) idx = line.indexOf('=');
      if (idx == -1) continue;

      final key = line.substring(0, idx).trim().toLowerCase();
      final value = line.substring(idx + 1).trim();
      result[key] = value;
    }
    return result;
  }

  // ─────────────────────────────────────────────────────────────
  // SAFE TYPE HELPERS
  // ─────────────────────────────────────────────────────────────

  /// Converts String, int, or double safely to int.
  int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return double.tryParse(value)?.toInt();
    return null;
  }

  /// Converts String or num safely to double.
  double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // DIALOGS
  // ─────────────────────────────────────────────────────────────

  Future<void> _showModelSelectionDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: AppColors.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detection Mode',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Select a mode to continue',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _buildDialogOption(
                title: 'Entrance / Exit',
                description: 'Scan QR codes & manage entry items',
                icon: Icons.qr_code_scanner_rounded,
                value: 'entrance_exit',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildDialogOption(
                title: 'Warehouse',
                description: 'Detect & classify product sections',
                icon: Icons.inventory_2_rounded,
                value: 'warehouse',
                color: Colors.green,
              ),
              const SizedBox(height: 24),
              _cancelButton(() => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );

    if (result == 'entrance_exit') {
      await _showMovementTypeDialog();
    } else if (result == 'warehouse') {
      await _showWarehouseSectionDialog();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  Future<void> _showMovementTypeDialog() async {
    final result = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogHeader(
                icon: Icons.swap_horiz_rounded,
                color: Colors.blue,
                title: 'Movement Type',
                subtitle: 'Entry or Exit?',
                onBack: () {
                  Navigator.pop(context);
                  _showModelSelectionDialog();
                },
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _buildDialogOption(
                title: 'Entry (Stock IN)',
                description: 'Products entering the warehouse',
                icon: Icons.login_rounded,
                value: 'IN',
                color: Colors.green,
                tinted: true,
              ),
              const SizedBox(height: 12),
              _buildDialogOption(
                title: 'Exit (Stock OUT)',
                description: 'Products leaving the warehouse',
                icon: Icons.logout_rounded,
                value: 'OUT',
                color: Colors.red,
                tinted: true,
              ),
              const SizedBox(height: 24),
              _cancelButton(() => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedModelType = 'entrance_exit';
        _selectedSection = null;
        _movementType = result;
        _modelDisplayName = result == 'IN'
            ? 'Entrance (Stock IN)'
            : 'Exit (Stock OUT)';
      });
      _initializeCamera();
    } else {
      if (mounted) _showModelSelectionDialog();
    }
  }

  Future<void> _showWarehouseSectionDialog() async {
    final section = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dialogHeader(
                icon: Icons.category_rounded,
                color: AppColors.primaryBlue,
                title: 'Warehouse Section',
                subtitle: 'Choose a section to scan',
                onBack: () {
                  Navigator.pop(context);
                  _showModelSelectionDialog();
                },
              ),
              const SizedBox(height: 24),
              const Divider(height: 1),
              const SizedBox(height: 24),
              _buildDialogOption(
                title: 'Chocolates',
                description: 'Detect & classify chocolate products',
                icon: Icons.cake_rounded,
                value: 'chocolates',
                color: Colors.brown,
              ),
              const SizedBox(height: 12),
              _buildDialogOption(
                title: 'Snacks',
                description: 'Detect & classify snack items',
                icon: Icons.fastfood_rounded,
                value: 'snacks',
                color: Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildDialogOption(
                title: 'Beverages',
                description: 'Detect & classify drink products',
                icon: Icons.local_drink_rounded,
                value: 'beverages',
                color: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildDialogOption(
                title: 'Dairy',
                description: 'Detect & classify dairy products',
                icon: Icons.water_drop_rounded,
                value: 'dairy',
                color: Colors.lightBlue,
              ),
              const SizedBox(height: 24),
              _cancelButton(() => Navigator.pop(context)),
            ],
          ),
        ),
      ),
    );

    if (section != null) {
      setState(() {
        _selectedModelType = 'warehouse';
        _selectedSection = section;
        _movementType = null;
        _modelDisplayName = _getSectionDisplayName(section);
      });
      _initializeCamera();
    } else {
      if (mounted) _showModelSelectionDialog();
    }
  }

  // ─────────────────────────────────────────────────────────────
  // DIALOG WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _dialogHeader({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onBack,
  }) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDialogOption({
    required String title,
    required String description,
    required IconData icon,
    required String value,
    required Color color,
    bool tinted = false,
  }) {
    return InkWell(
      onTap: () => Navigator.pop(context, value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: tinted ? color.withOpacity(0.4) : Colors.grey.shade300,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: tinted ? color.withOpacity(0.04) : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: tinted ? color : null,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _cancelButton(VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade300),
          ),
        ),
        child: const Text(
          'Cancel',
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // CAMERA
  // ─────────────────────────────────────────────────────────────

  Future<void> _initializeCamera() async {
    try {
      if (widget.cameras.isEmpty) {
        _showError('No cameras available');
        return;
      }
      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller!.initialize();
      await controller!.setFocusMode(FocusMode.auto);
      await controller!.setExposureMode(ExposureMode.auto);
      if (!mounted) return;
      setState(() => _isCameraInitialized = true);
      _startAutoDetection();
    } catch (e) {
      _showError('Camera initialization failed: $e');
    }
  }

  void _startAutoDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (_isCameraInitialized && !isProcessing && mounted) {
        captureAndDetect();
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  // DETECTION
  // ─────────────────────────────────────────────────────────────

  Future<void> captureAndDetect() async {
    if (controller == null || !controller!.value.isInitialized) return;
    if (controller!.value.isTakingPicture) return;
    if (isProcessing) return;
    if (_selectedModelType == null) return;

    setState(() => isProcessing = true);

    try {
      final image = await controller!.takePicture();
      final bytes = await image.readAsBytes();
      final b64Image = base64Encode(bytes);

      final response = await http
          .post(
            Uri.parse("http://192.168.100.171:5000/detect"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "image": b64Image,
              "model_type": _selectedModelType,
              "section": _selectedSection,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final bool ok = body["success"] == true;
        final List dets = ok ? (body["detections"] ?? []) : [];

        if (ok && dets.isNotEmpty) {
          for (final det in dets) {
            final String className = det['class'] as String;
            final double confidence = (det['confidence'] as num).toDouble();
            final String? qrText = det['qr_text'] as String?;

            if (confidence < 0.5) continue;

            if (_selectedModelType == 'entrance_exit' && qrText != null) {
              // ── Parse every field from the QR payload ─────────────────
              final qr = _parseQRText(qrText);

              // Accept 'quantity' OR 'qty' as the quantity key
              final product = qr['product'];
              final qty = _toInt(qr['quantity'] ?? qr['qty']) ?? 1;
              final type = (qr['type'] ?? _movementType ?? 'IN')
                  .toString()
                  .toUpperCase();
              final widRaw = qr['warehouse_id'];
              final wid =
                  _toInt(widRaw) ?? _toInt(staffData['warehouse_id']) ?? 0;
              final date = qr['date'];
              final expiryDate = qr['expiry_date'];
              final costPrice = _toDouble(qr['cost_price']);

              if (product != null && product.isNotEmpty) {
                _qrDetectedItems[product] = {
                  'qty': qty,
                  'type': type,
                  'warehouse_id': wid,
                  'date': date,
                  'expiry_date': expiryDate,
                  'cost_price': costPrice,
                  'raw': qrText,
                };
                print(
                  'QR parsed → product=$product  qty=$qty  type=$type  '
                  'wid=$wid  date=$date  expiry=$expiryDate  cost=$costPrice',
                );
              }
            } else if (_selectedModelType != 'entrance_exit') {
              // ── Warehouse: accumulate detection counts ─────────────────
              _detectedObjects[className] =
                  (_detectedObjects[className] ?? 0) + 1;
            }
          }

          setState(() {
            resultText = dets
                .map(
                  (e) =>
                      "${e['class']} (${(e['confidence'] as num).toStringAsFixed(2)})",
                )
                .join("\n");
          });
        } else {
          setState(() => resultText = "No objects detected");
        }
      } else {
        setState(() => resultText = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Detection error: $e");
      setState(() => resultText = "Error: $e");
    } finally {
      if (mounted) setState(() => isProcessing = false);
    }
  }

  // ─────────────────────────────────────────────────────────────
  // SAVE TO DATABASE
  // ─────────────────────────────────────────────────────────────

  Future<void> _saveToDatabaseAndFinalize() async {
    final isEntrance = _selectedModelType == 'entrance_exit';

    if (isEntrance && _qrDetectedItems.isEmpty) {
      _showError('No QR items detected to save');
      return;
    }
    if (!isEntrance && _detectedObjects.isEmpty) {
      _showError('No objects detected to save');
      return;
    }

    try {
      _showLoadingDialog();

      final today = DateTime.now();
      final todayStr =
          '${today.year}-'
          '${today.month.toString().padLeft(2, '0')}-'
          '${today.day.toString().padLeft(2, '0')}';

      final warehouseId = _toInt(staffData['warehouse_id']) ?? 0;

      // Fetch categories and build a normalized name → id map
      final cats = await supabase.from('categories').select('id, name');
      final Map<String, int> categoryMap = {};
      for (final c in cats) {
        final norm = _normalize(c['name'].toString());
        categoryMap[norm] = c['id'] as int;
      }
      print('Category map: $categoryMap');

      if (isEntrance) {
        await _saveInventoryMovements(categoryMap, warehouseId, todayStr);
      } else {
        await _saveProductCount(categoryMap, todayStr);
      }

      if (mounted) {
        Navigator.pop(context); // close loading
        _showSuccessDialog(
          isEntrance
              ? 'Inventory movements saved successfully!'
              : 'Product scan counts saved successfully!',
        );
        setState(() {
          _detectedObjects.clear();
          _qrDetectedItems.clear();
          resultText = "";
        });
      }
    } catch (e, st) {
      print('Error saving: $e\n$st');
      if (mounted) {
        Navigator.pop(context);
        _showError('Error saving: $e');
      }
    }
  }

  /// Normalize a category/product name for consistent matching.
  String _normalize(String s) =>
      s.toLowerCase().trim().replaceAll(' ', '_').replaceAll('-', '_');

  /// Insert rows into `inventory_movements`.
  Future<void> _saveInventoryMovements(
    Map<String, int> categoryMap,
    int warehouseId,
    String todayStr,
  ) async {
    final List<String> notFound = [];
    final List<Map<String, dynamic>> toInsert = [];

    for (final entry in _qrDetectedItems.entries) {
      final productName = entry.key;
      final data = entry.value;
      final norm = _normalize(productName);
      final categoryId = categoryMap[norm];

      print('QR "$productName" → norm="$norm" → id=$categoryId');

      if (categoryId == null) {
        notFound.add(productName);
        continue;
      }

      // All fields safely cast
      final movType =
          (data['type'] as String?)?.toUpperCase() ?? _movementType ?? 'IN';
      final rawQty = data['qty'];

final qty = (rawQty is int)
    ? rawQty
    : (rawQty is double)
        ? rawQty.toInt()
        : (rawQty is String)
            ? double.tryParse(rawQty)?.toInt() ?? 1
            : 1;
      // final qty = _toInt(data['qty']) ?? 1;

      final wid = _toInt(data['warehouse_id']) ?? warehouseId;
      final recvDate = _nonEmpty(data['date']) ?? todayStr;
      final expiryDate = _nonEmpty(data['expiry_date']); // nullable
      final rawCost = data['cost_price'];

final costPrice = (rawCost is int)
    ? rawCost
    : (rawCost is double)
        ? rawCost.toInt()
        : (rawCost is String)
            ? double.tryParse(rawCost)?.toInt()
            : null;
      final sku = 'SKU-$categoryId-${DateTime.now().millisecondsSinceEpoch}';

      final row = <String, dynamic>{
        'sku': sku,
        'category_id': categoryId,
        'received_date': recvDate,
        'movement_type': movType,
        'quantity': qty,
        'warehouse_id': wid,
        'reason': movType == 'IN' ? 'Stock Replenishment' : 'Sale / Dispatch',
      };

      // Only include optional columns when the value is actually present
      if (expiryDate != null) row['expiry_date'] = expiryDate;
      if (costPrice != null) row['cost_price'] = costPrice;

      toInsert.add(row);
      print('Queued insert: $row');
    }

    if (toInsert.isNotEmpty) {
      print('Inserting ${toInsert.length} row(s) into inventory_movements');
      await supabase.from('inventory_movements').insert(toInsert);
    }

    if (notFound.isNotEmpty) {
      _showError('Not found in categories: ${notFound.join(", ")}');
    }
  }

  /// Upsert rows in `product_count` for warehouse scanning.
  Future<void> _saveProductCount(
    Map<String, int> categoryMap,
    String todayStr,
  ) async {
    final List<String> notFound = [];
    final List<Map<String, dynamic>> toInsert = [];

    for (final entry in _detectedObjects.entries) {
      final norm = _normalize(entry.key);
      final categoryId = categoryMap[norm];
      final count = entry.value;

      print('Warehouse "${entry.key}" → norm="$norm" → id=$categoryId');

      if (categoryId == null) {
        notFound.add(entry.key);
        continue;
      }

      final existing = await supabase
          .from('product_count')
          .select('category_id, scanning_count')
          .eq('category_id', categoryId)
          .eq('scanning_date', todayStr)
          .maybeSingle();

      if (existing != null) {
        final newCount = (existing['scanning_count'] as int? ?? 0) + count;
        await supabase
            .from('product_count')
            .update({'scanning_count': newCount})
            .eq('category_id', categoryId)
            .eq('scanning_date', todayStr);
        print('Updated product_count $categoryId → $newCount');
      } else {
        toInsert.add({
          'category_id': categoryId,
          'scanning_count': count,
          'scanning_date': todayStr,
        });
      }
    }

    if (toInsert.isNotEmpty) {
      await supabase.from('product_count').insert(toInsert);
      print('Inserted ${toInsert.length} product_count row(s)');
    }

    if (notFound.isNotEmpty) {
      _showError('Not found in categories: ${notFound.join(", ")}');
    }
  }

  /// Returns null if the string is null or empty.
  String? _nonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  // ─────────────────────────────────────────────────────────────
  // UI HELPERS
  // ─────────────────────────────────────────────────────────────

  String _getSectionDisplayName(String section) {
    const map = {
      'chocolates': 'Chocolates',
      'snacks': 'Snacks',
      'beverages': 'Beverages',
      'dairy': 'Dairy',
    };
    return map[section] ?? 'Warehouse';
  }

  Color _getModelColor() {
    if (_selectedModelType == 'entrance_exit') {
      return _movementType == 'OUT' ? Colors.red : Colors.green;
    }
    const map = <String, Color>{
      'chocolates': Colors.brown,
      'snacks': Colors.orange,
      'beverages': Colors.blue,
      'dairy': Colors.lightBlue,
    };
    return map[_selectedSection] ?? Colors.green;
  }

  IconData _getModelIcon() {
    if (_selectedModelType == 'entrance_exit') {
      return _movementType == 'OUT'
          ? Icons.logout_rounded
          : Icons.login_rounded;
    }
    const map = <String, IconData>{
      'chocolates': Icons.cake_rounded,
      'snacks': Icons.fastfood_rounded,
      'beverages': Icons.local_drink_rounded,
      'dairy': Icons.water_drop_rounded,
    };
    return map[_selectedSection] ?? Icons.inventory_2_rounded;
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Saving to database...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Success'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _changeModel() {
    _detectionTimer?.cancel();
    setState(() {
      _isCameraInitialized = false;
      _detectedObjects.clear();
      _qrDetectedItems.clear();
      resultText = "";
    });
    controller?.dispose();
    controller = null;
    _showModelSelectionDialog();
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    final isEntrance = _selectedModelType == 'entrance_exit';

    // For display: entrance shows qty, warehouse shows detection count
    final Map<String, int> displayItems = isEntrance
        ? _qrDetectedItems.map((k, v) => MapEntry(k, _toInt(v['qty']) ?? 1))
        : _detectedObjects;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Camera preview ───────────────────────────────────────
            Positioned.fill(
              child: OverflowBox(
                alignment: Alignment.center,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.previewSize!.height,
                    height: controller!.value.previewSize!.width,
                    child: CameraPreview(controller!),
                  ),
                ),
              ),
            ),

            // ── Mode badge (top centre) ──────────────────────────────
            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: _changeModel,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _getModelColor().withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_getModelIcon(), color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _modelDisplayName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.swap_horiz,
                          color: Colors.white,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── Detecting spinner ────────────────────────────────────
            if (isProcessing)
              Positioned(
                top: 60,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Detecting…',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Bottom results panel ─────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.42,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.85),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Header row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isEntrance ? 'QR Detections' : 'Detected Objects',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getModelColor(),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${displayItems.length} items',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // List
                    Flexible(
                      child: displayItems.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(32),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    isEntrance
                                        ? Icons.qr_code_scanner
                                        : Icons.center_focus_weak,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    isEntrance
                                        ? 'Point camera at QR code'
                                        : 'Point camera at products',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Auto-detecting every 2 s',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: displayItems.length,
                              itemBuilder: (ctx, i) {
                                final e = displayItems.entries.elementAt(i);
                                final movType = isEntrance
                                    ? (_qrDetectedItems[e.key]?['type']
                                              ?.toString() ??
                                          _movementType)
                                    : null;
                                final typeColor = movType == 'OUT'
                                    ? Colors.red
                                    : Colors.green;

                                // Extra detail line for QR items
                                final expiryDate = isEntrance
                                    ? _nonEmpty(
                                        _qrDetectedItems[e.key]?['expiry_date'],
                                      )
                                    : null;
                                final costPrice = isEntrance
                                    ? _toDouble(
                                        _qrDetectedItems[e.key]?['cost_price'],
                                      )
                                    : null;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: isEntrance
                                              ? typeColor.withOpacity(0.2)
                                              : AppColors.primaryBlue,
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          isEntrance
                                              ? (movType == 'OUT'
                                                    ? Icons.logout_rounded
                                                    : Icons.login_rounded)
                                              : Icons.inventory_2,
                                          color: isEntrance
                                              ? typeColor
                                              : Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              e.key,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            if (movType != null)
                                              Text(
                                                movType == 'IN'
                                                    ? '● Stock IN'
                                                    : '● Stock OUT',
                                                style: TextStyle(
                                                  color: typeColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            // Show expiry & cost if available
                                            if (expiryDate != null)
                                              Text(
                                                'Exp: $expiryDate',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                            if (costPrice != null)
                                              Text(
                                                'Cost: \$${costPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 10,
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isEntrance
                                              ? typeColor
                                              : Colors.green,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          '${e.value}x',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),

                    // Action buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: displayItems.isEmpty
                                  ? null
                                  : () => setState(() {
                                      _detectedObjects.clear();
                                      _qrDetectedItems.clear();
                                      resultText = "";
                                    }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                disabledBackgroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: displayItems.isEmpty
                                  ? null
                                  : _saveToDatabaseAndFinalize,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                disabledBackgroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.save, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Save to Database',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Back button ──────────────────────────────────────────
            Positioned(
              top: 16,
              left: 16,
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
