"""
Tests pour le validateur de noms de fichiers
"""

import pytest

from arkalia_cia_python_backend.utils.filename_validator import (
    FilenameValidator,
    get_filename_validator,
)


class TestFilenameValidator:
    """Tests pour FilenameValidator"""

    def test_valid_filenames(self):
        """Test noms de fichiers valides"""
        validator = FilenameValidator()
        assert validator.validate("document.pdf") == "document.pdf"
        assert validator.validate("test_file_123.pdf") == "test_file_123.pdf"
        assert validator.validate("document-2024.pdf") == "document-2024.pdf"
        assert validator.validate("file_name.pdf") == "file_name.pdf"

    def test_invalid_characters(self):
        """Test caractères invalides"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="caractères non autorisés"):
            validator.validate("file/name.pdf")
        with pytest.raises(ValueError, match="caractères non autorisés"):
            validator.validate("file\\name.pdf")
        with pytest.raises(ValueError, match="caractères non autorisés"):
            validator.validate("file:name.pdf")

    def test_path_traversal(self):
        """Test protection path traversal"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="chemins relatifs interdits"):
            validator.validate("../etc/passwd")
        with pytest.raises(ValueError, match="chemins relatifs interdits"):
            validator.validate("../../secret.pdf")
        with pytest.raises(ValueError, match="chemins relatifs interdits"):
            validator.validate("./file.pdf")

    def test_reserved_names_windows(self):
        """Test noms réservés Windows"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="réservé"):
            validator.validate("CON.pdf")
        with pytest.raises(ValueError, match="réservé"):
            validator.validate("PRN.pdf")
        with pytest.raises(ValueError, match="réservé"):
            validator.validate("AUX.pdf")
        with pytest.raises(ValueError, match="réservé"):
            validator.validate("NUL.pdf")

    def test_length_limit(self):
        """Test limite de longueur"""
        validator = FilenameValidator()
        # Créer un nom trop long (256 caractères)
        long_name = "a" * 256 + ".pdf"
        with pytest.raises(ValueError, match="trop long"):
            validator.validate(long_name)

    def test_empty_filename(self):
        """Test nom de fichier vide"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="requis"):
            validator.validate("")
        with pytest.raises(ValueError, match="requis"):
            validator.validate(None)  # type: ignore[arg-type]

    def test_invalid_type(self):
        """Test type invalide"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="chaîne"):
            validator.validate(123)  # type: ignore
        with pytest.raises(ValueError, match="chaîne"):
            validator.validate([])  # type: ignore

    def test_ending_with_space_or_dot(self):
        """Test nom se terminant par espace ou point"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="espace ou un point"):
            validator.validate("file .pdf")
        with pytest.raises(ValueError, match="espace ou un point"):
            validator.validate("file..pdf")

    def test_validate_pdf_valid(self):
        """Test validation PDF valide"""
        validator = FilenameValidator()
        assert validator.validate_pdf("document.pdf") == "document.pdf"
        assert validator.validate_pdf("FILE.PDF") == "FILE.PDF"  # Case insensitive

    def test_validate_pdf_invalid_extension(self):
        """Test validation PDF avec extension invalide"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="PDF sont acceptés"):
            validator.validate_pdf("document.txt")
        with pytest.raises(ValueError, match="PDF sont acceptés"):
            validator.validate_pdf("document")

    def test_validate_pdf_with_path_traversal(self):
        """Test validation PDF avec path traversal"""
        validator = FilenameValidator()
        with pytest.raises(ValueError, match="chemins relatifs interdits"):
            validator.validate_pdf("../document.pdf")


class TestGetFilenameValidator:
    """Tests pour la fonction get_filename_validator"""

    def test_singleton_pattern(self):
        """Test que get_filename_validator retourne la même instance"""
        import arkalia_cia_python_backend.utils.filename_validator as validator_module

        validator_module._validator = None
        validator1 = get_filename_validator()
        validator2 = get_filename_validator()
        assert validator1 is validator2
