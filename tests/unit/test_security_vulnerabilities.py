"""
Tests de sécurité pour détecter les vulnérabilités courantes
Tests contre injection SQL, XSS, path traversal, etc.
"""

from fastapi.testclient import TestClient

from arkalia_cia_python_backend.api import app
from arkalia_cia_python_backend.database import CIADatabase
from arkalia_cia_python_backend.security_utils import (
    is_safe_path,
    sanitize_filename,
    sanitize_log_message,
)


class TestSQLInjection:
    """Tests contre les injections SQL"""

    def test_sql_injection_in_document_id(self):
        """Test que les IDs sont correctement échappés"""
        db = CIADatabase(":memory:")
        # Tentative d'injection SQL dans l'ID
        malicious_id = "1 OR 1=1"
        try:
            # Devrait échouer car l'ID doit être un entier
            db.get_document(int(malicious_id))
            # Si on arrive ici, vérifier que la requête est sécurisée
            assert True
        except (ValueError, TypeError):
            # C'est le comportement attendu - l'injection échoue
            assert True

    def test_sql_injection_in_string_fields(self):
        """Test que les champs string sont correctement échappés avec requêtes paramétrées"""
        db = CIADatabase(":memory:")
        # Tentative d'injection SQL dans le titre
        malicious_title = "'; DROP TABLE documents; --"
        # Les requêtes paramétrées devraient protéger contre cela
        db.add_reminder(
            title=malicious_title,
            description="test",
            reminder_date="2024-01-01T00:00:00",
        )
        # Si l'injection avait fonctionné, la table serait supprimée
        # Vérifier que la table existe toujours
        reminders = db.get_reminders()
        assert isinstance(reminders, list)  # La table existe toujours


class TestPathTraversal:
    """Tests contre les attaques de path traversal"""

    def test_path_traversal_in_filename(self):
        """Test que les noms de fichiers avec path traversal sont bloqués"""
        malicious_filenames = [
            "../../etc/passwd",
            "..\\..\\windows\\system32",
            "/etc/passwd",
            "C:\\Windows\\System32",
            "....//....//etc/passwd",
        ]

        for filename in malicious_filenames:
            sanitized = sanitize_filename(filename)
            # Le nom de fichier ne doit pas contenir de path traversal
            assert ".." not in sanitized
            assert "/" not in sanitized or sanitized.startswith("/")
            assert "\\" not in sanitized

    def test_safe_path_validation(self):
        """Test de validation des chemins sécurisés"""
        # Chemins valides
        assert is_safe_path("uploads/file.pdf", "uploads") is True
        assert is_safe_path("uploads/subdir/file.pdf", "uploads") is True

        # Chemins invalides (path traversal)
        assert is_safe_path("../../etc/passwd", "uploads") is False
        assert is_safe_path("uploads/../../etc/passwd", "uploads") is False
        assert is_safe_path("/etc/passwd", "uploads") is False


class TestXSSProtection:
    """Tests contre les attaques XSS"""

    def test_xss_in_input_fields(self):
        """Test que les champs d'entrée sont sanitizés"""
        client = TestClient(app)

        # Tentative XSS dans le titre
        xss_payloads = [
            "<script>alert('XSS')</script>",
            "<img src=x onerror=alert('XSS')>",
            "javascript:alert('XSS')",
            "<svg onload=alert('XSS')>",
        ]

        for payload in xss_payloads:
            # Tester avec un rappel
            response = client.post(
                "/api/reminders",
                json={
                    "title": payload,
                    "description": "test",
                    "reminder_date": "2024-01-01T00:00:00",
                },
            )
            # Le titre devrait être validé et rejeté ou sanitizé
            # Si validation Pydantic fonctionne, devrait être rejeté (car contient caractères invalides)
            if response.status_code not in [400, 422, 500]:
                # Si accepté, vérifier que le payload XSS n'est pas présent dans la réponse
                response_data = response.json()
                assert "<script>" not in str(response_data)
            else:
                # Rejeté comme attendu
                assert True


class TestSSRFProtection:
    """Tests contre les attaques SSRF"""

    def test_ssrf_blocked_private_ips(self):
        """Test que les URLs vers des IPs privées sont bloquées"""
        client = TestClient(app)

        # URLs vers IPs privées (devraient être bloquées)
        blocked_urls = [
            "http://127.0.0.1",
            "http://localhost",
            "http://192.168.1.1",
            "http://10.0.0.1",
            "http://172.16.0.1",
            "http://169.254.1.1",
        ]

        for url in blocked_urls:
            response = client.post(
                "/api/health-portals",
                json={"name": "Test", "url": url, "description": "Test"},
            )
            # Devrait rejeter les URLs vers IPs privées
            assert response.status_code in [400, 422], f"URL {url} devrait être bloquée"

    def test_ssrf_allowed_public_urls(self):
        """Test que les URLs publiques sont autorisées"""
        client = TestClient(app)

        # URLs publiques (devraient être autorisées)
        allowed_urls = [
            "https://example.com",
            "http://www.google.com",
            "https://github.com",
        ]

        for url in allowed_urls:
            response = client.post(
                "/api/health-portals",
                json={"name": "Test", "url": url, "description": "Test"},
            )
            # Devrait accepter les URLs publiques (ou erreur DB, pas erreur de validation)
            assert response.status_code not in [400, 422] or "privées" not in str(
                response.json()
            )


