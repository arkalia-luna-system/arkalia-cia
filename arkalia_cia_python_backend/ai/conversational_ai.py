"""
IA Conversationnelle pour analyse santé
Analyse données CIA + ARIA pour dialogue intelligent
"""
from datetime import datetime
from typing import Any
import logging

try:
    from arkalia_cia_python_backend.ai.aria_integration import ARIAIntegration
    ARIA_AVAILABLE = True
except ImportError:
    ARIA_AVAILABLE = False

logger = logging.getLogger(__name__)


class ConversationalAI:
    """IA conversationnelle pour santé"""

    def __init__(self, max_memory_size: int = 50, aria_base_url: str = "http://localhost:8001"):
        self.context_memory: list[dict[str, Any]] = []
        self.max_memory_size = max_memory_size  # Limiter la taille de la mémoire
        # Intégration ARIA si disponible
        if ARIA_AVAILABLE:
            try:
                self.aria = ARIAIntegration(aria_base_url)
            except Exception as e:
                logger.warning(f"ARIA non disponible: {e}")
                self.aria = None
        else:
            self.aria = None

    def analyze_question(self, question: str, user_data: dict) -> dict[str, Any]:
        """
        Analyse une question et génère une réponse intelligente
        
        Args:
            question: Question de l'utilisateur
            user_data: Données utilisateur (documents, médecins, consultations)
        
        Returns:
            {
                'answer': str,
                'related_documents': List[str],
                'suggestions': List[str],
                'patterns_detected': Dict
            }
        """
        question_lower = question.lower()
        
        # Détection type question
        question_type = self._detect_question_type(question_lower)
        
        # Génération réponse selon type
        answer = self._generate_answer(question_type, question, user_data)
        
        # Documents liés
        related_docs = self._find_related_documents(question_lower, user_data)
        
        # Suggestions
        suggestions = self._generate_suggestions(question_type, user_data)
        
        # Patterns détectés
        patterns = self._detect_patterns_in_question(question_lower, user_data)
        
        # Nettoyer la mémoire si elle devient trop grande
        if len(self.context_memory) > self.max_memory_size:
            # Garder seulement les 50 derniers éléments
            self.context_memory = self.context_memory[-self.max_memory_size:]
        
        return {
            'answer': answer,
            'related_documents': related_docs,
            'suggestions': suggestions,
            'patterns_detected': patterns,
            'question_type': question_type
        }
    
    def _detect_question_type(self, question: str) -> str:
        """Détecte le type de question"""
        if any(word in question for word in ['douleur', 'mal', 'souffre', 'symptôme']):
            return 'pain'
        elif any(word in question for word in ['médecin', 'docteur', 'consultation']):
            return 'doctor'
        elif any(word in question for word in ['examen', 'résultat', 'analyse', 'radio']):
            return 'exam'
        elif any(word in question for word in ['médicament', 'traitement', 'ordonnance']):
            return 'medication'
        elif any(word in question for word in ['quand', 'dernier', 'prochain', 'rdv']):
            return 'appointment'
        elif any(word in question for word in ['pourquoi', 'cause', 'raison']):
            return 'cause_effect'
        else:
            return 'general'
    
    def _generate_answer(self, question_type: str, question: str, user_data: dict) -> str:
        """Génère une réponse selon le type de question"""
        
        if question_type == 'pain':
            return self._answer_pain_question(question, user_data)
        elif question_type == 'doctor':
            return self._answer_doctor_question(question, user_data)
        elif question_type == 'exam':
            return self._answer_exam_question(question, user_data)
        elif question_type == 'medication':
            return self._answer_medication_question(question, user_data)
        elif question_type == 'appointment':
            return self._answer_appointment_question(question, user_data)
        elif question_type == 'cause_effect':
            return self._answer_cause_effect_question(question, user_data)
        else:
            return self._answer_general_question(question, user_data)
    
    def _answer_pain_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur la douleur"""
        # Essayer d'abord depuis user_data
        pain_data = user_data.get('pain_records', [])
        
        # Si pas de données, essayer ARIA
        if not pain_data and self.aria:
            try:
                user_id = user_data.get('user_id', 'default')
                pain_data = self.aria.get_pain_records(user_id, limit=10)
            except Exception as e:
                logger.debug(f"Erreur récupération ARIA: {e}")
        
        if pain_data:
            recent_pain = pain_data[-1] if pain_data else None
            if recent_pain:
                intensity = recent_pain.get('intensity', recent_pain.get('pain_level', 'N/A'))
                location = recent_pain.get('location', recent_pain.get('body_part', 'N/A'))
                date = recent_pain.get('date', recent_pain.get('timestamp', ''))
                
                answer = f"D'après vos données récentes, vous avez signalé une douleur d'intensité {intensity}/10 localisée à {location}"
                if date:
                    answer += f" le {date}"
                answer += ". "
                
                # Analyser patterns si disponibles
                if self.aria:
                    try:
                        patterns = self.aria.get_patterns(user_data.get('user_id', 'default'))
                        if patterns.get('recurring_patterns'):
                            answer += "J'ai détecté des patterns récurrents dans vos douleurs. "
                    except:
                        pass
                
                return answer
        
        return "Je peux analyser vos douleurs si vous avez des données dans ARIA. "
    
    def _answer_doctor_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les médecins"""
        doctors = user_data.get('doctors', [])
        
        if doctors:
            count = len(doctors)
            specialties = {d.get('specialty', '') for d in doctors if d.get('specialty')}
            specialties_str = ', '.join(specialties) if specialties else 'diverses spécialités'
            
            return f"Vous avez {count} médecin(s) enregistré(s) dans votre historique, couvrant {specialties_str}. "
        
        return "Vous n'avez pas encore de médecins enregistrés. "
    
    def _answer_exam_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les examens"""
        documents = user_data.get('documents', [])
        exam_docs = [d for d in documents if d.get('category') in ['resultat', 'examen']]
        
        if exam_docs:
            recent = exam_docs[-1] if exam_docs else None
            if recent:
                exam_name = recent.get('original_name', 'examen')
                exam_date = recent.get('created_at', '')
                return f"Votre dernier examen enregistré est '{exam_name}' du {exam_date}. "
        
        return "Je n'ai pas trouvé d'examens récents dans vos documents. "
    
    def _answer_medication_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les médicaments"""
        documents = user_data.get('documents', [])
        medication_docs = [d for d in documents if d.get('category') == 'ordonnance']
        
        if medication_docs:
            recent = medication_docs[-1] if medication_docs else None
            if recent:
                return f"Votre dernière ordonnance date du {recent.get('created_at', 'N/A')}. "
        
        return "Je n'ai pas trouvé d'ordonnances récentes. "
    
    def _answer_appointment_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les rendez-vous"""
        consultations = user_data.get('consultations', [])
        
        if consultations:
            upcoming = [c for c in consultations if c.get('date') > datetime.now().isoformat()]
            if upcoming:
                next_appt = upcoming[0]
                return f"Votre prochain rendez-vous est prévu le {next_appt.get('date', 'N/A')}. "
        
        return "Je n'ai pas trouvé de rendez-vous à venir. "
    
    def _answer_cause_effect_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions cause-effet"""
        # Récupérer données douleur depuis ARIA si disponible
        pain_data = user_data.get('pain_records', [])
        if not pain_data and self.aria:
            try:
                user_id = user_data.get('user_id', 'default')
                pain_data = self.aria.get_pain_records(user_id, limit=20)
            except:
                pass
        
        documents = user_data.get('documents', [])
        
        if pain_data and documents:
            # Analyser corrélations basiques
            answer = "En analysant vos données, je peux identifier des corrélations entre vos douleurs et vos examens. "
            
            # Si ARIA disponible, récupérer patterns avancés
            if self.aria:
                try:
                    patterns = self.aria.get_patterns(user_data.get('user_id', 'default'))
                    if patterns.get('correlations'):
                        answer += "ARIA a détecté des corrélations spécifiques. "
                except:
                    pass
            
            return answer
        
        # Essayer de récupérer métriques santé depuis ARIA
        if self.aria:
            try:
                health_metrics = self.aria.get_health_metrics(user_data.get('user_id', 'default'))
                if health_metrics:
                    return "J'ai accès à vos métriques santé depuis ARIA. Je peux analyser les corrélations entre douleurs, sommeil, activité et stress. "
            except:
                pass
        
        return "Pour analyser les causes et effets, j'ai besoin de plus de données (douleurs, examens). Connectez ARIA pour une analyse plus approfondie. "
    
    def _answer_general_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions générales"""
        return "Je peux vous aider à analyser vos données de santé. Posez-moi une question spécifique sur vos médecins, examens, douleurs ou médicaments. "
    
    def _find_related_documents(self, question: str, user_data: dict) -> list[str]:
        """Trouve documents liés à la question"""
        documents = user_data.get('documents', [])
        related = []
        
        # Recherche simple par mots-clés (limiter à 20 documents pour performance)
        keywords = question.split()
        # Ne traiter que les premiers documents pour économiser la mémoire
        for doc in documents[:20]:
            doc_name = (doc.get('original_name', '') + ' ' + doc.get('category', '')).lower()
            if any(kw in doc_name for kw in keywords if len(kw) > 3):
                related.append(doc.get('id'))
        
        return related[:5]  # Limiter à 5 résultats
    
    def _generate_suggestions(self, question_type: str, user_data: dict) -> list[str]:
        """Génère suggestions selon le type de question"""
        suggestions = []
        
        if question_type == 'pain':
            suggestions = [
                "Quand avez-vous ressenti cette douleur pour la première fois ?",
                "Y a-t-il des activités qui aggravent la douleur ?",
                "Avez-vous pris des médicaments pour cette douleur ?"
            ]
        elif question_type == 'doctor':
            suggestions = [
                "Quel médecin avez-vous consulté récemment ?",
                "Quand était votre dernière consultation ?",
                "Quelle spécialité recherchez-vous ?"
            ]
        elif question_type == 'exam':
            suggestions = [
                "Quel type d'examen recherchez-vous ?",
                "Quand avez-vous fait votre dernier examen ?",
                "Voulez-vous voir les résultats d'un examen spécifique ?"
            ]
        else:
            suggestions = [
                "Pouvez-vous reformuler votre question ?",
                "Voulez-vous voir vos documents récents ?",
                "Souhaitez-vous consulter vos médecins ?"
            ]
        
        return suggestions
    
    def _detect_patterns_in_question(self, question: str, user_data: dict) -> dict:
        """Détecte patterns dans la question"""
        patterns = {}
        
        # Détecter mentions temporelles
        if any(word in question for word in ['souvent', 'fréquent', 'régulier']):
            patterns['frequency'] = 'high'
        
        # Détecter urgence
        if any(word in question for word in ['urgent', 'immédiat', 'maintenant']):
            patterns['urgency'] = 'high'
        
        return patterns
    
    def prepare_appointment_questions(self, doctor_id: str, user_data: dict) -> list[str]:
        """Prépare questions pour un rendez-vous"""
        questions = [
            "Quels sont vos symptômes actuels ?",
            "Y a-t-il eu des changements depuis votre dernière visite ?",
            "Prenez-vous de nouveaux médicaments ?",
            "Avez-vous des examens récents à partager ?"
        ]
        
        # Personnaliser selon historique
        consultations = user_data.get('consultations', [])
        doctor_consultations = [c for c in consultations if c.get('doctor_id') == doctor_id]
        
        if doctor_consultations:
            last_consult = doctor_consultations[-1]
            questions.insert(0, f"Depuis votre dernière consultation le {last_consult.get('date', 'N/A')}, qu'est-ce qui a changé ?")
        
        return questions

