"""
Database Manager pour Arkalia CIA
Adapté du storage.py d'Arkalia-Luna-Pro
"""

import sqlite3
from pathlib import Path
from typing import Any


class CIADatabase:
    """Gestionnaire de base de données SQLite pour Arkalia CIA"""

    def __init__(self, db_path: str = "arkalia_cia.db"):
        # Sécurité : Valider le chemin de la base de données
        # Empêcher les path traversal attacks
        db_path_obj = Path(db_path)

        # Vérifier les path traversal attacks
        if ".." in str(db_path_obj):
            raise ValueError("Chemin de base de données invalide: path traversal détecté")

        # Permettre les chemins absolus pour les fichiers temporaires de tests
        # et les chemins relatifs dans le répertoire courant
        if db_path_obj.is_absolute():
            # Pour les tests : permettre les fichiers temporaires (commencent par /tmp ou /var)
            if not (
                str(db_path_obj).startswith("/tmp")  # nosec B108 - Validation de sécurité
                or str(db_path_obj).startswith("/var")
                or str(db_path_obj).startswith(str(Path.cwd()))
            ):
                # En production, on peut être plus strict si nécessaire
                # Pour l'instant, on permet les chemins absolus pour compatibilité tests
                pass

        self.db_path = str(db_path_obj.resolve())
        self.init_database()

    def init_database(self):
        """Initialise la base de données avec les tables nécessaires"""
        self.init_db()

    def init_db(self):
        """Initialise la base de données avec les tables nécessaires"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()

            # Table des documents
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS documents (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    original_name TEXT NOT NULL,
                    file_path TEXT NOT NULL,
                    file_type TEXT NOT NULL,
                    file_size INTEGER,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """
            )

            # Table des rappels
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS reminders (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    title TEXT NOT NULL,
                    description TEXT,
                    reminder_date TIMESTAMP NOT NULL,
                    is_completed BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """
            )

            # Table des contacts d'urgence
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS emergency_contacts (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    phone TEXT NOT NULL,
                    relationship TEXT,
                    is_primary BOOLEAN DEFAULT FALSE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """
            )

            # Table des portails santé
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS health_portals (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    name TEXT NOT NULL,
                    url TEXT NOT NULL,
                    description TEXT,
                    category TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """
            )

            conn.commit()

    def add_document(
        self,
        name: str,
        original_name: str,
        file_path: str,
        file_type: str,
        file_size: int,
    ) -> int | None:
        """Ajoute un document à la base de données"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO documents (name, original_name, file_path, file_type, file_size)
                VALUES (?, ?, ?, ?, ?)
            """,
                (name, original_name, file_path, file_type, file_size),
            )
            return cursor.lastrowid

    def get_documents(self) -> list[dict[str, Any]]:
        """Récupère tous les documents"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM documents ORDER BY created_at DESC")
            return [dict(row) for row in cursor.fetchall()]

    def get_document(self, doc_id: int) -> dict[str, Any] | None:
        """Récupère un document par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM documents WHERE id = ?", (doc_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def list_documents(self) -> list[dict[str, Any]]:
        """Liste tous les documents"""
        return self.get_documents()

    def delete_document(self, doc_id: int) -> bool:
        """Supprime un document par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM documents WHERE id = ?", (doc_id,))
            return cursor.rowcount > 0

    def save_document(self, filename: str, content: str, metadata: str) -> int | None:
        """Sauvegarde un document"""
        return self.add_document(filename, filename, "", "pdf", len(content))

    def add_reminder(self, title: str, description: str, reminder_date: str) -> int | None:
        """Ajoute un rappel"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO reminders (title, description, reminder_date)
                VALUES (?, ?, ?)
            """,
                (title, description, reminder_date),
            )
            return cursor.lastrowid

    def save_reminder(self, title: str, description: str, reminder_date: str) -> int | None:
        """Sauvegarde un rappel"""
        return self.add_reminder(title, description, reminder_date)

    def get_reminder(self, reminder_id: int) -> dict[str, Any] | None:
        """Récupère un rappel par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM reminders WHERE id = ?", (reminder_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def list_reminders(self) -> list[dict[str, Any]]:
        """Liste tous les rappels"""
        return self.get_reminders()

    def delete_reminder(self, reminder_id: int) -> bool:
        """Supprime un rappel par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM reminders WHERE id = ?", (reminder_id,))
            return cursor.rowcount > 0

    def get_reminders(self) -> list[dict[str, Any]]:
        """Récupère tous les rappels"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM reminders ORDER BY reminder_date ASC")
            return [dict(row) for row in cursor.fetchall()]

    def add_emergency_contact(
        self, name: str, phone: str, relationship: str, is_primary: bool = False
    ) -> int | None:
        """Ajoute un contact d'urgence"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO emergency_contacts (name, phone, relationship, is_primary)
                VALUES (?, ?, ?, ?)
            """,
                (name, phone, relationship, is_primary),
            )
            return cursor.lastrowid

    def save_contact(
        self, name: str, phone: str, relationship: str, is_primary: bool = False
    ) -> int | None:
        """Sauvegarde un contact d'urgence"""
        return self.add_emergency_contact(name, phone, relationship, is_primary)

    def get_contact(self, contact_id: int) -> dict[str, Any] | None:
        """Récupère un contact par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM emergency_contacts WHERE id = ?", (contact_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def list_contacts(self) -> list[dict[str, Any]]:
        """Liste tous les contacts"""
        return self.get_emergency_contacts()

    def delete_contact(self, contact_id: int) -> bool:
        """Supprime un contact par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM emergency_contacts WHERE id = ?", (contact_id,))
            return cursor.rowcount > 0

    def get_emergency_contacts(self) -> list[dict[str, Any]]:
        """Récupère tous les contacts d'urgence"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM emergency_contacts ORDER BY is_primary DESC, name ASC")
            return [dict(row) for row in cursor.fetchall()]

    def add_health_portal(self, name: str, url: str, description: str, category: str) -> int | None:
        """Ajoute un portail santé"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO health_portals (name, url, description, category)
                VALUES (?, ?, ?, ?)
            """,
                (name, url, description, category),
            )
            return cursor.lastrowid

    def save_portal(self, name: str, url: str, description: str, category: str) -> int | None:
        """Sauvegarde un portail santé"""
        return self.add_health_portal(name, url, description, category)

    def get_portal(self, portal_id: int) -> dict[str, Any] | None:
        """Récupère un portail par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM health_portals WHERE id = ?", (portal_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def list_portals(self) -> list[dict[str, Any]]:
        """Liste tous les portails"""
        return self.get_health_portals()

    def delete_portal(self, portal_id: int) -> bool:
        """Supprime un portail par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM health_portals WHERE id = ?", (portal_id,))
            return cursor.rowcount > 0

    def get_health_portals(self) -> list[dict[str, Any]]:
        """Récupère tous les portails santé"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM health_portals ORDER BY category, name ASC")
            return [dict(row) for row in cursor.fetchall()]


# Instance globale
db = CIADatabase()
