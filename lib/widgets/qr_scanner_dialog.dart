import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr/qr.dart';
import '../services/banking_provider.dart';
import '../theme/app_colors.dart';
import '../screens/transfer/transfer_screen.dart';

class QrCodePainter extends CustomPainter {
  final QrImage qrImage;
  final Color color;

  const QrCodePainter({
    required this.qrImage,
    this.color = const Color(0xFF0F172A),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final double squareSize = size.width / qrImage.moduleCount;

    for (int x = 0; x < qrImage.moduleCount; x++) {
      for (int y = 0; y < qrImage.moduleCount; y++) {
        if (qrImage.isDark(y, x)) {
          final rect = Rect.fromLTWH(
            x * squareSize,
            y * squareSize,
            squareSize + 0.25,
            squareSize + 0.25,
          );
          canvas.drawRect(rect, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant QrCodePainter oldDelegate) =>
      oldDelegate.qrImage != qrImage || oldDelegate.color != color;
}

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
              // Personal Real Scannable Receive QR Card
              Builder(
                builder: (context) {
                  final cleanName = user.name.toLowerCase().replaceAll(RegExp(r'\s+'), '');
                  final upiId = '$cleanName@banklite';
                  final upiUri = 'upi://pay?pa=$upiId&pn=${Uri.encodeComponent(user.name)}&cu=INR';

                  QrImage qrImage;
                  try {
                    final qrCode = QrCode.fromData(
                      data: upiUri,
                      errorCorrectLevel: QrErrorCorrectLevel.M,
                    );
                    qrImage = QrImage(qrCode);
                  } catch (_) {
                    final qrCode = QrCode.fromData(
                      data: upiId,
                      errorCorrectLevel: QrErrorCorrectLevel.L,
                    );
                    qrImage = QrImage(qrCode);
                  }

                  return Column(
                    children: [
                      Container(
                        width: 230,
                        height: 230,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.cardBorder, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 155,
                              height: 155,
                              child: CustomPaint(
                                painter: QrCodePainter(
                                  qrImage: qrImage,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              upiId,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.accentBlue,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Scan with any UPI App (GPay / PhonePe / Paytm)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Linked to ${selectedAcc.accountType} (${selectedAcc.maskedNumber})',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 14),
                      OutlinedButton.icon(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: upiId));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('UPI ID copied to clipboard: $upiId'),
                              backgroundColor: AppColors.primaryNavy,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy UPI ID'),
                        style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 44)),
                      ),
                    ],
                  );
                },
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
