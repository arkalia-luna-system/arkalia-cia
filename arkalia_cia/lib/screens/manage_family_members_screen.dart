import 'package:flutter/material.dart';
import '../services/family_sharing_service.dart';

class ManageFamilyMembersScreen extends StatefulWidget {
  const ManageFamilyMembersScreen({super.key});

  @override
  State<ManageFamilyMembersScreen> createState() => _ManageFamilyMembersScreenState();
}

class _ManageFamilyMembersScreenState extends State<ManageFamilyMembersScreen> {
  final FamilySharingService _sharingService = FamilySharingService();
  List<FamilyMember> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    try {
      final members = await _sharingService.getFamilyMembers();
      setState(() {
        _members = members;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addMember() async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => _AddMemberDialog(),
    );

    if (result != null) {
      final member = FamilyMember(
        name: result['name']!,
        email: result['email']!,
        phone: result['phone'],
        relationship: result['relationship']!,
      );
      await _sharingService.addFamilyMember(member);
      _loadMembers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gérer membres famille'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ElevatedButton.icon(
                    onPressed: _addMember,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un membre'),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                ),
                Expanded(
                  child: _members.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_outline, size: 64, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                'Aucun membre famille',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final member = _members[index];
                            return ListTile(
                              leading: CircleAvatar(
                                child: Text(member.name[0].toUpperCase()),
                              ),
                              title: Text(member.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(member.email),
                                  if (member.phone != null) Text('📞 ${member.phone}'),
                                  Text('Relation: ${member.relationship}'),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  String _relationship = 'Famille';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter membre famille'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom *'),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email *'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
              ),
              DropdownButtonFormField<String>(
                initialValue: _relationship,
                decoration: const InputDecoration(labelText: 'Relation'),
                items: ['Famille', 'Conjoint', 'Enfant', 'Parent', 'Autre']
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => setState(() => _relationship = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, {
                'name': _nameController.text,
                'email': _emailController.text,
                'phone': _phoneController.text.isEmpty ? null : _phoneController.text,
                'relationship': _relationship,
              });
            }
          },
          child: const Text('Ajouter'),
        ),
      ],
    );
  }
}

