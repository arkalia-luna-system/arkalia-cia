"""
Service pour la gestion des documents
Extrait la logique métier des endpoints API
"""

import logging
import os  # nosec B404
import tempfile
from contextlib import contextmanager
from datetime import datetime
from typing import cast

from arkalia_cia_python_backend.app_types import (
    DocumentMetadataDict,
    DocumentResultDict,
)
from arkalia_cia_python_backend.config import get_settings
from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.pdf_parser.metadata_extractor import MetadataExtractor
from arkalia_cia_python_backend.pdf_processor import PDFProcessor
from arkalia_cia_python_backend.security_utils import sanitize_log_message
from arkalia_cia_python_backend.utils.filename_validator import (
    get_filename_validator,
)

logger = logging.getLogger(__name__)


class DocumentService:
    """Service pour la gestion des documents"""

    def __init__(
        self,
        db: CIADatabase,
        pdf_processor: PDFProcessor,
    ):
        self.db = db
        self.pdf_processor = pdf_processor
        self.settings = get_settings()
        self.filename_validator = get_filename_validator()

    def validate_filename(self, filename: str | None) -> str:
        """
        Valide et nettoie un nom de fichier PDF

        Args:
            filename: Nom de fichier à valider

        Returns:
            Nom de fichier PDF sécurisé

        Raises:
            ValueError: Si le nom de fichier est invalide
        """
        return self.filename_validator.validate_pdf(filename)

    @contextmanager
    def _temp_file_context(self, suffix: str = ".pdf"):
        """
        Context manager pour fichiers temporaires avec cleanup garanti

        Args:
            suffix: Suffixe du fichier temporaire

        Yields:
            Chemin du fichier temporaire
        """
        tmp_file_path = None
        try:
            with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as tmp_file:
                tmp_file_path = tmp_file.name
            yield tmp_file_path
        finally:
            # Cleanup garanti même en cas d'exception
            if tmp_file_path and os.path.exists(tmp_file_path):
                try:
                    os.unlink(tmp_file_path)
                except OSError as e:
                    msg = (
                        f"Impossible de supprimer fichier temporaire "
                        f"{tmp_file_path}: {e}"
                    )
                    logger.warning(msg)

    def save_uploaded_file(self, file_content: bytes, filename: str) -> tuple[str, int]:
        """
        Sauvegarde un fichier uploadé dans un fichier temporaire

        Args:
            file_content: Contenu du fichier
            filename: Nom du fichier

        Returns:
            Tuple (chemin fichier temporaire, taille fichier)

        Raises:
            ValueError: Si le fichier est trop volumineux

        Note:
            Le fichier temporaire doit être nettoyé par l'appelant après utilisation
        """
        total_size = len(file_content)
        max_size = self.settings.max_file_size_bytes
        if total_size > max_size:
            max_mb = self.settings.max_file_size_mb
            raise ValueError(f"Le fichier est trop volumineux (max {max_mb} MB)")

        # Créer fichier temporaire (sans context manager car doit persister)
        tmp_file = tempfile.NamedTemporaryFile(delete=False, suffix=".pdf")
        tmp_file_path = tmp_file.name
        try:
            tmp_file.write(file_content)
        finally:
            tmp_file.close()

        return tmp_file_path, total_size

    def process_uploaded_file(
        self, file_content: bytes, original_filename: str
    ) -> DocumentResultDict:
        """
        Traite un fichier uploadé (validation, sauvegarde, extraction)

        Args:
            file_content: Contenu du fichier
            original_filename: Nom original du fichier

        Returns:
            Dictionnaire avec résultat du traitement

        Raises:
            ValueError: Si le traitement échoue
        """
        # Valider le nom de fichier
        safe_filename = self.validate_filename(original_filename)

        # Sauvegarder dans fichier temporaire avec cleanup garanti
        tmp_file_path = None
        try:
            with self._temp_file_context(suffix=".pdf") as tmp_file_path:
                # Écrire le contenu
                with open(tmp_file_path, "wb") as tmp_file:
                    tmp_file.write(file_content)

                # Traiter le PDF
                result = self.pdf_processor.process_pdf(tmp_file_path, safe_filename)

                if not result.get("success", False):
                    error_msg = result.get("error", "Erreur traitement PDF")
                    raise ValueError(error_msg)

                # Convertir en DocumentResultDict (type-safe)
                # process_pdf retourne preview_text, pas text_content
                preview_text = result.get("preview_text", "")
                return cast(
                    DocumentResultDict,
                    {
                        "filename": result["filename"],
                        "original_name": result["original_name"],
                        "file_path": result["file_path"],
                        "file_size": result["file_size"],
                        "text_content": preview_text if preview_text else "",
                    },
                )
        finally:
            # Cleanup fichier temporaire
            if tmp_file_path and os.path.exists(tmp_file_path):
                try:
                    os.unlink(tmp_file_path)
                except OSError as e:
                    logger.warning(
                        f"Impossible de supprimer fichier temporaire "
                        f"{tmp_file_path}: {e}"
                    )

    def extract_metadata(self, file_path: str) -> DocumentMetadataDict | None:
        """
        Extrait les métadonnées d'un fichier PDF

        Args:
            file_path: Chemin vers le fichier PDF

        Returns:
            Métadonnées extraites ou None en cas d'erreur
        """
        try:
            # Extraire texte (avec OCR si nécessaire)
            text_content = self.pdf_processor.extract_text_from_pdf(
                file_path, use_ocr=False
            )

            # Si peu de texte, essayer OCR
            min_length = self.settings.min_text_length_for_ocr
            use_ocr = len(text_content.strip()) < min_length
            if use_ocr:
                text_content = self.pdf_processor.extract_text_from_pdf(
                    file_path, use_ocr=True
                )

            # Extraire métadonnées
            metadata_extractor = MetadataExtractor()
            raw_metadata = metadata_extractor.extract_metadata(text_content)

            # Convertir en DocumentMetadataDict (type-safe)
            # Convertir datetime en string ISO si présent
            doc_date = raw_metadata.get("date")
            document_date_str: str | None = None
            if isinstance(doc_date, datetime):
                document_date_str = doc_date.isoformat()
            elif doc_date is None:
                document_date_str = None

            return cast(
                DocumentMetadataDict,
                {
                    "doctor_name": raw_metadata.get("doctor_name"),
                    "doctor_specialty": raw_metadata.get("doctor_specialty"),
                    "document_date": document_date_str,
                    "exam_type": raw_metadata.get("exam_type"),
                    "document_type": raw_metadata.get("document_type"),
                    "keywords": raw_metadata.get("keywords", []),
                    "extracted_text": raw_metadata.get("extracted_text", ""),
                },
            )
        except (ValueError, FileNotFoundError, OSError) as e:
            logger.warning(
                f"Erreur extraction métadonnées: {sanitize_log_message(str(e))}"
            )
            return None
        except Exception as e:
            msg = (
                f"Erreur inattendue lors de l'extraction métadonnées: "
                f"{sanitize_log_message(str(e))}"
            )
            logger.exception(msg)
            return None

    def save_document_with_metadata(
        self,
        result: DocumentResultDict,
        user_id: int,
        metadata: DocumentMetadataDict | None = None,
    ) -> int:
        """
        Sauvegarde un document en base de données avec métadonnées

        Args:
            result: Résultat du traitement PDF
            user_id: ID de l'utilisateur
            metadata: Métadonnées extraites (optionnel)

        Returns:
            ID du document créé
        """
        # Sauvegarder en base de données
        doc_id = self.db.add_document(
            name=result["filename"],
            original_name=result["original_name"],
            file_path=result["file_path"],
            file_type="pdf",
            file_size=result["file_size"],
        )

        if not doc_id:
            raise ValueError("Erreur lors de la sauvegarde du document")

        # Associer le document à l'utilisateur
        self.db.associate_document_to_user(user_id, doc_id)

        # Sauvegarder métadonnées si disponibles
        if metadata and doc_id:
            self._save_document_metadata(doc_id, metadata)

        return doc_id

    def _save_document_metadata(
        self, doc_id: int, metadata: DocumentMetadataDict
    ) -> None:
        """Sauvegarde les métadonnées d'un document"""
        # document_date est déjà une string ISO dans DocumentMetadataDict
        document_date_str = metadata.get("document_date")
        doctor_name = metadata.get("doctor_name")
        doctor_specialty = metadata.get("doctor_specialty")
        keywords_list = metadata.get("keywords", [])
        extracted_text = metadata.get("extracted_text", "")

        self.db.add_document_metadata(
            document_id=doc_id,
            doctor_name=doctor_name,
            doctor_specialty=doctor_specialty,
            document_date=document_date_str,
            exam_type=metadata.get("exam_type"),
            document_type=metadata.get("document_type"),
            keywords=",".join(keywords_list) if keywords_list else "",
            extracted_text=extracted_text[: self.settings.max_extracted_text_length],
        )
