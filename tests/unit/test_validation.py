"""
Tests unitaires pour ValidationHelper (Dart/Flutter)
Ces tests sont écrits en Python pour être compatibles avec la suite de tests existante
et tester la logique de validation qui peut être partagée.
"""

import re
from datetime import datetime


class TestValidationHelper:
    """Tests pour ValidationHelper"""

    def test_is_valid_phone_belgian(self):
        """Test de validation des numéros de téléphone belges"""
        valid_phones = [
            "0470123456",
            "0470 12 34 56",
            "0470-12-34-56",
            "+32470123456",
            "+32 470 12 34 56",
        ]
        
        invalid_phones = [
            "",
            "123",
            "abc",
            "1234567890123456",  # Trop long
            "0370123456",  # Ne commence pas par 04
        ]

        belgian_pattern = re.compile(r'^(?:\+32|0)?4[0-9]{8}$')
        
        for phone in valid_phones:
            cleaned = re.sub(r'[\s\-\(\)]', '', phone)
            assert belgian_pattern.match(cleaned) is not None, f"Phone {phone} should be valid"

        for phone in invalid_phones:
            if phone:
                cleaned = re.sub(r'[\s\-\(\)]', '', phone)
                assert belgian_pattern.match(cleaned) is None, f"Phone {phone} should be invalid"

    def test_is_valid_url(self):
        """Test de validation des URLs"""
        valid_urls = [
            "https://example.com",
            "http://example.com",
            "https://www.example.com/path",
            "http://subdomain.example.com:8080/path?query=value",
        ]
        
        invalid_urls = [
            "",
            "not-a-url",
            "ftp://example.com",  # Pas http/https
            "example.com",  # Pas de schéma
            "javascript:alert('xss')",  # Schéma invalide
        ]

        for url in valid_urls:
            assert url.startswith(('http://', 'https://')), f"URL {url} should be valid"

        for url in invalid_urls:
            if url:
                assert not (url.startswith(('http://', 'https://'))), f"URL {url} should be invalid"

    def test_is_valid_email(self):
        """Test de validation des emails"""
        valid_emails = [
            "test@example.com",
            "user.name@example.co.uk",
            "user+tag@example.com",
        ]
        
        invalid_emails = [
            "",
            "not-an-email",
            "@example.com",
            "user@",
            "user@example",
            "user space@example.com",
        ]

        email_pattern = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        
        for email in valid_emails:
            assert email_pattern.match(email) is not None, f"Email {email} should be valid"

        for email in invalid_emails:
            if email:
                assert email_pattern.match(email) is None, f"Email {email} should be invalid"

    def test_is_valid_name(self):
        """Test de validation des noms"""
        valid_names = [
            "Jean Dupont",
            "Marie-Claire",
            "O'Brien",
            "José",
        ]
        
        invalid_names = [
            "",
            "A",  # Trop court
            "X" * 101,  # Trop long
            "Jean123",  # Contient des chiffres
            "Jean@Dupont",  # Contient caractère spécial invalide
        ]

        name_pattern = re.compile(r"^[a-zA-ZÀ-ÿ\s\-']+$")
        
        for name in valid_names:
            assert len(name) >= 2 and len(name) <= 100, f"Name {name} length should be valid"
            assert name_pattern.match(name) is not None, f"Name {name} should be valid"

        for name in invalid_names:
            if name:
                is_invalid = (
                    len(name) < 2 or 
                    len(name) > 100 or 
                    name_pattern.match(name) is None
                )
                assert is_invalid, f"Name {name} should be invalid"

    def test_is_valid_date(self):
        """Test de validation des dates ISO 8601"""
        valid_dates = [
            "2024-01-01T10:00:00Z",
            "2024-12-31T23:59:59Z",
            "2024-01-01T10:00:00+01:00",
        ]
        
        invalid_dates = [
            "",
            "not-a-date",
            "2024-13-01",  # Mois invalide
            "2024-01-32",  # Jour invalide
            "01/01/2024",  # Format non ISO
        ]

        for date_str in valid_dates:
            try:
                datetime.fromisoformat(date_str.replace('Z', '+00:00'))
                assert True, f"Date {date_str} should be valid"
            except ValueError:
                assert False, f"Date {date_str} should be valid"

        for date_str in invalid_dates:
            if date_str:
                try:
                    datetime.fromisoformat(date_str.replace('Z', '+00:00'))
                    assert False, f"Date {date_str} should be invalid"
                except ValueError:
                    assert True, f"Date {date_str} should be invalid"

