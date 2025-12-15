// import 'package:flutter/material.dart';
// import 'package:iris_app/app_colors.dart';

// class CVScanningScreen extends StatefulWidget {
//   const CVScanningScreen({Key? key}) : super(key: key);

//   @override
//   State<CVScanningScreen> createState() => _CVScanningScreenState();
// }

// class _CVScanningScreenState extends State<CVScanningScreen> {
//   bool _isScanning = false;

//   void _startScanning() {
//     setState(() {
//       _isScanning = true;
//     });

//     // Simulate scanning process
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) {
//         setState(() {
//           _isScanning = false;
//         });
//         _showScanResult();
//       }
//     });
//   }

//   void _showScanResult() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Scan Result'),
//         content: const Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Item: Electronics Box #A123'),
//             SizedBox(height: 8),
//             Text('Location: Warehouse A, Section B'),
//             SizedBox(height: 8),
//             Text('Quantity: 25 units'),
//             SizedBox(height: 8),
//             Text('Status: ✓ Verified'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _startScanning();
//             },
//             child: const Text('Scan Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('CV Scanning'),
//       ),
//       body: Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               // Scanning Animation/Image
//               Container(
//                 width: 280,
//                 height: 280,
//                 decoration: BoxDecoration(
//                   color: _isScanning
//                       ? AppColors.primaryBlue.withOpacity(0.1)
//                       : Colors.transparent,
//                   borderRadius: BorderRadius.circular(20),
//                   border: Border.all(
//                     color: AppColors.primaryBlue,
//                     width: 3,
//                   ),
//                 ),
//                 child: _isScanning
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const CircularProgressIndicator(
//                             color: AppColors.primaryBlue,
//                             strokeWidth: 3,
//                           ),
//                           const SizedBox(height: 20),
//                           Text(
//                             'Scanning...',
//                             style: TextStyle(
//                               color: AppColors.primaryBlue,
//                               fontSize: 18,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       )
//                     : Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Image.network(
//                             'https://via.placeholder.com/150/0066B3/FFFFFF?text=CV',
//                             width: 150,
//                             height: 150,
//                             errorBuilder: (context, error, stackTrace) {
//                               return Icon(
//                                 Icons.qr_code_scanner,
//                                 size: 120,
//                                 color: AppColors.primaryBlue,
//                               );
//                             },
//                           ),
//                           const SizedBox(height: 16),
//                           const Text(
//                             'Computer Vision Scanner',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.w600,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//               ),
//               const SizedBox(height: 40),
//               const Text(
//                 'Position the camera to scan items',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: AppColors.textSecondary,
//                 ),
//                 textAlign: TextAlign.center,
//               ),
//               const SizedBox(height: 32),
//               SizedBox(
//                 width: double.infinity,
//                 child: ElevatedButton(
//                   onPressed: _isScanning ? null : _startScanning,
//                   style: ElevatedButton.styleFrom(
//                     padding: const EdgeInsets.symmetric(vertical: 16),
//                     disabledBackgroundColor: AppColors.mediumGrey,
//                   ),
//                   child: Text(
//                     _isScanning ? 'Scanning...' : 'Start Scanning',
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     children: [
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.info_outline,
//                             color: AppColors.info,
//                           ),
//                           const SizedBox(width: 12),
//                           const Expanded(
//                             child: Text(
//                               'Tips for better scanning:',
//                               style: TextStyle(
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 12),
//                       const Text(
//                         '• Ensure good lighting\n'
//                         '• Hold camera steady\n'
//                         '• Keep item in frame\n'
//                         '• Avoid shadows',
//                         style: TextStyle(
//                           color: AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/services.dart';
// import 'dart:typed_data';

// class CVScanningScreen extends StatefulWidget {
//   const CVScanningScreen({Key? key}) : super(key: key);

//   @override
//   State<CVScanningScreen> createState() => _CVScanningScreenState();
// }

// class _CVScanningScreenState extends State<CVScanningScreen> {
//   CameraController? _cameraController;
//   Interpreter? _interpreter;
//   List<String> _labels = [];
  
//   bool _isDetecting = false;
//   bool _isModelLoaded = false;
//   List<DetectionResult> _detections = [];
  
//   @override
//   void initState() {
//     super.initState();
//     _initializeCamera();
//     _loadModel();
//   }

//   Future<void> _initializeCamera() async {
//     final cameras = await availableCameras();
//     if (cameras.isEmpty) return;

//     _cameraController = CameraController(
//       cameras[0],
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     await _cameraController!.initialize();
    
//     // Start image stream
//     _cameraController!.startImageStream((image) {
//       if (!_isDetecting && _isModelLoaded) {
//         _isDetecting = true;
//         _runModelOnFrame(image);
//       }
//     });
    
//     setState(() {});
//   }

//   Future<void> _loadModel() async {
//     try {
//       // Load TFLite model
//       _interpreter = await Interpreter.fromAsset('assets/models/best.tflite');
      
//       // Load labels
//       final labelsData = await rootBundle.loadString('assets/models/labels.txt');
//       _labels = labelsData.split('\n').where((label) => label.isNotEmpty).toList();
      
//       setState(() {
//         _isModelLoaded = true;
//       });
      
//       print('✅ Model loaded successfully!');
//       print('📦 Loaded ${_labels.length} classes: $_labels');
//     } catch (e) {
//       print('❌ Error loading model: $e');
//     }
//   }

//   Future<void> _runModelOnFrame(CameraImage image) async {
//     if (_interpreter == null) {
//       _isDetecting = false;
//       return;
//     }

//     try {
//       // Convert CameraImage to img.Image
//       final imgImage = _convertCameraImage(image);
//       if (imgImage == null) {
//         _isDetecting = false;
//         return;
//       }

//       // Resize to model input size (640x640 for YOLO)
//       final resized = img.copyResize(imgImage, width: 640, height: 640);

//       // Convert to Float32List (normalized 0-1)
//       final input = _imageToByteListFloat32(resized);

//       // Prepare output buffer
//       // YOLO output shape: [1, 25200, 85] for 80 classes
//       // [1, 25200, (4 bbox + 1 conf + num_classes)]
//       final numClasses = _labels.length;
//       final output = List.generate(
//         1,
//         (_) => List.generate(
//           25200,
//           (_) => List.filled(4 + 1 + numClasses, 0.0),
//         ),
//       );

//       // Run inference
//       _interpreter!.run(input, output);

//       // Parse detections
//       final detections = _parseYOLOOutput(output[0], 0.35); // 0.35 confidence threshold

//       setState(() {
//         _detections = detections;
//       });
//     } catch (e) {
//       print('Error during detection: $e');
//     }

//     _isDetecting = false;
//   }

//   img.Image? _convertCameraImage(CameraImage image) {
//     try {
//       if (image.format.group == ImageFormatGroup.yuv420) {
//         return _convertYUV420(image);
//       } else if (image.format.group == ImageFormatGroup.bgra8888) {
//         return _convertBGRA8888(image);
//       }
//       return null;
//     } catch (e) {
//       print('Error converting image: $e');
//       return null;
//     }
//   }

//   img.Image _convertYUV420(CameraImage image) {
//     final width = image.width;
//     final height = image.height;
//     final yPlane = image.planes[0];
//     final uPlane = image.planes[1];
//     final vPlane = image.planes[2];

//     final imgImage = img.Image(width: width, height: height);

//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         final yIndex = y * yPlane.bytesPerRow + x;
//         final uvIndex = (y ~/ 2) * uPlane.bytesPerRow + (x ~/ 2);

//         final yValue = yPlane.bytes[yIndex];
//         final uValue = uPlane.bytes[uvIndex];
//         final vValue = vPlane.bytes[uvIndex];

//         final r = (yValue + 1.402 * (vValue - 128)).clamp(0, 255).toInt();
//         final g = (yValue - 0.344136 * (uValue - 128) - 0.714136 * (vValue - 128))
//             .clamp(0, 255)
//             .toInt();
//         final b = (yValue + 1.772 * (uValue - 128)).clamp(0, 255).toInt();

//         imgImage.setPixelRgba(x, y, r, g, b, 255);
//       }
//     }

//     return imgImage;
//   }

//   img.Image _convertBGRA8888(CameraImage image) {
//     return img.Image.fromBytes(
//       width: image.width,
//       height: image.height,
//       bytes: image.planes[0].bytes.buffer,
//       format: img.Format.uint8,
//     );
//   }

//   Float32List _imageToByteListFloat32(img.Image image) {
//     final convertedBytes = Float32List(1 * 640 * 640 * 3);
//     final buffer = Float32List.view(convertedBytes.buffer);
//     int pixelIndex = 0;

//     for (int y = 0; y < 640; y++) {
//       for (int x = 0; x < 640; x++) {
//         final pixel = image.getPixel(x, y);
//         buffer[pixelIndex++] = pixel.r / 255.0;
//         buffer[pixelIndex++] = pixel.g / 255.0;
//         buffer[pixelIndex++] = pixel.b / 255.0;
//       }
//     }

//     return convertedBytes;
//   }

//   List<DetectionResult> _parseYOLOOutput(List<List<double>> output, double threshold) {
//     List<DetectionResult> detections = [];

//     for (var detection in output) {
//       // detection format: [x, y, w, h, confidence, class_scores...]
//       final confidence = detection[4];
      
//       if (confidence < threshold) continue;

//       // Find class with highest score
//       int classId = 0;
//       double maxScore = 0;
//       for (int i = 5; i < detection.length; i++) {
//         if (detection[i] > maxScore) {
//           maxScore = detection[i];
//           classId = i - 5;
//         }
//       }

//       final finalConfidence = confidence * maxScore;
//       if (finalConfidence < threshold) continue;

//       detections.add(DetectionResult(
//         classId: classId,
//         className: classId < _labels.length ? _labels[classId] : 'Unknown',
//         confidence: finalConfidence,
//         bbox: [
//           detection[0] - detection[2] / 2, // x1
//           detection[1] - detection[3] / 2, // y1
//           detection[0] + detection[2] / 2, // x2
//           detection[1] + detection[3] / 2, // y2
//         ],
//       ));
//     }

//     // Apply NMS (Non-Maximum Suppression)
//     return _applyNMS(detections, 0.4);
//   }

//   List<DetectionResult> _applyNMS(List<DetectionResult> detections, double iouThreshold) {
//     detections.sort((a, b) => b.confidence.compareTo(a.confidence));
    
//     List<DetectionResult> filtered = [];
    
//     for (var detection in detections) {
//       bool keep = true;
//       for (var kept in filtered) {
//         if (_calculateIOU(detection.bbox, kept.bbox) > iouThreshold) {
//           keep = false;
//           break;
//         }
//       }
//       if (keep) filtered.add(detection);
//     }
    
//     return filtered;
//   }

//   double _calculateIOU(List<double> box1, List<double> box2) {
//     final x1 = box1[0] > box2[0] ? box1[0] : box2[0];
//     final y1 = box1[1] > box2[1] ? box1[1] : box2[1];
//     final x2 = box1[2] < box2[2] ? box1[2] : box2[2];
//     final y2 = box1[3] < box2[3] ? box1[3] : box2[3];

//     final intersection = (x2 - x1).clamp(0, double.infinity) * 
//                         (y2 - y1).clamp(0, double.infinity);
    
//     final area1 = (box1[2] - box1[0]) * (box1[3] - box1[1]);
//     final area2 = (box2[2] - box2[0]) * (box2[3] - box2[1]);
//     final union = area1 + area2 - intersection;

//     return union > 0 ? intersection / union : 0;
//   }

//   @override
//   void dispose() {
//     _cameraController?.dispose();
//     _interpreter?.close();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_cameraController == null || !_cameraController!.value.isInitialized) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('CV Scanning')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     final size = MediaQuery.of(context).size;
//     final deviceRatio = size.width / size.height;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Live Object Detection'),
//         actions: [
//           if (_isModelLoaded)
//             const Padding(
//               padding: EdgeInsets.all(16.0),
//               child: Icon(Icons.check_circle, color: Colors.green),
//             ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Camera Preview
//           SizedBox(
//             width: size.width,
//             height: size.height,
//             child: FittedBox(
//               fit: BoxFit.cover,
//               child: SizedBox(
//                 width: 100,
//                 child: CameraPreview(_cameraController!),
//               ),
//             ),
//           ),

//           // Detection Overlays
//           ..._buildDetectionBoxes(size),

//           // Detection Count
//           Positioned(
//             top: 16,
//             left: 16,
//             child: Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.black87,
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Detections: ${_detections.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   ..._buildDetectionList(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildDetectionBoxes(Size screenSize) {
//     return _detections.map((detection) {
//       final left = detection.bbox[0] * screenSize.width;
//       final top = detection.bbox[1] * screenSize.height;
//       final width = (detection.bbox[2] - detection.bbox[0]) * screenSize.width;
//       final height = (detection.bbox[3] - detection.bbox[1]) * screenSize.height;

//       return Positioned(
//         left: left,
//         top: top,
//         child: Container(
//           width: width,
//           height: height,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.green, width: 3),
//             borderRadius: BorderRadius.circular(8),
//           ),
//           child: Container(
//             padding: const EdgeInsets.all(4),
//             decoration: BoxDecoration(
//               color: Colors.green,
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               '${detection.className} ${(detection.confidence * 100).toStringAsFixed(0)}%',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }

//   List<Widget> _buildDetectionList() {
//     final counts = <String, int>{};
//     for (var detection in _detections) {
//       counts[detection.className] = (counts[detection.className] ?? 0) + 1;
//     }

//     return counts.entries.map((entry) {
//       return Padding(
//         padding: const EdgeInsets.only(top: 4),
//         child: Text(
//           '${entry.key}: ${entry.value}',
//           style: const TextStyle(color: Colors.white),
//         ),
//       );
//     }).toList();
//   }
// }

// class DetectionResult {
//   final int classId;
//   final String className;
//   final double confidence;
//   final List<double> bbox; // [x1, y1, x2, y2] normalized 0-1

//   DetectionResult({
//     required this.classId,
//     required this.className,
//     required this.confidence,
//     required this.bbox,
//   });
// }


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   final cameras = await availableCameras();
//   runApp(MyApp(cameras: cameras));
// }

// class MyApp extends StatelessWidget {
//   final List<CameraDescription> cameras;
//   const MyApp({Key? key, required this.cameras}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: CameraScreen(cameras: cameras),
//     );
//   }
// }



import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:iris_app/app_colors.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late List<CameraDescription> cameras;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   cameras = await availableCameras();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: CameraPage(),
//     );
//   }
// }


class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  
  const CameraPage({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController? controller;
  final supabase = Supabase.instance.client;
  
  bool isProcessing = false;
  bool _isCameraInitialized = false;
  Timer? _detectionTimer;
  
  // Store detected objects with their counts
  Map<String, int> _detectedObjects = {};
  String resultText = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      if (widget.cameras.isEmpty) {
        _showError('No cameras available');
        return;
      }

      controller = CameraController(
        widget.cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller!.initialize();
      
      if (!mounted) return;
      
      setState(() {
        _isCameraInitialized = true;
      });

      // Start auto-detection every 2 seconds
      _startAutoDetection();
    } catch (e) {
      _showError('Camera initialization failed: $e');
    }
  }

  void _startAutoDetection() {
    _detectionTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_isCameraInitialized && !isProcessing && mounted) {
        captureAndDetect();
      }
    });
  }

  Future<void> captureAndDetect() async {
    if (controller == null || !controller!.value.isInitialized) return;
    if (controller!.value.isTakingPicture) return;
    if (isProcessing) return;

    setState(() => isProcessing = true);

    try {
      final image = await controller!.takePicture();
      Uint8List bytes = await image.readAsBytes();
      String base64Image = base64Encode(bytes);

      final response = await http.post(
        Uri.parse("http://192.168.100.171:5000/detect"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"image": base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["success"] == true) {
          List detections = data["detections"] ?? [];

          if (detections.isNotEmpty) {
            // Update detection counts
            for (var detection in detections) {
              String className = detection['class'];
              double confidence = (detection['confidence'] as num).toDouble();
              
              // Only count detections with confidence > 50%
              if (confidence > 0.5) {
                _detectedObjects[className] = (_detectedObjects[className] ?? 0) + 1;
              }
            }

            setState(() {
              resultText = detections
                  .map((e) => "${e['class']} (${(e['confidence'] as num).toStringAsFixed(2)})")
                  .join("\n");
            });
          } else {
            setState(() => resultText = "No objects detected");
          }
        } else {
          setState(() => resultText = "Detection failed");
        }
      } else {
        setState(() => resultText = "Server error: ${response.statusCode}");
      }
    } catch (e) {
      print("Detection error: $e");
      setState(() => resultText = "Error: $e");
    } finally {
      if (mounted) {
        setState(() => isProcessing = false);
      }
    }
  }

  Future<void> _saveToDatabaseAndFinalize() async {
    if (_detectedObjects.isEmpty) {
      _showError('No objects detected to save');
      return;
    }

    try {
      _showLoadingDialog();

      final today = DateTime.now();
      final todayDate = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      // Fetch all categories from database
      final categoriesResponse = await supabase
          .from('categories')
          .select('id, name');

      // Create a map of category names to IDs (case-insensitive)
      Map<String, int> categoryMap = {};
      for (var category in categoriesResponse) {
        categoryMap[category['name'].toString().toLowerCase()] = category['id'];
      }

      // Prepare batch insert/update operations
      List<Map<String, dynamic>> recordsToInsert = [];
      List<String> notFoundCategories = [];

      for (var entry in _detectedObjects.entries) {
        String objectName = entry.key;
        int count = entry.value;
        
        // Find matching category ID (case-insensitive)
        int? categoryId = categoryMap[objectName.toLowerCase()];
        
        if (categoryId != null) {
          // Check if record already exists for today
          final existingRecord = await supabase
              .from('product_count')
              .select('scanning_count')
              .eq('category_id', categoryId)
              .maybeSingle();

          if (existingRecord != null) {
            // Update existing record (add to existing count)
            final newCount = (existingRecord['scanning_count'] ?? 0) + count;
            await supabase
                .from('product_count')
                .update({
                  'scanning_count': newCount,
                })
                .eq('category_id', categoryId);
          } else {
            // Insert new record
            recordsToInsert.add({
              'category_id': categoryId,
              'scanning_count': count,
            });
          }
        } else {
          notFoundCategories.add(objectName);
        }
      }

      // Batch insert new records
      if (recordsToInsert.isNotEmpty) {
        await supabase.from('product_count').insert(recordsToInsert);
      }

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success message
        String message = 'Saved ${_detectedObjects.length - notFoundCategories.length} categories to database';
        if (notFoundCategories.isNotEmpty) {
          message += '\n\nNot found in categories: ${notFoundCategories.join(", ")}';
        }

        _showSuccessDialog(message);
        
        // Clear detection data after successful save
        setState(() {
          _detectedObjects.clear();
          resultText = "";
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        _showError('Error saving to database: $e');
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
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
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
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
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _detectionTimer?.cancel();
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Camera Preview (Full Screen)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.previewSize!.height,
                  height: controller!.value.previewSize!.width,
                  child: CameraPreview(controller!),
                ),
              ),
            ),

            // Detection Indicator
            if (isProcessing)
              Positioned(
                top: 16,
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
                          'Detecting...',
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

            // Detection Results Panel (Bottom)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.4,
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
                    // Handle Bar
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Detected Objects',
                            style: TextStyle(
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
                              color: AppColors.primaryBlue,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${_detectedObjects.length} items',
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

                    // Detection List
                    Flexible(
                      child: _detectedObjects.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.center_focus_weak,
                                    size: 48,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Point camera at objects',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Auto-detecting every 2 seconds',
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
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: _detectedObjects.length,
                              itemBuilder: (context, index) {
                                final entry = _detectedObjects.entries.elementAt(index);
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
                                          color: AppColors.primaryBlue,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.inventory_2,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          entry.key,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.success,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          '${entry.value}x',
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

                    // Action Buttons
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _detectedObjects.isEmpty
                                  ? null
                                  : () {
                                      setState(() {
                                        _detectedObjects.clear();
                                        resultText = "";
                                      });
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade700,
                                disabledBackgroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 14),
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
                              onPressed: _detectedObjects.isEmpty
                                  ? null
                                  : _saveToDatabaseAndFinalize,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                disabledBackgroundColor: Colors.grey.shade700,
                                padding: const EdgeInsets.symmetric(vertical: 14),
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

            // Back Button
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