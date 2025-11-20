# Plan 06 : IA conversationnelle douleurs

**Version** : 1.0.0  
**Date** : 20 novembre 2025  
**Statut** : ✅ Implémenté

---

## Vue d'ensemble

IA "médecin virtuel" pour analyser douleurs, pathologie et examens.

---

## 🎯 **OBJECTIF**

Créer une IA conversationnelle spécialisée qui :
- Analyse croisée CIA + ARIA (douleurs ↔ examens)
- Détecte cause à effet
- Aide à préparer RDV avec questions pertinentes
- Parle de pathologie, examens, douleurs en langage simple

---

## 📋 **BESOINS IDENTIFIÉS**

### **Besoin Principal**
- ✅ IA spécialisée douleurs
- ✅ Analyse croisée CIA + ARIA
- ✅ Cause à effet (douleurs ↔ examens)
- ✅ Interface conversationnelle
- ✅ IA "médecin virtuel" pour préparer RDV

### **Inspiration**
- Arkhn Assistant IA
- PraxyConsultation

---

## 🏗️ **ARCHITECTURE**

### **Stack IA**

```
Backend (Python)
├── LangChain (orchestration LLM)
├── OpenAI API ou modèle local (LLaMA)
├── Vector database (Chroma/FAISS) pour contexte
└── RAG (Retrieval Augmented Generation)
```

### **Structure Fichiers**

```
arkalia_cia_python_backend/
├── ai/
│   ├── conversational_ai.py        # IA conversationnelle principale
│   ├── context_retriever.py          # Récupération contexte médical
│   ├── rdv_preparator.py            # Préparation RDV
│   └── cause_effect_analyzer.py     # Analyse cause-effet
└── api/
    └── chat_api.py                  # API chat
```

---

## 🔧 **IMPLÉMENTATION DÉTAILLÉE**

### **Étape 1 : Récupérateur Contexte**

**Fichier** : `arkalia_cia_python_backend/ai/context_retriever.py`

```python
"""
Récupère contexte médical depuis CIA et ARIA
Pour alimenter l'IA conversationnelle
"""
import sqlite3
from typing import Dict, List
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class ContextRetriever:
    """Récupère contexte médical pour IA"""
    
    def __init__(self, cia_db_path: str, aria_db_path: str):
        self.cia_db_path = cia_db_path
        self.aria_db_path = aria_db_path
    
    def get_recent_pain_data(self, days: int = 30) -> List[Dict]:
        """Récupère données douleur récentes depuis ARIA"""
        try:
            conn = sqlite3.connect(self.aria_db_path)
            cursor = conn.cursor()
            
            cutoff_date = (datetime.now() - timedelta(days=days)).isoformat()
            
            cursor.execute('''
                SELECT date, intensity, location, triggers, notes
                FROM pain_entries
                WHERE date >= ?
                ORDER BY date DESC
            ''', (cutoff_date,))
            
            results = []
            for row in cursor.fetchall():
                results.append({
                    'date': row[0],
                    'intensity': row[1],
                    'location': row[2],
                    'triggers': row[3],
                    'notes': row[4],
                })
            
            conn.close()
            return results
        
        except Exception as e:
            logger.error(f"Erreur récupération douleurs: {e}")
            return []
    
    def get_recent_exams(self, days: int = 90) -> List[Dict]:
        """Récupère examens récents depuis CIA"""
        try:
            conn = sqlite3.connect(self.cia_db_path)
            cursor = conn.cursor()
            
            cutoff_date = (datetime.now() - timedelta(days=days)).isoformat()
            
            cursor.execute('''
                SELECT id, title, category, created_at, text_content
                FROM documents
                WHERE category IN ('examen', 'resultat', 'compte_rendu')
                AND created_at >= ?
                ORDER BY created_at DESC
            ''', (cutoff_date,))
            
            results = []
            for row in cursor.fetchall():
                results.append({
                    'id': row[0],
                    'title': row[1],
                    'category': row[2],
                    'date': row[3],
                    'content': row[4][:500] if row[4] else '',  # Limiter taille
                })
            
            conn.close()
            return results
        
        except Exception as e:
            logger.error(f"Erreur récupération examens: {e}")
            return []
    
    def get_medical_context(self) -> Dict:
        """Récupère contexte médical complet"""
        return {
            'recent_pains': self.get_recent_pain_data(),
            'recent_exams': self.get_recent_exams(),
            'summary': self._generate_summary(),
        }
    
    def _generate_summary(self) -> str:
        """Génère résumé contexte médical"""
        pains = self.get_recent_pain_data()
        exams = self.get_recent_exams()
        
        summary = f"Données récentes:\n"
        summary += f"- {len(pains)} entrées douleur\n"
        summary += f"- {len(exams)} examens récents\n"
        
        if pains:
            avg_intensity = sum(p['intensity'] for p in pains) / len(pains)
            summary += f"- Intensité douleur moyenne: {avg_intensity:.1f}/10\n"
        
        return summary
```

---

### **Étape 2 : Analyseur Cause-Effet**

