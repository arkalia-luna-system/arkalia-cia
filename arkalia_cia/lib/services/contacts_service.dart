import 'package:flutter_contacts/flutter_contacts.dart' as contacts_api;
import 'package:url_launcher/url_launcher.dart';

/// Service de gestion des contacts natifs pour Arkalia CIA
/// Intègre les contacts système et les appels d'urgence
class ContactsService {
  /// Récupère tous les contacts
  static Future<List<contacts_api.Contact>> getContacts() async {
    try {
      // Vérifier d'abord le statut de la permission
      final permissionStatus = await contacts_api.FlutterContacts.requestPermission();
      if (permissionStatus) {
        return await contacts_api.FlutterContacts.getContacts();
      } else {
        // Retourner une liste vide au lieu de lancer une exception
        return [];
      }
    } catch (e) {
      // En cas d'erreur, retourner une liste vide plutôt que de lancer une exception
      return [];
    }
  }

  /// Récupère les contacts d'urgence (ICE - In Case of Emergency)
  static Future<List<contacts_api.Contact>> getEmergencyContacts() async {
    try {
      final contacts = await getContacts();
      return contacts.where((contact) {
        // Filtrer les contacts marqués comme ICE
        return contact.phones.any((phone) {
          final label = phone.label.toString().toLowerCase();
          return label.contains('ice') || label.contains('urgence');
        });
      }).toList();
    } catch (e) {
      // Retourner une liste vide en cas d'erreur plutôt que de lancer une exception
      return [];
    }
  }

  /// Ajoute un contact d'urgence
  static Future<bool> addEmergencyContact({
    required String name,
    required String phone,
    required String relationship,
  }) async {
    try {
      final contact = contacts_api.Contact(
        name: contacts_api.Name(first: name),
        phones: [
          contacts_api.Phone(
            phone,
            label: contacts_api.PhoneLabel.other,
          ),
        ],
      );

      await contact.insert();
      return true;
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout du contact d\'urgence: $e');
    }
  }

  /// Passe un appel téléphonique
  static Future<void> makePhoneCall(String phoneNumber) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        throw Exception('Impossible de lancer l\'appel téléphonique');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'appel téléphonique: $e');
    }
  }

  /// Envoie un SMS
  static Future<void> sendSMS(String phoneNumber, String message) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
        query: 'body=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw Exception('Impossible d\'envoyer le SMS');
      }
    } catch (e) {
      throw Exception('Erreur lors de l\'envoi du SMS: $e');
    }
  }

  /// Recherche des contacts par nom
  static Future<List<contacts_api.Contact>> searchContacts(String query) async {
    try {
      final contacts = await getContacts();
      return contacts.where((contact) {
        final name = contact.name.first.toLowerCase();
        final familyName = contact.name.last.toLowerCase();
        final searchQuery = query.toLowerCase();

        return name.contains(searchQuery) ||
               familyName.contains(searchQuery) ||
               '$name $familyName'.contains(searchQuery);
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche de contacts: $e');
    }
  }

  /// Récupère les contacts médicaux
  static Future<List<contacts_api.Contact>> getMedicalContacts() async {
    try {
      final contacts = await getContacts();
      return contacts.where((contact) {
        // Filtrer les contacts avec des labels médicaux
        return contact.phones.any((phone) {
          final label = phone.label.toString().toLowerCase();
          return label.contains('médecin') ||
                 label.contains('docteur') ||
                 label.contains('hôpital') ||
                 label.contains('pharmacie') ||
                 label.contains('urgences') ||
                 label.contains('cardio') ||
                 label.contains('neuro');
        });
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des contacts médicaux: $e');
    }
  }

  /// Vérifie les permissions des contacts
  static Future<bool> hasContactsPermission() async {
    try {
      return await contacts_api.FlutterContacts.requestPermission();
    } catch (e) {
      return false;
    }
  }

  /// Demande les permissions des contacts
  static Future<bool> requestContactsPermission() async {
    try {
      return await contacts_api.FlutterContacts.requestPermission();
    } catch (e) {
      return false;
    }
  }

  /// Supprime un contact
  static Future<bool> deleteContact(contacts_api.Contact contact) async {
    try {
      await contact.delete();
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la suppression du contact: $e');
    }
  }

  /// Met à jour un contact
  static Future<bool> updateContact(contacts_api.Contact contact) async {
    try {
      await contact.update();
      return true;
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour du contact: $e');
    }
  }

  /// Récupère les contacts favoris
  static Future<List<contacts_api.Contact>> getFavoriteContacts() async {
    try {
      final contacts = await getContacts();
      return contacts.where((contact) {
        // Filtrer les contacts marqués comme favoris
        return contact.phones.any((phone) {
          final label = phone.label.toString().toLowerCase();
          return label.contains('favori') || label.contains('favorite');
        });
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des contacts favoris: $e');
    }
  }
}
