import 'package:flutter/material.dart';
import '../services/banking_provider.dart';
import '../theme/app_colors.dart';
import '../screens/transfer/transfer_screen.dart';

class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const QrScannerDialog(),
    );
  }

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> with SingleTickerProviderStateMixin {
  int _selectedMode = 0; // 0 = Scan QR, 1 = My QR
  late AnimationController _laserController;

  @override
  void initState() {
    super.initState();
    _laserController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _laserController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final user = banking.user;
    final selectedAcc = banking.selectedAccount;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mode Switcher (Scan vs My QR)
            Container(
              height: 42,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedMode == 0 ? const Color(0xFF0F172A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Scan UPI QR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _selectedMode == 0 ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMode = 1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _selectedMode == 1 ? const Color(0xFF0F172A) : Colors.transparent,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'My Receive QR',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: _selectedMode == 1 ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (_selectedMode == 0) ...[
              // Scanner Camera Viewfinder Simulation
              Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.accentBlue, width: 2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Corner targeting brackets
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 140,
                        color: Colors.white.withValues(alpha: 0.15),
                      ),
                    ),
                    // Animated Laser line
                    AnimatedBuilder(
                      animation: _laserController,
                      builder: (context, child) {
                        return Positioned(
                          top: 20 + (_laserController.value * 160),
                          left: 20,
                          right: 20,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.electricCyan,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricCyan.withValues(alpha: 0.8),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Align merchant or peer QR code within frame',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const TransferScreen()),
                  );
                },
                icon: const Icon(Icons.flash_on_rounded, size: 18),
                label: const Text('Simulate Merchant QR Scan'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              ),
            ] else ...[
              // Personal Receive QR Card
              Container(
                width: 220,
                height: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppColors.cardBorder, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 140, color: AppColors.primaryNavy),
                    const SizedBox(height: 4),
                    Text(
                      '${user.name.toLowerCase().replaceAll(' ', '')}@banklite',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Linked to ${selectedAcc.accountType} (${selectedAcc.maskedNumber})',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('UPI ID copied to clipboard: swetakadam@banklite'),
                      backgroundColor: AppColors.primaryNavy,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('Copy UPI ID'),
                style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
              ),
            ],

            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}
