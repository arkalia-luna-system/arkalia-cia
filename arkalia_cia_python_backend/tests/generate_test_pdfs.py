"""
Générateur de PDFs de test pour valider les parsers Andaman 7 et MaSanté
"""

from reportlab.lib.pagesizes import letter
from reportlab.pdfgen import canvas
from datetime import datetime, timedelta
import random


def generate_test_andaman7_pdf(filename="test_andaman7.pdf"):
    """Générer un PDF qui ressemble à Andaman7"""
    c = canvas.Canvas(filename, pagesize=letter)

    c.setFont("Helvetica", 12)

    y = 750
    c.drawString(50, y, "ANDAMAN7 - MON DOSSIER DE SANTÉ")
    y -= 30

    # Ordonnance
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y, "Ordonnance")
    y -= 20
    c.setFont("Helvetica", 10)
    c.drawString(50, y, f"Date: 25/11/2025")
    y -= 15
    c.drawString(50, y, f"Médecin: Dr. Jean Dupont")
    y -= 15
    c.drawString(50, y, f"Prescriptions:")
    y -= 12
    c.drawString(70, y, "- Amoxicilline 500mg, 3x par jour pendant 7 jours")
    y -= 12
    c.drawString(70, y, "- Paracétamol 1000mg si douleur")

    y -= 25
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y, "Consultation")
    y -= 20
    c.setFont("Helvetica", 10)
    c.drawString(50, y, f"Date: 20/11/2025")
    y -= 15
    c.drawString(50, y, f"Médecin: Dr. Marie Martin")
    y -= 15
    c.drawString(50, y, f"Motif: Suivi diabète de type 2")
    y -= 12
    c.drawString(50, y, f"Observations: Tension bien contrôlée, glucose stable")

    y -= 25
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y, "Résultats")
    y -= 20
    c.setFont("Helvetica", 10)
    c.drawString(50, y, f"Date: 15/11/2025")
    y -= 15
    c.drawString(50, y, f"Glucose: 1.15 mmol/L")
    y -= 12
    c.drawString(50, y, f"Hémoglobine: 7.8 g/dL")
    y -= 12
    c.drawString(50, y, f"Créatinine: 0.9 mg/dL")

    c.save()
    print(f"✅ PDF test créé: {filename}")


def generate_test_masante_pdf(filename="test_masante.pdf"):
    """Générer un PDF qui ressemble à MaSanté"""
    c = canvas.Canvas(filename, pagesize=letter)
    c.setFont("Helvetica", 12)

    y = 750
    c.drawString(50, y, "MA SANTÉ - PORTAIL FÉDÉRAL DE SANTÉ")
    y -= 30
    c.drawString(50, y, "Dossier de Santé Électronique")
    y -= 20

    # Structure similaire mais légèrement différente
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y, "ORDONNANCE ÉLECTRONIQUE")
    y -= 20
    c.setFont("Helvetica", 10)
    c.drawString(50, y, "Émis le: 25/11/2025")
    y -= 15
    c.drawString(50, y, "Prescripteur: Dr. Pierre Lefevre")
    y -= 15
    c.drawString(50, y, "Médicaments:")
    y -= 12
    c.drawString(70, y, "• Lisinopril 10mg, 1x par jour")
    y -= 12
    c.drawString(70, y, "• Atorvastatine 20mg, 1x par jour")

    y -= 25
    c.setFont("Helvetica-Bold", 11)
    c.drawString(50, y, "CONSULTATION")
    y -= 20
    c.setFont("Helvetica", 10)
    c.drawString(50, y, "Date: 20/11/2025")
    y -= 15
    c.drawString(50, y, "Médecin: Docteur Sophie Bernard")
    y -= 15
    c.drawString(50, y, "Résumé: Consultation de suivi")

    c.save()
    print(f"✅ PDF test créé: {filename}")


if __name__ == "__main__":
    generate_test_andaman7_pdf()
    generate_test_masante_pdf()

