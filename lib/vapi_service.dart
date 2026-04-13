import 'dart:async';
import 'dart:convert';

import 'package:vapi/vapi.dart';

class VapiService {
  static final VapiService _instance = VapiService._internal();
  factory VapiService() => _instance;
  VapiService._internal();

  VapiClient? _client;
  VapiCall? _currentCall;

  final StreamController<Map<String, dynamic>> _formDataController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get formDataStream =>
      _formDataController.stream;

  bool _initialized = false;

  Future<void> initialize(String publicKey) async {
    if (_initialized) return;
    await VapiClient.platformInitialized.future;
    _client = VapiClient(publicKey.trim());
    _initialized = true;
  }

  Future<void> startCall(String assistantId) async {
    if (_client == null) {
      throw Exception("VapiService not initialized. Call initialize() first.");
    }

    _currentCall = await _client!.start(assistantId: assistantId.trim());

    _currentCall!.onEvent.listen((event) {
      print('🔔 ========== VAPI EVENT ==========');
      print('Label: ${event.label}');
      print('Value Type: ${event.value?.runtimeType}');
      
      // CRITICAL: Check if this is a message event with tool calls
      if (event.label == "message" && event.value != null) {
        try {
          final messageData = Map<String, dynamic>.from(event.value as Map);
          
          // Print the message type to see what we're getting
          final messageType = messageData['type'];
          print('📨 Message Type: $messageType');
          
          // Check if this message contains tool calls
          if (messageType == 'tool-calls' || messageData.containsKey('toolCalls')) {
            print('📞 TOOL CALLS MESSAGE DETECTED!');
            print('📞 Full Message Data: $messageData');
            
            // Extract toolCalls array
            final toolCalls = messageData['toolCalls'] ?? 
                             messageData['toolCallList'] ?? 
                             [];
            
            print('📞 Tool Calls: $toolCalls');

            if (toolCalls is List && toolCalls.isNotEmpty) {
              final firstToolCall = toolCalls[0];
              print('📞 First Tool Call: $firstToolCall');

              if (firstToolCall is Map) {
                final toolCallMap = Map<String, dynamic>.from(firstToolCall);
                final functionData = toolCallMap['function'];
                
                print('📞 Function Data: $functionData');

                if (functionData != null && functionData is Map) {
                  final functionMap = Map<String, dynamic>.from(functionData);
                  final functionName = functionMap['name'];
                  
                  print('📞 Function Name: $functionName');

                  if (functionName == "submitAppointmentForm") {
                    // Extract the arguments
                    final arguments = functionMap['arguments'];
                    
                    print('✅ Raw Arguments: $arguments');
                    print('✅ Arguments Type: ${arguments.runtimeType}');

                    Map<String, dynamic> formData;
                    
                    // Arguments might be a Map or a JSON string
                    if (arguments is Map) {
                      formData = Map<String, dynamic>.from(arguments);
                    } else if (arguments is String) {
                      try {
                        formData = Map<String, dynamic>.from(
                          jsonDecode(arguments)
                        );
                      } catch (e) {
                        print('❌ Failed to parse JSON string: $e');
                        return;
                      }
                    } else {
                      print('❌ Unknown arguments type');
                      return;
                    }

                    print('🎉 EXTRACTED FORM DATA: $formData');
                    
                    // Send to Flutter UI
                    _formDataController.add(formData);
                    
                    print('✅ Form data sent to stream!');
                  }
                }
              }
            }
          }
        } catch (e, stackTrace) {
          print('❌ Error processing message: $e');
          print('Stack trace: $stackTrace');
        }
      }
      
      print('==================================');

      // Other event handlers
      if (event.label == "call-start") {
        print("📞 Call started");
      }

      if (event.label == "call-end") {
        print("📞 Call ended");
      }

      if (event.label == "speech-start") {
        print("🗣️ User started speaking");
      }

      if (event.label == "speech-end") {
        print("🗣️ User finished speaking");
      }

      if (event.label == "transcript") {
        print("📝 Transcript: ${event.value}");
      }
    });
  }

  Future<void> stopCall() async {
    await _currentCall?.stop();
    _currentCall = null;
  }

  bool get isMuted => _currentCall?.isMuted ?? false;

  Future<void> toggleMute() async {
    if (_currentCall == null) return;
    _currentCall!.setMuted(!isMuted);
  }

  void dispose() {
    _formDataController.close();
    _currentCall?.dispose();
    _client?.dispose();
  }
}
class AppConfig {
  static const String enAssistantId = "f71f13bb-f937-4064-aee4-5f5fa9ab25da";
 

  static String getAssistantId() {
    // Get locale without context
  
     return enAssistantId;
    // return  ;
 
  }
}
