"""
Tests unitaires pour le module storage
"""

import tempfile
from pathlib import Path

from arkalia_cia_python_backend.storage import (
    JSONFileBackend,
    SQLiteBackend,
    StorageManager,
    get_storage,
    set_storage_backend,
)


class TestJSONFileBackend:
    """Tests pour JSONFileBackend"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.temp_dir = tempfile.mkdtemp()
        self.backend = JSONFileBackend(base_path=self.temp_dir)

    def teardown_method(self):
        """Nettoyage après chaque test"""
        import shutil

        if Path(self.temp_dir).exists():
            shutil.rmtree(self.temp_dir)

    def test_get_nonexistent_key(self):
        """Test de récupération d'une clé inexistante"""
        result = self.backend.get("nonexistent", default="default_value")
        assert result == "default_value"

    def test_set_and_get(self):
        """Test de sauvegarde et récupération"""
        self.backend.set("test_key", {"data": "test_value"})
        result = self.backend.get("test_key")
        assert result == {"data": "test_value"}

    def test_delete(self):
        """Test de suppression"""
        self.backend.set("test_key", {"data": "test_value"})
        assert self.backend.exists("test_key") is True
        self.backend.delete("test_key")
        assert self.backend.exists("test_key") is False

    def test_exists(self):
        """Test de vérification d'existence"""
        assert self.backend.exists("nonexistent") is False
        self.backend.set("test_key", {"data": "test_value"})
        assert self.backend.exists("test_key") is True

    def test_list_keys(self):
        """Test de listage des clés"""
        self.backend.set("key1", {"data": "value1"})
        self.backend.set("key2", {"data": "value2"})
        keys = self.backend.list_keys()
        assert "key1" in keys
        assert "key2" in keys

    def test_list_keys_with_prefix(self):
        """Test de listage avec préfixe"""
        self.backend.set("prefix_key1", {"data": "value1"})
        self.backend.set("prefix_key2", {"data": "value2"})
        self.backend.set("other_key", {"data": "value3"})
        keys = self.backend.list_keys(prefix="prefix_")
        assert "prefix_key1" in keys
        assert "prefix_key2" in keys
        assert "other_key" not in keys


class TestSQLiteBackend:
    """Tests pour SQLiteBackend"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.temp_db = tempfile.mktemp(suffix=".db")
        self.backend = SQLiteBackend(db_path=self.temp_db)

    def teardown_method(self):
        """Nettoyage après chaque test"""
        if Path(self.temp_db).exists():
            Path(self.temp_db).unlink()

    def test_get_nonexistent_key(self):
        """Test de récupération d'une clé inexistante"""
        result = self.backend.get("nonexistent", default="default_value")
        assert result == "default_value"

    def test_set_and_get(self):
        """Test de sauvegarde et récupération"""
        self.backend.set("test_key", {"data": "test_value"})
        result = self.backend.get("test_key")
        assert result == {"data": "test_value"}

    def test_delete(self):
        """Test de suppression"""
        self.backend.set("test_key", {"data": "test_value"})
        assert self.backend.exists("test_key") is True
        self.backend.delete("test_key")
        assert self.backend.exists("test_key") is False

    def test_exists(self):
        """Test de vérification d'existence"""
        assert self.backend.exists("nonexistent") is False
        self.backend.set("test_key", {"data": "test_value"})
        assert self.backend.exists("test_key") is True

    def test_list_keys(self):
        """Test de listage des clés"""
        self.backend.set("key1", {"data": "value1"})
        self.backend.set("key2", {"data": "value2"})
        keys = self.backend.list_keys()
        assert "key1" in keys
        assert "key2" in keys

    def test_list_keys_with_prefix(self):
        """Test de listage avec préfixe"""
        self.backend.set("prefix_key1", {"data": "value1"})
        self.backend.set("prefix_key2", {"data": "value2"})
        self.backend.set("other_key", {"data": "value3"})
        keys = self.backend.list_keys(prefix="prefix_")
        assert "prefix_key1" in keys
        assert "prefix_key2" in keys
        assert "other_key" not in keys


