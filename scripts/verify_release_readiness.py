#!/usr/bin/env python3
"""
Script de vérification automatique de la préparation à la release
Vérifie tous les points de la checklist sans nécessiter l'ouverture de l'app
"""

import subprocess
import sys
from pathlib import Path
from typing import Any

# Configuration
PROJECT_ROOT = Path(__file__).parent.parent
ARKALIA_CIA_DIR = PROJECT_ROOT / "arkalia_cia"
BUILD_DIR = ARKALIA_CIA_DIR / "build" / "app" / "outputs"
SCREENSHOTS_DIR = PROJECT_ROOT / "docs" / "screenshots"


def run_command(
    cmd: list[str], cwd: Path | None = None, timeout: int = 60
) -> tuple[int, str, str]:
    """Exécute une commande et retourne le code de retour, stdout et stderr"""
    try:
        result = subprocess.run(
            cmd,
            cwd=cwd or PROJECT_ROOT,
            capture_output=True,
            text=True,
            timeout=timeout,
        )
        return result.returncode, result.stdout, result.stderr
    except subprocess.TimeoutExpired:
        return 1, "", "Command timeout"
    except Exception as e:
        return 1, "", str(e)


def check_python_tests() -> dict[str, Any]:
    """Vérifie que tous les tests Python passent"""
    print("🔍 Vérification tests Python...")
    code, stdout, stderr = run_command(
        ["python3", "-m", "pytest", "tests/", "-q", "--tb=no", "--maxfail=1"],
        timeout=120,
    )

    if code == 0:
        # Extraire le nombre de tests
        lines = stdout.split("\n")
        test_count = 0
        for line in lines:
            if "passed" in line.lower():
                parts = line.split()
                for part in parts:
                    if part.isdigit():
                        test_count = int(part)
                        break

        return {
            "status": "✅",
            "passed": True,
            "test_count": test_count,
            "message": f"Tous les tests passent ({test_count} tests)",
        }
    else:
        return {
            "status": "❌",
            "passed": False,
            "message": "Des tests échouent",
            "error": stderr,
        }


def check_code_quality() -> dict[str, Any]:
    """Vérifie la qualité du code (Black, Ruff, MyPy, Bandit)"""
    print("🔍 Vérification qualité code...")
    results = {}

    # Black (rapide)
    code, stdout, stderr = run_command(
        ["black", "--check", "arkalia_cia_python_backend/", "tests/"], timeout=30
    )
    results["black"] = {
        "status": "✅" if code == 0 else "❌",
        "passed": code == 0,
    }

    # Ruff (rapide)
    code, stdout, stderr = run_command(
        ["ruff", "check", "arkalia_cia_python_backend/", "tests/"], timeout=30
    )
    results["ruff"] = {
        "status": "✅" if code == 0 else "❌",
        "passed": code == 0,
        "output": stdout if code != 0 else "",
    }

    # MyPy (peut être lent, timeout réduit)
    code, stdout, stderr = run_command(
        ["mypy", "arkalia_cia_python_backend/", "--ignore-missing-imports"], timeout=45
    )
    results["mypy"] = {
        "status": "✅" if code == 0 else "⚠️",
        "passed": code == 0,
    }

    # Bandit (peut être lent, timeout réduit)
    code, stdout, stderr = run_command(
        ["bandit", "-r", "arkalia_cia_python_backend/", "-ll"], timeout=45
    )
    results["bandit"] = {
        "status": "✅" if "No issues identified" in stdout else "❌",
        "passed": "No issues identified" in stdout,
    }

    all_passed = all(r["passed"] for r in results.values())
    return {
        "status": "✅" if all_passed else "⚠️",
        "passed": all_passed,
        "details": results,
    }


