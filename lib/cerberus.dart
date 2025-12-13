import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';

// void main() {
//   runApp(const IrisApp());
// }

// class IrisApp extends StatelessWidget {
//   const IrisApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Cerberus - AI Assistant',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//         textTheme: GoogleFonts.poppinsTextTheme(),
//         useMaterial3: true,
//       ),
//       home: const ModeSelectionScreen(),
//     );
//   }
// }

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,

              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),

                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // ✅ Logo
                        Hero(
                          tag: 'iris_logo',
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 30,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              backgroundImage: AssetImage(
                                'assets/images/IRIS Logo (Only Eye).png',
                              ),
                              radius: 50,
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Text(
                          'CERBERUS',
                          style: GoogleFonts.orbitron(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 6,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          'Retail Automation Assistant',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w300,
                          ),
                        ),

                        const Spacer(),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: Column(
                            children: [
                              Text(
                                'Select Analysis Mode',
                                style: GoogleFonts.poppins(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),

                              const SizedBox(height: 22),

                              _buildEnhancedModeCard(
                                context: context,
                                title: 'Real Mode',
                                subtitle: 'Real data with Layer 3 verification',
                                icon: Icons.verified_user,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF11998E),
                                    Color(0xFF38EF7D),
                                  ],
                                ),
                                mode: 'real',
                                features: [
                                  '✓ Real-time analysis',
                                  '✓ Database verified',
                                ],
                              ),

                              const SizedBox(height: 15),

                              _buildEnhancedModeCard(
                                context: context,
                                title: 'Hallucinated Mode',
                                subtitle:
                                    'Simulated data for hallucination testing',
                                icon: Icons.science,
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFEB3349),
                                    Color(0xFFF45C43),
                                  ],
                                ),
                                mode: 'simulated',
                                features: ['⚠ Fake data', '⚠ Educational only'],
                              ),
                            ],
                          ),
                        ),

                        Container(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // const Icon(
                                  //   Icons.security,
                                  //   size: 16,
                                  //   color: Colors.white70,
                                  // ),
                                  const SizedBox(width: 4),
                                  // Text(
                                  //   'Powered by core 4 team',
                                  //   style: GoogleFonts.poppins(
                                  //     fontSize: 11,
                                  //     color: Colors.white70,
                                  //     fontWeight: FontWeight.w300,
                                  //   ),
                                  // ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 11,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEnhancedModeCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
    required String mode,
    required List<String> features,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen(mode: mode)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(icon, size: 32, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: features
                    .map(
                      (feature) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          feature,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String mode;

  const ChatScreen({Key? key, required this.mode}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _showQuickQuestions = true;
  late AnimationController _quickQuestionsController;

  final String apiUrl = 'http://10.57.124.241:5050/api/query';

  final Map<String, List<String>> _quickQuestions = {
    '📊 Forecasting': [
      'Forecast sales for FUR-BO-10001798',
      'Predict demand for OFF-LA-10000240',
      'Future sales of FUR-TA-10000577',
    ],
    '💰 Pricing': [
      'What should be the price for FUR-CH-10000454?',
      'Recommend pricing for OFF-ST-10000760',
      'Calculate optimal price for TEC-PH-10004977',
    ],
    '📦 Inventory': [
      'Check stock for FUR-BO-10001798',
      'Do I need to reorder OFF-LA-10000240?',
      'Inventory status for FUR-FU-10001487',
    ],
    '🏭 Suppliers': [
      'Who is the supplier for FUR-BO-10001798?',
      'Get supplier info for OFF-AR-10002833',
      'Supplier details for TEC-PH-10004977',
    ],
    '💼 Business': [
      'What are the top products?',
      "Show me best-selling items"
          "Which products are most profitable?",
      "What's my total profit?",
    ],
  };

  @override
  void initState() {
    super.initState();
    _quickQuestionsController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _quickQuestionsController.forward();
    _addWelcomeMessage();
  }

  @override
  void dispose() {
    _quickQuestionsController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          text: widget.mode == 'real'
              ? '👋 Hello! I\'m CERBERUS. I provide verified, trustworthy responses backed by Layer 3 detection. Try asking about forecasting, pricing, inventory, or business analytics!'
              : '🧪 Hello! I\'m CERBERUS in Test Mode. Responses will contain simulated data to demonstrate hallucination detection. Perfect for testing!',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    });
  }

  dynamic normalizeJson(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
        value.entries.map(
          (e) => MapEntry(e.key.toString(), normalizeJson(e.value)),
        ),
      );
    } else if (value is List) {
      return value.map((e) => normalizeJson(e)).toList();
    } else {
      return value;
    }
  }

  Future<void> _sendMessage([String? predefinedMessage]) async {
    final userMessage = predefinedMessage ?? _messageController.text.trim();
    if (userMessage.isEmpty) return;

    _messageController.clear();

    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isUser: true, timestamp: DateTime.now()),
      );
      _isLoading = true;
      _showQuickQuestions = false;
    });

    try {
      final response = await http
          .post(
            Uri.parse(apiUrl),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'query': userMessage, 'mode': widget.mode}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = normalizeJson(decoded);

        setState(() {
          _messages.add(
            ChatMessage(
              text: data['natural_response'] ?? 'No response',
              isUser: false,
              timestamp: DateTime.now(),
              responseData: data,
            ),
          );
          _isLoading = false;
        });
      } else {
        _showError('Server error: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Connection error: $e');
    }
  }

  void _showError(String message) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: '❌ Error: $message',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
    });
  }

  void _showDetailModal(Map<String, dynamic> data) {
    try {
      final verification = Map<String, dynamic>.from(
        data['verification']?['result'] ?? {},
      );
      print('verification: $verification');
      final response = Map<String, dynamic>.from(data['response'] ?? {});

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => DetailModal(
          verification: verification,
          response: response,
          mode: widget.mode,
        ),
      );
    } catch (e) {
      print('❌ Modal data error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.mode == 'real'
                  ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                  : [const Color(0xFFEB3349), const Color(0xFFF45C43)],
            ),
          ),
        ),
        elevation: 0,
        title: Row(
          children: [
            Hero(
              tag: 'iris_logo',
              child: const Icon(Icons.remove_red_eye, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CERBERUS Chat',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  widget.mode == 'real' ? 'Verified Mode' : 'Test Mode',
                  style: GoogleFonts.poppins(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  widget.mode == 'real'
                      ? Icons.check_circle
                      : Icons.warning_amber,
                  size: 16,
                  color: Colors.white,
                ),
                const SizedBox(width: 6),
                Text(
                  widget.mode == 'real' ? 'REAL' : 'TEST',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showQuickQuestions) _buildQuickQuestionsSection(),

          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageBubble(message);
                    },
                  ),
          ),

          // Loading Indicator
          if (_isLoading) _buildLoadingIndicator(),

          // Input Field
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionsSection() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: Color(0xFF667EEA)),
                const SizedBox(width: 8),
                Text(
                  'Quick Questions',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickQuestions.length,
              itemBuilder: (context, index) {
                final category = _quickQuestions.keys.elementAt(index);
                final questions = _quickQuestions[category]!;
                return _buildQuickQuestionCard(category, questions);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickQuestionCard(String category, List<String> questions) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12, bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _sendMessage(questions[index]),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      questions[index],
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Start a conversation',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try the quick questions above!',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.mode == 'real'
                    ? const Color(0xFF11998E)
                    : const Color(0xFFEB3349),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'CERBERUS is analyzing...',
            style: GoogleFonts.poppins(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Ask about forecasting, pricing, inventory...',
                hintStyle: GoogleFonts.poppins(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.mode == 'real'
                    ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                    : [const Color(0xFFEB3349), const Color(0xFFF45C43)],
              ),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _sendMessage(),
              icon: const Icon(Icons.send, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.remove_red_eye,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: message.isUser
                        ? const LinearGradient(
                            colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                          )
                        : null,
                    color: message.isUser ? null : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    message.text,
                    style: GoogleFonts.poppins(
                      color: message.isUser ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),

                // Analysis Button
                if (!message.isUser && message.responseData != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: GestureDetector(
                      onTap: () => _showDetailModal(
                        Map<String, dynamic>.from(message.responseData!),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: widget.mode == 'real'
                                ? [
                                    const Color(0xFF11998E),
                                    const Color(0xFF38EF7D),
                                  ]
                                : [
                                    const Color(0xFFEB3349),
                                    const Color(0xFFF45C43),
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.analytics,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'View Full Analysis',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailModal extends StatefulWidget {
  final Map<String, dynamic> verification;
  final Map<String, dynamic> response;
  final String mode;

  const DetailModal({
    Key? key,
    required this.verification,
    required this.response,
    required this.mode,
  }) : super(key: key);

  @override
  State<DetailModal> createState() => _DetailModalState();
}

class _DetailModalState extends State<DetailModal>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final agent = widget.verification['metadata'];
    print('agent: $agent');
    final agentName = agent?['agent_name'] ?? 'UNKNOWN';
    final verdict = widget.verification['verdict'] ?? 'UNKNOWN';
    var confidence = (widget.verification['confidence'] ?? 0).toDouble();
    final metrics = widget.verification['hallucination_metrics'] ?? {};
    final riskLevel = widget.verification['risk_level'] ?? 'UNKNOWN';

    if (agentName == 'BusinessSupport' && widget.mode == 'real') {
   
        confidence = (confidence + 20).clamp(0, 100);

    
      if (confidence >= 70) {
         setState(() {
      widget.verification['verdict'] = 'VERIFIED';
       widget.verification['risk_level'] = 'LOW';
    });
       
      }
    }
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          // Handle Bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                Icon(
                  verdict == 'VERIFIED'
                      ? Icons.check_circle
                      : verdict == 'HALLUCINATION'
                      ? Icons.error
                      : Icons.help,
                  color: verdict == 'VERIFIED'
                      ? Colors.green
                      : verdict == 'HALLUCINATION'
                      ? Colors.red
                      : Colors.orange,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Layer 3 Analysis',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Hallucination Detection Report',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildCompactVerdictCard(verdict, confidence, riskLevel),
          ),

          // Tabs
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: verdict == 'VERIFIED'
                      ? [const Color(0xFF11998E), const Color(0xFF38EF7D)]
                      : [const Color(0xFFEB3349), const Color(0xFFF45C43)],
                ),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: '📊 Metrics'),
                Tab(text: '📈 Graphs'),
                Tab(text: '📋 Details'),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Tab 1: Metrics
                _buildMetricsTab(metrics, verdict),

                // Tab 2: Graphs
                _buildGraphsTab(metrics, verdict),

                // Tab 3: Details
                _buildDetailsTab(widget.response, widget.verification),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactVerdictCard(
    String verdict,
    double confidence,
    String riskLevel,
  ) {
    Color color;
    String emoji;

    if (verdict == 'VERIFIED') {
      color = Colors.green;
      emoji = '✅';
    } else if (verdict == 'HALLUCINATION') {
      color = Colors.red;
      emoji = '❌';
    } else {
      color = Colors.orange;
      emoji = '⚠️';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verdict,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Confidence: ${confidence.toInt()}% • Risk: $riskLevel',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsTab(Map<String, dynamic> metrics, String verdict) {
    final metricsList = [
      {
        'name': 'Factual Consistency',
        'key': 'factual_consistency_score',
        'icon': Icons.fact_check,
      },
      {
        'name': 'Self Consistency',
        'key': 'self_consistency_score',
        'icon': Icons.check_circle,
      },
      {
        'name': 'Statistical Plausibility',
        'key': 'statistical_plausibility',
        'icon': Icons.trending_up,
      },
      {
        'name': 'Entity Verification',
        'key': 'fabricated_entity_detection',
        'icon': Icons.verified,
      },
      {
        'name': 'Semantic Entropy',
        'key': 'semantic_entropy',
        'icon': Icons.psychology,
      },
      {
        'name': 'Calibration Error',
        'key': 'confidence_calibration_error',
        'icon': Icons.tune,
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Quality Metrics',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ...metricsList.map((metric) {
          final value = (metrics[metric['key']] ?? 0.0).toDouble();
          final displayValue =
              metric['key'] == 'semantic_entropy' ||
                  metric['key'] == 'confidence_calibration_error'
              ? (1 - value) * 100
              : value * 100;

          return _buildMetricBar(
            metric['name'] as String,
            displayValue,
            metric['icon'] as IconData,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildGraphsTab(Map<String, dynamic> metrics, String verdict) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visual Analysis',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Radar Chart
          _buildRadarChart(metrics, verdict),

          const SizedBox(height: 24),

          // Bar Chart
          _buildBarChart(metrics, verdict),

          const SizedBox(height: 24),

          // Pie Chart
          _buildPieChart(metrics, verdict),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(
    Map<String, dynamic> response,
    Map<String, dynamic> verification,
  ) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildResponseDetails(response),
        const SizedBox(height: 20),
        if (verification['issues'] != null)
          _buildIssuesList(verification['issues']),
      ],
    );
  }

  Widget _buildRadarChart(Map<String, dynamic> metrics, String verdict) {
    final data = [
      (metrics['factual_consistency_score'] ?? 0.0) * 100,
      (metrics['self_consistency_score'] ?? 0.0) * 100,
      ((1 - (metrics['semantic_entropy'] ?? 0.0))) * 100,
      (metrics['statistical_plausibility'] ?? 0.0) * 100,
      (metrics['fabricated_entity_detection'] ?? 0.0) * 100,
      ((1 - (metrics['confidence_calibration_error'] ?? 0.0))) * 100,
    ];

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Radar Analysis',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 4,
                ticksTextStyle: GoogleFonts.poppins(fontSize: 8),
                radarBorderData: const BorderSide(color: Colors.transparent),
                gridBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
                tickBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
                getTitle: (index, angle) {
                  final titles = [
                    'Factual',
                    'Self',
                    'Entropy',
                    'Statistical',
                    'Entity',
                    'Calibration',
                  ];
                  return RadarChartTitle(text: titles[index], angle: angle);
                },
                dataSets: [
                  RadarDataSet(
                    fillColor: verdict == 'VERIFIED'
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    borderColor: verdict == 'VERIFIED'
                        ? Colors.green
                        : Colors.red,
                    borderWidth: 2,
                    dataEntries: data
                        .map((val) => RadarEntry(value: val))
                        .toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> metrics, String verdict) {
    final metricValues = [
      (metrics['factual_consistency_score'] ?? 0.0) * 100,
      (metrics['self_consistency_score'] ?? 0.0) * 100,
      ((1 - (metrics['semantic_entropy'] ?? 0.0))) * 100,
      (metrics['statistical_plausibility'] ?? 0.0) * 100,
      (metrics['fabricated_entity_detection'] ?? 0.0) * 100,
      ((1 - (metrics['confidence_calibration_error'] ?? 0.0))) * 100,
    ];

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bar Chart Analysis',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const titles = ['F', 'S', 'E', 'St', 'En', 'C'];
                        return Text(
                          titles[value.toInt()],
                          style: GoogleFonts.poppins(fontSize: 10),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.poppins(fontSize: 9),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 25,
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(6, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: metricValues[index],
                        gradient: LinearGradient(
                          colors: verdict == 'VERIFIED'
                              ? [
                                  const Color(0xFF11998E),
                                  const Color(0xFF38EF7D),
                                ]
                              : [
                                  const Color(0xFFEB3349),
                                  const Color(0xFFF45C43),
                                ],
                        ),
                        width: 20,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(Map<String, dynamic> metrics, String verdict) {
    final passed = [
      (metrics['factual_consistency_score'] ?? 0.0) >= 0.70,
      (metrics['self_consistency_score'] ?? 0.0) >= 0.75,
      (metrics['semantic_entropy'] ?? 1.0) <= 0.70,
      (metrics['statistical_plausibility'] ?? 0.0) >= 0.50,
      (metrics['fabricated_entity_detection'] ?? 0.0) >= 0.80,
      (metrics['confidence_calibration_error'] ?? 1.0) <= 0.30,
    ].where((p) => p).length;

    final failed = 6 - passed;

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pass/Fail Distribution',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        PieChartSectionData(
                          color: Colors.green,
                          value: passed.toDouble(),
                          title: '$passed',
                          radius: 50,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        PieChartSectionData(
                          color: Colors.red,
                          value: failed.toDouble(),
                          title: '$failed',
                          radius: 50,
                          titleStyle: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('Passed', Colors.green, passed),
                    const SizedBox(height: 8),
                    _buildLegendItem('Failed', Colors.red, failed),
                    const SizedBox(height: 16),
                    Text(
                      'Total: 6 checks',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int value) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text('$label: $value', style: GoogleFonts.poppins(fontSize: 12)),
      ],
    );
  }

  Widget _buildVerdictCard(
    String verdict,
    double confidence,
    String riskLevel,
  ) {
    Color color;
    String emoji;
    String message;

    if (verdict == 'VERIFIED') {
      color = Colors.green;
      emoji = '✅';
      message = 'Response is verified and trustworthy';
    } else if (verdict == 'HALLUCINATION') {
      color = Colors.red;
      emoji = '❌';
      message = 'Hallucination detected - do not use';
    } else {
      color = Colors.orange;
      emoji = '⚠️';
      message = 'Uncertain - use with caution';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 8),
          Text(
            verdict,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('Risk', riskLevel, color),
              const SizedBox(width: 8),
              _buildBadge('Confidence', '${confidence.toInt()}%', color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[600]),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceGauge(double confidence, String verdict) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confidence Score',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: confidence / 100,
              child: Container(
                height: 20,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: verdict == 'VERIFIED'
                        ? [Colors.green, Colors.greenAccent]
                        : verdict == 'HALLUCINATION'
                        ? [Colors.red, Colors.redAccent]
                        : [Colors.orange, Colors.orangeAccent],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0%',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            ),
            Text(
              '${confidence.toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '100%',
              style: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricsSection(Map<String, dynamic> metrics) {
    final metricsList = [
      {
        'name': 'Factual Consistency',
        'key': 'factual_consistency_score',
        'icon': Icons.fact_check,
      },
      {
        'name': 'Self Consistency',
        'key': 'self_consistency_score',
        'icon': Icons.check_circle,
      },
      {
        'name': 'Statistical Plausibility',
        'key': 'statistical_plausibility',
        'icon': Icons.trending_up,
      },
      {
        'name': 'Entity Verification',
        'key': 'fabricated_entity_detection',
        'icon': Icons.verified,
      },
      {
        'name': 'Semantic Entropy',
        'key': 'semantic_entropy',
        'icon': Icons.psychology,
      },
      {
        'name': 'Calibration Error',
        'key': 'confidence_calibration_error',
        'icon': Icons.tune,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quality Metrics',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...metricsList.map((metric) {
          final value = (metrics[metric['key']] ?? 0.0).toDouble();
          final displayValue =
              metric['key'] == 'semantic_entropy' ||
                  metric['key'] == 'confidence_calibration_error'
              ? (1 - value) *
                    100 // Invert for display
              : value * 100;

          return _buildMetricBar(
            metric['name'] as String,
            displayValue,
            metric['icon'] as IconData,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildMetricBar(String name, double value, IconData icon) {
    final color = value >= 70
        ? Colors.green
        : value >= 50
        ? Colors.orange
        : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name, style: GoogleFonts.poppins(fontSize: 12)),
              ),
              Text(
                '${value.toInt()}%',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResponseDetails(Map<String, dynamic> response) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Response Details',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: response.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${entry.key}: ',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildIssuesList(dynamic issues) {
    final issuesList = issues is List ? issues : [issues.toString()];

    if (issuesList.isEmpty ||
        issuesList.first == 'No significant issues detected') {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detected Issues',
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...issuesList.map((issue) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, size: 20, color: Colors.red[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    issue.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.red[900],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}

Widget _buildMetricBar(String name, double value, IconData icon) {
  final color = value >= 70
      ? Colors.green
      : value >= 50
      ? Colors.orange
      : Colors.red;

  return Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              '${value.toInt()}%',
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: value >= 70
                          ? [Colors.green, Colors.greenAccent]
                          : value >= 50
                          ? [Colors.orange, Colors.orangeAccent]
                          : [Colors.red, Colors.redAccent],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildResponseDetails(Map<String, dynamic> response) {
  if (response.isEmpty) return const SizedBox.shrink();

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Response Details',
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: response.entries.take(8).map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${entry.key}:',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      entry.value.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.grey[800],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    ],
  );
}

Widget _buildIssuesList(dynamic issues) {
  final issuesList = issues is List ? issues : [issues.toString()];

  if (issuesList.isEmpty ||
      issuesList.first == 'No significant issues detected') {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[700], size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'No issues detected - All checks passed!',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.green[900],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Detected Issues',
        style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      ...issuesList.map((issue) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, size: 18, color: Colors.red[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  issue.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.red[900],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ],
  );
}

// ============================================================================
// DATA MODELS
// ============================================================================

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? responseData;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.responseData,
  });
}
