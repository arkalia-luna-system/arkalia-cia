"""
Tests pour le module retry
"""

from unittest.mock import patch

import pytest

from arkalia_cia_python_backend.utils.retry import retry_with_backoff


class TestRetryWithBackoff:
    """Tests pour le décorateur retry_with_backoff"""

    def test_success_first_try(self):
        """Test succès au premier essai"""

        @retry_with_backoff(max_retries=3)
        def func():
            return "success"

        assert func() == "success"

    def test_retry_on_failure(self):
        """Test retry en cas d'échec"""
        call_count = 0

        @retry_with_backoff(max_retries=3, backoff_factor=0.01)
        def func():
            nonlocal call_count
            call_count += 1
            if call_count < 3:
                raise Exception("Temporary failure")
            return "success"

        assert func() == "success"
        assert call_count == 3

    def test_max_retries_exceeded(self):
        """Test dépassement max retries"""

        @retry_with_backoff(max_retries=2, backoff_factor=0.01)
        def func():
            raise Exception("Always fails")

        with pytest.raises(Exception, match="Always fails"):
            func()

    def test_exponential_backoff(self):
        """Test exponential backoff"""
        delays = []

        def mock_sleep(delay):
            delays.append(delay)

        call_count = 0

        @retry_with_backoff(max_retries=3, backoff_factor=1.5)
        def func():
            nonlocal call_count
            call_count += 1
            if call_count < 3:
                raise Exception("Fail")
            return "success"

        with patch("time.sleep", mock_sleep):
            func()

        # Vérifier que les délais augmentent exponentiellement
        # Avec backoff_factor=1.5: attempt 0 = 1.5^0 = 1.0, attempt 1 = 1.5^1 = 1.5
        assert len(delays) >= 2
        assert delays[1] > delays[0], (
            f"Expected delays[1]={delays[1]} > delays[0]={delays[0]}"
        )

    def test_specific_exception_type(self):
        """Test retry seulement pour exceptions spécifiques"""
        call_count = 0

        @retry_with_backoff(
            max_retries=3, backoff_factor=0.01, exceptions=(ValueError,)
        )
        def func():
            nonlocal call_count
            call_count += 1
            if call_count < 2:
                raise ValueError("Value error")
            return "success"

        assert func() == "success"
        assert call_count == 2

    def test_no_retry_for_different_exception(self):
        """Test pas de retry pour exception différente"""

        @retry_with_backoff(
            max_retries=3, backoff_factor=0.01, exceptions=(ValueError,)
        )
        def func():
            raise TypeError("Type error")

        with pytest.raises(TypeError, match="Type error"):
            func()

    def test_uses_config_defaults(self):
        """Test utilisation des valeurs par défaut de la config"""
        call_count = 0

        @retry_with_backoff()  # Utilise les valeurs par défaut de la config
        def func():
            nonlocal call_count
            call_count += 1
            if call_count < 2:
                raise Exception("Fail")
            return "success"

        # Devrait utiliser max_retries=3 depuis la config
        assert func() == "success"
        assert call_count == 2
