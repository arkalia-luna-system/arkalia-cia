"""
Tests pour le validateur SSRF
"""

import pytest

from arkalia_cia_python_backend.security.ssrf_validator import (
    SSRFValidator,
    get_ssrf_validator,
)


class TestSSRFValidator:
    """Tests pour SSRFValidator"""

    def test_allowed_urls(self):
        """Test URLs autorisées"""
        validator = SSRFValidator()
        assert (
            validator.validate("https://api.example.com") == "https://api.example.com"
        )
        assert validator.validate("http://example.com") == "http://example.com"
        assert (
            validator.validate("https://www.example.com/path")
            == "https://www.example.com/path"
        )

    def test_blocked_localhost(self):
        """Test URLs localhost bloquées"""
        validator = SSRFValidator()
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://localhost")
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://127.0.0.1")
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://0.0.0.0")

    def test_blocked_private_ips(self):
        """Test détection IPs privées"""
        validator = SSRFValidator()
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://192.168.1.1")
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://10.0.0.1")
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://172.16.0.1")

    def test_blocked_link_local(self):
        """Test blocage link-local"""
        validator = SSRFValidator()
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://169.254.169.254")  # AWS metadata

    def test_invalid_schemes(self):
        """Test schémas invalides"""
        validator = SSRFValidator()
        with pytest.raises(ValueError, match="schémas http et https"):
            validator.validate("file:///etc/passwd")
        with pytest.raises(ValueError, match="schémas http et https"):
            validator.validate("ftp://example.com")
        with pytest.raises(ValueError, match="schémas http et https"):
            validator.validate("javascript:alert(1)")

    def test_invalid_url_format(self):
        """Test format URL invalide"""
        validator = SSRFValidator()
        with pytest.raises(ValueError):
            validator.validate("not-a-url")
        with pytest.raises(ValueError):
            validator.validate("")

    def test_empty_url(self):
        """Test URL vide"""
        validator = SSRFValidator()
        with pytest.raises(ValueError, match="invalide ou vide"):
            validator.validate("")
        with pytest.raises(ValueError, match="invalide ou vide"):
            validator.validate(None)  # type: ignore

    def test_missing_hostname(self):
        """Test hostname manquant"""
        validator = SSRFValidator()
        with pytest.raises(ValueError, match="Hostname manquant"):
            validator.validate("http://")

    def test_custom_blocked_ranges(self):
        """Test plages bloquées personnalisées"""
        validator = SSRFValidator(blocked_ranges=["example.com"])
        with pytest.raises(ValueError, match="adresses privées"):
            validator.validate("http://example.com")
        # Mais d'autres URLs devraient passer
        assert validator.validate("http://other.com") == "http://other.com"


class TestGetSSRFValidator:
    """Tests pour la fonction get_ssrf_validator"""

    def test_singleton_pattern(self):
        """Test que get_ssrf_validator retourne la même instance"""
        import arkalia_cia_python_backend.security.ssrf_validator as ssrf_module

        ssrf_module._validator = None
        validator1 = get_ssrf_validator()
        validator2 = get_ssrf_validator()
        assert validator1 is validator2