**Fichier** : `arkalia_cia_python_backend/ai/cause_effect_analyzer.py`

```python
"""
Analyse relations cause-effet entre douleurs et examens
"""
from datetime import datetime, timedelta
from typing import List, Dict
import logging

logger = logging.getLogger(__name__)


class CauseEffectAnalyzer:
    """Analyseur cause-effet médical"""
    
    def analyze_pain_exam_correlation(
        self,
        pain_data: List[Dict],
        exam_data: List[Dict]
    ) -> List[Dict]:
        """
        Analyse corrélations douleurs ↔ examens
        
        Returns:
            List[Dict] avec relations détectées
        """
        correlations = []
        
        for exam in exam_data:
            exam_date = datetime.fromisoformat(exam['date'])
            
            # Chercher douleurs avant examen (30 jours)
            pains_before = [
                p for p in pain_data
                if self._is_before_exam(p['date'], exam_date, days=30)
            ]
            
            # Chercher douleurs après examen (30 jours)
            pains_after = [
                p for p in pain_data
                if self._is_after_exam(p['date'], exam_date, days=30)
            ]
            
            # Analyser pattern
            if pains_before and not pains_after:
                correlations.append({
                    'type': 'exam_revealed_cause',
                    'exam': exam['title'],
                    'exam_date': exam['date'],
                    'pains_before': len(pains_before),
                    'pains_after': 0,
                    'interpretation': f"L'examen {exam['title']} a peut-être révélé la cause des douleurs"
                })
            elif pains_before and pains_after:
                avg_intensity_before = sum(p['intensity'] for p in pains_before) / len(pains_before)
                avg_intensity_after = sum(p['intensity'] for p in pains_after) / len(pains_after)
                
                if avg_intensity_after < avg_intensity_before * 0.7:
                    correlations.append({
                        'type': 'exam_helped_treatment',
                        'exam': exam['title'],
                        'exam_date': exam['date'],
                        'intensity_reduction': avg_intensity_before - avg_intensity_after,
                        'interpretation': f"L'examen {exam['title']} a aidé à réduire les douleurs"
                    })
        
        return correlations
    
    def _is_before_exam(self, pain_date: str, exam_date: datetime, days: int) -> bool:
        """Vérifie si douleur est avant examen"""
        pain_dt = datetime.fromisoformat(pain_date)
        return (exam_date - timedelta(days=days)) <= pain_dt < exam_date
    
    def _is_after_exam(self, pain_date: str, exam_date: datetime, days: int) -> bool:
        """Vérifie si douleur est après examen"""
        pain_dt = datetime.fromisoformat(pain_date)
        return exam_date < pain_dt <= (exam_date + timedelta(days=days))
```

---

### **Étape 3 : Préparateur RDV**

**Fichier** : `arkalia_cia_python_backend/ai/rdv_preparator.py`

```python
"""
Prépare questions pertinentes pour RDV médical
"""
from typing import List, Dict
import logging

logger = logging.getLogger(__name__)


class RDVPreparator:
    """Préparateur questions RDV"""
    
    def prepare_questions(
        self,
        doctor_specialty: str,
        recent_pains: List[Dict],
        recent_exams: List[Dict]
    ) -> List[str]:
        """
        Génère questions pertinentes pour RDV
        
        Args:
            doctor_specialty: Spécialité médecin
            recent_pains: Données douleur récentes
            recent_exams: Examens récents
        
        Returns:
            List[str] avec questions suggérées
        """
        questions = []
        
        # Questions basées sur spécialité
        specialty_questions = self._get_specialty_questions(doctor_specialty)
        questions.extend(specialty_questions)
        
        # Questions basées sur douleurs récentes
        if recent_pains:
            pain_questions = self._get_pain_questions(recent_pains)
            questions.extend(pain_questions)
        
        # Questions basées sur examens récents
        if recent_exams:
            exam_questions = self._get_exam_questions(recent_exams)
            questions.extend(exam_questions)
        
        # Questions générales
        general_questions = [
            "Quels sont les résultats de mes derniers examens?",
            "Y a-t-il des changements dans mon traitement?",
            "Quand dois-je revenir pour un suivi?",
        ]
        questions.extend(general_questions)
        
        return questions[:10]  # Limiter à 10 questions
    
    def _get_specialty_questions(self, specialty: str) -> List[str]:
        """Questions selon spécialité"""
        specialty_map = {
            'cardiologue': [
                "Comment va mon cœur?",
                "Dois-je continuer mes médicaments cardiaques?",
            ],
            'rhumatologue': [
                "Comment gérer mes douleurs articulaires?",
                "Y a-t-il des exercices recommandés?",
            ],
            'généraliste': [
                "Comment va ma santé générale?",
                "Y a-t-il des examens à faire?",
            ],
        }
        return specialty_map.get(specialty.lower(), [])
    
    def _get_pain_questions(self, pains: List[Dict]) -> List[str]:
        """Questions basées sur douleurs"""
        if not pains:
            return []
        
        avg_intensity = sum(p['intensity'] for p in pains) / len(pains)
        
        questions = []
        if avg_intensity > 7:
            questions.append("Pourquoi mes douleurs sont-elles si intenses?")
        if len(pains) > 10:
            questions.append("Pourquoi ai-je autant de douleurs récemment?")
        
        return questions
    
    def _get_exam_questions(self, exams: List[Dict]) -> List[str]:
        """Questions basées sur examens"""
        if not exams:
            return []
        
        return [
            f"Que signifient les résultats de {exams[0]['title']}?",
            "Y a-t-il des examens supplémentaires à faire?",
        ]
```

