# 🔧 Désactiver Mypy dans Cursor pour Réduire la Charge CPU

**Date**: 7 décembre 2025  
**Problème**: Mypy se relance automatiquement après avoir été tué, consommant beaucoup de CPU

---

## 🎯 Problème

Quand tu tues mypy avec `./scripts/fix_ram_overheat.sh`, Cursor IDE le relance automatiquement car :
- Cursor a une extension Python qui lance mypy en arrière-plan
- Elle vérifie les types Python en temps réel
- C'est pour ça que la CPU augmente au lieu de diminuer après avoir fermé des fenêtres

---

## ✅ Solution Automatique

Le script `./scripts/fix_ram_overheat.sh` a été mis à jour pour :
1. **Créer automatiquement** `.vscode/settings.json` si il n'existe pas
2. **Désactiver mypy** dans les paramètres Cursor
3. **Afficher un rappel** de redémarrer Cursor

### Utilisation

```bash
./scripts/fix_ram_overheat.sh
```

Le script va :
- ✅ Désactiver mypy dans `.vscode/settings.json`
- ✅ Tuer tous les processus mypy en cours
- ✅ Te rappeler de redémarrer Cursor

---

## 🔧 Solution Manuelle

### Option 1 : Via l'interface Cursor

1. Ouvrir Cursor
2. Aller dans **Settings** (⌘,)
3. Chercher : `Python > Analysis: Type Checking Mode`
4. Changer de `"basic"` ou `"standard"` à **`"off"`**
5. Redémarrer Cursor

### Option 2 : Via le fichier settings.json

Le fichier `.vscode/settings.json` a été créé avec :

```json
{
  "python.analysis.typeCheckingMode": "off",
  "python.analysis.banditEnabled": false
}
```

**Important** : Redémarrer Cursor après modification pour que ça prenne effet.

---

## ⚠️ Important

- **Mypy sera toujours disponible** via :
  - Pre-commit hooks (avant chaque commit)
  - Commandes manuelles : `python -m mypy arkalia_cia_python_backend`
  - CI/CD (GitHub Actions)

- **Seule la vérification automatique en temps réel est désactivée** dans Cursor

---

## 🔄 Réactiver Mypy (si besoin)

Si tu veux réactiver mypy dans Cursor :

1. Ouvrir `.vscode/settings.json`
2. Changer `"off"` en `"basic"` ou `"standard"`
3. Redémarrer Cursor

Ou via l'interface :
- Settings > Python > Analysis: Type Checking Mode > Basic

---

## 📊 Résultat Attendu

Après avoir désactivé mypy et redémarré Cursor :
- ✅ CPU devrait diminuer significativement
- ✅ RAM devrait se libérer
- ✅ Mypy ne se relancera plus automatiquement
- ✅ Les autres fonctionnalités Cursor continuent de fonctionner

---

**Dernière mise à jour** : 7 décembre 2025

