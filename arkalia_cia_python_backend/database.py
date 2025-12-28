"""
Database Manager pour Arkalia CIA
Adapté du storage.py d'Arkalia-Luna-Pro
"""

import sqlite3
import tempfile
from datetime import datetime
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
            raise ValueError(
                "Chemin de base de données invalide: path traversal détecté"
            )

        # Validation stricte des chemins autorisés
        if db_path_obj.is_absolute():
            temp_dir = tempfile.gettempdir()
            current_dir = str(Path.cwd())
            allowed_prefixes = [temp_dir, current_dir]
            if not any(
                str(db_path_obj).startswith(prefix) for prefix in allowed_prefixes
            ):
                raise ValueError(f"Chemin de base de données non autorisé: {db_path}")

        self.db_path = str(db_path_obj.resolve())
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

            # Table des médecins (pour consultations)
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS doctors (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    first_name TEXT NOT NULL,
                    last_name TEXT NOT NULL,
                    specialty TEXT,
                    phone TEXT,
                    email TEXT,
                    address TEXT,
                    city TEXT,
                    postal_code TEXT,
                    country TEXT DEFAULT 'Belgique',
                    notes TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """
            )

            # Table des consultations
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS consultations (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    doctor_id INTEGER NOT NULL,
                    user_id INTEGER,
                    date TEXT NOT NULL,
                    reason TEXT,
                    notes TEXT,
                    documents TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                )
            """
            )

            # Table des métadonnées documents
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS document_metadata (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    document_id INTEGER NOT NULL,
                    doctor_name TEXT,
                    doctor_specialty TEXT,
                    document_date TEXT,
                    exam_type TEXT,
                    document_type TEXT,
                    keywords TEXT,
                    extracted_text TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (document_id) REFERENCES documents(id) ON DELETE CASCADE
                )
            """
            )

            # Table des conversations IA
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS ai_conversations (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    question TEXT NOT NULL,
                    answer TEXT NOT NULL,
                    question_type TEXT,
                    related_documents TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """
            )

            # Table des utilisateurs
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS users (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    username TEXT NOT NULL UNIQUE,
                    email TEXT,
                    password_hash TEXT NOT NULL,
                    role TEXT DEFAULT 'user',
                    is_active BOOLEAN DEFAULT TRUE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            """
            )

            # Table pour associer les données aux utilisateurs
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS user_documents (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    document_id INTEGER NOT NULL,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
                    FOREIGN KEY (document_id) REFERENCES documents(id)
                        ON DELETE CASCADE,
                    UNIQUE(user_id, document_id)
                )
            """
            )

            # Table pour blacklist des tokens JWT révoqués
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS token_blacklist (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    token_jti TEXT NOT NULL UNIQUE,
                    user_id INTEGER NOT NULL,
                    token_type TEXT NOT NULL,
                    expires_at TIMESTAMP NOT NULL,
                    revoked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    reason TEXT,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                )
            """
            )

            # Index pour recherche rapide
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_token_blacklist_jti ON token_blacklist(token_jti)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_token_blacklist_user ON token_blacklist(user_id)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_token_blacklist_expires ON token_blacklist(expires_at)"
            )

            # Table pour audit log des accès
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS audit_logs (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER,
                    action TEXT NOT NULL,
                    resource_type TEXT NOT NULL,
                    resource_id TEXT,
                    ip_address TEXT,
                    user_agent TEXT,
                    success BOOLEAN DEFAULT TRUE,
                    error_message TEXT,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
                )
            """
            )

            # Index pour audit log
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_audit_logs_user ON audit_logs(user_id)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_audit_logs_action ON audit_logs(action)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_audit_logs_created ON audit_logs(created_at)"
            )

            # Table des membres famille
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS family_members (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    name TEXT NOT NULL,
                    email TEXT NOT NULL,
                    phone TEXT,
                    relationship TEXT,
                    is_active BOOLEAN DEFAULT TRUE,
                    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                )
            """
            )

            # Table des documents partagés
            cursor.execute(
                """
                CREATE TABLE IF NOT EXISTS shared_documents (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    user_id INTEGER NOT NULL,
                    document_id TEXT NOT NULL,
                    member_email TEXT NOT NULL,
                    permission_level TEXT DEFAULT 'view',
                    is_encrypted BOOLEAN DEFAULT TRUE,
                    shared_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
                )
            """
            )

            # Index pour partage familial
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_family_members_user ON family_members(user_id)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_family_members_email ON family_members(email)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_shared_documents_user ON shared_documents(user_id)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_shared_documents_doc ON shared_documents(document_id)"
            )
            cursor.execute(
                "CREATE INDEX IF NOT EXISTS idx_shared_documents_member ON shared_documents(member_email)"
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
                INSERT INTO documents (
                    name, original_name, file_path, file_type, file_size
                )
                VALUES (?, ?, ?, ?, ?)
            """,
                (name, original_name, file_path, file_type, file_size),
            )
            return cursor.lastrowid

    def get_documents(
        self, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les documents avec pagination"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    "SELECT * FROM documents ORDER BY created_at DESC LIMIT ? OFFSET ?",
                    (limit, skip),
                )
            else:
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

    def delete_document(self, doc_id: int) -> bool:
        """Supprime un document par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM documents WHERE id = ?", (doc_id,))
            return cursor.rowcount > 0

    def add_document_metadata(
        self,
        document_id: int,
        doctor_name: str | None = None,
        doctor_specialty: str | None = None,
        document_date: str | None = None,
        exam_type: str | None = None,
        document_type: str | None = None,
        keywords: str | None = None,
        extracted_text: str | None = None,
    ) -> int | None:
        """Ajoute des métadonnées à un document"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO document_metadata (
                    document_id, doctor_name, doctor_specialty, document_date,
                    exam_type, document_type, keywords, extracted_text
                )
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """,
                (
                    document_id,
                    doctor_name,
                    doctor_specialty,
                    document_date,
                    exam_type,
                    document_type,
                    keywords,
                    extracted_text,
                ),
            )
            return cursor.lastrowid

    def add_ai_conversation(
        self,
        question: str,
        answer: str,
        question_type: str = "general",
        related_documents: str | None = None,
    ) -> int | None:
        """Ajoute une conversation IA à la base de données"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                INSERT INTO ai_conversations (
                    question, answer, question_type, related_documents
                )
                VALUES (?, ?, ?, ?)
            """,
                (question, answer, question_type, related_documents),
            )
            return cursor.lastrowid

    def get_ai_conversations(
        self, limit: int = 50, skip: int = 0
    ) -> list[dict[str, Any]]:
        """Récupère les conversations IA avec pagination"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT * FROM ai_conversations
                ORDER BY created_at DESC
                LIMIT ? OFFSET ?
            """,
                (limit, skip),
            )
            return [dict(row) for row in cursor.fetchall()]

    def get_document_metadata(self, document_id: int) -> dict[str, Any] | None:
        """Récupère les métadonnées d'un document"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                "SELECT * FROM document_metadata WHERE document_id = ?", (document_id,)
            )
            row = cursor.fetchone()
            return dict(row) if row else None

    def get_documents_by_doctor_name(self, doctor_name: str) -> list[dict[str, Any]]:
        """Récupère les documents associés à un médecin par nom"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            # Formatage sécurisé : le pattern LIKE est construit AVANT le binding
            # Ceci est sûr car doctor_name vient déjà de la validation Pydantic
            search_pattern = f"%{doctor_name}%"
            cursor.execute(
                """
                SELECT d.*, dm.doctor_name, dm.doctor_specialty, dm.document_date
                FROM documents d
                JOIN document_metadata dm ON d.id = dm.document_id
                WHERE dm.doctor_name LIKE ?
                ORDER BY dm.document_date DESC
            """,
                (search_pattern,),
            )
            return [dict(row) for row in cursor.fetchall()]

    def add_reminder(
        self, title: str, description: str, reminder_date: str
    ) -> int | None:
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

    def get_reminder(self, reminder_id: int) -> dict[str, Any] | None:
        """Récupère un rappel par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM reminders WHERE id = ?", (reminder_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def delete_reminder(self, reminder_id: int) -> bool:
        """Supprime un rappel par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM reminders WHERE id = ?", (reminder_id,))
            return cursor.rowcount > 0

    def get_reminders(
        self, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les rappels avec pagination"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    "SELECT * FROM reminders "
                    "ORDER BY reminder_date ASC LIMIT ? OFFSET ?",
                    (limit, skip),
                )
            else:
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

    def get_contact(self, contact_id: int) -> dict[str, Any] | None:
        """Récupère un contact par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                "SELECT * FROM emergency_contacts WHERE id = ?", (contact_id,)
            )
            row = cursor.fetchone()
            return dict(row) if row else None

    def delete_contact(self, contact_id: int) -> bool:
        """Supprime un contact par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM emergency_contacts WHERE id = ?", (contact_id,))
            return cursor.rowcount > 0

    def get_emergency_contacts(
        self, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les contacts d'urgence avec pagination"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    "SELECT * FROM emergency_contacts "
                    "ORDER BY is_primary DESC, name ASC LIMIT ? OFFSET ?",
                    (limit, skip),
                )
            else:
                cursor.execute(
                    "SELECT * FROM emergency_contacts "
                    "ORDER BY is_primary DESC, name ASC"
                )
            return [dict(row) for row in cursor.fetchall()]

    def add_health_portal(
        self, name: str, url: str, description: str, category: str
    ) -> int | None:
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

    def get_portal(self, portal_id: int) -> dict[str, Any] | None:
        """Récupère un portail par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM health_portals WHERE id = ?", (portal_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def delete_portal(self, portal_id: int) -> bool:
        """Supprime un portail par ID"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM health_portals WHERE id = ?", (portal_id,))
            return cursor.rowcount > 0

    def get_health_portals(
        self, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les portails santé avec pagination"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    "SELECT * FROM health_portals "
                    "ORDER BY category, name ASC LIMIT ? OFFSET ?",
                    (limit, skip),
                )
            else:
                cursor.execute(
                    "SELECT * FROM health_portals ORDER BY category, name ASC"
                )
            return [dict(row) for row in cursor.fetchall()]

    def create_user(
        self,
        username: str,
        password_hash: str,
        email: str | None = None,
        role: str = "user",
    ) -> int | None:
        """Crée un nouvel utilisateur"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    """
                    INSERT INTO users (username, email, password_hash, role)
                    VALUES (?, ?, ?, ?)
                    """,
                    (username, email, password_hash, role),
                )
                return cursor.lastrowid
            except sqlite3.IntegrityError:
                return None

    def get_user_by_username(self, username: str) -> dict[str, Any] | None:
        """Récupère un utilisateur par nom d'utilisateur"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM users WHERE username = ?", (username,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def get_user_by_id(self, user_id: int) -> dict[str, Any] | None:
        """Récupère un utilisateur par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM users WHERE id = ?", (user_id,))
            row = cursor.fetchone()
            return dict(row) if row else None

    def associate_document_to_user(self, user_id: int, document_id: int) -> bool:
        """Associe un document à un utilisateur"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    """
                    INSERT INTO user_documents (user_id, document_id)
                    VALUES (?, ?)
                    """,
                    (user_id, document_id),
                )
                return True
            except sqlite3.IntegrityError:
                return False

    def get_user_documents(
        self, user_id: int, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les documents d'un utilisateur"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    """
                    SELECT d.* FROM documents d
                    INNER JOIN user_documents ud ON d.id = ud.document_id
                    WHERE ud.user_id = ?
                    ORDER BY d.created_at DESC
                    LIMIT ? OFFSET ?
                    """,
                    (user_id, limit, skip),
                )
            else:
                cursor.execute(
                    """
                    SELECT d.* FROM documents d
                    INNER JOIN user_documents ud ON d.id = ud.document_id
                    WHERE ud.user_id = ?
                    ORDER BY d.created_at DESC
                    """,
                    (user_id,),
                )
            return [dict(row) for row in cursor.fetchall()]

    # === GESTION BLACKLIST TOKENS ===

    def add_token_to_blacklist(
        self,
        token_jti: str,
        user_id: int,
        token_type: str,
        expires_at: datetime,
        reason: str | None = None,
    ) -> bool:
        """Ajoute un token à la blacklist"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    """
                    INSERT INTO token_blacklist (token_jti, user_id, token_type, expires_at, reason)
                    VALUES (?, ?, ?, ?, ?)
                    """,
                    (token_jti, user_id, token_type, expires_at.isoformat(), reason),
                )
                return True
            except sqlite3.IntegrityError:
                # Token déjà dans la blacklist
                return False

    def is_token_blacklisted(self, token_jti: str) -> bool:
        """Vérifie si un token est dans la blacklist"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT COUNT(*) FROM token_blacklist
                WHERE token_jti = ? AND expires_at > datetime('now')
                """,
                (token_jti,),
            )
            result = cursor.fetchone()
            return bool(result[0] > 0) if result else False

    def revoke_all_user_tokens(self, user_id: int, reason: str = "User logout") -> int:
        """Révoque tous les tokens d'un utilisateur"""
        # Note: On ne peut pas blacklister tous les tokens existants sans les avoir
        # Mais on peut marquer qu'on veut forcer une rotation
        # Pour l'instant, on retourne 0 (sera amélioré avec rotation)
        return 0

    def cleanup_expired_tokens(self) -> int:
        """Nettoie les tokens expirés de la blacklist"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                "DELETE FROM token_blacklist WHERE expires_at < datetime('now')"
            )
            return cursor.rowcount

    # === GESTION AUDIT LOG ===

    def add_audit_log(
        self,
        user_id: int | None,
        action: str,
        resource_type: str,
        resource_id: str | None = None,
        ip_address: str | None = None,
        user_agent: str | None = None,
        success: bool = True,
        error_message: str | None = None,
    ) -> int | None:
        """Ajoute une entrée dans l'audit log"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    """
                    INSERT INTO audit_logs (
                        user_id, action, resource_type, resource_id,
                        ip_address, user_agent, success, error_message
                    )
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        user_id,
                        action,
                        resource_type,
                        resource_id,
                        ip_address,
                        user_agent,
                        success,
                        error_message,
                    ),
                )
                return cursor.lastrowid
            except Exception:
                # En cas d'erreur, on ne bloque pas l'application
                return None

    def get_audit_logs(
        self,
        user_id: int | None = None,
        action: str | None = None,
        limit: int = 100,
        skip: int = 0,
    ) -> list[dict[str, Any]]:
        """Récupère les logs d'audit"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            conditions: list[str] = []
            params: list[Any] = []

            if user_id is not None:
                conditions.append("user_id = ?")
                params.append(user_id)
            if action is not None:
                conditions.append("action = ?")
                params.append(action)

            where_clause = " AND ".join(conditions) if conditions else "1=1"
            params.extend([limit, skip])

            cursor.execute(
                f"""
                SELECT * FROM audit_logs
                WHERE {where_clause}
                ORDER BY created_at DESC
                LIMIT ? OFFSET ?
                """,
                params,
            )
            return [dict(row) for row in cursor.fetchall()]

    # === GESTION CONSULTATIONS ===

    def get_consultations_by_user(
        self,
        user_id: int,
        start_date: datetime | None = None,
        end_date: datetime | None = None,
        limit: int = 50,
    ) -> list[dict[str, Any]]:
        """Récupère les consultations d'un utilisateur"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()

            conditions: list[str] = ["user_id = ?"]
            params: list[Any] = [user_id]

            if start_date:
                conditions.append("date >= ?")
                params.append(start_date.isoformat())
            if end_date:
                conditions.append("date <= ?")
                params.append(end_date.isoformat())

            where_clause = " AND ".join(conditions)
            params.append(limit)

            cursor.execute(
                f"""
                SELECT c.*, d.first_name, d.last_name, d.specialty
                FROM consultations c
                LEFT JOIN doctors d ON c.doctor_id = d.id
                WHERE {where_clause}
                ORDER BY c.date DESC
                LIMIT ?
                """,
                params,
            )
            return [dict(row) for row in cursor.fetchall()]

    # === GESTION PARTAGE FAMILIAL ===

    def add_family_member(
        self,
        user_id: int,
        name: str,
        email: str,
        phone: str | None = None,
        relationship: str | None = None,
        is_active: bool = True,
    ) -> int | None:
        """Ajoute un membre famille"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            try:
                cursor.execute(
                    """
                    INSERT INTO family_members (
                        user_id, name, email, phone, relationship, is_active
                    )
                    VALUES (?, ?, ?, ?, ?, ?)
                    """,
                    (user_id, name, email, phone, relationship, is_active),
                )
                return cursor.lastrowid
            except sqlite3.IntegrityError:
                return None

    def get_family_members(
        self, user_id: int, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les membres famille d'un utilisateur"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    """
                    SELECT * FROM family_members
                    WHERE user_id = ?
                    ORDER BY is_active DESC, name ASC
                    LIMIT ? OFFSET ?
                    """,
                    (user_id, limit, skip),
                )
            else:
                cursor.execute(
                    """
                    SELECT * FROM family_members
                    WHERE user_id = ?
                    ORDER BY is_active DESC, name ASC
                    """,
                    (user_id,),
                )
            return [dict(row) for row in cursor.fetchall()]

    def get_family_member(
        self, user_id: int, member_id: int
    ) -> dict[str, Any] | None:
        """Récupère un membre famille par ID"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            cursor.execute(
                """
                SELECT * FROM family_members
                WHERE id = ? AND user_id = ?
                """,
                (member_id, user_id),
            )
            row = cursor.fetchone()
            return dict(row) if row else None

    def update_family_member(
        self,
        user_id: int,
        member_id: int,
        name: str | None = None,
        email: str | None = None,
        phone: str | None = None,
        relationship: str | None = None,
        is_active: bool | None = None,
    ) -> bool:
        """Met à jour un membre famille"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            updates: list[str] = []
            params: list[Any] = []

            if name is not None:
                updates.append("name = ?")
                params.append(name)
            if email is not None:
                updates.append("email = ?")
                params.append(email)
            if phone is not None:
                updates.append("phone = ?")
                params.append(phone)
            if relationship is not None:
                updates.append("relationship = ?")
                params.append(relationship)
            if is_active is not None:
                updates.append("is_active = ?")
                params.append(is_active)

            if not updates:
                return False

            params.extend([member_id, user_id])
            cursor.execute(
                f"""
                UPDATE family_members
                SET {', '.join(updates)}
                WHERE id = ? AND user_id = ?
                """,
                params,
            )
            return cursor.rowcount > 0

    def delete_family_member(self, user_id: int, member_id: int) -> bool:
        """Supprime un membre famille"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            cursor.execute(
                """
                DELETE FROM family_members
                WHERE id = ? AND user_id = ?
                """,
                (member_id, user_id),
            )
            return cursor.rowcount > 0

    def share_document_with_member(
        self,
        user_id: int,
        document_id: str,
        member_email: str,
        permission_level: str = "view",
        is_encrypted: bool = True,
    ) -> int | None:
        """Partage un document avec un membre famille"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            try:
                # Vérifier si le partage existe déjà
                cursor.execute(
                    """
                    SELECT id FROM shared_documents
                    WHERE user_id = ? AND document_id = ? AND member_email = ?
                    """,
                    (user_id, document_id, member_email),
                )
                existing = cursor.fetchone()
                if existing and existing[0] is not None:
                    # Mettre à jour le partage existant
                    existing_id = int(existing[0])
                    cursor.execute(
                        """
                        UPDATE shared_documents
                        SET permission_level = ?, is_encrypted = ?, shared_at = CURRENT_TIMESTAMP
                        WHERE id = ?
                        """,
                        (permission_level, is_encrypted, existing_id),
                    )
                    return existing_id
                else:
                    # Créer un nouveau partage
                    cursor.execute(
                        """
                        INSERT INTO shared_documents (
                            user_id, document_id, member_email, permission_level, is_encrypted
                        )
                        VALUES (?, ?, ?, ?, ?)
                        """,
                        (user_id, document_id, member_email, permission_level, is_encrypted),
                    )
                    return cursor.lastrowid
            except sqlite3.IntegrityError:
                return None

    def get_shared_documents(
        self, user_id: int, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les documents partagés par un utilisateur"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    """
                    SELECT * FROM shared_documents
                    WHERE user_id = ?
                    ORDER BY shared_at DESC
                    LIMIT ? OFFSET ?
                    """,
                    (user_id, limit, skip),
                )
            else:
                cursor.execute(
                    """
                    SELECT * FROM shared_documents
                    WHERE user_id = ?
                    ORDER BY shared_at DESC
                    """,
                    (user_id,),
                )
            return [dict(row) for row in cursor.fetchall()]

    def get_shared_documents_for_member(
        self, member_email: str, skip: int = 0, limit: int | None = None
    ) -> list[dict[str, Any]]:
        """Récupère les documents partagés avec un membre"""
        with sqlite3.connect(self.db_path) as conn:
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            if limit is not None:
                cursor.execute(
                    """
                    SELECT * FROM shared_documents
                    WHERE member_email = ?
                    ORDER BY shared_at DESC
                    LIMIT ? OFFSET ?
                    """,
                    (member_email, limit, skip),
                )
            else:
                cursor.execute(
                    """
                    SELECT * FROM shared_documents
                    WHERE member_email = ?
                    ORDER BY shared_at DESC
                    """,
                    (member_email,),
                )
            return [dict(row) for row in cursor.fetchall()]

    def unshare_document(
        self, user_id: int, document_id: str, member_email: str | None = None
    ) -> bool:
        """Retire le partage d'un document"""
        with sqlite3.connect(self.db_path) as conn:
            cursor = conn.cursor()
            if member_email:
                # Retirer le partage pour un membre spécifique
                cursor.execute(
                    """
                    DELETE FROM shared_documents
                    WHERE user_id = ? AND document_id = ? AND member_email = ?
                    """,
                    (user_id, document_id, member_email),
                )
            else:
                # Retirer tous les partages du document
                cursor.execute(
                    """
                    DELETE FROM shared_documents
                    WHERE user_id = ? AND document_id = ?
                    """,
                    (user_id, document_id),
                )
            return cursor.rowcount > 0


# NOTE: Instance globale supprimée - utiliser get_database() via Depends() dans api.py