---

### **Étape 4 : IA Conversationnelle**

**Fichier** : `arkalia_cia_python_backend/ai/conversational_ai.py`

```python
"""
IA conversationnelle spécialisée santé
Utilise LangChain + LLM (OpenAI ou local)
"""
from langchain.llms import OpenAI
from langchain.chains import ConversationChain
from langchain.memory import ConversationBufferMemory
from typing import Dict, List
import logging
import os

logger = logging.getLogger(__name__)


class ConversationalAI:
    """IA conversationnelle santé"""
    
    def __init__(self):
        # Utiliser OpenAI ou modèle local (LLaMA)
        api_key = os.getenv('OPENAI_API_KEY')
        if api_key:
            self.llm = OpenAI(temperature=0.7)
        else:
            # Fallback sur modèle local si disponible
            logger.warning("OpenAI API key non trouvée, utilisation modèle local")
            self.llm = None
        
        self.memory = ConversationBufferMemory()
        self.context_retriever = None
    
    def set_context(self, context_retriever):
        """Définit récupérateur contexte"""
        self.context_retriever = context_retriever
    
    def chat(self, user_message: str, context: Dict = None) -> str:
        """
        Répond à message utilisateur avec contexte médical
        
        Args:
            user_message: Message utilisateur
            context: Contexte médical (optionnel)
        
        Returns:
            Réponse IA
        """
        if not self.llm:
            return "IA non disponible. Veuillez configurer OpenAI API key."
        
        # Récupérer contexte si disponible
        if context is None and self.context_retriever:
            context = self.context_retriever.get_medical_context()
        
        # Construire prompt avec contexte
        prompt = self._build_prompt(user_message, context)
        
        try:
            # Générer réponse
            chain = ConversationChain(
                llm=self.llm,
                memory=self.memory,
                verbose=True
            )
            
            response = chain.predict(input=prompt)
            return response
        
        except Exception as e:
            logger.error(f"Erreur génération réponse: {e}")
            return "Désolé, une erreur s'est produite. Veuillez réessayer."
    
    def _build_prompt(self, user_message: str, context: Dict) -> str:
        """Construit prompt avec contexte"""
        prompt = """Tu es ARIA, une assistante IA médicale spécialisée dans l'analyse des douleurs chroniques.
Tu as accès aux données médicales de l'utilisateur et tu dois répondre de manière claire et simple.

Contexte médical récent:
"""
        if context:
            prompt += f"- {len(context.get('recent_pains', []))} entrées douleur récentes\n"
            prompt += f"- {len(context.get('recent_exams', []))} examens récents\n"
        
        prompt += f"\nMessage utilisateur: {user_message}\n"
        prompt += "\nRéponds de manière claire, simple et bienveillante."
        
        return prompt
```

---

## ✅ **TESTS**

### **Tests IA**

```python
# tests/test_conversational_ai.py
def test_chat_basic():
    ai = ConversationalAI()
    response = ai.chat("Comment vont mes douleurs?")
    assert len(response) > 0
```

---

## 🚀 **PERFORMANCE**

### **Optimisations**

1. **Cache contexte** : Mettre en cache contexte médical
2. **Streaming réponses** : Streamer réponses pour UX fluide
3. **Modèle local** : Utiliser LLaMA local si possible (pas de coût API)

---

## 🔐 **SÉCURITÉ**

1. **Données locales** : Tout traitement local
2. **Pas de stockage cloud** : Conversations jamais envoyées cloud
3. **Anonymisation** : Anonymiser avant traitement si nécessaire

---

## 📅 **TIMELINE**

### **Semaine 1-2 : Backend IA**
- [ ] Jour 1-3 : ContextRetriever
- [ ] Jour 4-6 : CauseEffectAnalyzer
- [ ] Jour 7-10 : ConversationalAI + LangChain

### **Semaine 3-4 : Intégration**
- [ ] Jour 1-3 : API chat
- [ ] Jour 4-7 : Interface Flutter chat
- [ ] Jour 8-10 : Tests finaux

---

## 📚 **RESSOURCES**

- **LangChain** : https://python.langchain.com/
- **OpenAI API** : https://platform.openai.com/
- **LLaMA (local)** : https://github.com/facebookresearch/llama

---

**Statut** : 📋 **PLAN VALIDÉ**  
**Priorité** : 🟠 **HAUTE**  
**Temps estimé** : 1-2 mois

