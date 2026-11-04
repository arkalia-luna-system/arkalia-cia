import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/error_helper.dart';

/// Widget pour afficher un contact d'urgence
class EmergencyContactCard extends StatelessWidget {
  final Map<String, dynamic> contact;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EmergencyContactCard({
    super.key,
    required this.contact,
    this.onEdit,
    this.onDelete,
  });

  Future<void> _makePhoneCall() async {
    final phone = contact['phone'] as String?;
    if (phone == null || phone.isEmpty) return;

    final uri = Uri.parse('tel:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      ErrorHelper.logError('EmergencyContactCard._makePhoneCall', e);
    }
  }

  Future<void> _copyToClipboard(BuildContext context) async {
    final phone = contact['phone'] as String?;
    if (phone == null || phone.isEmpty) return;

    await Clipboard.setData(ClipboardData(text: phone));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro copié dans le presse-papier'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _sendSMS() async {
    final phone = contact['phone'] as String?;
    if (phone == null || phone.isEmpty) return;

    final uri = Uri.parse('sms:$phone');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (e) {
      ErrorHelper.logError('EmergencyContactCard._sendSMS', e);
    }
  }

  Future<void> _openWhatsApp() async {
    final phone = contact['phone'] as String?;
    if (phone == null || phone.isEmpty) return;

    // Nettoyer le numéro pour WhatsApp (enlever espaces, +, etc.)
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    final whatsappUrl = 'https://wa.me/$cleanPhone';

    try {
      final uri = Uri.parse(whatsappUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      ErrorHelper.logError('EmergencyContactCard._openWhatsApp', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = contact['name'] as String? ?? 'Contact sans nom';
    final displayName = contact['display_name'] as String? ?? name;
    final phone = contact['phone'] as String? ?? '';
    final relationship = contact['relationship'] as String? ?? '';
    final isPrimary = contact['is_primary'] as bool? ?? false;
    final emoji = contact['emoji'] as String? ?? '👤';
    final colorValue = contact['color'] as int?;
    // Couleur contact = donnée utilisateur (conservée)
    final color = colorValue != null ? Color(colorValue) : scheme.error;

    return Card(
      elevation: isPrimary ? 8 : 2,
      color: isPrimary ? color.withValues(alpha: 0.1) : null,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isPrimary) ...[
                            Icon(Icons.star, color: color, size: 16),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: color,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (name != displayName) ...[
                        const SizedBox(height: 2),
                        Text(
                          name,
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit?.call();
                        break;
                      case 'delete':
                        onDelete?.call();
                        break;
                    }
                  },
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit),
                            title: Text('Modifier'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete, color: scheme.error),
                            title: const Text('Supprimer'),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                ),
              ],
            ),
            if (relationship.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                relationship,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.phone, color: scheme.secondary, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Semantics(
                  button: true,
                  label: 'Appeler $displayName',
                  child: ElevatedButton.icon(
                    onPressed: _makePhoneCall,
                    icon: const Icon(Icons.call, size: 18),
                    label: const Text('Appeler'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.secondary,
                      foregroundColor: scheme.onSecondary,
                      minimumSize: const Size(100, 40),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Envoyer un SMS à $displayName',
                  child: ElevatedButton.icon(
                    onPressed: _sendSMS,
                    icon: const Icon(Icons.sms, size: 18),
                    label: const Text('SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      minimumSize: const Size(100, 40),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Ouvrir WhatsApp pour $displayName',
                  child: ElevatedButton.icon(
                    onPressed: _openWhatsApp,
                    icon: const Icon(Icons.chat, size: 18),
                    label: const Text('WhatsApp'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.tertiary,
                      foregroundColor: scheme.onTertiary,
                      minimumSize: const Size(100, 40),
                    ),
                  ),
                ),
                Semantics(
                  button: true,
                  label: 'Copier le numéro de $displayName',
                  child: OutlinedButton.icon(
                    onPressed: () => _copyToClipboard(context),
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copier'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(100, 40),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
