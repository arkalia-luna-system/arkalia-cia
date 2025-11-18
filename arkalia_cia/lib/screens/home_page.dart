import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'documents_screen.dart';
import 'reminders_screen.dart';
import 'emergency_screen.dart';
import 'health_screen.dart';
import 'aria_screen.dart';
import 'sync_screen.dart';
import 'settings_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arkalia CIA'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettings(context),
            tooltip: 'Paramètres',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Titre principal
            const Text(
              'Assistant Personnel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 40),

            // 6 boutons principaux
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  // Bouton 1: Import/voir doc
                  _buildActionButton(
                    context,
                    icon: MdiIcons.fileDocumentOutline,
                    title: 'Documents',
                    subtitle: 'Import/voir docs',
                    color: Colors.green,
                    onTap: () => _showDocuments(context),
                  ),

                  // Bouton 2: Portails santé
                  _buildActionButton(
                    context,
                    icon: MdiIcons.medicalBag,
                    title: 'Santé',
                    subtitle: 'Portails santé',
                    color: Colors.red,
                    onTap: () => _showHealth(context),
                  ),

                  // Bouton 3: Rappels simples
                  _buildActionButton(
                    context,
                    icon: MdiIcons.bellOutline,
                    title: 'Rappels',
                    subtitle: 'Rappels simples',
                    color: Colors.orange,
                    onTap: () => _showReminders(context),
                  ),

                  // Bouton 4: Urgence ICE
                  _buildActionButton(
                    context,
                    icon: MdiIcons.phoneAlert,
                    title: 'Urgence',
                    subtitle: 'ICE - Contacts',
                    color: Colors.purple,
                    onTap: () => _showEmergency(context),
                  ),

                  // Bouton 5: ARIA - Laboratoire Santé
                  _buildActionButton(
                    context,
                    icon: MdiIcons.heartPulse,
                    title: 'ARIA',
                    subtitle: 'Laboratoire Santé',
                    color: Colors.red,
                    onTap: () => _showARIA(context),
                  ),

                  // Bouton 6: CIA Sync
                  _buildActionButton(
                    context,
                    icon: MdiIcons.syncIcon,
                    title: 'Sync',
                    subtitle: 'CIA ↔ ARIA',
                    color: Colors.orange,
                    onTap: () => _showSync(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDocuments(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const DocumentsScreen()),
    );
  }

  void _showHealth(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthScreen()),
    );
  }

  void _showReminders(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RemindersScreen()),
    );
  }

  void _showEmergency(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyScreen()),
    );
  }

  void _showARIA(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ARIAScreen()),
    );
  }

  void _showSync(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SyncScreen()),
    );
  }

  void _showSettings(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SettingsScreen()),
    );
  }
}
