import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/api_service.dart';
import '../services/backend_config_service.dart';
import '../utils/error_helper.dart';
import '../utils/input_sanitizer.dart';
import '../widgets/senior_empty_state.dart';

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
          errorMessage =
              'Backend non configuré.\n\nVeuillez configurer l\'URL du backend dans les paramètres (Paramètres > Backend API).';
        } else if (!enabled) {
          errorMessage =
              'Backend non activé.\n\nVeuillez activer le backend dans les paramètres (Paramètres > Backend API).';
        } else {
          errorMessage =
              'Backend non configuré.\n\nVeuillez configurer le backend dans les paramètres (Paramètres > Backend API).';
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
            errorMessage =
                'Backend non configuré.\n\nVeuillez configurer l\'URL du backend dans les paramètres.';
          } else if (error.contains('Connection') || error.contains('Failed')) {
            errorMessage =
                'Impossible de se connecter au backend.\n\nVérifiez que le backend est démarré et que l\'URL est correcte.';
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
        errorMessage =
            'Backend non configuré.\n\nVeuillez configurer l\'URL du backend dans les paramètres.';
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
        ShareParams(text: _report!['formatted_text']),
      );
    } catch (e) {
      if (mounted) {
        ErrorHelper.logError('MedicalReportScreen._shareReport', e);
        final userMessage = ErrorHelper.getUserFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Impossible de partager : $userMessage'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapport médical'),
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
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
      body:
          _isLoading
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Préparation de votre rapport…',
                      style: TextStyle(
                        fontSize: 16,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              )
              : _error != null
              ? _buildErrorView()
              : _report == null
              ? SeniorEmptyState(
                icon: Icons.description_outlined,
                title: 'Aucun rapport',
                message:
                    'Aucun rapport n’est disponible pour le moment. Vous pouvez en générer un nouveau.',
                action: Semantics(
                  button: true,
                  label: 'Générer un rapport médical',
                  child: ElevatedButton.icon(
                    onPressed: _generateReport,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Générer le rapport'),
                  ),
                ),
              )
              : _buildReportView(),
    );
  }

  Widget _buildErrorView() {
    final scheme = Theme.of(context).colorScheme;
    return SeniorEmptyState(
      icon: Icons.error_outline,
      title: 'Rapport indisponible',
      message: _error ?? 'Une erreur est survenue. Veuillez réessayer.',
      useErrorAccent: true,
      action: Semantics(
        button: true,
        label: 'Réessayer de générer le rapport',
        child: ElevatedButton.icon(
          onPressed: _generateReport,
          icon: const Icon(Icons.refresh),
          label: const Text('Réessayer'),
          style: ElevatedButton.styleFrom(
            backgroundColor: scheme.primary,
            foregroundColor: scheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            minimumSize: const Size(48, 48),
          ),
        ),
      ),
    );
  }

  Widget _buildReportView() {
    final scheme = Theme.of(context).colorScheme;
    final formattedText = _report!['formatted_text'] as String? ?? '';
    final sections = _report!['sections'] as Map<String, dynamic>? ?? {};

    return Column(
      children: [
        if (widget.doctorName != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            color: scheme.primaryContainer.withValues(alpha: 0.45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: scheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Rapport pour : ${InputSanitizer.sanitize(widget.doctorName ?? '')}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: scheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_report!['report_date'] != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Date de consultation : ${_formatDate(_report!['report_date'])}',
                    style: TextStyle(
                      fontSize: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        if (sections.isNotEmpty) _buildQuickStats(sections),
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16.0),
            child: SelectableText(
              formattedText,
              style: TextStyle(
                fontSize: 14,
                fontFamily: 'monospace',
                height: 1.5,
                color: scheme.onSurface,
              ),
            ),
          ),
        ),
        if (formattedText.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: scheme.shadow.withValues(alpha: 0.12),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: Semantics(
                button: true,
                label: 'Partager le rapport médical',
                child: ElevatedButton.icon(
                  onPressed: _shareReport,
                  icon: const Icon(Icons.share),
                  label: const Text(
                    'Partager le rapport',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: scheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(48, 48),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildQuickStats(Map<String, dynamic> sections) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: scheme.secondaryContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (sections['documents'] != null)
            _buildStatItem(
              'Documents',
              '${sections['documents']['count'] ?? 0}',
              Icons.description,
              scheme.primary,
            ),
          if (sections['aria'] != null &&
              sections['aria']['pain_timeline'] != null)
            _buildStatItem(
              'Entrées douleur',
              '${sections['aria']['pain_timeline']['total_entries'] ?? 0}',
              Icons.favorite,
              scheme.error,
            ),
          if (sections['consultations'] != null)
            _buildStatItem(
              'Consultations',
              '${sections['consultations']['count'] ?? 0}',
              Icons.calendar_today,
              scheme.tertiary,
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color.withValues(alpha: 0.85),
          ),
        ),
        Text(label, style: TextStyle(fontSize: 14, color: onVariant)),
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
