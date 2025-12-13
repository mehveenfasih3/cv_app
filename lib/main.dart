// import 'package:flutter/material.dart';
// import 'package:iris_app/Detailmodal.dart';
// import 'package:iris_app/app_colors.dart';
// import 'package:iris_app/cerberus.dart';

// import 'package:iris_app/sign_in.dart';
// import 'package:iris_app/splash_screen.dart';


// void main() {
//   runApp( MyApp());
// }
// class MyApp extends StatefulWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   static ThemeMode _themeMode = ThemeMode.light;

//   static void toggleTheme(bool isDark) {
   
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'IRIS Warehouse Management',
//       debugShowCheckedModeBanner: false,
//       theme: _buildLightTheme(),
//       darkTheme: _buildDarkTheme(),
//       themeMode: _themeMode,
//       home: SplashScreen(),
//     );
//   }

//   ThemeData _buildLightTheme() {
//     return ThemeData(
//       primaryColor: AppColors.primaryBlue,
//       scaffoldBackgroundColor: AppColors.lightGrey,
//       brightness: Brightness.light,
//       appBarTheme: const AppBarTheme(
//         elevation: 0,
//         centerTitle: true,
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: AppColors.white,
//         iconTheme: IconThemeData(color: AppColors.white),
//       ),
//       // cardTheme: CardTheme(
//       //   elevation: 2,
//       //   color: AppColors.white,
//       //   shape: RoundedRectangleBorder(
//       //     borderRadius: BorderRadius.circular(12),
//       //   ),
//       // ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: AppColors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primaryBlue,
//           foregroundColor: AppColors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.white,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.mediumGrey),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.mediumGrey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
//         ),
//       ),
//     );
//   }

//   ThemeData _buildDarkTheme() {
//     return ThemeData(
//       primaryColor: AppColors.primaryBlue,
//       scaffoldBackgroundColor: AppColors.darkBackground,
//       brightness: Brightness.dark,
//       appBarTheme: const AppBarTheme(
//         elevation: 0,
//         centerTitle: true,
//         backgroundColor: AppColors.darkSurface,
//         foregroundColor: AppColors.white,
//         iconTheme: IconThemeData(color: AppColors.white),
//       ),
//       // cardTheme: CardTheme(
//       //   elevation: 2,
//       //   color: AppColors.darkCard,
//       //   shape: RoundedRectangleBorder(
//       //     borderRadius: BorderRadius.circular(12),
//       //   ),
//       // ),
//       floatingActionButtonTheme: const FloatingActionButtonThemeData(
//         backgroundColor: AppColors.primaryBlue,
//         foregroundColor: AppColors.white,
//       ),
//       elevatedButtonTheme: ElevatedButtonThemeData(
//         style: ElevatedButton.styleFrom(
//           backgroundColor: AppColors.primaryBlue,
//           foregroundColor: AppColors.white,
//           padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8),
//           ),
//         ),
//       ),
//       inputDecorationTheme: InputDecorationTheme(
//         filled: true,
//         fillColor: AppColors.darkCard,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.mediumGrey),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.mediumGrey),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(8),
//           borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
//         ),
//       ),
//     );
//   }
// }


import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:iris_app/cv_scanning.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;
  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CameraScreen(cameras: cameras),
    );
  }
}


