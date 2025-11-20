"""
Dépendances FastAPI pour injection de dépendances
Remplace les instances globales par injection propre
"""

from functools import lru_cache

from arkalia_cia_python_backend.ai.conversational_ai import ConversationalAI
from arkalia_cia_python_backend.ai.pattern_analyzer import AdvancedPatternAnalyzer
from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.pdf_processor import PDFProcessor
from arkalia_cia_python_backend.services.document_service import DocumentService


@lru_cache
def get_database() -> CIADatabase:
    """
    Retourne une instance de CIADatabase
    Utilise lru_cache pour singleton par requête
    """
    return CIADatabase()


@lru_cache
def get_pdf_processor() -> PDFProcessor:
    """
    Retourne une instance de PDFProcessor
    Utilise lru_cache pour singleton par requête
    """
    return PDFProcessor()


@lru_cache
def get_conversational_ai() -> ConversationalAI:
    """
    Retourne une instance de ConversationalAI
    Utilise lru_cache pour singleton par requête
    """
    return ConversationalAI()


@lru_cache
def get_pattern_analyzer() -> AdvancedPatternAnalyzer:
    """
    Retourne une instance de AdvancedPatternAnalyzer
    Utilise lru_cache pour singleton par requête
    """
    return AdvancedPatternAnalyzer()


@lru_cache
def get_document_service() -> DocumentService:
    """
    Retourne une instance de DocumentService
    Utilise lru_cache pour singleton par requête
    """
    return DocumentService(
        db=get_database(),
        pdf_processor=get_pdf_processor(),
    )
