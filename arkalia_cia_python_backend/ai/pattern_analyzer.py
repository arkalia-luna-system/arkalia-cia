"""
Analyseur patterns avancé pour données médicales
Améliore l'existant ARIA avec modèles ML plus sophistiqués
"""
from typing import Dict, List, Optional
from datetime import datetime, timedelta
import logging

logger = logging.getLogger(__name__)


class AdvancedPatternAnalyzer:
    """Analyseur patterns avancé"""
    
    def detect_temporal_patterns(self, data: List[Dict]) -> Dict[str, any]:
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
            
            return {
                'recurring_patterns': recurring,
                'trends': trends,
                'seasonality': seasonality
            }
        except Exception as e:
            logger.error(f"Erreur détection patterns: {e}")
            return {}
    
    def _detect_recurrence(self, data: List[Dict]) -> List[Dict]:
        """Détecte patterns récurrents"""
        patterns = []
        
        # Grouper par type et analyser fréquence
        types = {}
        for item in data:
            item_type = item.get('type', 'unknown')
            if item_type not in types:
                types[item_type] = []
            types[item_type].append(item)
        
        for exam_type, type_data in types.items():
            if len(type_data) < 3:
                continue
            
            # Trier par date
            type_data.sort(key=lambda x: x.get('date', ''))
            
            # Calculer intervalles entre occurrences
            intervals = []
            for i in range(1, len(type_data)):
                date1 = datetime.fromisoformat(type_data[i-1].get('date', ''))
                date2 = datetime.fromisoformat(type_data[i].get('date', ''))
                intervals.append((date2 - date1).days)
            
            if intervals:
                avg_interval = sum(intervals) / len(intervals)
                std_interval = (sum((x - avg_interval) ** 2 for x in intervals) / len(intervals)) ** 0.5
                
                # Pattern récurrent si écart-type faible
                if std_interval < avg_interval * 0.3:
                    patterns.append({
                        'type': exam_type,
                        'frequency_days': int(avg_interval),
                        'confidence': max(0.0, 1.0 - (std_interval / avg_interval)) if avg_interval > 0 else 0.0
                    })
        
        return patterns
    
    def _detect_trends(self, data: List[Dict]) -> Dict:
        """Détecte tendances"""
        trends = {}
        
        # Analyser évolution valeurs numériques
        numeric_data = [d for d in data if 'value' in d and isinstance(d.get('value'), (int, float))]
        
        if len(numeric_data) > 1:
            # Trier par date
            numeric_data.sort(key=lambda x: x.get('date', ''))
            values = [d['value'] for d in numeric_data]
            
            # Calculer pente (tendance)
            n = len(values)
            x_mean = (n - 1) / 2
            y_mean = sum(values) / n
            
            numerator = sum((i - x_mean) * (values[i] - y_mean) for i in range(n))
            denominator = sum((i - x_mean) ** 2 for i in range(n))
            
            slope = numerator / denominator if denominator > 0 else 0
            
            trends['slope'] = float(slope)
            trends['direction'] = 'increasing' if slope > 0.1 else 'decreasing' if slope < -0.1 else 'stable'
            
            # Force de la tendance
            if values:
                value_std = (sum((v - y_mean) ** 2 for v in values) / len(values)) ** 0.5
                trends['strength'] = abs(slope) / (value_std + 1e-6) if value_std > 0 else 0.0
        
        return trends
    
    def _detect_seasonality(self, data: List[Dict]) -> Dict:
        """Détecte saisonnalité"""
        seasonality = {}
        
        # Compter occurrences par mois
        monthly_counts = {}
        for item in data:
            if 'date' in item:
                try:
                    date = datetime.fromisoformat(item['date'])
                    month = date.month
                    monthly_counts[month] = monthly_counts.get(month, 0) + 1
                except:
                    continue
        
        if monthly_counts:
            # Identifier mois avec plus d'occurrences
            max_month = max(monthly_counts.items(), key=lambda x: x[1])[0]
            seasonality['peak_month'] = int(max_month)
            seasonality['peak_count'] = int(monthly_counts[max_month])
        
        return seasonality

