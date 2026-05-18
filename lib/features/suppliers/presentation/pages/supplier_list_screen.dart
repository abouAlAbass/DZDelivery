import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hissab_dz/core/database/database.dart';
import 'package:hissab_dz/core/database/database_provider.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/purchases/presentation/providers/purchase_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

enum _SupplierFilter { all, active, withContact, withAddress }

class SupplierListScreen extends ConsumerStatefulWidget {
  const SupplierListScreen({super.key});

  @override
  ConsumerState<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends ConsumerState<SupplierListScreen> {
  final _searchController = TextEditingController();
  _SupplierFilter _filter = _SupplierFilter.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suppliersAsync = ref.watch(suppliersListProvider);
    final db = ref.watch(appDatabaseProvider);

    final l10n = AppLocalizations.of(context)!;
    final isAr = l10n.localeName == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(l10n.suppliers)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: suppliersAsync.when(
        data: (suppliers) {
          final filtered = _filterSuppliers(suppliers);
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
                  return _SearchAndFilters(
                    controller: _searchController,
                    hintText: isAr
                        ? 'بحث عن مورد'
                        : 'Rechercher fournisseur, téléphone, email...',
                    resultCount: filtered.length,
                    filter: _filter,
                    onSearchChanged: (_) => setState(() {}),
                    onFilterChanged: (filter) =>
                        setState(() => _filter = filter),
                    isAr: isAr,
                  );
                }
                final supplier = filtered[index - 1];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(
                        supplier.isActive ? Icons.store : Icons.store_outlined,
                      ),
                    ),
                    title: Text(supplier.name),
                    subtitle: Text(
                      [supplier.phone, supplier.email, supplier.address]
                          .whereType<String>()
                          .where((v) => v.isNotEmpty)
                          .join(' - '),
                    ),
                    trailing: supplier.isActive
                        ? null
                        : const Icon(Icons.block, color: Colors.orange),
                    onTap: () => _showSupplierDialog(context, db, supplier),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('$error')),
      ),
      floatingActionButton: ContextualFab(
        onPressed: () => _showSupplierDialog(context, db, null),
        tooltip: l10n.addSupplier,
        icon: Icons.add,
        label: l10n.supplier,
      ),
    );
  }

  List<SupplierData> _filterSuppliers(List<SupplierData> suppliers) {
    final query = _searchController.text.trim().toLowerCase();
    return suppliers.where((supplier) {
      final haystack = [
        supplier.name,
        supplier.phone,
        supplier.email,
        supplier.address,
        supplier.note,
      ].whereType<String>().join(' ').toLowerCase();
      final matchesQuery = query.isEmpty || haystack.contains(query);
      final matchesFilter = switch (_filter) {
        _SupplierFilter.all => true,
        _SupplierFilter.active => supplier.isActive,
        _SupplierFilter.withContact =>
          (supplier.phone?.trim().isNotEmpty ?? false) ||
              (supplier.email?.trim().isNotEmpty ?? false),
        _SupplierFilter.withAddress =>
          supplier.address?.trim().isNotEmpty ?? false,
      };
      return matchesQuery && matchesFilter;
    }).toList();
  }

  Future<void> _showSupplierDialog(
    BuildContext context,
    AppDatabase db,
    SupplierData? supplier,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: supplier?.name ?? '');
    final phoneController = TextEditingController(text: supplier?.phone ?? '');
    final emailController = TextEditingController(text: supplier?.email ?? '');
    final addressController = TextEditingController(
      text: supplier?.address ?? '',
    );

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier == null ? l10n.newSupplier : l10n.editSupplier),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: l10n.name),
              ),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(labelText: l10n.phone),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: l10n.email),
              ),
              TextField(
                controller: addressController,
                decoration: InputDecoration(labelText: l10n.address),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (saved != true || nameController.text.trim().isEmpty) return;

    final companion = SuppliersCompanion(
      id: supplier == null ? const Value.absent() : Value(supplier.id),
      name: Value(nameController.text.trim()),
      phone: Value(_blankToNull(phoneController.text)),
      email: Value(_blankToNull(emailController.text)),
      address: Value(_blankToNull(addressController.text)),
      updatedAt: Value(DateTime.now()),
    );

    if (supplier == null) {
      await db.into(db.suppliers).insert(companion);
    } else {
      await (db.update(
        db.suppliers,
      )..where((row) => row.id.equals(supplier.id))).write(companion);
    }
  }

  String? _blankToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class _SearchAndFilters extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int resultCount;
  final _SupplierFilter filter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_SupplierFilter> onFilterChanged;
  final bool isAr;

  const _SearchAndFilters({
    required this.controller,
    required this.hintText,
    required this.resultCount,
    required this.filter,
    required this.onSearchChanged,
    required this.onFilterChanged,
    required this.isAr,
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
                _chip(_SupplierFilter.all, isAr ? 'الكل' : 'Tous'),
                _chip(_SupplierFilter.active, isAr ? 'نشط' : 'Actifs'),
                _chip(
                  _SupplierFilter.withContact,
                  isAr ? 'مع اتصال' : 'Avec contact',
                ),
                _chip(
                  _SupplierFilter.withAddress,
                  isAr ? 'مع عنوان' : 'Avec adresse',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isAr ? '$resultCount نتيجة' : '$resultCount résultat(s)',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _chip(_SupplierFilter value, String label) {
    return FilterChip(
      selected: filter == value,
      label: Text(label),
      onSelected: (_) => onFilterChanged(value),
    );
  }
}
