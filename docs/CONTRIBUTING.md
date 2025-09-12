# 🤝 Contribution - Arkalia CIA

## Vue d'ensemble

Arkalia CIA est un projet open source qui accueille les contributions de la communauté. Ce guide explique comment contribuer efficacement au projet.

## Code de conduite

### Principes
- **Respect** : Traiter tous les contributeurs avec respect
- **Inclusion** : Accueillir les contributions de tous
- **Collaboration** : Travailler ensemble pour améliorer le projet
- **Qualité** : Maintenir des standards élevés

### Comportement attendu
- Utiliser un langage respectueux
- Être constructif dans les critiques
- Accepter les retours positivement
- Respecter les décisions de l'équipe

## Processus de contribution

### 1. Fork et clone
```bash
# Fork le repository sur GitHub
# Puis cloner votre fork
git clone https://github.com/votre-username/arkalia-cia.git
cd arkalia-cia

# Ajouter le repository original comme remote
git remote add upstream https://github.com/arkalia-luna-system/arkalia-cia.git
```

### 2. Configuration de l'environnement
```bash
# Installer les dépendances
make install-dev

# Configurer pre-commit
pre-commit install

# Vérifier que tout fonctionne
make check
```

### 3. Créer une branche
```bash
# Créer une branche pour votre feature
git checkout -b feature/nom-de-votre-feature

# Ou pour un fix
git checkout -b fix/description-du-bug
```

### 4. Développement
```bash
# Faire vos modifications
# Tester régulièrement
make test

# Formater le code
make format

# Vérifier la qualité
make lint
```

### 5. Commit et push
```bash
# Ajouter vos modifications
git add .

# Commit avec un message descriptif
git commit -m "feat: ajouter fonctionnalité X"

# Push vers votre fork
git push origin feature/nom-de-votre-feature
```

### 6. Pull Request
1. Aller sur GitHub
2. Cliquer sur "New Pull Request"
3. Remplir le template de PR
4. Attendre la review

## Standards de code

### Flutter/Dart
```dart
// Utiliser des noms descriptifs
class DocumentService {
  // Méthodes publiques en camelCase
  Future<void> saveDocument(Document document) async {
    // Implémentation
  }
  
  // Variables privées avec underscore
  final _storage = LocalStorage();
}

// Documentation des méthodes publiques
/// Sauvegarde un document de manière sécurisée
/// 
/// [document] Le document à sauvegarder
/// 
/// Throws [StorageException] si la sauvegarde échoue
Future<void> saveDocument(Document document) async {
  // Implémentation
}
```

### Python
```python
# Utiliser des noms descriptifs
class DocumentService:
    """Service de gestion des documents."""
    
    def __init__(self):
        self._storage = LocalStorage()
    
    def save_document(self, document: Document) -> None:
        """Sauvegarde un document de manière sécurisée.
        
        Args:
            document: Le document à sauvegarder
            
        Raises:
            StorageException: Si la sauvegarde échoue
        """
        # Implémentation
```

### Formatage
```bash
# Flutter/Dart
dart format .

# Python
black .
isort .
```

### Linting
```bash
# Flutter/Dart
dart analyze

# Python
ruff check .
mypy arkalia_cia_python_backend/
```

## Tests

### Tests unitaires
```dart
// test/services/local_storage_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/services/local_storage_service.dart';

void main() {
  group('LocalStorageService', () {
    test('should save document', () async {
      // Arrange
      final document = Document(name: 'test.pdf');
      
      // Act
      await LocalStorageService.saveDocument(document);
      
      // Assert
      final documents = await LocalStorageService.getDocuments();
      expect(documents.length, 1);
      expect(documents.first.name, 'test.pdf');
    });
  });
}
```

### Tests d'intégration
```dart
// integration_test/app_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:arkalia_cia/main.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('should display home page', (tester) async {
      // Arrange
      await tester.pumpWidget(MyApp());
      
      // Act
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Arkalia CIA'), findsOneWidget);
    });
  });
}
```

### Couverture de tests
```bash
# Flutter
flutter test --coverage

# Python
pytest --cov=arkalia_cia_python_backend --cov-report=html
```

## Documentation

### Code
- Documenter toutes les méthodes publiques
- Utiliser des commentaires pour expliquer la logique complexe
- Maintenir la documentation à jour

### README
- Mettre à jour le README pour les nouvelles fonctionnalités
- Ajouter des exemples d'utilisation
- Documenter les changements breaking

### API
- Documenter les nouvelles APIs
- Mettre à jour les exemples
- Ajouter des schémas si nécessaire

## Types de contributions

### 🐛 Bug fixes
1. Identifier le bug
2. Créer une issue si elle n'existe pas
3. Créer une branche `fix/description`
4. Implémenter le fix
5. Ajouter des tests
6. Soumettre une PR

### ✨ Nouvelles fonctionnalités
1. Créer une issue pour discuter
2. Attendre l'approbation
3. Créer une branche `feature/nom`
4. Implémenter la fonctionnalité
5. Ajouter des tests
6. Mettre à jour la documentation
7. Soumettre une PR

### 📚 Documentation
1. Identifier ce qui manque
2. Créer une branche `docs/sujet`
3. Améliorer la documentation
4. Soumettre une PR

### 🧪 Tests
1. Identifier les tests manquants
2. Créer une branche `test/description`
3. Ajouter les tests
4. Vérifier la couverture
5. Soumettre une PR

## Review process

### Pour les contributeurs
1. Attendre les commentaires
2. Répondre aux questions
3. Apporter les modifications demandées
4. Rester disponible pour les clarifications

### Pour les reviewers
1. Vérifier le code
2. Tester les fonctionnalités
3. Vérifier les tests
4. Donner des retours constructifs
5. Approuver ou demander des modifications

## Communication

### Issues
- Utiliser les templates fournis
- Être précis dans la description
- Fournir des exemples de reproduction
- Utiliser les labels appropriés

### Pull Requests
- Utiliser le template fourni
- Décrire les changements
- Lier aux issues concernées
- Ajouter des screenshots si nécessaire

### Discussions
- Utiliser GitHub Discussions pour les questions
- Être respectueux et constructif
- Chercher dans les discussions existantes avant de créer une nouvelle

## Ressources

### Documentation
- [Architecture](ARCHITECTURE.md)
- [API](API.md)
- [Déploiement](DEPLOYMENT.md)

### Outils
- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [Python](https://python.org/)
- [FastAPI](https://fastapi.tiangolo.com/)

### Liens utiles
- [GitHub](https://github.com/arkalia-luna-system/arkalia-cia)
- [Issues](https://github.com/arkalia-luna-system/arkalia-cia/issues)
- [Discussions](https://github.com/arkalia-luna-system/arkalia-cia/discussions)

## Questions ?

Si vous avez des questions, n'hésitez pas à :
- Créer une issue
- Rejoindre les discussions
- Contacter l'équipe : contact@arkalia-luna.com

Merci de contribuer à Arkalia CIA ! 🚀
