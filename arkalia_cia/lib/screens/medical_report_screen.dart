import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../services/backend_config_service.dart';
import '../utils/error_helper.dart';
import '../utils/input_sanitizer.dart';

class MedicalReportScreen extends StatefulWidget {
  final String? consultationDate;
  final int? doctorId;
  final String? doctorName;

  const MedicalReportScreen({
    super.key,
    this.consultationDate,
    this.doctorId,
    this.doctorName,
  });

  @override
  State<MedicalReportScreen> createState() => _MedicalReportScreenState();
}

class _MedicalReportScreenState extends State<MedicalReportScreen> {
  Map<String, dynamic>? _report;
  bool _isLoading = false;
  String? _error;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Vérifier si le backend est configuré
      final backendConfigured = await ApiService.isBackendConfigured();
      if (!backendConfigured) {
        final url = await BackendConfigService.getBackendURL();
        final enabled = await BackendConfigService.isBackendEnabled();
        String errorMessage;
        if (url.isEmpty) {
          errorMessage = 'Backend non configuré.\n\nVeuillez configurer l\'URL du backend dans les paramètres (⚙️ > Backend API).';
        } else if (!enabled) {
          errorMessage = 'Backend non activé.\n\nVeuillez activer le backend dans les paramètres (⚙️ > Backend API).';
        } else {
          errorMessage = 'Backend non configuré.\n\nVeuillez configurer le backend dans les paramètres (⚙️ > Backend API).';
        }
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
        return;
      }

      final result = await ApiService.generateMedicalReport(
        consultationDate: widget.consultationDate,
        daysRange: 30,
        includeAria: true,
      );

      if (result['success'] == true || result['formatted_text'] != null) {
        setState(() {
          _report = result;
          _isLoading = false;
        });
      } else {
        // Message d'erreur plus clair
        String errorMessage = 'Erreur lors de la génération du rapport';
        if (result['error'] != null) {
          final error = result['error'] as String;
          if (error.contains('Backend non configuré')) {
            errorMessage = 'Backend non configuré.\n\nVeuillez configurer l\'URL du backend dans les paramètres.';
          } else if (error.contains('Connection') || error.contains('Failed')) {
            errorMessage = 'Impossible de se connecter au backend.\n\nVérifiez que le backend est démarré et que l\'URL est correcte.';
          } else {
            errorMessage = error;
          }
        }
        
        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      }
    } catch (e) {
      ErrorHelper.logError('MedicalReportScreen._generateReport', e);
      String errorMessage;
      final errorStr = e.toString();
      if (errorStr.contains('Backend non configuré')) {
        errorMessage = 'Backend non configuré.\n\nVeuillez configurer l\'URL du backend dans les paramètres.';
      } else {
        // Utiliser ErrorHelper pour les messages génériques
        errorMessage = ErrorHelper.getUserFriendlyMessage(e);
      }
      
      setState(() {
        _error = errorMessage;
        _isLoading = false;
      });
    }
  }

  Future<void> _shareReport() async {
    if (_report == null || _report!['formatted_text'] == null) return;

    try {
      await SharePlus.instance.share(
        ShareParams(
          text: _report!['formatted_text'],
        ),
      );
    } catch (e) {
      if (mounted) {
        ErrorHelper.logError('MedicalReportScreen._shareReport', e);
        final userMessage = ErrorHelper.getUserFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du partage: $userMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport Médical'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        actions: [
          if (_report != null && _report!['formatted_text'] != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareReport,
              tooltip: 'Partager le rapport',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _generateReport,
            tooltip: 'Régénérer le rapport',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _report == null
                  ? const Center(child: Text('Aucun rapport disponible'))
                  : _buildReportView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Erreur inconnue',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportView() {
    final formattedText = _report!['formatted_text'] as String? ?? '';
    final sections = _report!['sections'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        // En-tête avec informations
        if (widget.doctorName != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: Colors.green[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Text(
                      // Sanitizer à l'affichage pour prévenir XSS
                      'Rapport pour: ${InputSanitizer.sanitize(widget.doctorName ?? '')}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[900],
                      ),
                    ),
                  ],
                ),
                if (_report!['report_date'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Date de consultation: ${_formatDate(_report!['report_date'])}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ],
            ),
          ),

        // Statistiques rapides
        if (sections.isNotEmpty) _buildQuickStats(sections),

        // Rapport complet
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(
              formattedText,
              style: TextStyle(
                fontSize: 14, // Minimum 14sp pour accessibilité seniors
                fontFamily: 'monospace',
                height: 1.5,
                color: Colors.grey[900],
              ),
            ),
          ),
        ),

        // Bouton partager en bas
        if (formattedText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _shareReport,
                icon: const Icon(Icons.share),
                label: const Text(
                  'Partager le rapport',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> sections) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (sections['documents'] != null)
            _buildStatItem(
              'Documents',
              '${sections['documents']['count'] ?? 0}',
              Icons.description,
              Colors.blue,
            ),
          if (sections['aria'] != null && sections['aria']['pain_timeline'] != null)
            _buildStatItem(
              'Entrées douleur',
              '${sections['aria']['pain_timeline']['total_entries'] ?? 0}',
              Icons.favorite,
              Colors.red,
            ),
          if (sections['consultations'] != null)
            _buildStatItem(
              'Consultations',
              '${sections['consultations']['count'] ?? 0}',
              Icons.calendar_today,
              Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color.withOpacity(0.8),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr.replaceAll('Z', ''));
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

