"""
Configuration pytest globale pour Arkalia CIA
Protection contre les lancements multiples et optimisation des performances
"""
import os
import subprocess
import sys


def pytest_configure(config):
    """
    Hook pytest appelé au démarrage pour vérifier qu'aucun autre pytest ne tourne.
    Évite les explosions de processus qui surchargent le CPU.
    """
    # Vérifier s'il y a déjà des processus pytest en cours (sauf celui-ci)
    try:
        # Compter les processus pytest (exclure celui-ci)
        result = subprocess.run(
            ["pgrep", "-f", "pytest"],
            capture_output=True,
            text=True,
            timeout=2
        )

        if result.returncode == 0:
            # Il y a des processus pytest
            pids = result.stdout.strip().split('\n')
            current_pid = str(os.getpid())

            # Filtrer le PID actuel
            other_pids = [pid for pid in pids if pid and pid != current_pid]

            if other_pids:
                count = len(other_pids)
                print(
                    f"\n⚠️  ATTENTION: {count} processus pytest déjà en cours d'exécution!\n"
                    f"   PIDs: {', '.join(other_pids[:5])}{'...' if len(other_pids) > 5 else ''}\n"
                    f"   Cela peut causer une surcharge CPU excessive.\n"
                    f"   Recommandation: Utiliser ./scripts/run_tests.sh qui nettoie automatiquement.\n"
                    f"   Ou arrêter les processus: pkill -f 'pytest tests/'\n",
                    file=sys.stderr,
                )

                # En mode non-interactif (CI), on continue quand même
                # En mode interactif, on peut demander confirmation
                if sys.stdin.isatty():
                    response = input(
                        "   Continuer quand même? (o/N): "
                    ).strip().lower()
                    if response not in ('o', 'oui', 'y', 'yes'):
                        print("   Arrêt pour éviter la surcharge CPU.", file=sys.stderr)
                        sys.exit(1)
    except (subprocess.TimeoutExpired, FileNotFoundError, subprocess.SubprocessError):
        # pgrep n'est pas disponible (Windows) ou erreur - on continue
        pass


def pytest_collection_modifyitems(config, items):
    """
    Hook pour modifier la collection de tests si nécessaire.
    Peut être utilisé pour limiter le nombre de tests en parallèle.
    """
    # Optionnel: limiter le nombre de tests si trop nombreux
    # max_tests = int(os.getenv('PYTEST_MAX_TESTS', '0'))
    # if max_tests > 0 and len(items) > max_tests:
    #     items[:] = items[:max_tests]
    pass

