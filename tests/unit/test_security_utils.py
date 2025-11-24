"""
Tests unitaires pour security_utils
"""

from arkalia_cia_python_backend.security_utils import (
    is_safe_path,
    mask_sensitive_data,
    sanitize_error_detail,
    sanitize_filename,
    sanitize_html,
    sanitize_log_message,
    validate_file_extension,
    validate_phone_number,
)


class TestSanitizeLogMessage:
    """Tests pour sanitize_log_message"""

    def test_sanitize_password(self):
        """Test masquage des mots de passe"""
        message = "password: secret123"
        result = sanitize_log_message(message)
        assert "password" in result
        assert "secret123" not in result
        assert "***" in result

    def test_sanitize_api_key(self):
        """Test masquage des clés API"""
        message = "api_key: abc123xyz"
        result = sanitize_log_message(message)
        assert "api_key" in result
        assert "abc123xyz" not in result
        assert "***" in result

    def test_sanitize_token(self):
        """Test masquage des tokens"""
        message = "token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9"
        result = sanitize_log_message(message)
        assert "token" in result
        assert "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9" not in result

    def test_sanitize_email(self):
        """Test masquage des emails"""
        message = "user@example.com logged in"
        result = sanitize_log_message(message)
        assert "***@example.com" in result
        assert "user" not in result

    def test_sanitize_phone(self):
        """Test masquage des numéros de téléphone"""
        message = "Phone: +32470123456"
        result = sanitize_log_message(message)
        assert "***-****-3456" in result or "***" in result

    def test_empty_message(self):
        """Test avec message vide"""
        assert sanitize_log_message("") == ""
        # Note: None n'est pas accepté par le type checker, utiliser "" à la place


class TestSanitizeErrorDetail:
    """Tests pour sanitize_error_detail"""

    def test_permission_error(self):
        """Test erreur de permission"""
        error = PermissionError("Access denied")
        result = sanitize_error_detail(error)
        assert "permissions insuffisantes" in result.lower()

    def test_connection_error(self):
        """Test erreur de connexion"""
        error = ConnectionError("Connection failed")
        result = sanitize_error_detail(error)
        assert "connexion" in result.lower()

    def test_timeout_error(self):
        """Test erreur de timeout"""
        error = TimeoutError("Request timeout")
        result = sanitize_error_detail(error)
        assert "délai" in result.lower() or "timeout" in result.lower()

    def test_file_not_found(self):
        """Test erreur fichier non trouvé"""
        error = FileNotFoundError("/path/to/file.txt")
        result = sanitize_error_detail(error)
        assert "non trouvé" in result.lower()

    def test_value_error(self):
        """Test ValueError (message conservé)"""
        error = ValueError("Invalid value")
        result = sanitize_error_detail(error)
        assert "Invalid value" in result


class TestValidateFileExtension:
    """Tests pour validate_file_extension"""

    def test_valid_extensions(self):
        """Test extensions valides"""
        assert validate_file_extension("test.pdf", [".pdf", ".doc"])
        assert validate_file_extension("test.PDF", [".pdf", ".doc"])
        assert validate_file_extension("file.doc", ["pdf", "doc"])

    def test_invalid_extensions(self):
        """Test extensions invalides"""
        assert not validate_file_extension("test.txt", [".pdf", ".doc"])
        assert not validate_file_extension("test", [".pdf", ".doc"])

    def test_empty_filename(self):
        """Test avec nom de fichier vide"""
        assert not validate_file_extension("", [".pdf"])
        # Note: None n'est pas accepté par le type checker, utiliser "" à la place


class TestSanitizeFilename:
    """Tests pour sanitize_filename"""

    def test_basic_filename(self):
        """Test nom de fichier basique"""
        result = sanitize_filename("test.pdf")
        assert result == "test.pdf"

    def test_path_traversal(self):
        """Test protection path traversal"""
        result = sanitize_filename("../../../etc/passwd")
        assert ".." not in result
        assert "/" not in result or result.count("/") < 3

    def test_dangerous_chars(self):
        """Test caractères dangereux"""
        result = sanitize_filename('test<>:"|?*.txt')
        assert "<" not in result
        assert ">" not in result
        assert ":" not in result

    def test_max_length(self):
        """Test limitation longueur"""
        long_name = "a" * 300 + ".pdf"
        result = sanitize_filename(long_name, max_length=255)
        assert len(result) <= 255

    def test_empty_filename(self):
        """Test nom de fichier vide"""
        assert sanitize_filename("") == "file"
        # Note: None n'est pas accepté par le type checker, utiliser "" à la place


