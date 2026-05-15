import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/client_providers.dart';
import '../../domain/entities/client.dart';
import '../../../../l10n/app_localizations.dart';

class ClientDetailsScreen extends ConsumerWidget {
  final int clientId;
  const ClientDetailsScreen({super.key, required this.clientId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clientsAsync = ref.watch(clientsListProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clientDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditClientSheet(context, ref, clientId),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => _confirmDeleteClient(context, ref, l10n),
          ),
        ],
      ),
      body: clientsAsync.when(
        data: (clients) {
          final client = clients.firstWhere(
            (c) => c.id == clientId,
            orElse: () => throw Exception(l10n.noClients),
          );
          return _buildBody(context, client, l10n);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    Client client,
    AppLocalizations l10n,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                client.name[0].toUpperCase(),
                style: TextStyle(
                  fontSize: 40,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(context, [
            _buildInfoRow(context, Icons.person, l10n.name, client.name),
            _buildInfoRow(
              context,
              Icons.email,
              l10n.emailAddress,
              client.email ?? l10n.notProvided,
            ),
            _buildInfoRow(
              context,
              Icons.phone,
              l10n.phoneNumber,
              client.phone ?? l10n.notProvided,
            ),
            _buildInfoRow(
              context,
              Icons.location_on,
              l10n.address,
              client.address ?? l10n.notProvided,
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditClientSheet(BuildContext context, WidgetRef ref, int id) {
    final clients = ref.read(clientsListProvider).value ?? [];
    final client = clients.firstWhere((c) => c.id == id);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: EditClientForm(client: client),
      ),
    );
  }

  Future<void> _confirmDeleteClient(
    BuildContext context,
    WidgetRef ref,
    AppLocalizations l10n,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.delete),
        content: Text(l10n.deleteClientConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(clientRepositoryProvider).deleteClient(clientId);
        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.clientDeleted)),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!context.mounted) return;

        String message = l10n.error;
        final errorStr = e.toString();
        if (errorStr.contains('HAS_INVOICES')) {
          message = l10n.deleteClientErrorHasInvoices;
        } else if (errorStr.contains('HAS_PAYMENTS')) {
          message = l10n.deleteClientErrorHasPayments;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class EditClientForm extends ConsumerStatefulWidget {
  final Client client;
  const EditClientForm({super.key, required this.client});

  @override
  ConsumerState<EditClientForm> createState() => _EditClientFormState();
}

class _EditClientFormState extends ConsumerState<EditClientForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _emailController = TextEditingController(text: widget.client.email);
    _phoneController = TextEditingController(text: widget.client.phone);
    _addressController = TextEditingController(text: widget.client.address);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.editClient,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.name,
                prefixIcon: const Icon(Icons.person),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? l10n.requiredField : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: l10n.emailAddress,
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
                prefixIcon: const Icon(Icons.phone),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: l10n.address,
                prefixIcon: const Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final updatedClient = widget.client.copyWith(
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                  );
                  final navigator = Navigator.of(context);
                  await ref
                      .read(clientRepositoryProvider)
                      .updateClient(updatedClient);
                  if (!mounted) return;
                  navigator.pop();
                }
              },
              child: Text(l10n.updateClient),
            ),
          ],
        ),
      ),
    );
  }
}
