import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/client_providers.dart';
import '../../domain/entities/client.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/contextual_fab.dart';
import '../../../../core/widgets/entity_card.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../l10n/app_localizations.dart';

class ClientListScreen extends ConsumerWidget {
  const ClientListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final clientsAsync = ref.watch(searchedClientsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.clients),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              onChanged: (value) =>
                  ref.read(clientSearchProvider.notifier).update(value),
              decoration: InputDecoration(
                hintText: l10n.searchClients,
                prefixIcon: const Icon(Icons.search),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: clientsAsync.when(
        data: (clients) => clients.isEmpty
            ? _buildEmptyState(context, l10n)
            : ResponsiveContent(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.xs,
                    AppSpacing.bottomNavClearance,
                  ),
                  itemCount: clients.length,
                  itemBuilder: (context, index) =>
                      _buildClientCard(context, clients[index], l10n),
                ),
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
      floatingActionButton: ContextualFab(
        onPressed: () => _showAddClientSheet(context),
        tooltip: l10n.addClient,
        icon: Icons.add,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return AppEmptyState(
      icon: Icons.people_outline,
      title: l10n.noClients,
      action: ElevatedButton(
        onPressed: () => _showAddClientSheet(context),
        child: Text(l10n.addFirstClient),
      ),
    );
  }

  Widget _buildClientCard(
    BuildContext context,
    Client client,
    AppLocalizations l10n,
  ) {
    final contactInfo = [
      if (client.phone != null && client.phone!.isNotEmpty) client.phone!,
      if (client.email != null && client.email!.isNotEmpty) client.email!,
    ];

    return EntityCard(
      icon: Icons.person_outline,
      color: AppColors.info,
      title: client.name,
      subtitle: contactInfo.isEmpty
          ? l10n.notProvided
          : contactInfo.join(' - '),
      onTap: () => context.pushNamed(
        'client_details',
        pathParameters: {'id': client.id.toString()},
      ),
    );
  }

  void _showAddClientSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) =>
          const Padding(padding: EdgeInsets.all(16.0), child: AddClientForm()),
    );
  }
}

class AddClientForm extends ConsumerStatefulWidget {
  const AddClientForm({super.key});

  @override
  ConsumerState<AddClientForm> createState() => _AddClientFormState();
}

class _AddClientFormState extends ConsumerState<AddClientForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

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
              l10n.addClient,
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
                labelText: l10n.email,
                prefixIcon: const Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.phone,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
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
                  final client = Client(
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    address: _addressController.text,
                  );
                  final navigator = Navigator.of(context);
                  await ref.read(clientRepositoryProvider).createClient(client);
                  if (!mounted) return;
                  navigator.pop();
                }
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
