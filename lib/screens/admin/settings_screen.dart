import 'package:flutter/material.dart';
import '../../widgets/admin_layout.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _emailNotifications = true;
  bool _darkTheme = false;
  String _selectedLanguage = 'English';
  final List<String> _languages = ['English', 'Spanish', 'French', 'German'];

  @override
  Widget build(BuildContext context) {
    return AdminLayout(
      title: 'Settings',
      currentIndex: 5, // Settings tab
      child: _buildSettingsContent(),
    );
  }

  Widget _buildSettingsContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'System Settings',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Settings categories
          _buildSettingsCategory(
            title: 'General',
            icon: Icons.settings,
            children: [
              _buildLanguageSetting(),
              _buildSwitchTile(
                title: 'Dark Theme',
                subtitle: 'Enable dark mode for the admin panel',
                value: _darkTheme,
                onChanged: (value) {
                  setState(() {
                    _darkTheme = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSettingsCategory(
            title: 'Notifications',
            icon: Icons.notifications,
            children: [
              _buildSwitchTile(
                title: 'Email Notifications',
                subtitle: 'Receive emails for important updates',
                value: _emailNotifications,
                onChanged: (value) {
                  setState(() {
                    _emailNotifications = value;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildSettingsCategory(
            title: 'Security',
            icon: Icons.security,
            children: [_buildPasswordChange(), _buildTwoFactorAuth()],
          ),
          const SizedBox(height: 16),

          _buildSettingsCategory(
            title: 'System',
            icon: Icons.system_update,
            children: [
              _buildListTile(
                title: 'Check for Updates',
                subtitle: 'Last checked: Today at 9:30 AM',
                trailing: const Icon(Icons.refresh),
                onTap: () {
                  // Check for updates
                },
              ),
              _buildListTile(
                title: 'Backup Data',
                subtitle: 'Last backup: Yesterday at 10:00 PM',
                trailing: const Icon(Icons.backup),
                onTap: () {
                  // Backup data
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCategory({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.blue,
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required String subtitle,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }

  Widget _buildLanguageSetting() {
    return ListTile(
      title: const Text('Language'),
      subtitle: const Text('Select your preferred language'),
      trailing: DropdownButton<String>(
        value: _selectedLanguage,
        onChanged: (String? newValue) {
          if (newValue != null) {
            setState(() {
              _selectedLanguage = newValue;
            });
          }
        },
        items:
            _languages.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
      ),
    );
  }

  Widget _buildPasswordChange() {
    return ListTile(
      title: const Text('Change Password'),
      subtitle: const Text('Update your login credentials'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Show password change dialog
      },
    );
  }

  Widget _buildTwoFactorAuth() {
    return ListTile(
      title: const Text('Two-Factor Authentication'),
      subtitle: const Text('Add an extra layer of security'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        // Show 2FA setup
      },
    );
  }
}
