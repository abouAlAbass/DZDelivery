import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:hissab_dz/core/theme/theme.dart';
import 'package:hissab_dz/core/widgets/app_empty_state.dart';
import 'package:hissab_dz/core/widgets/app_drawer.dart';
import 'package:hissab_dz/core/widgets/contextual_fab.dart';
import 'package:hissab_dz/core/widgets/entity_card.dart';
import 'package:hissab_dz/core/widgets/responsive_content.dart';
import 'package:hissab_dz/features/clients/domain/entities/client.dart';
import 'package:hissab_dz/features/clients/presentation/providers/client_providers.dart';
import 'package:hissab_dz/features/projects/domain/entities/project.dart';
import 'package:hissab_dz/features/projects/domain/entities/project_status.dart';
import 'package:hissab_dz/features/projects/presentation/providers/project_providers.dart';
import 'package:hissab_dz/l10n/app_localizations.dart';

class ProjectListScreen extends ConsumerWidget {
  const ProjectListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final projectsAsync = ref.watch(projectsListProvider);
    final currencyFormat = NumberFormat.currency(symbol: l10n.currencySymbol);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.projects)),
      drawer: MediaQuery.sizeOf(context).width >= 1100
          ? null
          : const AppDrawer(),
      body: projectsAsync.when(
        data: (projects) {
          if (projects.isEmpty) {
            return _buildEmptyState(context, l10n);
          }

          return ResponsiveContent(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.xs,
                AppSpacing.bottomNavClearance,
              ),
              itemCount: projects.length,
              itemBuilder: (context, index) {
                final project = projects[index];
                return EntityCard(
                  icon: Icons.folder_open_outlined,
                  color: AppColors.project,
                  title: project.name,
                  subtitle:
                      '${project.clientName ?? l10n.unknownClient} - ${_statusLabel(l10n, project.status)}',
                  trailing: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(project.invoiceTotal),
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      Text(
                        currencyFormat.format(project.balance),
                        style: TextStyle(
                          color: project.balance >= 0
                              ? AppColors.profit
                              : AppColors.expense,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  onTap: () => context.pushNamed(
                    'project_details',
                    pathParameters: {'id': project.id.toString()},
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
      floatingActionButton: ContextualFab(
        onPressed: () => _showProjectSheet(context, l10n),
        tooltip: l10n.addProject,
        icon: Icons.add,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  static String _statusLabel(AppLocalizations l10n, ProjectStatus status) {
    switch (status) {
      case ProjectStatus.planned:
        return l10n.planned;
      case ProjectStatus.inProgress:
        return l10n.inProgress;
      case ProjectStatus.completed:
        return l10n.completed;
      case ProjectStatus.awaitingPayment:
        return l10n.awaitingPayment;
    }
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    return AppEmptyState(
      icon: Icons.folder_open_outlined,
      title: l10n.noProjects,
      action: ElevatedButton.icon(
        onPressed: () => _showProjectSheet(context, l10n),
        icon: const Icon(Icons.add),
        label: Text(l10n.addProject),
      ),
    );
  }

  void _showProjectSheet(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.78,
        child: _ProjectForm(l10n: l10n),
      ),
    );
  }
}

class _ProjectForm extends ConsumerStatefulWidget {
  final AppLocalizations l10n;

  const _ProjectForm({required this.l10n});

  @override
  ConsumerState<_ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<_ProjectForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _siteAddressController = TextEditingController();
  final _descriptionController = TextEditingController();
  Client? _selectedClient;
  ProjectStatus _selectedStatus = ProjectStatus.planned;

  @override
  void dispose() {
    _nameController.dispose();
    _siteAddressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n;
    final clientsAsync = ref.watch(clientsListProvider);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        16,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.addProject,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _saveProject,
                  icon: const Icon(Icons.save_outlined, size: 18),
                  label: Text(l10n.save),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: l10n.projectName,
                        prefixIcon: const Icon(Icons.folder),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? l10n.noData
                          : null,
                    ),
                    const SizedBox(height: 12),
                    clientsAsync.when(
                      data: (clients) => DropdownButtonFormField<Client>(
                        initialValue: _selectedClient,
                        decoration: InputDecoration(
                          labelText: l10n.selectClient,
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        items: clients
                            .map(
                              (client) => DropdownMenuItem(
                                value: client,
                                child: Text(client.name),
                              ),
                            )
                            .toList(),
                        onChanged: (client) =>
                            setState(() => _selectedClient = client),
                        validator: (client) =>
                            client == null ? l10n.noData : null,
                      ),
                      loading: () => const LinearProgressIndicator(),
                      error: (e, st) => Text('${l10n.error}: $e'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _siteAddressController,
                      decoration: InputDecoration(
                        labelText: l10n.siteAddress,
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ProjectStatus>(
                      initialValue: _selectedStatus,
                      decoration: InputDecoration(
                        labelText: l10n.projectStatus,
                        prefixIcon: const Icon(Icons.flag_outlined),
                      ),
                      items: ProjectStatus.values
                          .map(
                            (status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                ProjectListScreen._statusLabel(l10n, status),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (status) => setState(
                        () => _selectedStatus = status ?? ProjectStatus.planned,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: l10n.description,
                        prefixIcon: const Icon(Icons.notes),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: _saveProject,
                      icon: const Icon(Icons.save_outlined),
                      label: Text(l10n.save),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProject() async {
    if (!_formKey.currentState!.validate()) return;

    final navigator = Navigator.of(context);
    final description = _descriptionController.text.trim();
    final siteAddress = _siteAddressController.text.trim();
    await ref
        .read(projectRepositoryProvider)
        .createProject(
          Project(
            clientId: _selectedClient!.id,
            name: _nameController.text.trim(),
            siteAddress: siteAddress.isEmpty ? null : siteAddress,
            status: _selectedStatus,
            description: description.isEmpty ? null : description,
          ),
        );
    if (mounted) navigator.pop();
  }
}
