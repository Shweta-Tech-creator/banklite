import 'package:flutter/material.dart';
import '../services/banking_provider.dart';
import '../theme/app_colors.dart';

class AiFraudShieldSheet extends StatefulWidget {
  const AiFraudShieldSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AiFraudShieldSheet(),
    );
  }

  @override
  State<AiFraudShieldSheet> createState() => _AiFraudShieldSheetState();
}

class _AiFraudShieldSheetState extends State<AiFraudShieldSheet> {
  bool _cardFrozen = false;
  bool _aiAnomalyProtection = true;
  bool _internationalTxnBlocked = true;
  bool _isSimulating = false;
  String? _simulatedResult;

  void _runAiSimulation() async {
    setState(() {
      _isSimulating = true;
      _simulatedResult = null;
    });

    await Future.delayed(const Duration(milliseconds: 1200));

    if (mounted) {
      setState(() {
        _isSimulating = false;
        _simulatedResult = '✅ AI Risk Score: 0.03 (Very Low Risk)\n• Pattern: Routine transfer frequency\n• Beneficiary: Verified KYC status\n• Verdict: Auto-Authorized with 256-bit Token';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final selectedAcc = banking.selectedAccount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.only(top: 12, left: 20, right: 20, bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF0066FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Security & Fraud Shield',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Real-time transaction anomaly protection',
                        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Score Card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: CircularProgressIndicator(
                                value: _cardFrozen ? 0.45 : 0.99,
                                strokeWidth: 6,
                                backgroundColor: Colors.white12,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _cardFrozen ? AppColors.warning : AppColors.successDark,
                                ),
                              ),
                            ),
                            Text(
                              _cardFrozen ? '45%' : '99%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cardFrozen ? 'Card Frozen (Protected)' : 'Protection Status: Active',
                                style: TextStyle(
                                  color: _cardFrozen ? const Color(0xFFFBBF24) : AppColors.electricCyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _cardFrozen
                                    ? 'All incoming and outgoing transactions on ${selectedAcc.maskedNumber} are locked.'
                                    : 'Zero abnormal transfer patterns detected in the last 30 days.',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Interactive Security Controls
                  const Text(
                    'Security & Anomaly Controls',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // 1. Instant Card Freeze Toggle
                  _buildControlTile(
                    icon: Icons.ac_unit_rounded,
                    iconColor: const Color(0xFF0284C7),
                    title: 'Instant Card Freeze',
                    subtitle: 'Emergency one-tap lock for debit card & online payments',
                    value: _cardFrozen,
                    onChanged: (val) {
                      setState(() => _cardFrozen = val);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(_cardFrozen ? '🔒 Card instantly locked!' : '🔓 Card unlocked and active!'),
                          backgroundColor: _cardFrozen ? AppColors.error : AppColors.successDark,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  // 2. AI Anomaly Alert Toggle
                  _buildControlTile(
                    icon: Icons.auto_awesome,
                    iconColor: AppColors.accentBlue,
                    title: 'AI Anomaly & Velocity Guard',
                    subtitle: 'Auto-flags sudden high-value or burst transactions above ₹25k',
                    value: _aiAnomalyProtection,
                    onChanged: (val) {
                      setState(() => _aiAnomalyProtection = val);
                    },
                  ),

                  const SizedBox(height: 8),

                  // 3. International Protection
                  _buildControlTile(
                    icon: Icons.public_off_rounded,
                    iconColor: const Color(0xFF8B5CF6),
                    title: 'Block Overseas / Cross-Border Txn',
                    subtitle: 'Restrict cross-border unauthorized payment gateways',
                    value: _internationalTxnBlocked,
                    onChanged: (val) {
                      setState(() => _internationalTxnBlocked = val);
                    },
                  ),

                  const SizedBox(height: 22),

                  // Viva AI Live Simulator
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.science_outlined, color: AppColors.accentBlue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'AI Risk Engine Live Simulator (Viva Demo)',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryNavy,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Test the real-time AI evaluation pipeline by simulating an incoming transaction risk audit.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _isSimulating ? null : _runAiSimulation,
                          icon: _isSimulating
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.play_arrow_rounded, size: 18),
                          label: Text(_isSimulating ? 'Analyzing Transaction...' : 'Run Live AI Risk Audit'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryNavy,
                            minimumSize: const Size(double.infinity, 42),
                          ),
                        ),
                        if (_simulatedResult != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFA7F3D0)),
                            ),
                            child: Text(
                              _simulatedResult!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF065F46),
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.accentBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
