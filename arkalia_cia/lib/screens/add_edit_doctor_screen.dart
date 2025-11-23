import 'package:flutter/material.dart';
import '../services/doctor_service.dart';
import '../models/doctor.dart';
import '../utils/error_helper.dart';

class AddEditDoctorScreen extends StatefulWidget {
  final Doctor? doctor;
  final Map<String, dynamic>? detectedData; // Données détectées depuis PDF

  const AddEditDoctorScreen({super.key, this.doctor, this.detectedData});

  @override
  State<AddEditDoctorScreen> createState() => _AddEditDoctorScreenState();
}

class _AddEditDoctorScreenState extends State<AddEditDoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _doctorService = DoctorService();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _specialtyController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _notesController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.doctor != null) {
      _firstNameController.text = widget.doctor!.firstName;
      _lastNameController.text = widget.doctor!.lastName;
      _specialtyController.text = widget.doctor!.specialty ?? '';
      _phoneController.text = widget.doctor!.phone ?? '';
      _emailController.text = widget.doctor!.email ?? '';
      _addressController.text = widget.doctor!.address ?? '';
      _cityController.text = widget.doctor!.city ?? '';
      _postalCodeController.text = widget.doctor!.postalCode ?? '';
      _notesController.text = widget.doctor!.notes ?? '';
    } else if (widget.detectedData != null) {
      // Pré-remplir avec données détectées depuis PDF
      final data = widget.detectedData!;
      final doctorName = data['doctor_name'] as String?;
      if (doctorName != null) {
        final parts = doctorName.split(' ');
        if (parts.isNotEmpty) {
          _firstNameController.text = parts[0];
          if (parts.length > 1) {
            _lastNameController.text = parts.sublist(1).join(' ');
          }
        }
      }
      _specialtyController.text = data['doctor_specialty'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _addressController.text = data['address'] ?? '';
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _specialtyController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveDoctor() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final doctor = Doctor(
        id: widget.doctor?.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        specialty: _specialtyController.text.trim().isEmpty 
            ? null 
            : _specialtyController.text.trim(),
        phone: _phoneController.text.trim().isEmpty 
            ? null 
            : _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty 
            ? null 
            : _emailController.text.trim(),
        address: _addressController.text.trim().isEmpty 
            ? null 
            : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty 
            ? null 
            : _cityController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty 
            ? null 
            : _postalCodeController.text.trim(),
        notes: _notesController.text.trim().isEmpty 
            ? null 
            : _notesController.text.trim(),
      );

      if (widget.doctor == null) {
        await _doctorService.insertDoctor(doctor);
      } else {
        await _doctorService.updateDoctor(doctor);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ErrorHelper.logError('AddEditDoctorScreen._saveDoctor', e);
        final userMessage = ErrorHelper.getUserFriendlyMessage(e);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.doctor == null ? 'Ajouter un médecin' : 'Modifier médecin'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _formKey.currentState?.validate() == true ? _saveDoctor : null,
              tooltip: 'Enregistrer',
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Nom
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Prénom *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le prénom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nom *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            // Spécialité
            TextFormField(
              controller: _specialtyController,
              decoration: const InputDecoration(
                labelText: 'Spécialité',
                border: OutlineInputBorder(),
                hintText: 'Ex: Cardiologue, Généraliste',
              ),
            ),
            const SizedBox(height: 16),
            
            // Téléphone
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            
            // Email
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            
            // Adresse
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),
            
            // Ville et Code postal
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Code postal',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Notes
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            
            // Bouton sauvegarder
            ElevatedButton(
              onPressed: _isSaving ? null : _saveDoctor,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: _isSaving
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(widget.doctor == null ? 'Ajouter' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }
}

