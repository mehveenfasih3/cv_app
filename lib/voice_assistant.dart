// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'dart:async';

// // VAPI Integration Service
// class VapiService {
//   static const String vapiPublicKey = 'YOUR_VAPI_PUBLIC_KEY'; // Get from vapi.ai dashboard
//   static const String vapiAssistantId = 'YOUR_ASSISTANT_ID'; // Create in VAPI dashboard
  
//   // Web RTC peer connection for voice
//   dynamic _webRTCConnection;
//   bool _isCallActive = false;
  
//   Future<void> startCall() async {
//     // VAPI Web SDK integration - use vapi_flutter package
//     // This is a placeholder - actual implementation uses WebRTC
//     _isCallActive = true;
//     print('📞 VAPI call started');
//   }
  
//   Future<void> endCall() async {
//     _isCallActive = false;
//     print('📞 VAPI call ended');
//   }
  
//   bool get isCallActive => _isCallActive;
// }


// // Main Chat Screen with Voice
// class VoiceChatScreen extends StatefulWidget {
//   const VoiceChatScreen({Key? key}) : super(key: key);

//   @override
//   State<VoiceChatScreen> createState() => _VoiceChatScreenState();
// }

// class _VoiceChatScreenState extends State<VoiceChatScreen>
//     with TickerProviderStateMixin {
//   final VapiService _vapiService = VapiService();
//   final List<ChatMessage> _messages = [];
//   bool _isCallActive = false;
//   bool _showConfirmationDialog = false;
//   Map<String, dynamic>? _pendingOperation;
  
//   late AnimationController _pulseController;
//   late AnimationController _waveController;

//   @override
//   void initState() {
//     super.initState();
//     _initializeAnimations();
//     _addWelcomeMessage();
//   }

//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);

//     _waveController = AnimationController(
//       duration: const Duration(milliseconds: 2000),
//       vsync: this,
//     )..repeat();
//   }

//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _waveController.dispose();
//     super.dispose();
//   }

//   void _addWelcomeMessage() {
//     setState(() {
//       _messages.add(
//         ChatMessage(
//           text: "Hello! I'm IRIS, your retail assistant. Tap the microphone to start talking!",
//           isUser: false,
//           timestamp: DateTime.now(),
//         ),
//       );
//     });
//   }

//   Future<void> _toggleVoiceCall() async {
//     if (_isCallActive) {
//       // End call
//       await _vapiService.endCall();
//       setState(() {
//         _isCallActive = false;
//         _messages.add(
//           ChatMessage(
//             text: "Voice session ended. Tap to start again!",
//             isUser: false,
//             timestamp: DateTime.now(),
//           ),
//         );
//       });
//     } else {
//       // Start call
//       await _vapiService.startCall();
//       setState(() {
//         _isCallActive = true;
//         _messages.add(
//           ChatMessage(
//             text: "🎤 Listening... Speak your query!",
//             isUser: false,
//             timestamp: DateTime.now(),
//           ),
//         );
//       });
//     }
//   }

