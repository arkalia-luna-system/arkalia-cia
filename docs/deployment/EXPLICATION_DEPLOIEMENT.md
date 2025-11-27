# 📱 Explication Simple : Comment Fonctionne le Déploiement

**Date** : 27 novembre 2025  
**Pour** : Comprendre comment l'app arrive sur le téléphone de ta mère

---

## ❓ Questions Fréquentes

### 1. Les branches GitHub sont-elles déployées automatiquement ?

**NON** ❌

**Explication** :
- Les branches GitHub (`develop`, `main`) contiennent juste le **code source**
- Play Console ne lit **PAS** automatiquement GitHub
- Tu dois **manuellement** build et uploader l'app

**Analogie** :
- GitHub = Recette de cuisine (le code)
- Play Console = Restaurant (où les clients mangent)
- Tu dois cuisiner (build) et servir (upload) manuellement

---

### 2. Comment l'app se met à jour pour les testeurs ?

**Processus actuel (manuel)** :

```
1. Tu codes sur ton Mac
   ↓
2. Tu commits sur GitHub (develop/main)
   ↓
3. Tu builds l'App Bundle localement
   flutter build appbundle --release
   ↓
4. Tu uploades sur Play Console (site web)
   ↓
5. Play Console valide (quelques minutes)
   ↓
6. Les testeurs reçoivent une notification
   ↓
7. Ils mettent à jour via Play Store (comme WhatsApp)
```

**Les testeurs** :
- ✅ Reçoivent une notification automatique
- ✅ Voient "Mise à jour disponible" dans Play Store
- ✅ Cliquent sur "Mettre à jour" (comme n'importe quelle app)
- ✅ L'app se met à jour automatiquement

---

### 3. Peut-on automatiser la mise à jour ?

**OUI** ✅ (mais configuration complexe)

**Option 1 : GitHub Actions (Automatique)** ✅ **CONFIGURÉ**

Quand tu pushes sur `main` → Build automatique → Upload automatique → Testeurs reçoivent la mise à jour

**Configuration** :
- ✅ Workflow créé : `.github/workflows/deploy-play-store.yml` (27 novembre 2025)
- ⏳ Créer un compte de service Google Play (à faire)
- ⏳ Ajouter le secret `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` dans GitHub (à faire)

**Avantages** :
- ✅ Automatique (push = déploiement)
- ✅ Pas d'intervention manuelle
- ✅ Workflow prêt et configuré

**Inconvénients** :
- ❌ Configuration initiale complexe (compte de service Google)
- ⏳ Nécessite le secret GitHub (à configurer)

**Option 2 : Manuel (Actuel - Simple)**

Tu décides quand build et uploader

**Avantages** :
- ✅ Simple et contrôlé
- ✅ Pas de configuration complexe

**Inconvénients** :
- ❌ Manuel (5-10 minutes par déploiement)

---

## 🎯 Workflow Recommandé pour Toi

### Pour les Corrections Urgentes

```bash
# 1. Corriger le bug
# ... code ...

# 2. Commit
git add -A
git commit -m "fix: Description"
git push origin develop

# 3. Build (2-3 minutes)
cd arkalia_cia
./android/build-android.sh flutter build appbundle --release

# 4. Upload Play Console (2 minutes)
# - Va sur play.google.com/console
# - Tests internes → Créer version
# - Upload app-release.aab
# - Publier

# Total : 5-10 minutes
```

### Pour les Nouvelles Fonctionnalités

```bash
# 1. Développer sur feature branch
git checkout -b feature/nouvelle-fonctionnalite
# ... code ...

# 2. Tester localement
flutter run

# 3. Merge sur develop
git checkout develop
git merge feature/nouvelle-fonctionnalite
git push origin develop

# 4. Tester sur develop
# 5. Si stable, merge sur main
# 6. Build et upload pour testeurs
```

---

## 📋 Résumé

| Question | Réponse |
|----------|---------|
| **GitHub → App automatique ?** | ❌ NON - Manuel |
| **Comment mettre à jour ?** | Build local → Upload Play Console |
| **Testeurs reçoivent automatiquement ?** | ✅ OUI - Notification Play Store |
| **Peut-on automatiser ?** | ✅ OUI - Mais configuration complexe |
| **Recommandé pour toi ?** | ✅ Manuel (simple et contrôlé) |

---

**Dernière mise à jour** : 27 novembre 2025

