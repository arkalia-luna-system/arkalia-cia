# 🔌 API Documentation - Arkalia CIA

## Vue d'ensemble

Arkalia CIA utilise une architecture local-first. Les APIs sont principalement des services locaux qui interagissent avec les systèmes natifs du téléphone.

## Services locaux

### LocalStorageService

Service principal pour le stockage local sécurisé.

#### Méthodes principales

```dart
class LocalStorageService {
  // Initialisation
  static Future<void> init() async
  
  // Documents
  static Future<void> saveDocument(Map<String, dynamic> document) async
  static Future<List<Map<String, dynamic>>> getDocuments() async
  static Future<void> deleteDocument(int id) async
  
  // Rappels
  static Future<void> saveReminder(Map<String, dynamic> reminder) async
  static Future<List<Map<String, dynamic>>> getReminders() async
  static Future<void> deleteReminder(int id) async
  
  // Contacts d'urgence
  static Future<void> saveEmergencyContact(Map<String, dynamic> contact) async
  static Future<List<Map<String, dynamic>>> getEmergencyContacts() async
  static Future<void> deleteEmergencyContact(int id) async
  
  // Portails santé
  static Future<void> saveHealthPortal(Map<String, dynamic> portal) async
  static Future<List<Map<String, dynamic>>> getHealthPortals() async
  static Future<void> deleteHealthPortal(int id) async
}
```

#### Modèles de données

**Document**
```dart
{
  'id': int,
  'name': String,
  'path': String,
  'size': int,
  'created_at': String,
  'category': String?,
  'encrypted': bool
}
```

**Rappel**
```dart
{
  'id': int,
  'title': String,
  'description': String?,
  'reminder_date': String,
  'is_completed': bool,
  'created_at': String,
  'recurring': bool
}
```

**Contact d'urgence**
```dart
{
  'id': int,
  'name': String,
  'phone': String,
  'relationship': String,
  'is_ice': bool,
  'created_at': String
}
```

**Portail santé**
```dart
{
  'id': int,
  'name': String,
  'url': String,
  'description': String?,
  'icon': String?,
  'created_at': String
}
```

### CalendarService

Service d'intégration avec le calendrier natif.

```dart
class CalendarService {
  // Initialisation
  static Future<void> init() async
  
  // Gestion des événements
  static Future<void> addReminder({
    required String title,
    required String description,
    required DateTime reminderDate,
  }) async
  
  static Future<List<Event>> getUpcomingEvents() async
  static Future<void> deleteEvent(String eventId) async
  
  // Notifications
  static Future<void> scheduleNotification({
    required String title,
    required String description,
    required DateTime date,
  }) async
}
```

### ContactsService

Service d'intégration avec les contacts natifs.

```dart
class ContactsService {
  // Récupération des contacts
  static Future<List<Contact>> getContacts() async
  static Future<List<Contact>> getEmergencyContacts() async
  
  // Gestion des contacts
  static Future<void> addEmergencyContact({
    required String name,
    required String phone,
    required String relationship,
  }) async
  
  // Appels
  static Future<void> makePhoneCall(String phoneNumber) async
  static Future<void> sendSMS(String phoneNumber, String message) async
}
```

### NotificationService

Service de gestion des notifications locales.

```dart
class NotificationService {
  // Initialisation
  static Future<void> init() async
  
  // Notifications immédiates
  static Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async
  
  // Notifications programmées
  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime date,
  }) async
  
  // Gestion des canaux
  static Future<void> createNotificationChannel({
    required String id,
    required String name,
    required String description,
  }) async
}
```

## Backend Python (Phase 3)

### API FastAPI

Le backend Python sera utilisé en Phase 3 pour la synchronisation et le partage familial.

#### Endpoints principaux

**Documents**
```
GET    /api/documents          # Liste des documents
POST   /api/documents          # Upload document
GET    /api/documents/{id}     # Détails document
DELETE /api/documents/{id}     # Supprimer document
```

**Rappels**
```
GET    /api/reminders          # Liste des rappels
POST   /api/reminders          # Créer rappel
PUT    /api/reminders/{id}     # Modifier rappel
DELETE /api/reminders/{id}     # Supprimer rappel
```

**Contacts**
```
GET    /api/contacts           # Liste des contacts
POST   /api/contacts           # Ajouter contact
PUT    /api/contacts/{id}      # Modifier contact
DELETE /api/contacts/{id}      # Supprimer contact
```

**Synchronisation**
```
POST   /api/sync/upload        # Upload données locales
POST   /api/sync/download      # Télécharger données
GET    /api/sync/status        # Statut synchronisation
```

#### Modèles Pydantic

```python
class DocumentResponse(BaseModel):
    id: int
    name: str
    original_name: str
    file_path: str
    file_type: str
    file_size: int
    created_at: str

class ReminderRequest(BaseModel):
    title: str
    description: str | None = None
    reminder_date: str

class EmergencyContactRequest(BaseModel):
    name: str
    phone: str
    relationship: str
    is_ice: bool = False
```

## Sécurité

### Chiffrement local
- **Algorithme** : AES-256
- **Clé** : Générée localement
- **IV** : Aléatoire pour chaque document

### Authentification (Phase 3)
- **JWT** : Tokens d'accès
- **2FA** : Authentification à deux facteurs
- **OAuth** : Intégration avec les providers

### Permissions
- **Calendrier** : Lecture/écriture
- **Contacts** : Lecture
- **Stockage** : Accès aux fichiers
- **Notifications** : Envoi

## Gestion d'erreurs

### Codes d'erreur locaux
```dart
enum LocalError {
  storageError,
  calendarError,
  contactsError,
  notificationError,
  encryptionError,
  permissionError
}
```

### Gestion des erreurs
```dart
try {
  await LocalStorageService.saveDocument(document);
} on LocalError catch (e) {
  // Gestion spécifique par type d'erreur
  switch (e) {
    case LocalError.storageError:
      // Afficher message d'erreur stockage
      break;
    case LocalError.permissionError:
      // Demander permissions
      break;
    // ...
  }
}
```

## Tests

### Tests unitaires
```dart
void main() {
  group('LocalStorageService', () {
    test('should save document', () async {
      // Test de sauvegarde
    });
    
    test('should retrieve documents', () async {
      // Test de récupération
    });
  });
}
```

### Tests d'intégration
```dart
void main() {
  group('CalendarService', () {
    test('should create calendar event', () async {
      // Test d'intégration calendrier
    });
  });
}
```

## Monitoring

### Logs locaux
```dart
class Logger {
  static void info(String message) {
    // Log info
  }
  
  static void error(String message, [dynamic error]) {
    // Log erreur
  }
  
  static void debug(String message) {
    // Log debug
  }
}
```

### Métriques
- Nombre de documents stockés
- Fréquence d'utilisation des rappels
- Erreurs de synchronisation
- Performance des opérations
