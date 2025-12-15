import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:iris_app/Detailmodal.dart';
import 'package:iris_app/app_colors.dart';
import 'package:iris_app/cerberus.dart';
import 'package:iris_app/cv_scanning.dart';

import 'package:iris_app/sign_in.dart';
import 'package:iris_app/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
   WidgetsFlutterBinding.ensureInitialized();
   await Supabase.initialize(
    url: 'https://wmbffynawfhaliubqqhk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtYmZmeW5hd2ZoYWxpdWJxcWhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjEzNzMzOTAsImV4cCI6MjA3Njk0OTM5MH0.z0PwZXosZALT4aa4dvLY_qfBKBgvoYiEI6HzGjGCoi4',
  );
 cameras = await availableCameras();
  runApp( MyApp());
}
class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  static ThemeMode _themeMode = ThemeMode.light;

  static void toggleTheme(bool isDark) {
   
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IRIS Warehouse Management',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _themeMode,
      home: SplashScreen(),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.lightGrey,
      brightness: Brightness.light,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      // cardTheme: CardTheme(
      //   elevation: 2,
      //   color: AppColors.white,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      // ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      primaryColor: AppColors.primaryBlue,
      scaffoldBackgroundColor: AppColors.darkBackground,
      brightness: Brightness.dark,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.white,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      // cardTheme: CardTheme(
      //   elevation: 2,
      //   color: AppColors.darkCard,
      //   shape: RoundedRectangleBorder(
      //     borderRadius: BorderRadius.circular(12),
      //   ),
      // ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.mediumGrey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
      ),
    );
  }
}


// import 'dart:typed_data';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'package:http/http.dart' as http;
// import 'package:image/image.dart' as img;
// import 'package:iris_app/cv_scanning.dart';

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
// class CameraScreen extends StatefulWidget {
//   final List<CameraDescription> cameras;
//   const CameraScreen({Key? key, required this.cameras}) : super(key: key);

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
  
//   CameraController? _controller;
//   bool _isDetecting = false;
//   List detections = [];

//   @override
//   void initState() {
//     super.initState();
//     _initCamera();
//   }

//   void _initCamera() async {
//     if (widget.cameras.isEmpty) return;

//     _controller = CameraController(
//       widget.cameras[0],
//       ResolutionPreset.medium, // keep medium for same quality as before
//       enableAudio: false,
//     );

//     await _controller!.initialize();
//     if (!mounted) return;
//     setState(() {});

//     // Start continuous image stream
//     _controller!.startImageStream((CameraImage image) {
//       if (!_isDetecting) _processCameraImage(image);
//     });
//   }

//   void _processCameraImage(CameraImage image) async {
//     _isDetecting = true;

//     try {
//       // Convert CameraImage to JPEG
//       final jpegBytes = _convertYUV420ToJPEG(image);

//       // Send to Flask backend
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('http://192.168.100.171:5000/detect'),
//       );
//       request.files.add(
//         http.MultipartFile.fromBytes('image', jpegBytes, filename: 'frame.jpg'),
//       );

//       var response = await request.send().timeout(Duration(seconds: 5));
//       final resStr = await response.stream.bytesToString();
//       final jsonResponse = json.decode(resStr);

//       if (mounted) {
//         setState(() {
//           detections = jsonResponse['detections'] ?? [];
//         });
//       }
//     } catch (e) {
//       print("Error sending frame: $e");
//     }

//     await Future.delayed(Duration(milliseconds: 500)); // throttle FPS
//     _isDetecting = false;
//   }

//   Uint8List _convertYUV420ToJPEG(CameraImage image) {
//     final width = image.width;
//     final height = image.height;
//     final img.Image img1 = img.Image(width: width, height: height);

//     final planeY = image.planes[0];
//     final planeU = image.planes[1];
//     final planeV = image.planes[2];

//     for (int y = 0; y < height; y++) {
//       for (int x = 0; x < width; x++) {
//         final yp = planeY.bytes[y * planeY.bytesPerRow + x];
//         final up = planeU.bytes[(y ~/ 2) * planeU.bytesPerRow + (x ~/ 2)];
//         final vp = planeV.bytes[(y ~/ 2) * planeV.bytesPerRow + (x ~/ 2)];

