import 'package:flutter/material.dart';
import '../../services/banking_provider.dart';
import '../../theme/app_colors.dart';
import '../../widgets/responsive_wrapper.dart';
import '../login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text(
          'Are you sure you want to securely log out of your BankLite session?',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final banking = context.bankingRead;
              banking.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              minimumSize: const Size(100, 42),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showInfoModal(BuildContext context, String title, String content) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(content, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.5)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final banking = context.banking;
    final user = banking.user;
    final selectedAcc = banking.selectedAccount;

    return ResponsiveWrapper(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Account Profile'),
          automaticallyImplyLeading: false,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              children: [
                // Signature User Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: AppColors.cardBorder.withValues(alpha: 0.9),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar with gradient halo ring & verified emerald badge
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(3.5),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.electricCyan,
                                  AppColors.accentBlue,
                                  AppColors.accentIndigo,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accentBlue.withValues(alpha: 0.25),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: AppColors.primaryNavy,
                              child: Text(
                                user.name
                                    .trim()
                                    .split(RegExp(r'\s+'))
                                    .where((n) => n.isNotEmpty)
                                    .map((n) => n[0].toUpperCase())
                                    .take(2)
                                    .join(),
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.success.withValues(alpha: 0.45),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Name & Tier Badge
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF06B6D4), Color(0xFF2563EB)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.diamond_outlined, size: 12, color: Colors.white),
                            const SizedBox(width: 4),
                            Text(
                              '${user.customerTier.toUpperCase()} MEMBER',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Email, Phone & Primary Account
                      _buildInfoRow(Icons.email_outlined, user.email),
                      const SizedBox(height: 10),
                      _buildInfoRow(Icons.phone_iphone_outlined, user.phone),
                      const SizedBox(height: 10),
                      _buildInfoRow(
                        Icons.account_balance_outlined,
                        'Primary: ${selectedAcc.accountType} (${selectedAcc.maskedNumber})',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Settings Options Group
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.cardBorder.withValues(alpha: 0.9),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.025),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.badge_outlined,
                        iconColor: AppColors.accentIndigo,
                        bgColor: AppColors.softIndigoBg,
                        title: 'Personal Information & KYC',
                        subtitle: 'Full name, KYC verification & PAN details',
                        onTap: () => _showInfoModal(
                          context,
                          'Personal Information',
                          'Account Holder: ${user.name}\nCustomer ID: ${user.userId}\nAccount Number: ${user.accountNumber}\nKYC Verification: ${user.isKycVerified ? "Fully Verified (${user.customerTier})" : "Pending Verification"}\nPhone: ${user.phone}\nEmail: ${user.email}\nPrimary Branch: BankLite Main Digital Branch\nMember Since: ${user.joinedDate}',
                        ),
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.shield_outlined,
                        iconColor: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFE0F2FE),
                        title: 'Security & App PIN',
                        subtitle: 'Biometric Face ID, 2FA & PIN settings',
                        onTap: () => _showInfoModal(
                          context,
                          'Security Settings',
                          'BankLite utilizes 256-bit AES encryption.\n• App PIN: Active\n• Biometric Touch / Face ID: Active\n• Login Session: Encrypted\n• Instant Card Freeze: Available',
                        ),
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.notifications_none_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        bgColor: const Color(0xFFFFFBEB),
                        title: 'Notification Preferences',
                        subtitle: 'Transaction SMS, push alerts & budget reminders',
                        onTap: () => _showInfoModal(
                          context,
                          'Notification Settings',
                          'Active Notification Channels:\n• Instant Payment SMS & Push Alerts: Enabled\n• Monthly Budget & Overspending Warning: Enabled\n• Utility Bill Reminders: 3 days prior',
                        ),
                      ),
                      const Divider(height: 1),
                      _buildSettingsTile(
                        icon: Icons.support_agent_rounded,
                        iconColor: AppColors.successDark,
                        bgColor: AppColors.successLight,
                        title: '24/7 Priority Support',
                        subtitle: 'Live banker chat, FAQs & toll-free line',
                        onTap: () => _showInfoModal(
                          context,
                          'BankLite Priority Support',
                          '24/7 Concierge Banking Support\nToll Free: 1800-800-BANK\nEmail: priority@banklite.com\nBankLite Digital Banking Corp.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Modern Tinted Logout Button
                InkWell(
                  onTap: () => _showLogoutDialog(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout_rounded, size: 18, color: AppColors.error),
                        SizedBox(width: 8),
                        Text(
                          'Logout from Account',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'BankLite Digital Banking v2.4.1 • 256-bit SSL Encrypted',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.softBlueBg,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 15, color: AppColors.accentBlue),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.2,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
