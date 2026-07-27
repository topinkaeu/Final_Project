import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _autoAnalyze = true;
  bool _includePayload = false;
  String _riskLevel = "Medium";
  String _language = "English";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Settings",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // balances the back button
                ],
              ),
              const SizedBox(height: 12),

              _sectionLabel("General"),
              _card([
                _switchTile(
                  icon: Icons.dark_mode_outlined,
                  title: "Dark Mode",
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                ),
                _navTile(
                  icon: Icons.notifications_none,
                  title: "Notifications",
                  onTap: () {},
                ),
                _navTile(
                  icon: Icons.language_outlined,
                  title: "Language",
                  trailingText: _language,
                  onTap: () {},
                ),
                _navTile(
                  icon: Icons.folder_open_outlined,
                  title: "File Storage",
                  trailingText: "1.25 GB / 5 GB",
                  onTap: () {},
                ),
              ]),

              const SizedBox(height: 24),
              _sectionLabel("Security"),
              _card([
                _navTile(
                  icon: Icons.shield_outlined,
                  title: "Risk Detection Level",
                  trailingText: _riskLevel,
                  onTap: () => _showRiskLevelPicker(context),
                ),
                _switchTile(
                  icon: Icons.autorenew,
                  title: "Auto Analyze on Import",
                  value: _autoAnalyze,
                  onChanged: (v) => setState(() => _autoAnalyze = v),
                ),
                _switchTile(
                  icon: Icons.description_outlined,
                  title: "Include Packet Payload",
                  value: _includePayload,
                  onChanged: (v) => setState(() => _includePayload = v),
                ),
              ]),

              const SizedBox(height: 24),
              _sectionLabel("Others"),
              _card([
                _navTile(
                  icon: Icons.info_outline,
                  title: "About",
                  onTap: () {},
                ),
                _navTile(
                  icon: Icons.help_outline,
                  title: "Help & Support",
                  onTap: () {},
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  void _showRiskLevelPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: ["Low", "Medium", "High"].map((level) {
          return ListTile(
            title: Text(level),
            trailing: _riskLevel == level
                ? const Icon(Icons.check, color: Colors.indigo)
                : null,
            onTap: () {
              setState(() => _riskLevel = level);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8, left: 4),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
    ),
  );

  Widget _card(List<Widget> children) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFFF7F7FA),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(children: children),
  );

  Widget _switchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        activeTrackColor: Colors.indigo,
      ),
    );
  }

  Widget _navTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 20, color: Colors.black87),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null)
            Text(
              trailingText,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}