def check_build_exists() -> dict[str, Any]:
    """Vérifie si le build release Android existe"""
    print("🔍 Vérification build release Android...")

    apk_path = BUILD_DIR / "flutter-apk" / "app-release.apk"
    aab_path = BUILD_DIR / "bundle" / "release" / "app-release.aab"

    apk_exists = apk_path.exists()
    aab_exists = aab_path.exists()

    if apk_exists:
        size = apk_path.stat().st_size / (1024 * 1024)  # MB
        return {
            "status": "✅",
            "passed": True,
            "apk_exists": True,
            "aab_exists": aab_exists,
            "apk_size_mb": round(size, 2),
            "apk_path": str(apk_path),
            "message": f"APK existe ({size:.1f} MB)",
        }
    else:
        return {
            "status": "❌",
            "passed": False,
            "apk_exists": False,
            "aab_exists": False,
            "message": "Build APK n'existe pas - À créer avec: flutter build apk --release",
        }


def check_screenshots() -> dict[str, Any]:
    """Vérifie l'existence des screenshots"""
    print("🔍 Vérification screenshots...")

    android_dir = SCREENSHOTS_DIR / "android"
    ios_dir = SCREENSHOTS_DIR / "ios"

    android_screenshots = (
        list(android_dir.glob("*.jpeg")) + list(android_dir.glob("*.png"))
        if android_dir.exists()
        else []
    )
    ios_screenshots = (
        list(ios_dir.glob("*.jpeg")) + list(ios_dir.glob("*.png"))
        if ios_dir.exists()
        else []
    )

    return {
        "status": "✅" if android_screenshots else "⚠️",
        "android_count": len(android_screenshots),
        "ios_count": len(ios_screenshots),
        "android_exists": len(android_screenshots) > 0,
        "ios_exists": len(ios_screenshots) > 0,
        "message": f"Android: {len(android_screenshots)} screenshots, iOS: {len(ios_screenshots)} screenshots",
    }


def check_security_checklist() -> dict[str, Any]:
    """Vérifie la checklist sécurité"""
    print("🔍 Vérification checklist sécurité...")

    checks = {}

    # Vérifier chiffrement AES-256
    encryption_file = ARKALIA_CIA_DIR / "lib" / "utils" / "encryption_helper.dart"
    if encryption_file.exists():
        content = encryption_file.read_text()
        checks["aes256"] = {
            "status": "✅" if "AES" in content and "256" in content else "❌",
            "passed": "AES" in content and "256" in content,
        }
    else:
        checks["aes256"] = {"status": "❌", "passed": False}

    # Vérifier authentification biométrique
    auth_file = ARKALIA_CIA_DIR / "lib" / "services" / "auth_service.dart"
    if auth_file.exists():
        content = auth_file.read_text()
        checks["biometric"] = {
            "status": "✅" if "LocalAuthentication" in content else "❌",
            "passed": "LocalAuthentication" in content,
        }
    else:
        checks["biometric"] = {"status": "❌", "passed": False}

    # Vérifier Privacy Policy
    privacy_file = PROJECT_ROOT / "PRIVACY_POLICY.txt"
    checks["privacy_policy"] = {
        "status": "✅" if privacy_file.exists() else "❌",
        "passed": privacy_file.exists(),
    }

    # Vérifier Terms of Service
    terms_file = PROJECT_ROOT / "TERMS_OF_SERVICE.txt"
    checks["terms_of_service"] = {
        "status": "✅" if terms_file.exists() else "❌",
        "passed": terms_file.exists(),
    }

    all_passed = all(c["passed"] for c in checks.values())
    return {
        "status": "✅" if all_passed else "⚠️",
        "passed": all_passed,
        "details": checks,
    }


def check_flutter_analyze() -> dict[str, Any]:
    """Vérifie Flutter analyze"""
    print("🔍 Vérification Flutter analyze...")
    code, stdout, stderr = run_command(
        ["flutter", "analyze", ARKALIA_CIA_DIR], timeout=60
    )

    if code == 0:
        return {
            "status": "✅",
            "passed": True,
            "message": "Flutter analyze: Aucune erreur",
        }
    else:
        errors = stdout.count("error •") + stderr.count("error •")
        warnings = stdout.count("warning •") + stderr.count("warning •")
        return {
            "status": "⚠️" if errors == 0 else "❌",
            "passed": errors == 0,
            "errors": errors,
            "warnings": warnings,
            "message": f"Flutter analyze: {errors} erreurs, {warnings} warnings",
        }


