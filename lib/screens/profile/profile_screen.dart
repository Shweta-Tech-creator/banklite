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
                // User Profile Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.cardBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar with verified badge
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 44,
                            backgroundColor: AppColors.primaryNavy,
                            child: Text(
                              user.name.trim().split(RegExp(r'\s+')).where((n) => n.isNotEmpty).map((n) => n[0].toUpperCase()).take(2).join(),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.successDark,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, color: Colors.white, size: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Name & Tier
                      Text(
                        user.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          user.customerTier.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Divider(height: 1),
                      const SizedBox(height: 14),

                      // Email, Phone & Primary Account
                      _buildInfoRow(Icons.email_outlined, user.email),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.phone_iphone_outlined, user.phone),
                      const SizedBox(height: 8),
                      _buildInfoRow(Icons.account_balance_outlined, 'Primary: ${selectedAcc.accountType} (${selectedAcc.maskedNumber})'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Settings Options Group
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.badge_outlined,
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

                const SizedBox(height: 20),

                // Logout Button
                OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.5),
                  ),
                  icon: const Icon(Icons.logout, size: 18),
                  label: const Text('Logout from Account'),
                ),

                const SizedBox(height: 16),

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
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
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
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.softBlueBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.accentBlue, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
        onTap: onTap,
      ),
    );
  }
}
