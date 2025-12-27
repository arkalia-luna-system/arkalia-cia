"""
Service de génération de rapports médicaux pré-consultation
Combine données CIA (documents, consultations) + ARIA (douleur, patterns, métriques)
"""

import logging
from datetime import datetime, timedelta
from typing import Any

try:
    from arkalia_cia_python_backend.ai.aria_integration import ARIAIntegration

    ARIA_AVAILABLE = True
except ImportError:
    ARIA_AVAILABLE = False

from arkalia_cia_python_backend.database import CIADatabase

logger = logging.getLogger(__name__)


class MedicalReportService:
    """Service de génération de rapports médicaux"""

    def __init__(
        self,
        db: CIADatabase,
        aria_base_url: str = "http://localhost:8001",
    ):
        self.db = db
        self.aria: ARIAIntegration | None = None
        if ARIA_AVAILABLE:
            try:
                self.aria = ARIAIntegration(aria_base_url)
            except Exception as e:
                logger.warning(f"ARIA non disponible pour rapports: {e}")
                self.aria = None

    def generate_pre_consultation_report(
        self,
        user_id: str,
        consultation_date: datetime | None = None,
        days_range: int = 30,
        include_aria: bool = True,
    ) -> dict[str, Any]:
        """
        Génère un rapport médical pré-consultation combinant CIA + ARIA

        Args:
            user_id: ID utilisateur
            consultation_date: Date de la consultation (défaut: aujourd'hui)
            days_range: Nombre de jours à inclure (défaut: 30)
            include_aria: Inclure les données ARIA si disponibles

        Returns:
            Dict avec rapport structuré (format texte pour l'instant, PDF à venir)
        """
        if consultation_date is None:
            consultation_date = datetime.now()

        report: dict[str, Any] = {
            "report_date": consultation_date.isoformat(),
            "generated_at": datetime.now().isoformat(),
            "days_range": days_range,
            "sections": {},
        }

        # 1. Documents médicaux pertinents (CIA)
        start_date = consultation_date - timedelta(days=days_range)
        documents = self._get_relevant_documents(user_id, start_date, consultation_date)
        report["sections"]["documents"] = {
            "title": "DOCUMENTS MÉDICAUX (CIA)",
            "items": documents,
            "count": len(documents),
        }

        # 2. Consultations précédentes (CIA)
        consultations = self._get_recent_consultations(
            user_id, start_date, consultation_date
        )
        report["sections"]["consultations"] = {
            "title": "CONSULTATIONS RÉCENTES",
            "items": consultations,
            "count": len(consultations),
        }

        # 3. Données ARIA si disponibles et demandées
        if include_aria and self.aria:
            aria_data = self._get_aria_data(user_id, days_range)
            if aria_data:
                report["sections"]["aria"] = aria_data

        # 4. Générer le texte formaté
        report["formatted_text"] = self._format_report_text(report)

        return report

    def _get_relevant_documents(
        self, user_id: str, start_date: datetime, end_date: datetime
    ) -> list[dict[str, Any]]:
        """Récupère les documents médicaux pertinents"""
        try:
            # Récupérer tous les documents de l'utilisateur
            all_docs = self.db.get_documents(skip=0, limit=100)
            relevant_docs = []

            for doc in all_docs:
                # Filtrer par date si disponible
                doc_date_str = doc.get("created_at") or doc.get("date")
                if doc_date_str:
                    try:
                        doc_date = datetime.fromisoformat(
                            doc_date_str.replace("Z", "+00:00")
                        )
                        if start_date <= doc_date <= end_date:
                            relevant_docs.append(
                                {
                                    "name": doc.get("filename", "Document"),
                                    "date": doc_date_str,
                                    "type": doc.get("category", "Document"),
                                    "description": doc.get("description", ""),
                                }
                            )
                    except (ValueError, AttributeError):
                        # Si date invalide, inclure quand même
                        relevant_docs.append(
                            {
                                "name": doc.get("filename", "Document"),
                                "date": doc_date_str,
                                "type": doc.get("category", "Document"),
                                "description": doc.get("description", ""),
                            }
                        )

            # Trier par date décroissante
            relevant_docs.sort(key=lambda x: x.get("date", ""), reverse=True)
            return relevant_docs[:10]  # Limiter à 10 documents les plus récents
        except Exception as e:
            logger.warning(f"Erreur récupération documents: {e}")
            return []

    def _get_recent_consultations(
        self, user_id: str, start_date: datetime, end_date: datetime
    ) -> list[dict[str, Any]]:
        """Récupère les consultations récentes depuis la base de données"""
        try:
            consultations_data = self.db.get_consultations_by_user(
                user_id=int(user_id),
                start_date=start_date,
                end_date=end_date,
                limit=20,
            )

            consultations = []
            for consult in consultations_data:
                doctor_name = f"{consult.get('first_name', '')} {consult.get('last_name', '')}".strip()
                consultations.append(
                    {
                        "date": consult.get("date", ""),
                        "doctor": doctor_name,
                        "specialty": consult.get("specialty", ""),
                        "reason": consult.get("reason", ""),
                        "notes": consult.get("notes", ""),
                    }
                )

            return consultations
        except Exception as e:
            logger.warning(f"Erreur récupération consultations: {e}")
            return []

    def _get_aria_data(self, user_id: str, days_range: int) -> dict[str, Any] | None:
        """Récupère les données ARIA (douleur, patterns, métriques)"""
        if not self.aria:
            return None

        try:
            # Récupérer données douleur
            pain_records = self.aria.get_pain_records(user_id, limit=100)
            patterns = self.aria.get_patterns(user_id)
            health_metrics = self.aria.get_health_metrics(user_id, days=days_range)

            if not pain_records and not patterns and not health_metrics:
                return None

            # Analyser les données douleur
            pain_summary = self._analyze_pain_data(pain_records)

            return {
                "title": "DONNÉES ARIA (30 derniers jours)",
                "pain_timeline": pain_summary,
                "patterns": patterns,
                "health_metrics": health_metrics,
            }
        except Exception as e:
            logger.debug(f"ARIA non accessible pour rapport: {e}")
            return None

    def _analyze_pain_data(self, pain_records: list[dict[str, Any]]) -> dict[str, Any]:
        """Analyse les données de douleur pour générer un résumé"""
        if not pain_records:
            return {}

        intensities = [
            r.get("intensity", r.get("pain_level", 0))
            for r in pain_records
            if isinstance(r.get("intensity", r.get("pain_level", 0)), int | float)
        ]

        locations = [
            r.get("location", r.get("body_part", ""))
            for r in pain_records
            if r.get("location") or r.get("body_part")
        ]

        triggers = [r.get("trigger", "") for r in pain_records if r.get("trigger")]

        # Calculer statistiques
        avg_intensity = sum(intensities) / len(intensities) if intensities else 0
        max_intensity = max(intensities) if intensities else 0

        # Localisation la plus fréquente
        location_counts: dict[str, int] = {}
        for loc in locations:
            if loc:
                location_counts[loc] = location_counts.get(loc, 0) + 1

        most_common_location = (
            max(location_counts.items(), key=lambda x: x[1])[0]
            if location_counts
            else None
        )
        location_percentage = (
            (location_counts[most_common_location] / len(locations) * 100)
            if most_common_location and locations
            else 0
        )

        # Déclencheurs les plus fréquents
        trigger_counts: dict[str, int] = {}
        for trigger in triggers:
            if trigger:
                trigger_counts[trigger] = trigger_counts.get(trigger, 0) + 1

        most_common_triggers = sorted(
            trigger_counts.items(), key=lambda x: x[1], reverse=True
        )[:3]

        # Pic de douleur (dernière entrée avec intensité max)
        peak_pain = None
        if pain_records:
            peak_entry = max(
                pain_records,
                key=lambda x: x.get("intensity", x.get("pain_level", 0)),
            )
            peak_intensity = peak_entry.get(
                "intensity", peak_entry.get("pain_level", 0)
            )
            peak_date = peak_entry.get("timestamp", peak_entry.get("date", ""))
            peak_pain = {
                "intensity": peak_intensity,
                "date": peak_date,
            }

        return {
            "average_intensity": round(avg_intensity, 1),
            "max_intensity": max_intensity,
            "peak_pain": peak_pain,
            "most_common_location": most_common_location,
            "location_percentage": round(location_percentage, 0),
            "most_common_triggers": [
                {
                    "trigger": t[0],
                    "count": t[1],
                    "percentage": round(t[1] / len(triggers) * 100, 0),
                }
                for t in most_common_triggers
            ],
            "total_entries": len(pain_records),
        }

    def _format_report_text(self, report: dict[str, Any]) -> str:
        """Formate le rapport en texte structuré"""
        lines = []
        consultation_date = datetime.fromisoformat(
            report["report_date"].replace("Z", "+00:00")
        )

        # En-tête
        lines.append("=" * 60)
        lines.append(
            f"RAPPORT MÉDICAL - Consultation du {consultation_date.strftime('%d/%m/%Y')}"
        )
        lines.append("=" * 60)
        lines.append("")

        # Section Documents
        if "documents" in report["sections"]:
            docs_section = report["sections"]["documents"]
            lines.append(docs_section["title"])
            lines.append("-" * 60)
            if docs_section["items"]:
                for doc in docs_section["items"]:
                    doc_date = doc.get("date", "")
                    if doc_date:
                        try:
                            date_obj = datetime.fromisoformat(
                                doc_date.replace("Z", "+00:00")
                            )
                            date_str = date_obj.strftime("%d/%m/%Y")
                        except (ValueError, AttributeError):
                            date_str = doc_date
                    else:
                        date_str = "Date inconnue"

                    lines.append(
                        f"- {doc.get('name', 'Document')} ({doc.get('type', 'Document')}) - {date_str}"
                    )
            else:
                lines.append("Aucun document récent")
            lines.append("")

        # Section Consultations
        if "consultations" in report["sections"]:
            cons_section = report["sections"]["consultations"]
            if cons_section["items"]:
                lines.append(cons_section["title"])
                lines.append("-" * 60)
                for cons in cons_section["items"]:
                    lines.append(f"- {cons}")
                lines.append("")

        # Section ARIA
        if "aria" in report["sections"]:
            aria_section = report["sections"]["aria"]
            lines.append(aria_section["title"])
            lines.append("-" * 60)

            # Timeline douleur
            if "pain_timeline" in aria_section:
                pain = aria_section["pain_timeline"]
                lines.append("TIMELINE DOULEUR")
                if pain.get("total_entries", 0) > 0:
                    lines.append(
                        f"- Intensité moyenne : {pain.get('average_intensity', 'N/A')}/10"
                    )
                    if pain.get("peak_pain"):
                        peak = pain["peak_pain"]
                        peak_date = peak.get("date", "")
                        if peak_date:
                            try:
                                date_obj = datetime.fromisoformat(
                                    peak_date.replace("Z", "+00:00")
                                )
                                date_str = date_obj.strftime("%d/%m/%Y, %H:%M")
                            except (ValueError, AttributeError):
                                date_str = peak_date
                        else:
                            date_str = "Date inconnue"
                        lines.append(
                            f"- Pic douleur : {peak.get('intensity', 'N/A')}/10 ({date_str})"
                        )
                    if pain.get("most_common_location"):
                        lines.append(
                            f"- Localisation principale : {pain['most_common_location']} "
                            f"({pain.get('location_percentage', 0):.0f}% des entrées)"
                        )
                    if pain.get("most_common_triggers"):
                        lines.append("- Déclencheurs fréquents :")
                        for trigger_info in pain["most_common_triggers"]:
                            lines.append(
                                f"  • {trigger_info['trigger']} ({trigger_info['percentage']:.0f}%)"
                            )
                else:
                    lines.append("Aucune donnée douleur disponible")
                lines.append("")

            # Patterns détectés
            if "patterns" in aria_section and aria_section["patterns"]:
                patterns = aria_section["patterns"]
                lines.append("PATTERNS DÉTECTÉS")
                # Formater les patterns selon leur structure
                if isinstance(patterns, dict):
                    for key, value in patterns.items():
                        if isinstance(value, dict):
                            desc = value.get("description", value.get("pattern", ""))
                            corr = value.get("correlation", value.get("strength", ""))
                            if desc:
                                lines.append(f"- {desc}")
                                if corr:
                                    lines.append(f"  (corrélation: {corr})")
                        else:
                            lines.append(f"- {key}: {value}")
                lines.append("")

            # Métriques santé
            if "health_metrics" in aria_section and aria_section["health_metrics"]:
                metrics = aria_section["health_metrics"]
                lines.append("MÉTRIQUES SANTÉ")
                if isinstance(metrics, dict):
                    if "sleep" in metrics:
                        sleep = metrics["sleep"]
                        avg = sleep.get("avg_30d", sleep.get("average", ""))
                        target = sleep.get("target", "")
                        trend = sleep.get("trend", "")
                        lines.append(f"- Sommeil moyen : {avg}h/jour")
                        if target:
                            lines.append(f"  (objectif : {target}h)")
                        if trend:
                            lines.append(f"  (tendance : {trend})")
                    if "stress" in metrics:
                        stress = metrics["stress"]
                        avg = stress.get("avg_30d", stress.get("average", ""))
                        trend = stress.get("trend", "")
                        lines.append(f"- Niveau stress : {avg}/10")
                        if trend:
                            lines.append(f"  (tendance : {trend})")
                    if "activity" in metrics:
                        activity = metrics["activity"]
                        avg = activity.get("avg_30d", activity.get("average", ""))
                        trend = activity.get("trend", "")
                        unit = activity.get("unit", "")
                        lines.append(f"- Activité physique : {avg} {unit}")
                        if trend:
                            lines.append(f"  (tendance : {trend})")
                lines.append("")

        # Pied de page
        lines.append("=" * 60)
        lines.append(f"Rapport généré le {datetime.now().strftime('%d/%m/%Y à %H:%M')}")
        lines.append("Arkalia CIA - Assistant Santé Personnel")

        return "\n".join(lines)

    def export_report_to_text(self, report: dict[str, Any]) -> str:
        """Exporte le rapport en texte brut"""
        formatted_text = report.get("formatted_text", "")
        return str(formatted_text) if formatted_text else ""

    def export_report_to_pdf(
        self, report: dict[str, Any], output_path: str | None = None
    ) -> str:
        """Exporte le rapport en PDF (gratuit avec reportlab)"""
        try:
            from reportlab.lib.pagesizes import letter
            from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
            from reportlab.lib.units import inch
            from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer

            # Créer le document PDF
            if output_path is None:
                import tempfile

                output_path = tempfile.mktemp(suffix=".pdf")

            doc = SimpleDocTemplate(output_path, pagesize=letter)
            story = []
            styles = getSampleStyleSheet()

            # Style titre
            title_style = ParagraphStyle(
                "CustomTitle",
                parent=styles["Heading1"],
                fontSize=16,
                textColor="black",
                spaceAfter=12,
            )

            # Style sous-titre
            subtitle_style = ParagraphStyle(
                "CustomSubtitle",
                parent=styles["Heading2"],
                fontSize=14,
                textColor="black",
                spaceAfter=8,
            )

            # En-tête
            consultation_date = datetime.fromisoformat(
                report["report_date"].replace("Z", "+00:00")
            )
            story.append(
                Paragraph(
                    f"RAPPORT MÉDICAL - Consultation du {consultation_date.strftime('%d/%m/%Y')}",
                    title_style,
                )
            )
            story.append(Spacer(1, 0.2 * inch))

            # Section Documents
            if "documents" in report["sections"]:
                docs_section = report["sections"]["documents"]
                story.append(Paragraph(docs_section["title"], subtitle_style))
                if docs_section["items"]:
                    for doc in docs_section["items"]:
                        doc_date = doc.get("date", "")
                        if doc_date:
                            try:
                                date_obj = datetime.fromisoformat(
                                    doc_date.replace("Z", "+00:00")
                                )
                                date_str = date_obj.strftime("%d/%m/%Y")
                            except (ValueError, AttributeError):
                                date_str = doc_date
                        else:
                            date_str = "Date inconnue"
                        story.append(
                            Paragraph(
                                f"• {doc.get('name', 'Document')} ({doc.get('type', 'Document')}) - {date_str}",
                                styles["Normal"],
                            )
                        )
                else:
                    story.append(Paragraph("Aucun document récent", styles["Normal"]))
                story.append(Spacer(1, 0.1 * inch))

            # Section Consultations
            if "consultations" in report["sections"]:
                cons_section = report["sections"]["consultations"]
                if cons_section["items"]:
                    story.append(Paragraph(cons_section["title"], subtitle_style))
                    for cons in cons_section["items"]:
                        story.append(Paragraph(f"• {cons}", styles["Normal"]))
                    story.append(Spacer(1, 0.1 * inch))

            # Section ARIA
            if "aria" in report["sections"]:
                aria_section = report["sections"]["aria"]
                story.append(Paragraph(aria_section["title"], subtitle_style))

                # Timeline douleur
                if "pain_timeline" in aria_section:
                    pain = aria_section["pain_timeline"]
                    story.append(Paragraph("Timeline Douleur", styles["Heading3"]))
                    if pain.get("total_entries", 0) > 0:
                        story.append(
                            Paragraph(
                                f"Intensité moyenne : {pain.get('average_intensity', 'N/A')}/10",
                                styles["Normal"],
                            )
                        )
                        if pain.get("peak_pain"):
                            peak = pain["peak_pain"]
                            peak_date = peak.get("date", "")
                            if peak_date:
                                try:
                                    date_obj = datetime.fromisoformat(
                                        peak_date.replace("Z", "+00:00")
                                    )
                                    date_str = date_obj.strftime("%d/%m/%Y, %H:%M")
                                except (ValueError, AttributeError):
                                    date_str = peak_date
                            else:
                                date_str = "Date inconnue"
                            story.append(
                                Paragraph(
                                    f"Pic douleur : {peak.get('intensity', 'N/A')}/10 ({date_str})",
                                    styles["Normal"],
                                )
                            )
                    else:
                        story.append(
                            Paragraph(
                                "Aucune donnée douleur disponible", styles["Normal"]
                            )
                        )
                    story.append(Spacer(1, 0.1 * inch))

                # Patterns détectés
                if "patterns" in aria_section and aria_section["patterns"]:
                    patterns = aria_section["patterns"]
                    story.append(Paragraph("Patterns Détectés", styles["Heading3"]))
                    if isinstance(patterns, dict):
                        for key, value in patterns.items():
                            if isinstance(value, dict):
                                desc = value.get(
                                    "description", value.get("pattern", "")
                                )
                                if desc:
                                    story.append(
                                        Paragraph(f"• {desc}", styles["Normal"])
                                    )
                            else:
                                story.append(
                                    Paragraph(f"• {key}: {value}", styles["Normal"])
                                )
                    story.append(Spacer(1, 0.1 * inch))

            # Pied de page
            story.append(Spacer(1, 0.2 * inch))
            story.append(
                Paragraph(
                    f"Rapport généré le {datetime.now().strftime('%d/%m/%Y à %H:%M')}",
                    styles["Normal"],
                )
            )
            story.append(
                Paragraph("Arkalia CIA - Assistant Santé Personnel", styles["Normal"])
            )

            # Générer le PDF
            doc.build(story)
            logger.info(f"Rapport PDF généré : {output_path}")
            return output_path

        except ImportError as e:
            logger.error("reportlab non disponible pour export PDF")
            raise RuntimeError("Export PDF non disponible (reportlab requis)") from e
        except Exception as e:
            logger.error(f"Erreur génération PDF : {e}")
            raise
