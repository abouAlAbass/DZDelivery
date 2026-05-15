import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../providers/settings_providers.dart';
import '../../domain/entities/business_profile.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../l10n/app_localizations.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _expenseTypeController = TextEditingController();

  String? _logoPath;
  bool _initialized = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _expenseTypeController.dispose();
    super.dispose();
  }

  void _initFromProfile(BusinessProfile profile) {
    if (!_initialized) {
      _nameController.text = profile.companyName;
      _addressController.text = profile.address ?? '';
      _phoneController.text = profile.phone ?? '';
      _emailController.text = profile.email ?? '';
      _websiteController.text = profile.website ?? '';
      _logoPath = profile.logoPath;
      _initialized = true;
    }
  }

  Future<void> _pickLogo() async {
    const typeGroup = XTypeGroup(
      label: 'Images',
      extensions: ['jpg', 'jpeg', 'png', 'webp'],
    );
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;

    // Copy image to app Documents so the path persists
    final docsDir = await getApplicationDocumentsDirectory();
    final logoDir = Directory(p.join(docsDir.path, 'InvoicePro', 'logos'));
    if (!logoDir.existsSync()) logoDir.createSync(recursive: true);

    final ext = p.extension(file.path);
    final savedPath = p.join(logoDir.path, 'company_logo$ext');
    await File(file.path).copy(savedPath);

    setState(() => _logoPath = savedPath);
  }

  void _removeLogo() => setState(() => _logoPath = null);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final profileAsync = ref.watch(businessProfileProvider);
    final currentLocale = ref.watch(appLocaleProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appSettings)),
      body: profileAsync.when(
        data: (profile) {
          if (profile != null) _initFromProfile(profile);
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo Section ──────────────────────────────────────────
                  _buildLanguageSection(l10n, currentLocale),
                  const SizedBox(height: 16),
                  _buildThemeSection(l10n),
                  const SizedBox(height: 24),

                  Text(
                    l10n.companyLogo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildLogoSection(context),
                  const SizedBox(height: 24),

                  // ── Business Info ─────────────────────────────────────────
                  Text(
                    l10n.companyInfo,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    l10n.companyLogoSubtitle,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: l10n.companyName,
                      prefixIcon: const Icon(Icons.business),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? l10n.requiredField : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _addressController,
                    decoration: InputDecoration(
                      labelText: l10n.address,
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: l10n.phone,
                      prefixIcon: const Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.email,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _websiteController,
                    decoration: InputDecoration(
                      labelText: l10n.website,
                      prefixIcon: const Icon(Icons.language),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 32),
                  _buildExpenseTypesSection(l10n),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _isSaving ? null : () => _save(l10n),
                    icon: _isSaving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save),
                    label: Text(l10n.saveSettings),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('${l10n.error}: $e')),
      ),
    );
  }

  Widget _buildThemeSection(AppLocalizations l10n) {
    final themeMode = ref.watch(themeProvider);
    final themeLabel = themeMode == ThemeMode.system
        ? l10n.systemTheme
        : themeMode == ThemeMode.dark
            ? l10n.darkTheme
            : l10n.lightTheme;

    return Card(
      child: ListTile(
        leading: const Icon(Icons.brightness_medium),
        title: Text(l10n.theme),
        subtitle: Text(themeLabel),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _showThemeDialog(l10n, themeMode),
      ),
    );
  }

  void _showThemeDialog(AppLocalizations l10n, ThemeMode currentMode) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _themeTile(l10n.systemTheme, ThemeMode.system, currentMode),
            _themeTile(l10n.lightTheme, ThemeMode.light, currentMode),
            _themeTile(l10n.darkTheme, ThemeMode.dark, currentMode),
          ],
        ),
      ),
    );
  }

  Widget _themeTile(String label, ThemeMode mode, ThemeMode currentMode) {
    return ListTile(
      title: Text(label),
      trailing: mode == currentMode
          ? const Icon(Icons.check_circle, color: Colors.green)
          : null,
      onTap: () {
        ref.read(themeProvider.notifier).setThemeMode(mode);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildLanguageSection(AppLocalizations l10n, Locale currentLocale) {
    final currentInfo = _localeInfo(currentLocale);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.language),
        title: Text(l10n.language),
        subtitle: Text(currentInfo['native'] as String),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              currentInfo['flag'] as String,
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: () => _showLanguageDialog(l10n, currentLocale),
      ),
    );
  }

  Map<String, dynamic> _localeInfo(Locale locale) {
    return supportedLocalesInfo.firstWhere(
      (info) => (info['locale'] as Locale).languageCode == locale.languageCode,
      orElse: () => supportedLocalesInfo.first,
    );
  }

  void _showLanguageDialog(AppLocalizations l10n, Locale currentLocale) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: supportedLocalesInfo.map((info) {
            final locale = info['locale'] as Locale;
            final isSelected =
                locale.languageCode == currentLocale.languageCode;

            return ListTile(
              leading: Text(
                info['flag'] as String,
                style: const TextStyle(fontSize: 22),
              ),
              title: Text(info['native'] as String),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
              onTap: () {
                ref.read(appLocaleProvider.notifier).setLocale(locale);
                Navigator.pop(dialogContext);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpenseTypesSection(AppLocalizations l10n) {
    final typesAsync = ref.watch(expenseTypesProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.expenseTypes,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.expenseTypesSubtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _expenseTypeController,
                    decoration: InputDecoration(
                      labelText: l10n.expenseType,
                      prefixIcon: const Icon(Icons.category),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () async {
                    final name = _expenseTypeController.text.trim();
                    if (name.isEmpty) return;
                    await ref
                        .read(projectRepositoryProvider)
                        .addExpenseType(name);
                    _expenseTypeController.clear();
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 8),
            typesAsync.when(
              data: (types) => Column(
                children: types.map((type) {
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.label_outline),
                    title: Text(type.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => ref
                          .read(projectRepositoryProvider)
                          .deleteExpenseType(type.id!),
                    ),
                  );
                }).toList(),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (e, st) => Text('${l10n.error}: $e'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasLogo = _logoPath != null && File(_logoPath!).existsSync();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Logo preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasLogo
                  ? Image.file(File(_logoPath!), fit: BoxFit.contain)
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 36,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.noLogo,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(width: 20),

            // Action buttons
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  OutlinedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload_file),
                    label: Text(hasLogo ? l10n.changeLogo : l10n.uploadLogo),
                  ),
                  if (hasLogo) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _removeLogo,
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      label: Text(
                        l10n.removeLogo,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    l10n.logoHelp,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(AppLocalizations l10n) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final profile = BusinessProfile(
      companyName: _nameController.text.trim(),
      address: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      phone: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      website: _websiteController.text.trim().isEmpty
          ? null
          : _websiteController.text.trim(),
      logoPath: _logoPath,
    );

    await ref.read(settingsRepositoryProvider).saveBusinessProfile(profile);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.settingsSaved),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
