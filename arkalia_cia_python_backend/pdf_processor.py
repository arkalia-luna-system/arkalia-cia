"""
PDF Processor pour Arkalia CIA
Adapté du auto_documenter.py d'Athalia
"""

import logging
import os  # nosec B404
import shutil
from datetime import datetime
from pathlib import Path
from typing import Any

from pypdf import PdfReader

from arkalia_cia_python_backend.pdf_parser.ocr_integration import (
    OCR_AVAILABLE,
    OCRIntegration,
)
from arkalia_cia_python_backend.security_utils import (
    sanitize_error_detail,
    sanitize_log_message,
)

logger = logging.getLogger(__name__)

# Limites de sécurité
MAX_PDF_SIZE = 50 * 1024 * 1024  # 50 MB
MAX_PDF_PAGES = 1000  # Limite raisonnable pour éviter les DoS


class PDFProcessor:
    """Processeur de fichiers PDF pour Arkalia CIA"""

    def __init__(self, upload_dir: str = "uploads"):
        self.upload_dir = Path(upload_dir)
        self.upload_dir.mkdir(exist_ok=True)
        # Initialiser OCR si disponible
        self.ocr: OCRIntegration | None = None
        if OCR_AVAILABLE:
            try:
                self.ocr = OCRIntegration()
            except Exception as e:
                logger.warning(f"OCR non initialisé: {e}")
                self.ocr = None

    def generate_filename(self, original_name: str) -> str:
        """Génère un nom de fichier unique"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        name, ext = os.path.splitext(original_name)
        return f"{name}_{timestamp}{ext}"

    def extract_text_from_pdf(self, file_path: str, use_ocr: bool = False) -> str:
        """Extrait le texte d'un PDF, avec OCR si nécessaire"""
        try:
            # D'abord essayer extraction texte normale
            with open(file_path, "rb") as file:
                reader = PdfReader(file)
                text_parts = []
                # Traiter page par page pour éviter de charger tout en mémoire
                for i, page in enumerate(reader.pages):
                    page_text = page.extract_text()
                    text_parts.append(page_text)
                    # Libérer la référence de la page après extraction
                    if i % 10 == 0:  # Nettoyer périodiquement
                        import gc

                        gc.collect()

                result = "".join(text_parts)
                del text_parts

            # Si peu de texte et OCR disponible, utiliser OCR
            if len(result.strip()) < 100 and (
                use_ocr
                or (hasattr(self, "ocr") and self.ocr and self.ocr.is_available())
            ):
                if hasattr(self, "ocr") and self.ocr and self.ocr.is_available():
                    logger.info("Utilisation OCR pour PDF scanné")
                    ocr_result = self.ocr.process_scanned_pdf(file_path)
                    text_result = ocr_result.get("text")
                    if text_result:
                        return str(text_result)

            return result
        except Exception as e:
            logger.error(f"Erreur extraction PDF: {e}")
            # Essayer OCR en dernier recours
            if hasattr(self, "ocr") and self.ocr and self.ocr.is_available():
                try:
                    ocr_result = self.ocr.process_scanned_pdf(file_path)
                    text_result = ocr_result.get("text")
                    return (
                        str(text_result)
                        if text_result
                        else f"Erreur lors de l'extraction: {str(e)}"
                    )
                except Exception as ocr_error:
                    # Logger l'erreur OCR secondaire mais continuer
                    # avec résultat partiel
                    logger.warning(
                        f"Erreur OCR secondaire (non bloquante): {ocr_error}",
                        exc_info=False,
                    )
            return f"Erreur lors de l'extraction: {str(e)}"

    def save_pdf_to_uploads(self, file_path: str, filename: str) -> str:
        """Sauvegarde un PDF dans le dossier uploads"""
        try:
            destination = self.upload_dir / filename
            shutil.copy2(file_path, destination)
            return str(destination)
        except Exception as e:
            raise Exception(f"Erreur lors de la sauvegarde: {str(e)}") from e

    def process_pdf(self, file_path: str, original_name: str) -> dict[str, Any]:
        """Traite un fichier PDF et le sauvegarde avec validations de sécurité"""
        try:
            # Vérifier que le fichier existe
            if not os.path.exists(file_path):
                return {"success": False, "error": "Fichier non trouvé"}

            # Vérifier la taille du fichier avant traitement
            file_size = os.path.getsize(file_path)
            if file_size > MAX_PDF_SIZE:
                max_mb = MAX_PDF_SIZE / (1024 * 1024)
                return {
                    "success": False,
                    "error": f"Fichier trop volumineux (max {max_mb:.0f} MB)",
                }

            # Vérifier que c'est bien un fichier (pas un répertoire)
            if not os.path.isfile(file_path):
                return {
                    "success": False,
                    "error": "Le chemin ne pointe pas vers un fichier",
                }

            # Lire le PDF avec validation
            with open(file_path, "rb") as file:
                # Vérifier les premiers bytes pour confirmer que c'est un PDF
                header = file.read(4)
                if header != b"%PDF":
                    return {
                        "success": False,
                        "error": "Le fichier n'est pas un PDF valide",
                    }

                file.seek(0)  # Retourner au début
                pdf_reader = PdfReader(file)

                # Vérifier le nombre de pages (protection DoS)
                num_pages = len(pdf_reader.pages)
                if num_pages > MAX_PDF_PAGES:
                    return {
                        "success": False,
                        "error": f"PDF trop volumineux (max {MAX_PDF_PAGES} pages)",
                    }

                # Extraire les métadonnées avec sanitization
                def sanitize_metadata(value: str | None) -> str:
                    """Nettoie les métadonnées pour éviter les injections"""
                    if not value:
                        return ""
                    # Limiter la longueur et supprimer les caractères dangereux
                    cleaned = str(value)[:200]  # Limiter à 200 caractères
                    # Supprimer les caractères de contrôle
                    cleaned = "".join(
                        c for c in cleaned if ord(c) >= 32 or c in "\n\r\t"
                    )
                    return cleaned

                metadata = {
                    "num_pages": num_pages,
                    "title": sanitize_metadata(
                        pdf_reader.metadata.get("/Title", "")
                        if pdf_reader.metadata
                        else None
                    ),
                    "author": sanitize_metadata(
                        pdf_reader.metadata.get("/Author", "")
                        if pdf_reader.metadata
                        else None
                    ),
                    "subject": sanitize_metadata(
                        pdf_reader.metadata.get("/Subject", "")
                        if pdf_reader.metadata
                        else None
                    ),
                }

                # Extraire le texte de la première page
                first_page_text = ""
                if pdf_reader.pages:
                    first_page = pdf_reader.pages[0]
                    first_page_text = first_page.extract_text()[
                        :500
                    ]  # Limiter à 500 caractères

                # Générer un nom de fichier unique et sécurisé
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                file_extension = Path(original_name).suffix
                # S'assurer que l'extension est .pdf
                if file_extension.lower() != ".pdf":
                    file_extension = ".pdf"
                safe_name = self._sanitize_filename(original_name)
                new_filename = f"{safe_name}_{timestamp}{file_extension}"

                # Valider le chemin de destination (sécurité)
                destination_path = self.upload_dir / new_filename
                # S'assurer que le chemin résolu est bien dans upload_dir
                resolved_dest = destination_path.resolve()
                resolved_upload = self.upload_dir.resolve()
                if (
                    resolved_upload not in resolved_dest.parents
                    and resolved_dest.parent != resolved_upload
                ):
                    return {
                        "success": False,
                        "error": "Chemin de destination invalide",
                    }

                # Copier le fichier vers le dossier d'upload
                shutil.copy2(file_path, destination_path)

                # Calculer la taille du fichier
                file_size = os.path.getsize(destination_path)

                return {
                    "success": True,
                    "filename": new_filename,
                    "original_name": original_name,
                    "file_path": str(destination_path),
                    "file_size": file_size,
                    "metadata": metadata,
                    "preview_text": first_page_text,
                }

        except Exception as e:
            # Logger l'erreur complète mais retourner un message sécurisé
            logger.error(
                sanitize_log_message(f"Erreur traitement PDF: {str(e)}"),
                exc_info=True,
            )
            return {"success": False, "error": sanitize_error_detail(e)}

    def _sanitize_filename(self, filename: str) -> str:
        """Nettoie un nom de fichier pour qu'il soit sûr"""
        # Remplacer les caractères problématiques
        safe_chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_"
        safe_filename = ""

        for char in filename:
            if char in safe_chars:
                safe_filename += char
            elif char == " ":
                safe_filename += "_"
            else:
                safe_filename += ""

        # Limiter la longueur
        if len(safe_filename) > 50:
            safe_filename = safe_filename[:50]

        return safe_filename or "document"

    def get_file_info(self, file_path: str) -> dict[str, Any]:
        """Récupère les informations d'un fichier"""
        try:
            if not os.path.exists(file_path):
                return {"success": False, "error": "Fichier non trouvé"}

            stat = os.stat(file_path)
            return {
                "success": True,
                "file_size": stat.st_size,
                "created_at": datetime.fromtimestamp(stat.st_ctime).isoformat(),
                "modified_at": datetime.fromtimestamp(stat.st_mtime).isoformat(),
            }
        except Exception as e:
            return {"success": False, "error": str(e)}


# NOTE: Instance globale supprimée - utiliser get_pdf_processor() via Depends() dans api.py
