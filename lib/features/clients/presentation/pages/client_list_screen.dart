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
import '../../../../core/widgets/address_picker_field.dart';
import '../../../../l10n/app_localizations.dart';

enum _ClientFilter { all, withContact, withAddress, noContact }

class ClientListScreen extends ConsumerStatefulWidget {
  const ClientListScreen({super.key});

  @override
  ConsumerState<ClientListScreen> createState() => _ClientListScreenState();
}

class _ClientListScreenState extends ConsumerState<ClientListScreen> {
  final _searchController = TextEditingController();
  _ClientFilter _filter = _ClientFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final clientsAsync = ref.watch(clientsListProvider);
    final isAr = l10n.localeName == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.clients)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: clientsAsync.when(
        data: (clients) {
          final filtered = _filterClients(clients);
          if (clients.isEmpty) return _buildEmptyState(context, l10n);

          return ResponsiveContent(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.bottomNavClearance,
              ),
              itemCount: filtered.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _ClientSearchAndFilters(
                    controller: _searchController,
                    hintText: l10n.searchClients,
                    resultCount: filtered.length,
                    filter: _filter,
                    isAr: isAr,
                    onSearchChanged: (_) => setState(() {}),
                    onFilterChanged: (filter) =>
                        setState(() => _filter = filter),
                  );
                }
                return _buildClientCard(context, filtered[index - 1], l10n);
              },
            ),
          );
        },
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

  List<Client> _filterClients(List<Client> clients) {
    final query = _searchController.text.trim().toLowerCase();
    return clients.where((client) {
      final hasContact =
          (client.phone?.trim().isNotEmpty ?? false) ||
          (client.email?.trim().isNotEmpty ?? false);
      final hasAddress =
          (client.address?.trim().isNotEmpty ?? false) ||
          (client.addressName?.trim().isNotEmpty ?? false);
      final haystack = [
        client.name,
        client.phone,
        client.email,
        client.address,
        client.addressName,
      ].whereType<String>().join(' ').toLowerCase();
      final matchesQuery = query.isEmpty || haystack.contains(query);
      final matchesFilter = switch (_filter) {
        _ClientFilter.all => true,
        _ClientFilter.withContact => hasContact,
        _ClientFilter.withAddress => hasAddress,
        _ClientFilter.noContact => !hasContact,
      };
      return matchesQuery && matchesFilter;
    }).toList();
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

class _ClientSearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int resultCount;
  final _ClientFilter filter;
  final bool isAr;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_ClientFilter> onFilterChanged;

  const _ClientSearchAndFilters({
    required this.controller,
    required this.hintText,
    required this.resultCount,
    required this.filter,
    required this.isAr,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: controller,
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: hintText,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          controller.clear();
                          onSearchChanged('');
                        },
                      ),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                _chip(_ClientFilter.all, isAr ? 'الكل' : 'Tous'),
                _chip(
                  _ClientFilter.withContact,
                  isAr ? 'مع اتصال' : 'Avec contact',
                ),
                _chip(
                  _ClientFilter.withAddress,
                  isAr ? 'مع عنوان' : 'Avec adresse',
                ),
                _chip(
                  _ClientFilter.noContact,
                  isAr ? 'بدون اتصال' : 'Sans contact',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isAr ? '$resultCount نتيجة' : '$resultCount client(s)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(_ClientFilter value, String label) {
    return FilterChip(
      selected: filter == value,
      label: Text(label),
      onSelected: (_) => onFilterChanged(value),
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

  String? _addressName;
  double? _latitude;
  double? _longitude;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
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
            AddressPickerField(
              onChanged: (name, lat, lng) {
                _addressName = name;
                _latitude = lat;
                _longitude = lng;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final client = Client(
                    name: _nameController.text,
                    email: _emailController.text,
                    phone: _phoneController.text,
                    address: _addressName, // Using address for the name string
                    addressName: _addressName,
                    latitude: _latitude,
                    longitude: _longitude,
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
