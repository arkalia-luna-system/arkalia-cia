"""
IA Conversationnelle pour analyse santé
Analyse données CIA + ARIA pour dialogue intelligent
"""

import logging
import re
from datetime import datetime
from typing import Any

try:
    from arkalia_cia_python_backend.ai.aria_integration import ARIAIntegration

    ARIA_AVAILABLE = True
except ImportError:
    ARIA_AVAILABLE = False

logger = logging.getLogger(__name__)


class ConversationalAI:
    """IA conversationnelle pour santé"""

    def __init__(
        self, max_memory_size: int = 50, aria_base_url: str = "http://localhost:8001"
    ):
        self.context_memory: list[dict[str, Any]] = []
        self.max_memory_size = max_memory_size  # Limiter la taille de la mémoire
        # Intégration ARIA si disponible
        self.aria: ARIAIntegration | None = None
        if ARIA_AVAILABLE:
            try:
                self.aria = ARIAIntegration(aria_base_url)
            except Exception as e:
                logger.warning(f"ARIA non disponible: {e}")
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
            self.context_memory = self.context_memory[-self.max_memory_size :]

        return {
            "answer": answer,
            "related_documents": related_docs,
            "suggestions": suggestions,
            "patterns_detected": patterns,
            "question_type": question_type,
        }

    def _detect_question_type(self, question: str) -> str:
        """Détecte le type de question"""
        if any(word in question for word in ["douleur", "mal", "souffre", "symptôme"]):
            return "pain"
        elif any(word in question for word in ["médecin", "docteur", "consultation"]):
            return "doctor"
        elif any(
            word in question for word in ["examen", "résultat", "analyse", "radio"]
        ):
            return "exam"
        elif any(
            word in question for word in ["médicament", "traitement", "ordonnance"]
        ):
            return "medication"
        elif any(word in question for word in ["quand", "dernier", "prochain", "rdv"]):
            return "appointment"
        elif any(word in question for word in ["pourquoi", "cause", "raison"]):
            return "cause_effect"
        else:
            return "general"

    def _generate_answer(
        self, question_type: str, question: str, user_data: dict
    ) -> str:
        """Génère une réponse selon le type de question"""

        if question_type == "pain":
            return self._answer_pain_question(question, user_data)
        elif question_type == "doctor":
            return self._answer_doctor_question(question, user_data)
        elif question_type == "exam":
            return self._answer_exam_question(question, user_data)
        elif question_type == "medication":
            return self._answer_medication_question(question, user_data)
        elif question_type == "appointment":
            return self._answer_appointment_question(question, user_data)
        elif question_type == "cause_effect":
            return self._answer_cause_effect_question(question, user_data)
        else:
            return self._answer_general_question(question, user_data)

    def _answer_pain_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur la douleur"""
        # Essayer d'abord depuis user_data
        pain_data = user_data.get("pain_records", [])

        # Si pas de données, essayer ARIA
        if not pain_data and self.aria:
            try:
                user_id = user_data.get("user_id", "default")
                pain_data = self.aria.get_pain_records(user_id, limit=10)
            except Exception as e:
                logger.debug(f"Erreur récupération ARIA: {e}")

        if pain_data:
            recent_pain = pain_data[-1] if pain_data else None
            if recent_pain:
                intensity = recent_pain.get(
                    "intensity", recent_pain.get("pain_level", "N/A")
                )
                location = recent_pain.get(
                    "location", recent_pain.get("body_part", "N/A")
                )
                date = recent_pain.get("date", recent_pain.get("timestamp", ""))

                answer = (
                    f"D'après vos données récentes, vous avez signalé "
                    f"une douleur d'intensité {intensity}/10 "
                    f"localisée à {location}"
                )
                if date:
                    answer += f" le {date}"
                answer += ". "

                # Analyser patterns si disponibles
                if self.aria:
                    try:
                        patterns = self.aria.get_patterns(
                            user_data.get("user_id", "default")
                        )
                        if patterns.get("recurring_patterns"):
                            answer += (
                                "J'ai détecté des patterns récurrents "
                                "dans vos douleurs. "
                            )
                    except Exception as pattern_error:
                        # Logger l'erreur mais continuer sans patterns
                        logger.debug(
                            (
                                f"Patterns ARIA non disponibles "
                                f"(non bloquant): {pattern_error}"
                            ),
                            exc_info=False,
                        )

                return answer

        return "Je peux analyser vos douleurs si vous avez des données dans ARIA. "

    def suggest_exam_type(self, text: str) -> dict[str, Any]:
        """
        Suggère le type d'examen le plus probable depuis un texte

        Returns:
            {'type': str, 'confidence': float, 'alternatives': List[str]}
        """
        from arkalia_cia_python_backend.pdf_parser.metadata_extractor import (
            MetadataExtractor,
        )

        extractor = MetadataExtractor()
        result = extractor._extract_exam_type_with_confidence(text)

        # Trouver alternatives (autres types possibles avec confiance > 0.5)
        alternatives = []
        text_lower = text.lower()
        for exam_type, pattern in extractor.exam_patterns.items():
            if exam_type != result.get("type"):
                matches = re.findall(pattern, text_lower, re.IGNORECASE)
                if matches:
                    confidence = 0.7 if len(matches) == 1 else min(0.9, 0.7 + (len(matches) * 0.05))
                    if confidence > 0.5:
                        alternatives.append({"type": exam_type, "confidence": confidence})

        return {
            "type": result.get("type"),
            "confidence": result.get("confidence", 0.0),
            "alternatives": sorted(alternatives, key=lambda x: x["confidence"], reverse=True),
        }

    def suggest_doctor_completion(self, partial_doctor: dict) -> dict[str, Any]:
        """
        Suggère de compléter les informations manquantes d'un médecin

        Args:
            partial_doctor: Dict avec nom, spécialité, etc. (peut être incomplet)

        Returns:
            {'suggestions': List[dict], 'missing_fields': List[str]}
        """
        suggestions = []
        missing_fields = []

        # Vérifier champs manquants
        if not partial_doctor.get("address"):
            missing_fields.append("address")
            suggestions.append({
                "field": "address",
                "message": "L'adresse du cabinet pourrait être trouvée dans vos documents récents.",
            })

        if not partial_doctor.get("phone"):
            missing_fields.append("phone")
            suggestions.append({
                "field": "phone",
                "message": "Le numéro de téléphone pourrait être dans vos documents ou consultations.",
            })

        if not partial_doctor.get("email"):
            missing_fields.append("email")
            suggestions.append({
                "field": "email",
                "message": "L'email pourrait être trouvé dans vos documents.",
            })

        return {
            "suggestions": suggestions,
            "missing_fields": missing_fields,
        }

    def detect_duplicates(self, doctors: list[dict]) -> list[dict[str, Any]]:
        """
        Détecte les doublons potentiels dans une liste de médecins

        Returns:
            List de {'doctor1': dict, 'doctor2': dict, 'similarity_score': float}
        """
        from difflib import SequenceMatcher

        duplicates = []

        for i, doctor1 in enumerate(doctors):
            for doctor2 in doctors[i+1:]:
                # Comparer noms
                name1 = f"{doctor1.get('first_name', '')} {doctor1.get('last_name', '')}".strip().lower()
                name2 = f"{doctor2.get('first_name', '')} {doctor2.get('last_name', '')}".strip().lower()

                name_similarity = SequenceMatcher(None, name1, name2).ratio()

                # Comparer spécialités
                specialty1 = (doctor1.get("specialty") or "").lower()
                specialty2 = (doctor2.get("specialty") or "").lower()
                specialty_match = specialty1 == specialty2 and specialty1 != ""

                # Score de similarité combiné
                similarity_score = name_similarity
                if specialty_match:
                    similarity_score = min(1.0, similarity_score + 0.2)

                # Si similarité > 0.8, considérer comme doublon potentiel
                if similarity_score > 0.8:
                    duplicates.append({
                        "doctor1": doctor1,
                        "doctor2": doctor2,
                        "similarity_score": similarity_score,
                        "reason": "Nom similaire" + (" et même spécialité" if specialty_match else ""),
                    })

        return sorted(duplicates, key=lambda x: x["similarity_score"], reverse=True)

    def answer_pathology_question(
        self, question: str, pathologies: list[dict]
    ) -> dict[str, Any]:
        """
        Répond aux questions sur les pathologies

        Args:
            question: Question de l'utilisateur
            pathologies: Liste des pathologies suivies

        Returns:
            {
                'answer': str,
                'pathology_mentioned': str | None,
                'suggestions': List[str],
                'exams_suggested': List[str],
                'treatments_suggested': List[str]
            }
        """
        question_lower = question.lower()
        pathology_mentioned = None

        # Détecter quelle pathologie est mentionnée
        for pathology in pathologies:
            name = pathology.get("name", "").lower()
            if name in question_lower:
                pathology_mentioned = pathology.get("name")
                break

        if not pathology_mentioned and pathologies:
            # Si aucune pathologie spécifique, utiliser la première
            pathology_mentioned = pathologies[0].get("name")

        answer = ""
        suggestions = []
        exams_suggested = []
        treatments_suggested = []

        if pathology_mentioned:
            pathology = next(
                (p for p in pathologies if p.get("name") == pathology_mentioned),
                {},
            )

            if pathology:
                answer = f"Concernant votre suivi de {pathology_mentioned}, "

                # Informations sur la pathologie
                symptoms = pathology.get("symptoms", [])
                if symptoms:
                    answer += f"les symptômes suivis sont : {', '.join(symptoms[:3])}. "

                # Suggérer examens
                exams = pathology.get("exams", [])
                if exams:
                    exams_suggested = exams[:3]
                    answer += f"Examens recommandés : {', '.join(exams_suggested)}. "

                # Suggérer traitements
                treatments = pathology.get("treatments", [])
                if treatments:
                    treatments_suggested = treatments[:3]
                    answer += f"Traitements possibles : {', '.join(treatments_suggested)}. "

                # Suggestions selon le type de question
                if "quand" in question_lower or "prochain" in question_lower:
                    suggestions.append(
                        f"Vérifiez vos rappels pour {pathology_mentioned} dans le calendrier."
                    )
                if "symptôme" in question_lower or "douleur" in question_lower:
                    suggestions.append(
                        f"Enregistrez vos symptômes pour {pathology_mentioned} dans le suivi."
                    )
        else:
            answer = "Je peux vous aider avec vos pathologies. Quelle pathologie vous intéresse ?"

        return {
            "answer": answer,
            "pathology_mentioned": pathology_mentioned,
            "suggestions": suggestions,
            "exams_suggested": exams_suggested,
            "treatments_suggested": treatments_suggested,
        }

    def suggest_questions_for_appointment(
        self, doctor_id: str, pathologies: list[dict]
    ) -> list[str]:
        """
        Génère des questions pertinentes pour un RDV selon pathologies suivies

        Args:
            doctor_id: ID du médecin
            pathologies: Liste des pathologies suivies

        Returns:
            List de questions suggérées
        """
        questions = []

        # Questions générales
        questions.extend([
            "Quels sont les résultats de mes derniers examens ?",
            "Y a-t-il des changements dans mon traitement ?",
            "Dois-je modifier mon mode de vie ?",
        ])

        # Questions spécifiques par pathologie
        for pathology in pathologies:
            name = pathology.get("name", "")
            symptoms = pathology.get("symptoms", [])
            exams = pathology.get("exams", [])

            if symptoms:
                questions.append(
                    f"Concernant {name}, mes symptômes ({', '.join(symptoms[:2])}) sont-ils normaux ?"
                )

            if exams:
                questions.append(
                    f"Quand dois-je refaire {exams[0]} pour {name} ?"
                )

        return questions[:8]  # Limiter à 8 questions

    def _answer_doctor_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les médecins"""
        doctors = user_data.get("doctors", [])

        if doctors:
            count = len(doctors)
            specialties = {
                d.get("specialty", "") for d in doctors if d.get("specialty")
            }
            specialties_str = (
                ", ".join(specialties) if specialties else "diverses spécialités"
            )

            return (
                f"Vous avez {count} médecin(s) enregistré(s) "
                f"dans votre historique, couvrant {specialties_str}. "
            )

        return "Vous n'avez pas encore de médecins enregistrés. "

    def _answer_exam_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les examens"""
        documents = user_data.get("documents", [])
        exam_docs = [
            d for d in documents if d.get("category") in ["resultat", "examen"]
        ]

        if exam_docs:
            recent = exam_docs[-1] if exam_docs else None
            if recent:
                exam_name = recent.get("original_name", "examen")
                exam_date = recent.get("created_at", "")
                return (
                    f"Votre dernier examen enregistré est "
                    f"'{exam_name}' du {exam_date}. "
                )

        return "Je n'ai pas trouvé d'examens récents dans vos documents. "

    def _answer_medication_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les médicaments"""
        documents = user_data.get("documents", [])
        medication_docs = [d for d in documents if d.get("category") == "ordonnance"]

        if medication_docs:
            recent = medication_docs[-1] if medication_docs else None
            if recent:
                return (
                    f"Votre dernière ordonnance date du "
                    f"{recent.get('created_at', 'N/A')}. "
                )

        return "Je n'ai pas trouvé d'ordonnances récentes. "

    def _answer_appointment_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions sur les rendez-vous"""
        consultations = user_data.get("consultations", [])

        if consultations:
            upcoming = [
                c for c in consultations if c.get("date") > datetime.now().isoformat()
            ]
            if upcoming:
                next_appt = upcoming[0]
                return (
                    f"Votre prochain rendez-vous est prévu le "
                    f"{next_appt.get('date', 'N/A')}. "
                )

        return "Je n'ai pas trouvé de rendez-vous à venir. "

    def _answer_cause_effect_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions cause-effet"""
        # Récupérer données douleur depuis ARIA si disponible
        pain_data = user_data.get("pain_records", [])
        if not pain_data and self.aria:
            try:
                user_id = user_data.get("user_id", "default")
                pain_data = self.aria.get_pain_records(user_id, limit=20)
            except Exception as pain_error:
                # Logger l'erreur mais continuer sans données de douleur
                logger.debug(
                    (
                        f"Données douleur ARIA non disponibles "
                        f"(non bloquant): {pain_error}"
                    ),
                    exc_info=False,
                )

        documents = user_data.get("documents", [])

        if pain_data and documents:
            # Analyser corrélations basiques
            answer = (
                "En analysant vos données, je peux identifier des "
                "corrélations entre vos douleurs et vos examens. "
            )

            # Si ARIA disponible, récupérer patterns avancés et métriques santé
            if self.aria:
                try:
                    user_id = user_data.get("user_id", "default")
                    patterns = self.aria.get_patterns(user_id)
                    health_metrics = self.aria.get_health_metrics(user_id, days=30)

                    # Analyser corrélations croisées CIA+ARIA
                    correlations = self._analyze_cross_correlations(
                        pain_data, documents, health_metrics, patterns
                    )

                    if correlations:
                        answer += (
                            f"J'ai détecté {len(correlations)} "
                            f"corrélation(s) significative(s) : "
                        )
                        for corr in correlations[:3]:  # Limiter à 3 corrélations
                            answer += f"{corr['description']}. "
                    elif patterns.get("correlations"):
                        answer += "ARIA a détecté des corrélations spécifiques. "
                except Exception as e:
                    logger.debug(f"Erreur analyse croisée: {e}")

            return answer

        # Essayer de récupérer métriques santé depuis ARIA
        if self.aria:
            try:
                user_id = user_data.get("user_id", "default")
                health_metrics = self.aria.get_health_metrics(user_id, days=30)
                if health_metrics:
                    return (
                        "En analysant vos métriques santé ARIA, "
                        "je peux identifier des patterns. "
                    )
            except Exception as metrics_error:
                # Logger l'erreur mais continuer sans métriques santé
                logger.debug(
                    (
                        f"Métriques santé ARIA non disponibles "
                        f"(non bloquant): {metrics_error}"
                    ),
                    exc_info=False,
                )

        return "Je n'ai pas assez de données pour analyser les corrélations. "

    def _analyze_cross_correlations(
        self,
        pain_data: list[dict],
        documents: list[dict],
        health_metrics: dict,
        patterns: dict,
    ) -> list[dict]:
        """Analyse corrélations croisées entre CIA et ARIA"""
        correlations = []

        try:
            # Corrélation douleur ↔ examens
            if pain_data and documents:
                # Analyser si pics de douleur correspondent à examens
                pain_dates = [
                    datetime.fromisoformat(p.get("date", ""))
                    for p in pain_data
                    if p.get("date") and p.get("intensity", 0) > 5
                ]
                exam_dates = [
                    datetime.fromisoformat(d.get("created_at", ""))
                    for d in documents
                    if d.get("created_at")
                ]

                if pain_dates and exam_dates:
                    # Vérifier si examens suivent pics de douleur (dans les 7 jours)
                    # Optimisé: trier les dates d'examens pour recherche
                    # binaire au lieu de boucle imbriquée O(n²)
                    exam_dates_sorted = sorted(exam_dates)
                    matches = 0
                    for pain_date in pain_dates:
                        # Chercher le premier examen dans les 7 jours suivant la douleur
                        for exam_date in exam_dates_sorted:
                            days_diff = (exam_date - pain_date).days
                            if days_diff < 0:
                                continue  # Examen avant la douleur, continuer
                            if days_diff <= 7:
                                matches += 1
                                break
                            else:
                                # Dates triées, pas besoin de continuer
                                break

                    if matches > 0:
                        confidence = min(1.0, matches / len(pain_dates))
                        correlations.append(
                            {
                                "type": "pain_exam",
                                "description": (
                                    f"{matches} examen(s) effectué(s) "
                                    f"après pic de douleur"
                                ),
                                "confidence": confidence,
                                "severity": "high" if confidence > 0.5 else "medium",
                            }
                        )

            # Corrélation métriques santé ↔ douleur
            if health_metrics and pain_data:
                # Analyser corrélation stress/sommeil avec douleur
                if "stress_levels" in health_metrics and pain_data:
                    stress_levels = health_metrics.get("stress_levels", [])
                    if stress_levels:
                        avg_stress = sum(stress_levels) / len(stress_levels)
                        avg_pain = sum(
                            p.get("intensity", 0)
                            for p in pain_data
                            if p.get("intensity")
                        ) / max(len(pain_data), 1)

                        if avg_stress > 5 and avg_pain > 5:
                            # Calculer corrélation temporelle
                            stress_pain_corr = self._calculate_temporal_correlation(
                                stress_levels,
                                [p.get("intensity", 0) for p in pain_data],
                            )
                            correlations.append(
                                {
                                    "type": "stress_pain",
                                    "description": (
                                        "Corrélation entre niveau de stress élevé "
                                        "et douleur"
                                    ),
                                    "confidence": max(0.7, stress_pain_corr),
                                    "severity": (
                                        "high" if stress_pain_corr > 0.6 else "medium"
                                    ),
                                }
                            )

                # Analyser corrélation sommeil ↔ douleur
                if "sleep_hours" in health_metrics and pain_data:
                    sleep_hours = health_metrics.get("sleep_hours", [])
                    if sleep_hours:
                        avg_sleep = sum(sleep_hours) / len(sleep_hours)
                        avg_pain = sum(
                            p.get("intensity", 0)
                            for p in pain_data
                            if p.get("intensity")
                        ) / max(len(pain_data), 1)

                        if avg_sleep < 6 and avg_pain > 5:
                            correlations.append(
                                {
                                    "type": "sleep_pain",
                                    "description": (
                                        "Corrélation entre manque de sommeil "
                                        "et douleur"
                                    ),
                                    "confidence": 0.65,
                                    "severity": "medium",
                                }
                            )

            # Corrélations depuis patterns ARIA
            if patterns.get("correlations"):
                for corr in patterns["correlations"][:3]:  # Limiter à 3
                    correlations.append(
                        {
                            "type": "aria_pattern",
                            "description": corr.get(
                                "description", "Pattern ARIA détecté"
                            ),
                            "confidence": corr.get("confidence", 0.5),
                            "severity": corr.get("severity", "medium"),
                        }
                    )

            # Trier par confiance décroissante
            def get_confidence(x: dict) -> float:
                conf = x.get("confidence", 0.0)
                if isinstance(conf, int | float):
                    return float(conf)
                return 0.0

            correlations.sort(key=get_confidence, reverse=True)

        except Exception as e:
            logger.debug(f"Erreur analyse corrélations croisées: {e}")

        return correlations[:5]  # Limiter à 5 corrélations les plus importantes

    def _calculate_temporal_correlation(
        self, series1: list[float], series2: list[float]
    ) -> float:
        """Calcule corrélation temporelle entre deux séries"""
        try:
            if len(series1) != len(series2) or len(series1) < 2:
                return 0.5  # Corrélation par défaut

            # Calculer corrélation de Pearson simplifiée
            mean1 = sum(series1) / len(series1)
            mean2 = sum(series2) / len(series2)

            numerator = sum(
                (series1[i] - mean1) * (series2[i] - mean2) for i in range(len(series1))
            )
            denominator1 = sum((series1[i] - mean1) ** 2 for i in range(len(series1)))
            denominator2 = sum((series2[i] - mean2) ** 2 for i in range(len(series2)))

            if denominator1 == 0 or denominator2 == 0:
                return 0.5

            correlation = numerator / ((denominator1 * denominator2) ** 0.5)
            return float(
                max(0.0, min(1.0, abs(correlation)))
            )  # Normaliser entre 0 et 1
        except (ValueError, ZeroDivisionError, TypeError) as e:
            logger.debug(f"Erreur calcul corrélation: {e}")
            return 0.5
        except Exception as e:
            logger.warning(f"Erreur inattendue calcul corrélation: {e}")
            return 0.5

    def _answer_general_question(self, question: str, user_data: dict) -> str:
        """Répond aux questions générales"""
        return (
            "Je peux vous aider à analyser vos données de santé. "
            "Posez-moi une question spécifique sur vos médecins, "
            "examens, douleurs ou médicaments. "
        )

    def _find_related_documents(self, question: str, user_data: dict) -> list[str]:
        """Trouve documents liés à la question"""
        documents = user_data.get("documents", [])
        related = []

        # Recherche simple par mots-clés (limiter à 20 documents pour performance)
        keywords = question.split()
        # Ne traiter que les premiers documents pour économiser la mémoire
        for doc in documents[:20]:
            doc_name = (
                doc.get("original_name", "") + " " + doc.get("category", "")
            ).lower()
            if any(kw in doc_name for kw in keywords if len(kw) > 3):
                related.append(doc.get("id"))

        return related[:5]  # Limiter à 5 résultats

    def _generate_suggestions(self, question_type: str, user_data: dict) -> list[str]:
        """Génère suggestions selon le type de question"""
        suggestions = []

        if question_type == "pain":
            suggestions = [
                "Quand avez-vous ressenti cette douleur pour la première fois ?",
                "Y a-t-il des activités qui aggravent la douleur ?",
                "Avez-vous pris des médicaments pour cette douleur ?",
            ]
        elif question_type == "doctor":
            suggestions = [
                "Quel médecin avez-vous consulté récemment ?",
                "Quand était votre dernière consultation ?",
                "Quelle spécialité recherchez-vous ?",
            ]
        elif question_type == "exam":
            suggestions = [
                "Quel type d'examen recherchez-vous ?",
                "Quand avez-vous fait votre dernier examen ?",
                "Voulez-vous voir les résultats d'un examen spécifique ?",
            ]
        else:
            suggestions = [
                "Pouvez-vous reformuler votre question ?",
                "Voulez-vous voir vos documents récents ?",
                "Souhaitez-vous consulter vos médecins ?",
            ]

        return suggestions

    def _detect_patterns_in_question(self, question: str, user_data: dict) -> dict:
        """Détecte patterns dans la question"""
        patterns = {}

        # Détecter mentions temporelles
        if any(word in question for word in ["souvent", "fréquent", "régulier"]):
            patterns["frequency"] = "high"

        # Détecter urgence
        if any(word in question for word in ["urgent", "immédiat", "maintenant"]):
            patterns["urgency"] = "high"

        return patterns

    def prepare_appointment_questions(
        self, doctor_id: str, user_data: dict
    ) -> list[str]:
        """Prépare questions pour un rendez-vous"""
        questions = [
            "Quels sont vos symptômes actuels ?",
            "Y a-t-il eu des changements depuis votre dernière visite ?",
            "Prenez-vous de nouveaux médicaments ?",
            "Avez-vous des examens récents à partager ?",
        ]

        # Personnaliser selon historique
        consultations = user_data.get("consultations", [])
        doctor_consultations = [
            c for c in consultations if c.get("doctor_id") == doctor_id
        ]

        if doctor_consultations:
            last_consult = doctor_consultations[-1]
            questions.insert(
                0,
                (
                    f"Depuis votre dernière consultation le "
                    f"{last_consult.get('date', 'N/A')}, "
                    f"qu'est-ce qui a changé ?"
                ),
            )

        return questions
