import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/device.dart';
import '../services/user_profile_service.dart';
import '../services/multi_device_sync_service.dart';
import '../services/google_auth_service.dart';
import '../utils/app_logger.dart';
import '../utils/error_helper.dart';

/// Écran de gestion du profil utilisateur et des appareils connectés
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Vérifier d'abord si l'utilisateur est connecté avec Google
      // Si oui, créer automatiquement le profil s'il n'existe pas
      final googleUser = await GoogleAuthService.getCurrentUser();
      if (googleUser != null && googleUser['email']?.isNotEmpty == true) {
        final existingProfile = await UserProfileService.getProfile();
        if (existingProfile == null) {
          // Créer automatiquement le profil depuis Google
          await UserProfileService.createProfile(
            email: googleUser['email']!,
            displayName: googleUser['name']?.isNotEmpty == true ? googleUser['name'] : null,
          );
          AppLogger.info('✅ Profil utilisateur créé automatiquement depuis Google');
        }
      }
      
      final profile = await UserProfileService.getProfile();
      setState(() {
        _profile = profile;
        _isLoading = false;
      });
    } catch (e) {
      ErrorHelper.logError('UserProfileScreen._loadProfile', e);
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ErrorHelper.getUserFriendlyMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _syncProfile() async {
    setState(() {
      _isSyncing = true;
    });

    try {
      final success = await MultiDeviceSyncService.syncProfile();
      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profil synchronisé avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erreur lors de la synchronisation'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Erreur synchronisation', e);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  Future<void> _removeDevice(Device device) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer appareil'),
        content: Text(
          'Voulez-vous vraiment supprimer "${device.deviceName}" de votre profil ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await UserProfileService.removeDevice(device.deviceId);
        await _loadProfile();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Appareil supprimé'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        AppLogger.error('Erreur suppression device', e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Utilisateur'),
        actions: [
          if (_profile != null)
            IconButton(
              icon: _isSyncing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.sync),
              onPressed: _isSyncing ? null : _syncProfile,
              tooltip: 'Synchroniser',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _profile == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.person_outline, size: 64, color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucun profil utilisateur',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Créez un compte pour activer la synchronisation multi-appareil',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Informations profil
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person, size: 32),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _profile!.displayName ?? 'Utilisateur',
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          _profile!.email,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (_profile!.lastSync != null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Icon(Icons.sync, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Dernière synchronisation: ${_formatDate(_profile!.lastSync!)}',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Appareils connectés
                      Text(
                        'Appareils connectés (${_profile!.devices.length})',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._profile!.devices.map((device) => _buildDeviceCard(device)),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    // Utiliser un FutureBuilder pour obtenir l'ID de l'appareil actuel
    return FutureBuilder<String>(
      future: UserProfileService.getCurrentDeviceId(),
      builder: (context, snapshot) {
        final currentDeviceId = snapshot.data ?? '';
        final isCurrentDevice = device.deviceId == currentDeviceId;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(
              _getPlatformIcon(device.platform),
              color: device.isActive ? Colors.green : Colors.grey,
            ),
            title: Text(
              device.deviceName,
              style: TextStyle(
                fontWeight: isCurrentDevice ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${device.platform} • ${_formatDate(device.lastSeen)}'),
                if (isCurrentDevice)
                  const Text(
                    'Appareil actuel',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                if (!device.isActive)
                  const Text(
                    'Inactif',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
            trailing: !isCurrentDevice
                ? IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _removeDevice(device),
                    tooltip: 'Supprimer',
                  )
                : null,
          ),
        );
      },
    );
  }

  IconData _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'ios':
        return Icons.phone_iphone;
      case 'android':
        return Icons.phone_android;
      case 'web':
        return Icons.language;
      case 'macos':
        return Icons.laptop_mac;
      case 'windows':
        return Icons.laptop_windows;
      case 'linux':
        return Icons.laptop;
      default:
        return Icons.device_unknown;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return 'Il y a ${diff.inMinutes} min';
      }
      return 'Il y a ${diff.inHours} h';
    } else if (diff.inDays == 1) {
      return 'Hier';
    } else if (diff.inDays < 7) {
      return 'Il y a ${diff.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

