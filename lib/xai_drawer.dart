import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iris_app/app_colors.dart';

// ── Data model parsed from actual backend response ─────────────────────────
class XaiExplanation {
  final String agentType;
  final double confidence;
  final String headline;
  final String priority;
  final List<String> keyFacts;
  final List<String> boostingDemand;
  final List<String> reducingDemand;
  final List<String> whyThisDemand;
  final List<String> priceSensitivity;
  final String advice;
  final String nextStep;
  final String technicalNote;

  const XaiExplanation({
    required this.agentType,
    required this.confidence,
    required this.headline,
    required this.priority,
    required this.keyFacts,
    required this.boostingDemand,
    required this.reducingDemand,
    required this.whyThisDemand,
    required this.priceSensitivity,
    required this.advice,
    required this.nextStep,
    required this.technicalNote,
  });

  factory XaiExplanation.fromResponseData(Map<String, dynamic> data) {
    // data is the full HTTP response body
    final xai      = data['xai']      as Map<String, dynamic>? ?? {};
    final friendly = xai['friendly_explanation'] as Map<String, dynamic>? ?? {};
    final agentName = xai['agent']    as String? ?? '';
    final confidence = (xai['confidence'] ?? 0).toDouble();

    String agentType = 'demand';
    if (agentName.contains('Pricing'))       agentType = 'pricing';
    if (agentName.contains('Replenishment')) agentType = 'replenishment';
    if (agentName.contains('Supplier'))      agentType = 'supplier';

    List<String> toList(dynamic v) {
      if (v == null) return [];
      if (v is List) return v.map((e) => e.toString()).toList();
      return [];
    }

    return XaiExplanation(
      agentType:        agentType,
      confidence:       confidence,
      headline:         friendly['headline']      as String? ?? '',
      priority:         friendly['priority']      as String? ?? '',
      keyFacts:         toList(friendly['key_facts']),
      boostingDemand:   toList(friendly['boosting_demand']),
      reducingDemand:   toList(friendly['reducing_demand']),
      whyThisDemand:    toList(friendly['why_this_demand']),
      priceSensitivity: toList(friendly['price_sensitivity']),
      advice:           friendly['advice']        as String?
                     ?? friendly['next_step']     as String? ?? '',
      nextStep:         friendly['next_step']     as String? ?? '',
      technicalNote:    friendly['technical_note'] as String? ?? '',
    );
  }

  bool get hasContent =>
      headline.isNotEmpty || keyFacts.isNotEmpty || advice.isNotEmpty;
}

// ── Entry point ────────────────────────────────────────────────────────────
void showXaiDrawer(BuildContext context, Map<String, dynamic> responseData) {
  final xai = XaiExplanation.fromResponseData(responseData);

  if (!xai.hasContent) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'No XAI explanation available for this response.',
          style: GoogleFonts.bricolageGrotesque(fontSize: 13),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
    return;
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'XAI',
    barrierColor: Colors.black38,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => const SizedBox.shrink(),
    transitionBuilder: (ctx, animation, _, __) {
      final slide = Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      ));
      return SlideTransition(
        position: slide,
        child: Align(
          alignment: Alignment.centerRight,
          child: _XaiDrawerSheet(xai: xai),
        ),
      );
    },
  );
}

