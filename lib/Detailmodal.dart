import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailModal extends StatelessWidget {
  final Map<String, dynamic> verification;
  final Map<String, dynamic> response;

  const DetailModal({
    Key? key,
    required this.verification,
    required this.response,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final confidence = (verification['confidence'] ?? 0).toDouble();
    final verdict = verification['verdict'] ?? 'UNKNOWN';
    final checks = Map<String, dynamic>.from(
      verification['checks_performed'] ?? {},
    );
    final issues = List<String>.from(verification['issues'] ?? []);
    final recommendations = List<String>.from(verification['recommendations'] ?? []);

    // Extract metrics for chart
   final metricList = checks.entries.map((e) {
  final name = e.key;
  final score = ((e.value['score'] ?? 0) * 100).toDouble();

  // Normalize "passed" safely — handle bool, string, or null
  final rawPassed = e.value['passed'];
  final passed = (rawPassed == true || rawPassed == 'true' || rawPassed == 'True');

  return Metric(name, score, passed);
}).toList();


    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                _buildVerdictBadge(verdict, confidence),
                const SizedBox(height: 20),

                Text(
                  'Verification Metrics',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                _buildMetricsChart(metricList),
                const SizedBox(height: 16),

                _buildMetricsList(metricList),
                const SizedBox(height: 20),

                if (issues.isNotEmpty) _buildIssues(issues),
                if (recommendations.isNotEmpty) _buildRecommendations(recommendations),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVerdictBadge(String verdict, double confidence) {
    Color color;
    IconData icon;
    if (verdict == 'HALLUCINATION') {
      color = Colors.red;
      icon = Icons.error;
    } else if (verdict == 'VERIFIED') {
      color = Colors.green;
      icon = Icons.check_circle;
    } else {
      color = Colors.orange;
      icon = Icons.warning;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  verdict,
                  style: GoogleFonts.poppins(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Confidence: ${confidence.toStringAsFixed(2)}%',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

Widget _buildMetricsChart(List<Metric> metrics) {
  return SizedBox(
    height: 260,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: metrics.length * 60.0, // Adjust width dynamically
        child: BarChart(
          BarChartData(
            maxY: 100,
            alignment: BarChartAlignment.spaceAround,
            barGroups: metrics.asMap().entries.map((entry) {
              final m = entry.value;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: m.score,
                    width: 18,
                    color: m.passed ? Colors.green : Colors.red,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }).toList(),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, meta) {
                    if (v.toInt() < 0 || v.toInt() >= metrics.length) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 60, // each label takes limited space
                        child: Text(
                          metrics[v.toInt()].label.replaceAll('_', '\n'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 9),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (v, _) =>
                      Text('${v.toInt()}%', style: const TextStyle(fontSize: 10)),
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(show: true, horizontalInterval: 20),
          ),
        ),
      ),
    ),
  );
}

  Widget _buildMetricsList(List<Metric> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: metrics.map((m) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(m.label.replaceAll('_', ' '),
                  style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700])),
              Text(
                '${m.score.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: m.passed ? Colors.green : Colors.red),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildIssues(List<String> issues) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('⚠️ Issues Detected',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 10),
          ...issues.map((e) => Text('• $e', style: const TextStyle(fontSize: 13))),
        ],
      );

  Widget _buildRecommendations(List<String> recs) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Text('💡 Recommendations',
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          const SizedBox(height: 10),
          ...recs.map((e) => Text('• $e', style: const TextStyle(fontSize: 13))),
        ],
      );
}

class Metric {
  final String label;
  final double score;
  final bool passed;

  Metric(this.label, this.score, this.passed);
}