class TestStorageManager:
    """Tests pour StorageManager"""

    def setup_method(self):
        """Configuration avant chaque test"""
        self.temp_dir = tempfile.mkdtemp()
        self.manager = StorageManager(backend="json", base_path=self.temp_dir)

    def teardown_method(self):
        """Nettoyage après chaque test"""
        import shutil

        if Path(self.temp_dir).exists():
            shutil.rmtree(self.temp_dir)

    def test_get_state(self):
        """Test de récupération d'état"""
        self.manager.save_state("test_module", {"key": "value"})
        state = self.manager.get_state("test_module")
        assert state == {"key": "value"}

    def test_save_state(self):
        """Test de sauvegarde d'état"""
        result = self.manager.save_state("test_module", {"key": "value"})
        assert result is True

    def test_get_decision(self):
        """Test de récupération de décision"""
        self.manager.save_decision("test_module", "decision1", {"action": "test"})
        decision = self.manager.get_decision("test_module", "decision1")
        assert decision == {"action": "test"}

    def test_save_decision(self):
        """Test de sauvegarde de décision"""
        result = self.manager.save_decision("test_module", "decision1", {"action": "test"})
        assert result is True

    def test_get_config(self):
        """Test de récupération de configuration"""
        config = {"setting1": "value1"}
        self.manager.save_config("test_module", config)
        retrieved_config = self.manager.get_config("test_module")
        assert retrieved_config == config

    def test_save_config(self):
        """Test de sauvegarde de configuration"""
        config = {"setting1": "value1"}
        result = self.manager.save_config("test_module", config)
        assert result is True

    def test_get_metrics(self):
        """Test de récupération de métriques"""
        metrics = {"metric1": 100}
        self.manager.save_metrics("test_module", metrics)
        retrieved_metrics = self.manager.get_metrics("test_module")
        assert retrieved_metrics == metrics

    def test_save_metrics(self):
        """Test de sauvegarde de métriques"""
        metrics = {"metric1": 100}
        result = self.manager.save_metrics("test_module", metrics)
        assert result is True

    def test_list_module_data(self):
        """Test de listage des données d'un module"""
        self.manager.save_state("test_module", {"key": "value"})
        self.manager.save_config("test_module", {"setting": "value"})
        keys = self.manager.list_module_data("test_module")
        assert len(keys) >= 2

    def test_delete_module_data(self):
        """Test de suppression des données d'un module"""
        self.manager.save_state("test_module", {"key": "value"})
        result = self.manager.delete_module_data("test_module")
        assert result is True

    def test_backup_module(self):
        """Test de sauvegarde d'un module"""
        self.manager.save_state("test_module", {"key": "value"})
        backup_path = tempfile.mktemp(suffix=".json")
        result = self.manager.backup_module("test_module", backup_path)
        assert result is True
        assert Path(backup_path).exists()
        if Path(backup_path).exists():
            Path(backup_path).unlink()

    def test_restore_module(self):
        """Test de restauration d'un module"""
        self.manager.save_state("test_module", {"key": "value"})
        backup_path = tempfile.mktemp(suffix=".json")
        self.manager.backup_module("test_module", backup_path)
        self.manager.delete_module_data("test_module")
        result = self.manager.restore_module("test_module", backup_path)
        assert result is True
        if Path(backup_path).exists():
            Path(backup_path).unlink()

    def test_sqlite_backend(self):
        """Test avec backend SQLite"""
        temp_db = tempfile.mktemp(suffix=".db")
        manager = StorageManager(backend="sqlite", db_path=temp_db)
        result = manager.save_state("test_module", {"key": "value"})
        assert result is True
        state = manager.get_state("test_module")
        assert state == {"key": "value"}
        if Path(temp_db).exists():
            Path(temp_db).unlink()


class TestStorageFunctions:
    """Tests pour les fonctions utilitaires"""

    def test_get_storage(self):
        """Test de récupération de l'instance globale"""
        storage = get_storage()
        assert storage is not None
        assert isinstance(storage, StorageManager)

    def test_set_storage_backend(self):
        """Test de changement de backend"""
        temp_dir = tempfile.mkdtemp()
        set_storage_backend("json", base_path=temp_dir)
        storage = get_storage()
        assert storage.backend_type == "json"
        import shutil

        if Path(temp_dir).exists():
            shutil.rmtree(temp_dir)

    def test_json_backend_error_handling(self):
        """Test de gestion d'erreurs JSON backend"""
        temp_dir = tempfile.mkdtemp()
        backend = JSONFileBackend(base_path=temp_dir)
        # Test avec une clé inexistante - devrait retourner la valeur par défaut
        result = backend.get("nonexistent_key", default="default")
        assert result == "default"
        import shutil

        if Path(temp_dir).exists():
            shutil.rmtree(temp_dir)

    def test_sqlite_backend_error_handling(self):
        """Test de gestion d'erreurs SQLite backend"""
        temp_db = tempfile.mktemp(suffix=".db")
        backend = SQLiteBackend(db_path=temp_db)
        # Test avec une clé inexistante
        result = backend.get("nonexistent_key", default="default")
        assert result == "default"
        if Path(temp_db).exists():
            Path(temp_db).unlink()

    def test_storage_manager_error_handling(self):
        """Test de gestion d'erreurs StorageManager"""
        temp_dir = tempfile.mkdtemp()
        manager = StorageManager(backend="json", base_path=temp_dir)
        # Test avec des données invalides
        result = manager.get_state("nonexistent_module", default={})
        assert result == {}
        import shutil

        if Path(temp_dir).exists():
            shutil.rmtree(temp_dir)