// ── Drawer sheet ───────────────────────────────────────────────────────────
class _XaiDrawerSheet extends StatelessWidget {
  final XaiExplanation xai;
  const _XaiDrawerSheet({required this.xai});

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: (screenW * 0.88).clamp(300.0, 420.0),
        height: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(-6, 0),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                children: [
                  _buildAgentBadge(),
                  const SizedBox(height: 12),
                  if (xai.headline.isNotEmpty) ...[
                    _buildHeadlineCard(),
                    const SizedBox(height: 12),
                  ],
                  if (xai.priority.isNotEmpty) ...[
                    _buildPriorityCard(),
                    const SizedBox(height: 12),
                  ],
                  if (xai.keyFacts.isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.list_alt_rounded,
                      title: 'Key facts',
                      items: xai.keyFacts,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (xai.boostingDemand.isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.trending_up_rounded,
                      title: 'Boosting demand',
                      items: xai.boostingDemand,
                      accentColor: const Color(0xFF3B6D11),
                      bgColor: const Color(0xFFEAF3DE),
                      borderColor: const Color(0xFFC0DD97),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (xai.reducingDemand.isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.trending_down_rounded,
                      title: 'Reducing demand',
                      items: xai.reducingDemand,
                      accentColor: const Color(0xFFA32D2D),
                      bgColor: const Color(0xFFFCEBEB),
                      borderColor: const Color(0xFFF7C1C1),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (xai.whyThisDemand.isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.psychology_rounded,
                      title: 'Why this demand',
                      items: xai.whyThisDemand,
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (xai.priceSensitivity.isNotEmpty) ...[
                    _buildSection(
                      icon: Icons.price_change_rounded,
                      title: 'Price sensitivity',
                      items: xai.priceSensitivity,
                      accentColor: const Color(0xFF854F0B),
                      bgColor: const Color(0xFFFAEEDA),
                      borderColor: const Color(0xFFFAC775),
                    ),
                    const SizedBox(height: 12),
                  ],
                  if (xai.advice.isNotEmpty) ...[
                    _buildAdviceCard(),
                    const SizedBox(height: 12),
                  ],
                  if (xai.technicalNote.isNotEmpty) ...[
                    _buildTechnicalNote(),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 12, 14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_graph_rounded,
                color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'XAI Explanation',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'AI reasoning breakdown',
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
            padding: EdgeInsets.zero,
            constraints:
                const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }

  // ── Agent badge ────────────────────────────────────────────────────────────
  Widget _buildAgentBadge() {
    final labels = {
      'demand':        ('Demand Forecast',    Icons.bar_chart_rounded,        Color(0xFF185FA5), Color(0xFFE6F1FB)),
      'pricing':       ('Pricing Strategy',   Icons.sell_rounded,             Color(0xFF854F0B), Color(0xFFFAEEDA)),
      'replenishment': ('Replenishment',       Icons.inventory_2_rounded,      Color(0xFF3B6D11), Color(0xFFEAF3DE)),
      'supplier':      ('Supplier Selection', Icons.local_shipping_rounded,   Color(0xFF533AB7), Color(0xFFEEEDFE)),
    };
    final info = labels[xai.agentType] ?? ('Analysis', Icons.analytics_rounded, AppColors.primaryBlue, Color(0xFFE6F1FB));

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: info.$4,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: info.$3.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(info.$2, size: 14, color: info.$3),
              const SizedBox(width: 6),
              Text(
                info.$1,
                style: GoogleFonts.bricolageGrotesque(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: info.$3,
                ),
              ),
            ],
          ),
        ),
        if (xai.confidence > 0) ...[
          const SizedBox(width: 8),
          Text(
            '${(xai.confidence * 100).toInt()}% confidence',
            style: GoogleFonts.bricolageGrotesque(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }

  // ── Headline card ──────────────────────────────────────────────────────────
  Widget _buildHeadlineCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: AppColors.primaryBlue.withOpacity(0.2)),
      ),
      child: Text(
        xai.headline,
        style: GoogleFonts.bricolageGrotesque(
          fontSize: 14,
          height: 1.55,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // ── Priority card ──────────────────────────────────────────────────────────
  Widget _buildPriorityCard() {
    Color bg; Color fg; Color border;
    if (xai.priority.contains('CRITICAL') || xai.priority.contains('🔴')) {
      bg = const Color(0xFFFCEBEB); fg = const Color(0xFFA32D2D);
      border = const Color(0xFFF7C1C1);
    } else if (xai.priority.contains('HIGH') || xai.priority.contains('🟠')) {
      bg = const Color(0xFFFAEEDA); fg = const Color(0xFF854F0B);
      border = const Color(0xFFFAC775);
    } else if (xai.priority.contains('MEDIUM') || xai.priority.contains('🟡')) {
      bg = const Color(0xFFFAF3DA); fg = const Color(0xFF7A6010);
      border = const Color(0xFFF0D870);
    } else {
      bg = const Color(0xFFEAF3DE); fg = const Color(0xFF3B6D11);
      border = const Color(0xFFC0DD97);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(Icons.flag_rounded, size: 16, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              xai.priority,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Generic section card ───────────────────────────────────────────────────
  Widget _buildSection({
    required IconData icon,
    required String title,
    required List<String> items,
    Color? accentColor,
    Color? bgColor,
    Color? borderColor,
  }) {
    final ac = accentColor ?? AppColors.primaryBlue;
    final bg = bgColor ?? Colors.grey.withOpacity(0.05);
    final bc = borderColor ?? Colors.grey.withOpacity(0.15);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: bc),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(13, 12, 13, 8),
            child: Row(
              children: [
                Icon(icon, size: 14, color: ac),
                const SizedBox(width: 6),
                Text(
                  title.toUpperCase(),
                  style: GoogleFonts.bricolageGrotesque(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: ac,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: bc),
          Padding(
            padding: const EdgeInsets.all(13),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                // detect arrow prefix for coloring
                final isUp   = item.startsWith('⬆');
                final isDown = item.startsWith('⬇');
                final itemColor = isUp
                    ? const Color(0xFF3B6D11)
                    : isDown
                        ? const Color(0xFFA32D2D)
                        : AppColors.textPrimary;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    item,
                    style: GoogleFonts.bricolageGrotesque(
                      fontSize: 13,
                      height: 1.55,
                      color: itemColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Advice card ────────────────────────────────────────────────────────────
  Widget _buildAdviceCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.white, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              xai.advice.isNotEmpty ? xai.advice : xai.nextStep,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 13,
                height: 1.55,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Technical note ─────────────────────────────────────────────────────────
  Widget _buildTechnicalNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              xai.technicalNote,
              style: GoogleFonts.bricolageGrotesque(
                fontSize: 11,
                height: 1.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}