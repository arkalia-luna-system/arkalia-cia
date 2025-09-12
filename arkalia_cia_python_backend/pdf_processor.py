"""
PDF Processor pour Arkalia CIA
Adapté du auto_documenter.py d'Athalia
"""

import os
import shutil
from datetime import datetime
from pathlib import Path
from typing import Any

import PyPDF2


class PDFProcessor:
    """Processeur de fichiers PDF pour Arkalia CIA"""

    def __init__(self, upload_dir: str = "uploads"):
        self.upload_dir = Path(upload_dir)
        self.upload_dir.mkdir(exist_ok=True)

    def generate_filename(self, original_name: str) -> str:
        """Génère un nom de fichier unique"""
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        name, ext = os.path.splitext(original_name)
        return f"{name}_{timestamp}{ext}"

    def extract_text_from_pdf(self, file_path: str) -> str:
        """Extrait le texte d'un PDF"""
        try:
            with open(file_path, "rb") as file:
                reader = PyPDF2.PdfReader(file)
                text = ""
                for page in reader.pages:
                    text += page.extract_text()
                return text
        except Exception as e:
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
        """Traite un fichier PDF et le sauvegarde"""
        try:
            # Vérifier que le fichier existe
            if not os.path.exists(file_path):
                return {"success": False, "error": "Fichier non trouvé"}

            # Lire le PDF
            with open(file_path, "rb") as file:
                pdf_reader = PyPDF2.PdfReader(file)

                # Extraire les métadonnées
                metadata = {
                    "num_pages": len(pdf_reader.pages),
                    "title": (
                        pdf_reader.metadata.get("/Title", "")
                        if pdf_reader.metadata
                        else ""
                    ),
                    "author": (
                        pdf_reader.metadata.get("/Author", "")
                        if pdf_reader.metadata
                        else ""
                    ),
                    "subject": (
                        pdf_reader.metadata.get("/Subject", "")
                        if pdf_reader.metadata
                        else ""
                    ),
                }

                # Extraire le texte de la première page
                first_page_text = ""
                if pdf_reader.pages:
                    first_page = pdf_reader.pages[0]
                    first_page_text = first_page.extract_text()[
                        :500
                    ]  # Limiter à 500 caractères

                # Générer un nom de fichier unique
                timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                file_extension = Path(original_name).suffix
                safe_name = self._sanitize_filename(original_name)
                new_filename = f"{safe_name}_{timestamp}{file_extension}"

                # Copier le fichier vers le dossier d'upload
                destination_path = self.upload_dir / new_filename
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
            return {"success": False, "error": str(e)}

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


# Instance globale
pdf_processor = PDFProcessor()