//   void _showConfirmation(Map<String, dynamic> operation) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Row(
//           children: [
//             const Icon(Icons.warning_amber, color: Colors.orange, size: 28),
//             const SizedBox(width: 12),
//             Text(
//               'Confirm Action',
//               style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//           ],
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               'You are about to modify data:',
//               style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
//             ),
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey[100],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Text(
//                 json.encode(operation),
//                 style: GoogleFonts.robotoMono(fontSize: 12),
//               ),
//             ),
//             const SizedBox(height: 12),
//             Text(
//               'Are you sure you want to proceed?',
//               style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _sendVoiceConfirmation(false);
//             },
//             child: Text('Cancel', style: GoogleFonts.poppins(color: Colors.grey)),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _sendVoiceConfirmation(true);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: Text('Confirm', style: GoogleFonts.poppins(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   void _sendVoiceConfirmation(bool confirmed) {
//     // Send confirmation back to VAPI
//     // VAPI will handle this via function calling
//     print('User confirmed: $confirmed');
    
//     setState(() {
//       _messages.add(
//         ChatMessage(
//           text: confirmed 
//             ? "✅ Operation confirmed and executed" 
//             : "❌ Operation cancelled",
//           isUser: false,
//           timestamp: DateTime.now(),
//         ),
//       );
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[50],
//       appBar: _buildAppBar(),
//       body: Column(
//         children: [
//           // Voice Status Indicator
//           if (_isCallActive) _buildVoiceIndicator(),

//           // Messages
//           Expanded(
//             child: _messages.isEmpty
//                 ? _buildEmptyState()
//                 : ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: _messages.length,
//                     itemBuilder: (context, index) {
//                       return _buildMessageBubble(_messages[index]);
//                     },
//                   ),
//           ),

//           // Voice Button
//           _buildVoiceButton(),
//         ],
//       ),
//     );
//   }

//   PreferredSizeWidget _buildAppBar() {
//     return AppBar(
//       backgroundColor: Colors.white,
//       elevation: 2,
//       title: Row(
//         children: [
//           Container(
//             width: 40,
//             height: 40,
//             decoration: BoxDecoration(
//               gradient: const LinearGradient(
//                 colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.visibility, color: Colors.white, size: 22),
//           ),
//           const SizedBox(width: 12),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'IRIS Voice Assistant',
//                 style: GoogleFonts.poppins(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//               Text(
//                 _isCallActive ? '🎤 Listening...' : 'Tap to speak',
//                 style: GoogleFonts.poppins(
//                   fontSize: 11,
//                   color: _isCallActive ? Colors.green : Colors.grey,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildVoiceIndicator() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [Colors.blue.shade50, Colors.purple.shade50],
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedBuilder(
//             animation: _pulseController,
//             builder: (context, child) {
//               return Transform.scale(
//                 scale: 1.0 + (_pulseController.value * 0.3),
//                 child: Container(
//                   width: 12,
//                   height: 12,
//                   decoration: BoxDecoration(
//                     color: Colors.red,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.red.withOpacity(0.5),
//                         blurRadius: 8,
//                         spreadRadius: 2,
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//           ),
//           const SizedBox(width: 12),
//           Text(
//             'IRIS is listening...',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(width: 8),
//           _buildWaveAnimation(),
//         ],
//       ),
//     );
//   }

//   Widget _buildWaveAnimation() {
//     return Row(
//       children: List.generate(4, (index) {
//         return AnimatedBuilder(
//           animation: _waveController,
//           builder: (context, child) {
//             final delay = index * 0.1;
//             final value = (_waveController.value + delay) % 1.0;
//             final height = 4 + (value * 16);
            
//             return Container(
//               width: 3,
//               height: height,
//               margin: const EdgeInsets.symmetric(horizontal: 2),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             );
//           },
//         );
//       }),
//     );
//   }

//   Widget _buildVoiceButton() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//       ),
//       child: Center(
//         child: GestureDetector(
//           onTap: _toggleVoiceCall,
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 300),
//             width: _isCallActive ? 80 : 70,
//             height: _isCallActive ? 80 : 70,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: _isCallActive
//                     ? [Colors.red.shade400, Colors.red.shade600]
//                     : [const Color(0xFF667EEA), const Color(0xFF764BA2)],
//               ),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: (_isCallActive ? Colors.red : Colors.blue).withOpacity(0.3),
//                   blurRadius: 20,
//                   spreadRadius: 5,
//                 ),
//               ],
//             ),
//             child: Icon(
//               _isCallActive ? Icons.call_end : Icons.mic,
//               color: Colors.white,
//               size: _isCallActive ? 36 : 32,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 120,
//             height: 120,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.blue.shade100, Colors.purple.shade100],
//               ),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(Icons.mic, size: 60, color: Colors.white),
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'Tap to Talk with IRIS',
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.black87,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             'Ask about products, prices, inventory & more',
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey[600],
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMessageBubble(ChatMessage message) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 16),
//       child: Row(
//         mainAxisAlignment: message.isUser
//             ? MainAxisAlignment.end
//             : MainAxisAlignment.start,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           if (!message.isUser) ...[
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 gradient: const LinearGradient(
//                   colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: const Icon(Icons.visibility, color: Colors.white, size: 18),
//             ),
//             const SizedBox(width: 8),
//           ],
//           Flexible(
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 gradient: message.isUser
//                     ? const LinearGradient(
//                         colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
//                       )
//                     : null,
//                 color: message.isUser ? null : Colors.white,
//                 borderRadius: BorderRadius.circular(20),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 message.text,
//                 style: GoogleFonts.poppins(
//                   color: message.isUser ? Colors.white : Colors.black87,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Data Model
// class ChatMessage {
//   final String text;
//   final bool isUser;
//   final DateTime timestamp;

//   ChatMessage({
//     required this.text,
//     required this.isUser,
//     required this.timestamp, required responseData,
//   });
// }