"""
Analyseur patterns avancé pour données médicales
Améliore l'existant ARIA avec modèles ML plus sophistiqués
"""

import logging
from datetime import datetime, timedelta
from typing import Any

try:
    import pandas as pd
    from prophet import Prophet

    PROPHET_AVAILABLE = True
except ImportError:
    PROPHET_AVAILABLE = False

logger = logging.getLogger(__name__)


class AdvancedPatternAnalyzer:
    """Analyseur patterns avancé"""

    def detect_temporal_patterns(self, data: list[dict]) -> dict[str, Any]:
        """
        Détecte patterns temporels dans données

        Args:
            data: Liste de dicts avec ['date', 'value', 'type']

        Returns:
            {
                'recurring_patterns': List[Dict],  # Patterns récurrents
                'trends': Dict,                     # Tendances
                'seasonality': Dict                 # Saisonnalité
            }
        """
        try:
            # Analyser récurrence
            recurring = self._detect_recurrence(data)

            # Analyser tendances
            trends = self._detect_trends(data)

            # Analyser saisonnalité
            seasonality = self._detect_seasonality(data)

            # Prédictions avec Prophet si disponible
            predictions = {}
            if PROPHET_AVAILABLE and len(data) >= 7:  # Minimum 7 points pour Prophet
                try:
                    predictions = self._generate_prophet_predictions(data)
                except Exception as e:
                    logger.warning(f"Erreur prédictions Prophet: {e}")
                    predictions = {}

            return {
                "recurring_patterns": recurring,
                "trends": trends,
                "seasonality": seasonality,
                "predictions": predictions,
            }
        except Exception as e:
            logger.error(f"Erreur détection patterns: {e}")
            return {}

    def _detect_recurrence(self, data: list[dict]) -> list[dict]:
        """Détecte patterns récurrents"""
        patterns = []

        # Grouper par type et analyser fréquence
        types: dict[str, list] = {}
        for item in data:
            item_type = item.get("type", "unknown")
            if item_type not in types:
                types[item_type] = []
            types[item_type].append(item)

        for exam_type, type_data in types.items():
            if len(type_data) < 3:
                continue

            # Trier par date
            type_data.sort(key=lambda x: x.get("date", ""))

            # Calculer intervalles entre occurrences
            intervals = []
            for i in range(1, len(type_data)):
                date1 = datetime.fromisoformat(type_data[i - 1].get("date", ""))
                date2 = datetime.fromisoformat(type_data[i].get("date", ""))
                intervals.append((date2 - date1).days)

            if intervals:
                # Optimisé: calculer moyenne et écart-type en une seule passe
                # pour réduire les itérations
                avg_interval = sum(intervals) / len(intervals)
                # Utiliser sum avec générateur pour économiser la mémoire
                variance = sum((x - avg_interval) ** 2 for x in intervals) / len(
                    intervals
                )
                std_interval = variance**0.5

                # Pattern récurrent si écart-type faible
                if std_interval < avg_interval * 0.3:
                    patterns.append(
                        {
                            "type": exam_type,
                            "frequency_days": int(avg_interval),
                            "confidence": (
                                max(0.0, 1.0 - (std_interval / avg_interval))
                                if avg_interval > 0
                                else 0.0
                            ),
                        }
                    )

        return patterns

    def _detect_trends(self, data: list[dict]) -> dict:
        """Détecte tendances"""
        trends = {}

        # Analyser évolution valeurs numériques
        numeric_data = [
            d for d in data if "value" in d and isinstance(d.get("value"), int | float)
        ]

        if len(numeric_data) > 1:
            # Trier par date
            numeric_data.sort(key=lambda x: x.get("date", ""))
            values = [d["value"] for d in numeric_data]

            # Calculer pente (tendance)
            n = len(values)
            x_mean = (n - 1) / 2
            y_mean = sum(values) / n

            numerator = sum((i - x_mean) * (values[i] - y_mean) for i in range(n))
            denominator = sum((i - x_mean) ** 2 for i in range(n))

            slope = numerator / denominator if denominator > 0 else 0

            trends["slope"] = slope
            trends["direction"] = (
                "increasing"
                if slope > 0.1
                else "decreasing" if slope < -0.1 else "stable"
            )

            # Force de la tendance
            if values:
                value_std = (
                    sum((v - y_mean) ** 2 for v in values) / len(values)
                ) ** 0.5
                trends["strength"] = (
                    abs(slope) / (value_std + 1e-6) if value_std > 0 else 0.0
                )

        return trends

    def _detect_seasonality(self, data: list[dict]) -> dict:
        """Détecte saisonnalité"""
        seasonality = {}

        # Compter occurrences par mois
        monthly_counts: dict[str, int] = {}
        for item in data:
            if "date" in item:
                try:
                    date = datetime.fromisoformat(item["date"])
                    month_str = str(date.month)
                    monthly_counts[month_str] = monthly_counts.get(month_str, 0) + 1
                except Exception:
                    # Ignorer les dates invalides et continuer avec les suivantes
                    continue  # nosec B112

        if monthly_counts:
            # Identifier mois avec plus d'occurrences
            max_month = max(monthly_counts.items(), key=lambda x: x[1])[0]
            seasonality["peak_month"] = int(max_month)
            seasonality["peak_count"] = int(monthly_counts[max_month])

        return seasonality

    def _generate_prophet_predictions(
        self, data: list[dict], periods: int = 30
    ) -> dict[str, Any]:
        """Génère des prédictions avec Prophet pour les 30 prochains jours"""
        if not PROPHET_AVAILABLE:
            return {}

        try:
            # Préparer données pour Prophet (format: ds=date, y=value)
            df_data = []
            for item in data:
                if "date" in item and "value" in item:
                    try:
                        date = datetime.fromisoformat(item["date"])
                        value = float(item["value"])
                        df_data.append({"ds": date, "y": value})
                    except (ValueError, TypeError):
                        continue

            if len(df_data) < 7:  # Prophet nécessite au moins 7 points
                return {}

            df = pd.DataFrame(df_data)
            df = df.sort_values("ds")

            # Créer et entraîner modèle Prophet
            model = Prophet(
                yearly_seasonality=True,
                weekly_seasonality=True,
                daily_seasonality=False,
            )
            model.fit(df)

            # Générer prédictions pour les prochains jours
            future = model.make_future_dataframe(periods=periods)
            forecast = model.predict(future)

            # Extraire prédictions futures seulement
            last_date = df["ds"].max()
            future_forecast = forecast[forecast["ds"] > last_date]

            # Formater résultats
            predictions_list = []
            for _, row in future_forecast.iterrows():
                predictions_list.append(
                    {
                        "date": row["ds"].isoformat(),
                        "predicted_value": float(row["yhat"]),
                        "lower_bound": float(row["yhat_lower"]),
                        "upper_bound": float(row["yhat_upper"]),
                    }
                )

            return {
                "periods": periods,
                "predictions": predictions_list[:periods],  # Limiter à periods
                "trend": {
                    "direction": (
                        "increasing"
                        if forecast["trend"].iloc[-1] > forecast["trend"].iloc[0]
                        else "decreasing"
                    ),
                    "strength": abs(
                        forecast["trend"].iloc[-1] - forecast["trend"].iloc[0]
                    ),
                },
            }
        except Exception as e:
            logger.error(f"Erreur génération prédictions Prophet: {e}")
            return {}

    def predict_future_events(
        self, data: list[dict], event_type: str = "document", days_ahead: int = 30
    ) -> dict[str, Any]:
        """
        Prédit les événements futurs basés sur les patterns historiques

        Args:
            data: Liste de dicts avec ['date', 'value', 'type']
            event_type: Type d'événement à prédire ('document', 'consultation', 'exam')
            days_ahead: Nombre de jours à prédire

        Returns:
            {
                'predicted_dates': List[str],  # Dates prédites
                'confidence': float,          # Confiance globale
                'pattern_based': bool          # Si basé sur pattern récurrent
            }
        """
        try:
            # Filtrer par type d'événement
            filtered_data = [d for d in data if d.get("type") == event_type]

            if len(filtered_data) < 3:
                return {
                    "predicted_dates": [],
                    "confidence": 0.0,
                    "pattern_based": False,
                }

            # Détecter pattern récurrent
            recurring = self._detect_recurrence(filtered_data)

            predicted_dates = []
            confidence = 0.0

            if recurring:
                # Utiliser pattern récurrent pour prédire
                pattern = recurring[0]
                frequency_days = pattern.get("frequency_days", 0)
                pattern_confidence = pattern.get("confidence", 0.0)

                if frequency_days > 0:
                    # Trier par date
                    filtered_data.sort(key=lambda x: x.get("date", ""))
                    last_date = datetime.fromisoformat(
                        filtered_data[-1].get("date", "")
                    )

                    # Prédire prochaines occurrences
                    for i in range(1, min(5, days_ahead // frequency_days + 1)):
                        predicted_date = last_date + timedelta(days=frequency_days * i)
                        if predicted_date <= datetime.now() + timedelta(
                            days=days_ahead
                        ):
                            predicted_dates.append(predicted_date.isoformat())

                    confidence = pattern_confidence
                    pattern_based = True
                else:
                    pattern_based = False
            else:
                # Utiliser Prophet pour prédire si assez de données
                if PROPHET_AVAILABLE and len(filtered_data) >= 7:
                    try:
                        predictions = self._generate_prophet_predictions(
                            filtered_data, periods=days_ahead
                        )
                        if predictions.get("predictions"):
                            # Extraire dates où valeur prédite > seuil
                            threshold = sum(
                                d.get("value", 0) for d in filtered_data
                            ) / len(filtered_data)

                            for pred in predictions["predictions"]:
                                if pred.get("predicted_value", 0) > threshold * 0.8:
                                    predicted_dates.append(pred.get("date", ""))

                            confidence = 0.6  # Confiance modérée pour Prophet
                            pattern_based = False
                        else:
                            pattern_based = False
                    except Exception:
                        pattern_based = False
                else:
                    pattern_based = False

            return {
                "predicted_dates": predicted_dates[:10],  # Limiter à 10 dates
                "confidence": min(1.0, confidence),
                "pattern_based": pattern_based,
            }
        except Exception as e:
            logger.error(f"Erreur prédiction événements futurs: {e}")
            return {
                "predicted_dates": [],
                "confidence": 0.0,
                "pattern_based": False,
            }
