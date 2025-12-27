import 'package:flutter/material.dart';
import '../services/pathology_service.dart';
import '../models/pathology.dart';
import '../models/pathology_tracking.dart';

class PathologyTrackingScreen extends StatefulWidget {
  final int pathologyId;
  final PathologyTracking? existingEntry;

  const PathologyTrackingScreen({
    super.key,
    required this.pathologyId,
    this.existingEntry,
  });

  @override
  State<PathologyTrackingScreen> createState() => _PathologyTrackingScreenState();
}

class _PathologyTrackingScreenState extends State<PathologyTrackingScreen> {
  final PathologyService _pathologyService = PathologyService();
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  
  Pathology? _pathology;
  DateTime _selectedDate = DateTime.now();
  final Map<String, dynamic> _trackingData = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingEntry != null) {
      // Mode édition : pré-remplir les champs
      _selectedDate = widget.existingEntry!.date;
      _trackingData.addAll(widget.existingEntry!.data);
      if (widget.existingEntry!.notes != null) {
        _notesController.text = widget.existingEntry!.notes!;
      }
    }
    _loadPathology();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadPathology() async {
    setState(() => _isLoading = true);
    try {
      final pathology = await _pathologyService.getPathologyById(widget.pathologyId);
      if (mounted) {
        setState(() {
          _pathology = pathology;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateTrackingData(String key, dynamic value) {
    setState(() {
      _trackingData[key] = value;
    });
  }

  Future<void> _saveTracking() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      if (widget.existingEntry != null && widget.existingEntry!.id != null) {
        // Mode édition
        final tracking = PathologyTracking(
          id: widget.existingEntry!.id,
          pathologyId: widget.pathologyId,
          date: _selectedDate,
          data: _trackingData,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        await _pathologyService.updateTracking(tracking);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrée modifiée avec succès')),
          );
        }
      } else {
        // Mode création
        final tracking = PathologyTracking(
          pathologyId: widget.pathologyId,
          date: _selectedDate,
          data: _trackingData,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );
        await _pathologyService.insertTracking(tracking);
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Entrée enregistrée avec succès')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle entrée'),
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_pathology == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nouvelle entrée'),
          backgroundColor: Colors.purple[600],
          foregroundColor: Colors.white,
        ),
        body: const Center(child: Text('Pathologie introuvable')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingEntry != null 
            ? 'Modifier l\'entrée - ${_pathology!.name}'
            : 'Suivi - ${_pathology!.name}'),
        backgroundColor: _pathology!.color,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date
              Card(
                child: ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Date'),
                  subtitle: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 16),

              // Champs adaptatifs selon la pathologie
              ..._buildAdaptiveFields(),

              // Notes
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Ajoutez des notes...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton sauvegarder
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveTracking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _pathology!.color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.existingEntry != null ? 'Modifier' : 'Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAdaptiveFields() {
    final fields = <Widget>[];

    // Douleur (pour toutes les pathologies)
    fields.add(
      Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Niveau de douleur (0-10)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Slider(
                value: (_trackingData['painLevel'] as num?)?.toDouble() ?? 0.0,
                min: 0,
                max: 10,
                divisions: 10,
                label: '${(_trackingData['painLevel'] as num?)?.toInt() ?? 0}/10',
                onChanged: (value) {
                  _updateTrackingData('painLevel', value.toInt());
                },
              ),
              Text(
                'Niveau: ${(_trackingData['painLevel'] as num?)?.toInt() ?? 0}/10',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
    fields.add(const SizedBox(height: 16));

    // Champs spécifiques selon la pathologie
    final name = _pathology!.name.toLowerCase();

    if (name.contains('endométriose') || name.contains('endometriose')) {
      // Cycle
      fields.add(_buildTextField(
        'Jour du cycle',
        'cycle',
        hint: 'Ex: 5',
        keyboardType: TextInputType.number,
      ));
      fields.add(const SizedBox(height: 16));

      // Saignements
      fields.add(_buildCheckboxField(
        'Saignements',
        'bleeding',
      ));
      fields.add(const SizedBox(height: 16));

      // Fatigue
      fields.add(_buildSliderField(
        'Fatigue (0-10)',
        'fatigue',
        min: 0,
        max: 10,
      ));
      fields.add(const SizedBox(height: 16));
    }

    if (name.contains('cancer') || name.contains('myélome') || name.contains('myelome')) {
      // Effets secondaires
      fields.add(_buildMultiSelectField(
        'Effets secondaires',
        'sideEffects',
        ['Nausées', 'Fatigue', 'Perte d\'appétit', 'Douleurs'],
      ));
      fields.add(const SizedBox(height: 16));

      // Traitement
      fields.add(_buildTextField(
        'Traitement reçu',
        'treatment',
        hint: 'Ex: Chimiothérapie cycle 3',
      ));
      fields.add(const SizedBox(height: 16));
    }

    if (name.contains('ostéoporose') || name.contains('osteoporose')) {
      // Fracture
      fields.add(_buildCheckboxField(
        'Fracture',
        'fracture',
      ));
      fields.add(const SizedBox(height: 16));

      // Activité physique
      fields.add(_buildTextField(
        'Activité physique (minutes)',
        'physicalActivity',
        hint: 'Ex: 30',
        keyboardType: TextInputType.number,
      ));
      fields.add(const SizedBox(height: 16));
    }

    if (name.contains('arthr') || name.contains('tendinite') || name.contains('spondyl')) {
      // Localisation
      fields.add(_buildTextField(
        'Localisation de la douleur',
        'location',
        hint: 'Ex: Genou droit',
      ));
      fields.add(const SizedBox(height: 16));

      // Mobilité
      fields.add(_buildSliderField(
        'Mobilité (0-10)',
        'mobility',
        min: 0,
        max: 10,
      ));
      fields.add(const SizedBox(height: 16));

      // Médicaments pris
      fields.add(_buildCheckboxField(
        'Médicaments pris',
        'medicationTaken',
      ));
      fields.add(const SizedBox(height: 16));
    }

    if (name.contains('parkinson')) {
      // Tremblements
      fields.add(_buildSliderField(
        'Tremblements (0-10)',
        'tremors',
        min: 0,
        max: 10,
      ));
      fields.add(const SizedBox(height: 16));

      // Rigidité
      fields.add(_buildSliderField(
        'Rigidité (0-10)',
        'rigidity',
        min: 0,
        max: 10,
      ));
      fields.add(const SizedBox(height: 16));

      // Médicaments pris
      fields.add(_buildCheckboxField(
        'Médicaments pris',
        'medicationTaken',
      ));
      fields.add(const SizedBox(height: 16));
    }

    // Symptômes génériques
    if (_pathology!.symptoms.isNotEmpty) {
      fields.add(_buildMultiSelectField(
        'Symptômes présents',
        'symptoms',
        _pathology!.symptoms,
      ));
      fields.add(const SizedBox(height: 16));
    }

    return fields;
  }

  Widget _buildTextField(
    String label,
    String key, {
    String? hint,
    TextInputType? keyboardType,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                border: const OutlineInputBorder(),
              ),
              keyboardType: keyboardType,
              onChanged: (value) {
                _updateTrackingData(key, value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderField(
    String label,
    String key, {
    required double min,
    required double max,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: (_trackingData[key] as num?)?.toDouble() ?? min,
              min: min,
              max: max,
              divisions: (max - min).toInt(),
              label: '${(_trackingData[key] as num?)?.toInt() ?? min.toInt()}',
              onChanged: (value) {
                _updateTrackingData(key, value.toInt());
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxField(String label, String key) {
    return Card(
      child: CheckboxListTile(
        title: Text(label),
        value: _trackingData[key] as bool? ?? false,
        onChanged: (value) {
          _updateTrackingData(key, value ?? false);
        },
      ),
    );
  }

  Widget _buildMultiSelectField(
    String label,
    String key,
    List<String> options,
  ) {
    final selected = (_trackingData[key] as List?)?.cast<String>() ?? [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = selected.contains(option);
                return FilterChip(
                  label: Text(option),
                  selected: isSelected,
                  onSelected: (value) {
                    setState(() {
                      final newSelected = List<String>.from(selected);
                      if (value) {
                        if (!newSelected.contains(option)) {
                          newSelected.add(option);
                        }
                      } else {
                        newSelected.remove(option);
                      }
                      _updateTrackingData(key, newSelected);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

