"""
Tests du parser avec PDFs générés
"""

import os
import sys
from pathlib import Path

# Ajouter le chemin parent pour les imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from services.health_portal_parsers import get_health_portal_parser

from tests.generate_test_pdfs import (
    generate_test_andaman7_pdf,
    generate_test_masante_pdf,
)


def test_andaman7_parser():
    """Tester le parser Andaman 7"""
    print("\n=== TEST PARSER ANDAMAN7 ===")

    # Générer PDF de test
    test_file = "test_andaman7.pdf"
    generate_test_andaman7_pdf(test_file)

    if not os.path.exists(test_file):
        print(f"❌ Erreur: {test_file} non créé")
        return False

    try:
        # Parser le PDF
        parser = get_health_portal_parser()
        result = parser.parse_portal_pdf(test_file, "andaman7")

        print(f"\n✅ Documents trouvés: {result.get('total_documents', 0)}")

        documents = result.get("documents", [])
        for i, doc in enumerate(documents, 1):
            print(f"\n  Document {i}:")
            print(f"    Type: {doc.get('type')}")
            print(f"    Date: {doc.get('date')}")
            print(f"    Praticien: {doc.get('practitioner')}")
            print(f"    Description: {doc.get('description', '')[:80]}...")

        # Assertions
        assert len(documents) > 0, "❌ Aucun document trouvé"
        assert any(d['type'] == 'Ordonnance' for d in documents), "❌ Ordonnance non trouvée"
        assert any(d['type'] == 'Consultation' for d in documents), "❌ Consultation non trouvée"

        print("\n✅ Tests Andaman7 PASSÉS")
        return True

    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        # Nettoyer
        if os.path.exists(test_file):
            os.unlink(test_file)


def test_masante_parser():
    """Tester le parser MaSanté"""
    print("\n=== TEST PARSER MASANTE ===")

    # Générer PDF de test
    test_file = "test_masante.pdf"
    generate_test_masante_pdf(test_file)

    if not os.path.exists(test_file):
        print(f"❌ Erreur: {test_file} non créé")
        return False

    try:
        # Parser le PDF
        parser = get_health_portal_parser()
        result = parser.parse_portal_pdf(test_file, "masante")

        print(f"\n✅ Documents trouvés: {result.get('total_documents', 0)}")

        documents = result.get("documents", [])
        for i, doc in enumerate(documents, 1):
            print(f"\n  Document {i}:")
            print(f"    Type: {doc.get('type')}")
            print(f"    Date: {doc.get('date')}")
            print(f"    Praticien: {doc.get('practitioner')}")

        # Assertions
        assert len(documents) > 0, "❌ Aucun document trouvé"

        print("\n✅ Tests MaSanté PASSÉS")
        return True

    except Exception as e:
        print(f"\n❌ Erreur: {e}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        # Nettoyer
        if os.path.exists(test_file):
            os.unlink(test_file)


def test_parser_integration():
    """Test d'intégration complet des parsers"""
    print("\n=== TEST INTÉGRATION PARSERS ===")
    
    results = {
        'andaman7': False,
        'masante': False,
    }
    
    try:
        results['andaman7'] = test_andaman7_parser()
        results['masante'] = test_masante_parser()
        
        total_tests = len(results)
        passed_tests = sum(1 for v in results.values() if v)
        
        print(f"\n📊 Résultats: {passed_tests}/{total_tests} tests passés")
        
        return all(results.values())
    except Exception as e:
        print(f"\n❌ Erreur dans test d'intégration: {e}")
        import traceback
        traceback.print_exc()
        return False


if __name__ == "__main__":
    print("🚀 Démarrage des tests de parser...")
    print("=" * 60)

    success_andaman7 = test_andaman7_parser()
    success_masante = test_masante_parser()
    
    # Test d'intégration
    success_integration = test_parser_integration()

    if success_andaman7 and success_masante and success_integration:
        print("\n" + "=" * 60)
        print("🎉 TOUS LES TESTS SONT PASSÉS !")
        print("=" * 60)
        sys.exit(0)
    else:
        print("\n" + "=" * 60)
        print("❌ Certains tests ont échoué")
        print("=" * 60)
        sys.exit(1)