//         int r = (yp + 1.402 * (vp - 128)).toInt();
//         int g = (yp - 0.344136 * (up - 128) - 0.714136 * (vp - 128)).toInt();
//         int b = (yp + 1.772 * (up - 128)).toInt();

//         r = r.clamp(0, 255);
//         g = g.clamp(0, 255);
//         b = b.clamp(0, 255);

//         img1.setPixelRgb(x, y, r, g, b);
//       }
//     }

//     return img.encodeJpg(img1, quality: 80);
//   }

//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_controller == null || !_controller!.value.isInitialized) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final size = _controller!.value.previewSize!;
//     final screenWidth = MediaQuery.of(context).size.width;
//     final screenHeight =
//         screenWidth * size.height / size.width; // maintain aspect ratio

//     return Scaffold(
//       body: Stack(
//         children: [
//           CameraPreview(_controller!),
//           ..._buildBoundingBoxes(screenWidth, screenHeight),
//         ],
//       ),
//     );
//   }

//   List<Widget> _buildBoundingBoxes(double screenWidth, double screenHeight) {
//     if (detections.isEmpty) return [];

//     return detections.map((det) {
//       final bbox = det['bbox']; // [x1, y1, x2, y2]
//       double left = bbox[0] / 840 * screenWidth; // model input assumed 640x640
//       double top = bbox[1] / 840 * screenHeight;
//       double width = (bbox[2] - bbox[0]) / 840 * screenWidth;
//       double height = (bbox[3] - bbox[1]) / 840 * screenHeight;

//       return Positioned(
//         left: left,
//         top: top,
//         child: Container(
//           width: width,
//           height: height,
//           decoration: BoxDecoration(
//             border: Border.all(color: Colors.red, width: 2),
//           ),
//           child: Align(
//             alignment: Alignment.topLeft,
//             child: Container(
//               color: Colors.red,
//               padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
//               child: Text(
//                 "${det['class']} ${(det['confidence'] * 100).toStringAsFixed(0)}%",
//                 style: TextStyle(color: Colors.white, fontSize: 12),
//               ),
//             ),
//           ),
//         ),
//       );
//     }).toList();
//   }
// }




// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;

// late List<CameraDescription> cameras;

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

// class CameraPage extends StatefulWidget {
//   @override
//   _CameraPageState createState() => _CameraPageState();
// }

// class _CameraPageState extends State<CameraPage> {
//   late CameraController controller;
//   bool isProcessing = false;
//   String resultText = "";

//   @override
//   void initState() {
//     super.initState();
//     controller = CameraController(
//       cameras[0],
//       ResolutionPreset.medium,
//       enableAudio: false,
//     );

//     controller.initialize().then((_) {
//       if (!mounted) return;
//       setState(() {});
//     });
//   }

//   Future<void> captureAndDetect() async {
//     if (!controller.value.isInitialized) return;
//     if (controller.value.isTakingPicture) return;
//     if (isProcessing) return;

//     setState(() => isProcessing = true);

//     try {
//       final image = await controller.takePicture();
//       Uint8List bytes = await image.readAsBytes();
//       String base64Image = base64Encode(bytes);

//       final response = await http.post(
//         Uri.parse("http://192.168.100.171:5000/detect"),
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode({"image": base64Image}),
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data["success"] == true) {
//           List detections = data["detections"] ?? [];

//           setState(() {
//             resultText = detections.isEmpty
//                 ? "No objects detected"
//                 : detections
//                     .map((e) =>
//                         "${e['class']} (${(e['confidence'] as num).toStringAsFixed(2)})")
//                     .join("\n");
//           });
//         } else {
//           setState(() => resultText = "Detection failed");
//         }
//       } else {
//         setState(() => resultText = "Server error");
//       }
//     } catch (e) {
//       setState(() => resultText = "Error: $e");
//     } finally {
//       setState(() => isProcessing = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (!controller.value.isInitialized) {
//       return Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: Text("Grocery Liquids Detector")),
//       body: Column(
//         children: [
//           AspectRatio(
//             aspectRatio: controller.value.aspectRatio,
//             child: CameraPreview(controller),
//           ),
//           SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: isProcessing ? null : captureAndDetect,
//             child: Text(isProcessing ? "Detecting..." : "Detect"),
//           ),
//           Padding(
//             padding: EdgeInsets.all(8),
//             child: Text(resultText, style: TextStyle(fontSize: 16)),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     controller.dispose();
//     super.dispose();
//   }
// }