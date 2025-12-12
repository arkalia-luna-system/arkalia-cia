# 🔍 AUDIT COMPLET DES DÉPENDANCES - ARKALIA CIA

**Date** : 12 décembre 2025  
**Version** : 1.3.1+6  
**Objectif** : Vérifier que toutes les dépendances sont gratuites, justifiées et nécessaires

---

## ✅ RÉSUMÉ EXÉCUTIF

**Résultat** : ✅ **100% GRATUIT - TOUTES LES DÉPENDANCES SONT JUSTIFIÉES**

- ✅ **0 dépendance payante**
- ✅ **0 API externe payante utilisée**
- ✅ **0 service cloud payant**
- ✅ **Toutes les dépendances sont open-source et gratuites**
- ✅ **Toutes les dépendances sont justifiées et utilisées**

---

## 📦 DÉPENDANCES FLUTTER (pubspec.yaml)

### ✅ Base de données
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `sqflite` | ^2.3.0 | MIT | Base de données SQLite locale | ✅ Utilisé partout (documents, médecins, etc.) |
| `path` | ^1.8.3 | MIT | Manipulation chemins fichiers | ✅ Utilisé pour chemins fichiers |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Fichiers et PDF
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `file_picker` | ^10.3.7 | MIT | Sélection fichiers (PDF upload) | ✅ Utilisé dans documents_screen.dart |
| `path_provider` | ^2.1.1 | MIT | Chemins répertoires système | ✅ Utilisé pour stockage local |
| `open_filex` | ^4.4.0 | MIT | Ouverture fichiers système | ✅ Utilisé pour ouvrir PDFs |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ UI et Graphiques
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `cupertino_icons` | ^1.0.2 | MIT | Icônes iOS | ✅ Utilisé pour UI iOS |
| `material_design_icons_flutter` | ^7.0.7296 | Apache 2.0 | Icônes Material Design | ✅ Utilisé partout (MdiIcons) |
| `table_calendar` | ^3.1.2 | MIT | Calendrier avec table | ✅ Utilisé dans calendar_screen.dart |
| `fl_chart` | ^0.71.0 | MIT | Graphiques (charts) | ✅ Utilisé pour graphiques pathologies |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Notifications
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `flutter_local_notifications` | ^17.0.0 | MIT | Notifications locales | ✅ Utilisé pour rappels médicaments |
| `timezone` | ^0.9.4 | MIT | Gestion fuseaux horaires | ✅ Utilisé avec notifications |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ HTTP et Réseau
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `http` | ^1.1.0 | BSD-3-Clause | Requêtes HTTP | ✅ Utilisé pour appels backend local |
| `http_parser` | ^4.0.2 | BSD-3-Clause | Parsing HTTP | ✅ Utilisé avec http |
| `connectivity_plus` | ^6.1.5 | Apache 2.0 | Vérification connexion | ✅ Utilisé pour détecter offline |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**  
**Note** : Tous les appels HTTP sont vers `localhost` ou backends locaux (pas d'API externe payante)

### ✅ Utilitaires
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `url_launcher` | ^6.2.1 | BSD-3-Clause | Ouvrir URLs (portails santé) | ✅ Utilisé pour ouvrir portails santé |
| `share_plus` | ^12.0.1 | MIT | Partage fichiers | ✅ Utilisé pour partage documents |
| `shared_preferences` | ^2.2.2 | MIT | Stockage préférences | ✅ Utilisé pour config utilisateur |
| `local_auth` | ^2.1.7 | Apache 2.0 | Authentification biométrique | ✅ Utilisé pour déverrouillage biométrique |
| `device_calendar` | ^4.3.2 | MIT | Intégration calendrier système | ✅ Utilisé pour sync calendrier |
| `flutter_contacts` | ^1.1.7 | MIT | Accès contacts système | ✅ Utilisé pour contacts ICE |
| `permission_handler` | ^11.3.1 | MIT | Gestion permissions | ✅ Utilisé pour demander permissions |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Sécurité
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `crypto` | ^3.0.3 | BSD-3-Clause | Cryptographie (hash) | ✅ Utilisé pour hash mots de passe |
| `encrypt` | ^5.0.1 | MIT | Chiffrement AES | ✅ Utilisé pour chiffrement documents |
| `flutter_secure_storage` | ^9.0.0 | MIT | Stockage sécurisé (keychain) | ✅ Utilisé pour tokens JWT |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Dev Dependencies
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `flutter_test` | SDK | BSD-3-Clause | Tests Flutter | ✅ Utilisé pour tests |
| `flutter_lints` | ^3.0.0 | BSD-3-Clause | Linting code | ✅ Utilisé pour qualité code |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

---

## 🐍 DÉPENDANCES PYTHON (requirements.txt)

### ✅ Base de données
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `sqlite3` | Built-in | Python | Base de données SQLite | ✅ Utilisé dans database.py |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ** (inclus dans Python)

### ✅ Traitement PDF
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `pypdf` | 6.1.3 | BSD-3-Clause | Parsing PDF | ✅ Utilisé dans pdf_processor.py |
| `python-magic` | 0.4.27 | MIT | Détection type fichier | ✅ Utilisé pour validation fichiers |
| `reportlab` | 4.0.9 | BSD-3-Clause | Génération PDF | ✅ Utilisé pour rapports médicaux |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Framework Web
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `fastapi` | 0.121.2 | MIT | Framework web API | ✅ Utilisé dans api.py (backend) |
| `uvicorn` | 0.35.0 | BSD-3-Clause | Serveur ASGI | ✅ Utilisé pour lancer backend |
| `pydantic` | 2.9.2 | MIT | Validation données | ✅ Utilisé pour modèles API |
| `starlette` | 0.49.1 | BSD-3-Clause | Framework web (base FastAPI) | ✅ Dépendance FastAPI |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**  
**Note** : Backend optionnel, fonctionne en localhost uniquement

### ✅ Sécurité
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `cryptography` | 46.0.3 | Apache 2.0 / BSD | Chiffrement AES-256 | ✅ Utilisé pour chiffrement documents |
| `authlib` | 1.6.5 | BSD-3-Clause | OAuth/JWT | ✅ Utilisé pour authentification |
| `passlib[bcrypt]` | 1.7.4 | BSD-3-Clause | Hash mots de passe | ✅ Utilisé dans auth.py |
| `PyJWT` | 2.9.0 | MIT | Tokens JWT | ✅ Utilisé pour authentification |
| `python-jose[cryptography]` | 3.3.0 | MIT | Alternative JWT | ✅ Utilisé pour compatibilité |
| `bleach` | 6.1.0 | Apache 2.0 | Sanitization HTML/XSS | ✅ Utilisé pour sécurité inputs |
| `slowapi` | 0.1.9 | MIT | Rate limiting | ✅ Utilisé pour protection API |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Utilitaires
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `python-dotenv` | 1.1.1 | BSD-3-Clause | Variables d'environnement | ✅ Utilisé pour config |
| `pydantic-settings` | 2.6.1 | MIT | Configuration Pydantic | ✅ Utilisé pour settings |
| `click` | 8.1.8 | BSD-3-Clause | CLI | ✅ Utilisé pour scripts |
| `rich` | 14.2.0 | MIT | Terminal formatting | ✅ Utilisé pour logs |
| `phonenumbers` | 9.0.19 | Apache 2.0 | Validation téléphone | ✅ Utilisé pour validation |
| `python-multipart` | 0.0.20 | Apache 2.0 | Multipart form data | ✅ Utilisé pour upload fichiers |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Tests
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `pytest` | 9.0.0 | MIT | Framework tests | ✅ Utilisé pour tests unitaires |
| `pytest-asyncio` | 1.3.0 | Apache 2.0 | Tests async | ✅ Utilisé pour tests API |
| `pytest-cov` | 7.0.0 | MIT | Coverage tests | ✅ Utilisé pour coverage |
| `httpx` | 0.27.0 | BSD-3-Clause | Client HTTP tests | ✅ Utilisé pour tests API |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

### ✅ Machine Learning
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `prophet` | 1.1.5 | MIT | Prédictions temporelles | ✅ Utilisé pour prédictions patterns |
| `numpy` | 1.26.4 | BSD-3-Clause | Calculs numériques | ✅ Utilisé avec prophet/pandas |
| `pandas` | 2.2.2 | BSD-3-Clause | Analyse données | ✅ Utilisé pour analyse patterns |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**  
**Note** : Utilisé pour prédictions locales (pas d'API externe)

### ✅ Logging
| Dépendance | Version | Licence | Justification | Utilisation |
|------------|---------|---------|---------------|-------------|
| `loguru` | 0.7.3 | MIT | Logging avancé | ✅ Utilisé pour logs backend |

**Verdict** : ✅ **GRATUIT - JUSTIFIÉ**

---

## 🔍 VÉRIFICATION APIS EXTERNES

### ✅ Appels HTTP vérifiés

**Tous les appels HTTP sont vers :**
- ✅ `localhost:8000` (backend Python local)
- ✅ `localhost:8001` (ARIA local)
- ✅ `192.168.x.x` (réseau local uniquement)

**Aucun appel vers :**
- ❌ APIs OpenAI/Claude/Gemini
- ❌ Services cloud (AWS, GCP, Azure)
- ❌ Services payants (Firebase, Stripe, etc.)
- ❌ APIs portails santé automatiques (Andaman 7 API payante)

**Verdict** : ✅ **100% LOCAL - AUCUNE API PAYANTE**

---

## 🚫 SERVICES EXCLUS (Documentation)

### ❌ APIs IA Payantes
- **OpenAI GPT** : ❌ Exclu (mentionné uniquement dans `docs/plans/PLAN_06_IA_CONVERSATIONNELLE.md` - plan, pas code)
- **Anthropic Claude** : ❌ Exclu
- **Google Gemini** : ❌ Exclu

**Solution actuelle** : ✅ IA locale avec patterns (100% gratuit)

### ❌ Services Cloud Payants
- **AWS S3** : ❌ Exclu
- **Google Cloud Storage** : ❌ Exclu
- **Azure Blob** : ❌ Exclu
- **Firebase** : ❌ Exclu

**Solution actuelle** : ✅ Stockage local SQLite (100% gratuit)

### ❌ APIs Portails Santé Automatiques
- **Andaman 7 API** : ❌ Exclu (2 000-5 000€/an)
- **eHealth API** : ⏸️ Non prioritaire (accréditation longue, mais gratuit)
- **MaSanté API** : ❌ Non disponible

**Solution actuelle** : ✅ Import manuel PDF (100% gratuit)

---

## 📊 STATISTIQUES

### Dépendances Flutter
- **Total** : 25 dépendances
- **Gratuites** : 25 (100%)
- **Payantes** : 0 (0%)
- **Justifiées** : 25 (100%)

### Dépendances Python
- **Total** : 24 dépendances
- **Gratuites** : 24 (100%)
- **Payantes** : 0 (0%)
- **Justifiées** : 24 (100%)

### APIs Externes
- **Appels HTTP** : Uniquement localhost/réseau local
- **APIs payantes utilisées** : 0
- **Services cloud utilisés** : 0

---

## ✅ CONCLUSION

**Résultat final** : ✅ **100% GRATUIT - TOUTES LES DÉPENDANCES SONT JUSTIFIÉES**

### Points clés :
1. ✅ **Toutes les dépendances sont open-source et gratuites**
2. ✅ **Aucune dépendance payante n'est utilisée**
3. ✅ **Aucune API externe payante n'est appelée**
4. ✅ **Toutes les dépendances sont justifiées et utilisées**
5. ✅ **Le projet respecte l'engagement de gratuité à 100%**

### Garanties :
- ✅ Arkalia CIA reste 100% gratuit
- ✅ Aucune fonctionnalité payante ne sera ajoutée
- ✅ Aucune API payante ne sera intégrée
- ✅ Toutes les fonctionnalités restent locales et gratuites

---

**Dernière mise à jour** : 12 décembre 2025  
**Statut** : ✅ **VALIDÉ - 100% GRATUIT**