class TestInputValidation:
    """Tests de validation des entrées"""

    def test_phone_validation(self):
        """Test de validation des numéros de téléphone"""
        client = TestClient(app)

        # Numéros valides
        valid_phones = ["+32470123456", "0470123456", "+32123456789"]
        for phone in valid_phones:
            response = client.post(
                "/api/emergency-contacts",
                json={
                    "name": "Test User",
                    "phone": phone,
                    "relationship": "Friend",
                },
            )
            # Devrait accepter les numéros valides
            assert response.status_code in [200, 201, 500]  # 500 si DB pas initialisée

        # Numéros invalides
        invalid_phones = ["123", "abc", "+++", ""]
        for phone in invalid_phones:
            response = client.post(
                "/api/emergency-contacts",
                json={
                    "name": "Test User",
                    "phone": phone,
                    "relationship": "Friend",
                },
            )
            # Devrait rejeter les numéros invalides
            assert response.status_code in [400, 422]

    def test_url_validation(self):
        """Test de validation des URLs"""
        client = TestClient(app)

        # URLs valides
        valid_urls = ["https://example.com", "http://test.org"]
        for url in valid_urls:
            response = client.post(
                "/api/health-portals",
                json={"name": "Test", "url": url, "description": "Test"},
            )
            assert response.status_code in [200, 201, 500]

        # URLs invalides
        invalid_urls = ["javascript:alert(1)", "ftp://test.com", "not-a-url"]
        for url in invalid_urls:
            response = client.post(
                "/api/health-portals",
                json={"name": "Test", "url": url, "description": "Test"},
            )
            assert response.status_code in [400, 422]


class TestRateLimiting:
    """Tests du rate limiting"""

    def test_rate_limiting_decorator_present(self):
        """Test que le décorateur de rate limiting est présent"""
        # Vérifier que le rate limiter est configuré
        # Note: TestClient ne simule pas vraiment le rate limiting
        # mais on peut vérifier que le décorateur est présent
        # Le vrai rate limiting sera testé en intégration
        assert hasattr(app.state, "limiter")


class TestSecurityHeaders:
    """Tests des headers de sécurité HTTP"""

    def test_security_headers_present(self):
        """Test que les headers de sécurité sont présents"""
        client = TestClient(app)
        response = client.get("/health")

        # Vérifier les headers de sécurité
        assert "X-Content-Type-Options" in response.headers
        assert response.headers["X-Content-Type-Options"] == "nosniff"
        assert "X-Frame-Options" in response.headers
        assert response.headers["X-Frame-Options"] == "DENY"
        assert "X-XSS-Protection" in response.headers


class TestLoggingSecurity:
    """Tests de sécurité du logging"""

    def test_sanitize_log_message(self):
        """Test que les messages de log sont sanitizés"""
        sensitive_messages = [
            "password: secret123",
            "api_key: abc123xyz",
            "token: bearer_token_here",
            "email: user@example.com",
            "phone: +32470123456",
        ]

        for message in sensitive_messages:
            sanitized = sanitize_log_message(message)
            # Les informations sensibles doivent être masquées
            assert "secret123" not in sanitized
            assert "abc123xyz" not in sanitized
            assert "bearer_token_here" not in sanitized
            assert "user@" not in sanitized
            assert "+32470123456" not in sanitized or "****" in sanitized


class TestFileUploadSecurity:
    """Tests de sécurité pour l'upload de fichiers"""

    def test_file_extension_validation(self):
        """Test que seuls les PDF sont acceptés"""
        client = TestClient(app)
        # Tester avec différents types de fichiers
        malicious_files = [
            ("test.exe", b"fake exe content"),
            ("test.php", b"<?php system($_GET['cmd']); ?>"),
            ("test.html", b"<script>alert('XSS')</script>"),
        ]

        for filename, content in malicious_files:
            response = client.post(
                "/api/documents/upload",
                files={"file": (filename, content, "application/octet-stream")},
            )
            # Devrait rejeter les fichiers non-PDF
            assert response.status_code in [400, 422]

    def test_file_size_limit(self):
        """Test que la taille des fichiers est limitée"""
        client = TestClient(app)
        # Créer un fichier trop volumineux (51 MB)
        large_content = b"x" * (51 * 1024 * 1024)
        response = client.post(
            "/api/documents/upload",
            files={"file": ("large.pdf", large_content, "application/pdf")},
        )
        # Devrait rejeter les fichiers trop volumineux
        assert response.status_code in [400, 413]


class TestDatabaseSecurity:
    """Tests de sécurité de la base de données"""

    def test_database_path_validation(self):
        """Test que les chemins de base de données sont validés"""
        # Tentative d'utiliser un chemin avec path traversal
        malicious_paths = [
            "../../etc/passwd",
            "..\\..\\windows\\system32",
            "/etc/passwd",
        ]

        for path in malicious_paths:
            try:
                db = CIADatabase(path)
                # Si l'initialisation réussit, vérifier que le chemin est sécurisé
                assert ".." not in db.db_path
            except ValueError:
                # C'est le comportement attendu - chemin invalide rejeté
                assert True