def generate_report(results: dict[str, Any]) -> str:
    """Génère un rapport de vérification"""
    report = []
    report.append("=" * 70)
    report.append("📋 RAPPORT DE VÉRIFICATION AUTOMATIQUE - RELEASE READINESS")
    report.append("=" * 70)
    report.append("")

    # Tests Python
    test_result = results.get("tests", {})
    report.append(f"🧪 Tests Python: {test_result.get('status', '❓')}")
    report.append(f"   {test_result.get('message', 'Non vérifié')}")
    report.append("")

    # Qualité code
    quality_result = results.get("code_quality", {})
    report.append(f"✨ Qualité Code: {quality_result.get('status', '❓')}")
    if "details" in quality_result:
        for tool, result in quality_result["details"].items():
            report.append(f"   - {tool}: {result['status']}")
    report.append("")

    # Build
    build_result = results.get("build", {})
    report.append(f"📦 Build Release Android: {build_result.get('status', '❓')}")
    report.append(f"   {build_result.get('message', 'Non vérifié')}")
    if build_result.get("apk_exists"):
        report.append(f"   Taille APK: {build_result.get('apk_size_mb', 0)} MB")
    report.append("")

    # Screenshots
    screenshots_result = results.get("screenshots", {})
    report.append(f"📸 Screenshots: {screenshots_result.get('status', '❓')}")
    report.append(f"   {screenshots_result.get('message', 'Non vérifié')}")
    report.append("")

    # Sécurité
    security_result = results.get("security", {})
    report.append(f"🔒 Checklist Sécurité: {security_result.get('status', '❓')}")
    if "details" in security_result:
        for check, result in security_result["details"].items():
            report.append(f"   - {check}: {result['status']}")
    report.append("")

    # Flutter Analyze
    flutter_result = results.get("flutter_analyze", {})
    report.append(f"🔍 Flutter Analyze: {flutter_result.get('status', '❓')}")
    report.append(f"   {flutter_result.get('message', 'Non vérifié')}")
    report.append("")

    # Résumé
    report.append("=" * 70)
    all_passed = all(
        [
            test_result.get("passed", False),
            quality_result.get("passed", False),
            build_result.get("passed", False),
            security_result.get("passed", False),
            flutter_result.get("passed", False),
        ]
    )

    if all_passed:
        report.append("✅ TOUS LES CHECKS AUTOMATIQUES PASSENT")
        report.append("")
        report.append("⚠️  CE QUI RESTE À FAIRE MANUELLEMENT:")
        report.append("   1. Tests manuels sur device réel (iPhone + Android)")
        report.append("   2. Vérifier visuellement les screenshots")
        report.append("   3. Prendre screenshots iOS si nécessaire")
        report.append("   4. Tests de stabilité (usage prolongé)")
    else:
        report.append("⚠️  CERTAINS CHECKS ÉCHOUENT - CORRIGER AVANT RELEASE")

    report.append("=" * 70)

    return "\n".join(report)


def main():
    """Fonction principale"""
    print("🚀 Démarrage vérification automatique de release readiness...")
    print("")

    results = {}

    # Tests Python
    results["tests"] = check_python_tests()

    # Qualité code
    results["code_quality"] = check_code_quality()

    # Build
    results["build"] = check_build_exists()

    # Screenshots
    results["screenshots"] = check_screenshots()

    # Sécurité
    results["security"] = check_security_checklist()

    # Flutter Analyze
    results["flutter_analyze"] = check_flutter_analyze()

    # Générer rapport
    report = generate_report(results)
    print("")
    print(report)

    # Sauvegarder rapport
    report_file = PROJECT_ROOT / "docs" / "RELEASE_READINESS_REPORT.txt"
    report_file.write_text(report)
    print("")
    print(f"📄 Rapport sauvegardé: {report_file}")

    # Code de retour
    all_passed = all(
        [
            results["tests"].get("passed", False),
            results["code_quality"].get("passed", False),
            results["build"].get("passed", False),
            results["security"].get("passed", False),
            results["flutter_analyze"].get("passed", False),
        ]
    )

    return 0 if all_passed else 1


if __name__ == "__main__":
    sys.exit(main())