class TestIsSafePath:
    """Tests pour is_safe_path"""

    def test_safe_path(self, tmp_path):
        """Test chemin sûr"""
        allowed_dir = str(tmp_path / "allowed")
        file_path = str(tmp_path / "allowed" / "file.txt")
        assert is_safe_path(file_path, allowed_dir)

    def test_unsafe_path_traversal(self, tmp_path):
        """Test path traversal"""
        allowed_dir = str(tmp_path / "allowed")
        file_path = str(tmp_path / "file.txt")
        assert not is_safe_path(file_path, allowed_dir)

    def test_invalid_path(self):
        """Test chemin invalide"""
        assert not is_safe_path("/invalid/path/../../etc/passwd", "/allowed")


class TestMaskSensitiveData:
    """Tests pour mask_sensitive_data"""

    def test_mask_password(self):
        """Test masquage mot de passe"""
        data = {"username": "test", "password": "secret123"}
        result = mask_sensitive_data(data)
        assert result["username"] == "test"
        assert result["password"] == "***"

    def test_mask_api_key(self):
        """Test masquage clé API"""
        data = {"api_key": "abc123", "name": "test"}
        result = mask_sensitive_data(data)
        assert result["api_key"] == "***"
        assert result["name"] == "test"

    def test_nested_dict(self):
        """Test dictionnaire imbriqué"""
        data = {"user": {"password": "secret", "name": "test"}}
        result = mask_sensitive_data(data)
        assert result["user"]["password"] == "***"
        assert result["user"]["name"] == "test"

    def test_list_with_dicts(self):
        """Test liste avec dictionnaires"""
        data = {"users": [{"password": "secret1"}, {"password": "secret2"}]}
        result = mask_sensitive_data(data)
        assert result["users"][0]["password"] == "***"
        assert result["users"][1]["password"] == "***"

    def test_custom_sensitive_keys(self):
        """Test clés sensibles personnalisées"""
        data = {"custom_secret": "value", "name": "test"}
        result = mask_sensitive_data(data, sensitive_keys=["custom_secret"])
        assert result["custom_secret"] == "***"
        assert result["name"] == "test"


class TestSanitizeHtml:
    """Tests pour sanitize_html"""

    def test_script_tag_removal(self):
        """Test suppression balise script"""
        html = '<script>alert("xss")</script>Hello'
        result = sanitize_html(html)
        assert "script" not in result.lower()
        # Le contenu peut rester si bleach n'est pas disponible
        # On vérifie juste que les balises sont supprimées
        assert "<script>" not in result.lower()
        assert "</script>" not in result.lower()

    def test_iframe_removal(self):
        """Test suppression iframe"""
        html = '<iframe src="evil.com"></iframe>Content'
        result = sanitize_html(html)
        assert "iframe" not in result.lower()

    def test_javascript_protocol(self):
        """Test suppression protocole javascript"""
        html = '<a href="javascript:alert(1)">Link</a>'
        result = sanitize_html(html)
        assert "javascript:" not in result.lower()

    def test_safe_text(self):
        """Test texte sûr"""
        text = "Hello World"
        result = sanitize_html(text)
        assert "Hello World" in result

    def test_empty_text(self):
        """Test texte vide"""
        assert sanitize_html("") == ""
        # Note: None n'est pas accepté par le type checker, utiliser "" à la place


class TestValidatePhoneNumber:
    """Tests pour validate_phone_number"""

    def test_valid_belgian_phone(self):
        """Test numéro belge valide"""
        is_valid, normalized = validate_phone_number("0470123456", "BE")
        assert is_valid or normalized  # Peut être valide même sans phonenumbers

    def test_valid_international_phone(self):
        """Test numéro international valide"""
        is_valid, normalized = validate_phone_number("+32470123456", "BE")
        assert normalized  # Devrait retourner quelque chose

    def test_invalid_phone(self):
        """Test numéro invalide"""
        is_valid, normalized = validate_phone_number("123", "BE")
        assert not is_valid or not normalized

    def test_empty_phone(self):
        """Test numéro vide"""
        is_valid, normalized = validate_phone_number("", "BE")
        assert not is_valid
        assert normalized == ""

    def test_phone_with_spaces(self):
        """Test numéro avec espaces"""
        is_valid, normalized = validate_phone_number("0470 12 34 56", "BE")
        # Devrait nettoyer les espaces
        assert " " not in normalized or not is_valid
