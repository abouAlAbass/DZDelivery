import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/theme.dart';
import '../../../../core/widgets/sticky_action_footer.dart';
import '../../../../core/widgets/responsive_content.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/entities/invoice_status.dart';
import '../../presentation/providers/invoice_providers.dart';
import '../../../clients/domain/entities/client.dart';
import '../../../clients/presentation/providers/client_providers.dart';
import '../../../projects/domain/entities/project.dart';
import '../../../projects/presentation/providers/project_providers.dart';
import '../../../articles/domain/entities/article.dart';
import '../../../articles/presentation/providers/article_providers.dart';
import '../../services/pdf_invoice_service.dart';
import '../../../../features/settings/presentation/providers/settings_providers.dart';
import 'package:share_plus/share_plus.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  final int? invoiceId;
  final int? initialProjectId;

  const CreateInvoiceScreen({super.key, this.invoiceId, this.initialProjectId});

  @override
  ConsumerState<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberController = TextEditingController();
  final _notesController = TextEditingController();
  
  Client? _selectedClient;
  Project? _selectedProject;
  DateTime _issueDate = DateTime.now();
  DateTime? _dueDate;
  InvoiceStatus _status = InvoiceStatus.draft;

  // Items handling
  final List<_InvoiceItemData> _items = [];
  
  double _taxRate = 0;
  double _discount = 0;
  bool _isSaving = false;
  bool _isLoading = false;

  bool get _isEditMode => widget.invoiceId != null;

  @override
  void initState() {
    super.initState();
    _dueDate = DateTime.now().add(const Duration(days: 30));
    _invoiceNumberController.text = 'INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    
    // Add first empty item if not editing
    if (!_isEditMode) {
      _addItem();
    }

    if (widget.initialProjectId != null) {
      _loadInitialProject(widget.initialProjectId!);
    }
    if (_isEditMode) {
      _loadExistingInvoice();
    }
  }

  @override
  void dispose() {
    _invoiceNumberController.dispose();
    _notesController.dispose();
    for (var item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_InvoiceItemData());
    });
  }

  void _removeItem(int index) {
    if (_items.length > 1) {
      setState(() {
        final removed = _items.removeAt(index);
        removed.dispose();
      });
    }
  }

  bool _isItemEmpty(int index) {
    final item = _items[index];
    return item.descriptionController.text.trim().isEmpty &&
        (double.tryParse(item.priceController.text) ?? 0) == 0;
  }

  void _applyArticleToItem(int index, Article article) {
    final item = _items[index];
    final quantity = article.defaultQuantity <= 0 ? 1.0 : article.defaultQuantity;
    item.descriptionController.text = article.name;
    item.quantityController.text = quantity.toString();
    item.priceController.text = article.price.toStringAsFixed(2);
  }

  void _appendItemFromArticle(Article article) {
    final quantity = article.defaultQuantity <= 0 ? 1.0 : article.defaultQuantity;
    _items.add(_InvoiceItemData(
      description: article.name,
      quantity: quantity,
      price: article.price,
    ));
  }

  void _addQuickTemplateArticles(
    String template,
    List<Article> articles,
    AppLocalizations l10n,
  ) {
    final matching = articles
        .where((article) => article.quickTemplate == template)
        .toList()
      ..sort((a, b) {
        final order = a.quickTemplateOrder.compareTo(b.quickTemplateOrder);
        return order != 0 ? order : a.name.compareTo(b.name);
      });

    if (matching.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noQuickTemplateArticles)),
      );
      return;
    }

    setState(() {
      var start = 0;
      if (_items.length == 1 && _isItemEmpty(0)) {
        _applyArticleToItem(0, matching.first);
        start = 1;
      }
      for (final article in matching.skip(start)) {
        _appendItemFromArticle(article);
      }
    });
  }

  Future<void> _showPdf() async {
    if (_selectedClient == null) return;
    
    final l10n = AppLocalizations.of(context)!;
    final profile = ref.read(businessProfileProvider).value;
    
    final invoice = Invoice(
      id: widget.invoiceId,
      invoiceNumber: _invoiceNumberController.text,
      clientId: _selectedClient!.id!,
      issueDate: _issueDate,
      dueDate: _dueDate,
      status: _status,
      items: _items.map((data) {
        final q = double.tryParse(data.quantityController.text.replaceAll(',', '.')) ?? 1;
        final p = double.tryParse(data.priceController.text.replaceAll(',', '.')) ?? 0;
        return InvoiceItem(
          invoiceId: widget.invoiceId ?? 0,
          description: data.descriptionController.text,
          quantity: q,
          unitPrice: p,
          amount: q * p,
        );
      }).toList(),
      subtotal: _subtotal,
      taxRate: _taxRate,
      discountAmount: _discount,
      total: _total,
      notes: _notesController.text,
      client: _selectedClient,
    );

    final file = await PdfInvoiceService.generateInvoicePdf(
      invoice: invoice,
      profile: profile,
      l10n: l10n,
    );
    
    await Share.shareXFiles([XFile(file.path)], text: l10n.invoiceLabel);
  }

  Future<void> _loadInitialProject(int projectId) async {
    final project = await ref.read(projectRepositoryProvider).getProjectById(projectId);
    if (!mounted || project == null) return;
    
    Client? client;
    if (project.clientId != null) {
      client = await ref.read(clientRepositoryProvider).getClientById(project.clientId!);
    }

    setState(() {
      _selectedProject = project;
      if (client != null) _selectedClient = client;
    });
  }

  Future<void> _loadExistingInvoice() async {
    setState(() => _isLoading = true);
    final invoice = await ref.read(invoiceRepositoryProvider).getInvoiceById(widget.invoiceId!);
    if (!mounted) return;

    if (invoice == null) {
      setState(() => _isLoading = false);
      context.pop();
      return;
    }

    // Clear and load items
    for (var item in _items) {
      item.dispose();
    }
    _items.clear();
    
    for (var item in invoice.items) {
      _items.add(_InvoiceItemData.fromItem(item));
    }

    setState(() {
      _selectedClient = invoice.client;
      _selectedProject = null; // We could find it if needed
      _invoiceNumberController.text = invoice.invoiceNumber;
      _issueDate = invoice.issueDate;
      _dueDate = invoice.dueDate;
      _status = invoice.status;
      _taxRate = invoice.taxRate;
      _discount = invoice.discountAmount;
      _notesController.text = invoice.notes ?? '';
      _isLoading = false;
    });
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.total);
  double get _taxAmount => _subtotal * (_taxRate / 100);
  double get _total => _subtotal + _taxAmount - _discount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDesktop = MediaQuery.of(context).size.width >= AppBreakpoints.desktop;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditMode ? l10n.editInvoice : l10n.createInvoice,
          style: GoogleFonts.inter(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_isEditMode)
            IconButton(
              onPressed: _showPdf,
              icon: const Icon(Icons.share),
              tooltip: l10n.share,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: FilledButton.icon(
              onPressed: _isSaving ? null : _saveInvoice,
              icon: _isSaving 
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.check, size: 18),
              label: Text(l10n.save),
            ),
          ),
        ],
      ),
      bottomNavigationBar: !isDesktop ? StickyActionFooter(
        label: l10n.total,
        value: NumberFormat.currency(symbol: l10n.currencySymbol).format(_total),
        actionLabel: l10n.save,
        actionIcon: Icons.save,
        onPressed: _saveInvoice,
        loading: _isSaving,
      ) : null,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ResponsiveContent(
            maxWidth: 1200,
            child: isDesktop ? _buildDesktopLayout(l10n) : _buildMobileLayout(l10n),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildClientCard(l10n),
        const SizedBox(height: 16),
        _buildInvoiceDetailsCard(l10n),
        const SizedBox(height: 24),
        _buildItemsSection(l10n, isMobile: true),
        const SizedBox(height: 24),
        _buildSummaryCard(l10n),
        const SizedBox(height: 100), // Space for footer
      ],
    );
  }

  Widget _buildDesktopLayout(AppLocalizations l10n) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Client & Details
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _buildClientCard(l10n),
              const SizedBox(height: 16),
              _buildInvoiceDetailsCard(l10n),
              const SizedBox(height: 16),
              _buildNotesCard(l10n),
            ],
          ),
        ),
        const SizedBox(width: 24),
        // Right Column: Items & Summary
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildItemsSection(l10n, isMobile: false),
              const SizedBox(height: 24),
              _buildSummaryCard(l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClientCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.billTo,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildClientSearch(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildClientSearch(AppLocalizations l10n) {
    final clientsAsync = ref.watch(clientsListProvider);
    
    return clientsAsync.when(
      data: (clients) => SearchAnchor(
        builder: (context, controller) {
          return SearchBar(
            controller: controller,
            hintText: _selectedClient?.name ?? l10n.searchClients,
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(Theme.of(context).colorScheme.surface),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey),
            )),
            padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12)),
            leading: const Icon(Icons.search, color: AppColors.textMuted),
            onTap: () => controller.openView(),
            onChanged: (_) => controller.openView(),
          );
        },
        suggestionsBuilder: (context, controller) {
          final query = controller.text.toLowerCase();
          final filtered = clients.where((c) => c.name.toLowerCase().contains(query)).toList();
          
          return filtered.map((c) => ListTile(
            title: Text(c.name),
            subtitle: Text(c.email ?? ''),
            onTap: () {
              setState(() => _selectedClient = c);
              controller.closeView(c.name);
            },
          ));
        },
      ),
      loading: () => const LinearProgressIndicator(),
      error: (_, __) => const Text('Error loading clients'),
    );
  }

  Widget _buildInvoiceDetailsCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey.withAlpha(50)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.description_outlined, color: Theme.of(context).colorScheme.primary, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.invoiceDetails,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _invoiceNumberController,
              decoration: InputDecoration(
                labelText: l10n.invoiceNumber,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              validator: (v) => v?.isEmpty ?? true ? l10n.requiredField : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDatePickerField(
                    label: l10n.issueDate,
                    value: _issueDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _issueDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _issueDate = picked);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePickerField(
                    label: l10n.dueDate,
                    value: _dueDate ?? DateTime.now(),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _dueDate ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _dueDate = picked);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePickerField({required String label, required DateTime value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          AppLocalizations.of(context)!.localeName == 'ar'
              ? DateFormat('dd/MM/yyyy', 'en').format(value)
              : DateFormat.yMMMd().format(value),
        ),
      ),
    );
  }

  Widget _buildItemsSection(AppLocalizations l10n, {required bool isMobile}) {
    final articlesAsync = ref.watch(articlesListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildQuickTemplates(l10n, articlesAsync),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.items,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 18),
            ),
            FilledButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n.addItem),
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (isMobile)
          ...List.generate(_items.length, (index) => _buildMobileItem(index, l10n, articlesAsync))
        else
          _buildDesktopItemTable(l10n, articlesAsync),
      ],
    );
  }

  Widget _buildArticleAutocomplete(int index, AppLocalizations l10n, List<Article> articles, {bool isDense = false}) {
    final item = _items[index];
    return Autocomplete<Article>(
      displayStringForOption: (option) => option.name,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return const Iterable<Article>.empty();
        return articles.where((article) =>
            article.name.toLowerCase().contains(textEditingValue.text.toLowerCase()) ||
            (article.code?.toLowerCase().contains(textEditingValue.text.toLowerCase()) ?? false));
      },
      onSelected: (Article article) {
        setState(() {
          _applyArticleToItem(index, article);
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        // Sync the autocomplete controller with our item controller
        if (controller.text != item.descriptionController.text) {
          controller.text = item.descriptionController.text;
        }
        
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: isDense ? null : l10n.description,
            border: isDense ? InputBorder.none : const OutlineInputBorder(),
            isDense: isDense,
            suffixIcon: IconButton(
              icon: Icon(Icons.list_alt, size: 20, color: Theme.of(context).colorScheme.primary),
              onPressed: () => _showArticlePicker(index, articles),
              tooltip: l10n.selectArticle,
            ),
          ),
          onChanged: (v) {
            item.descriptionController.text = v;
            setState(() {});
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4,
            child: SizedBox(
              width: 300,
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.name),
                    subtitle: Text('${option.price} ${l10n.currencySymbol}'),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showArticlePicker(int index, List<Article> articles) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.selectArticle),
        content: SizedBox(
          width: 400,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: articles.length,
            itemBuilder: (context, i) {
              final article = articles[i];
              return ListTile(
                title: Text(article.name),
                subtitle: Text('${article.price} ${AppLocalizations.of(context)!.currencySymbol}'),
                onTap: () {
                  setState(() => _applyArticleToItem(index, article));
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildQuickTemplates(AppLocalizations l10n, AsyncValue<List<Article>> articlesAsync) {
    final templateLabels = {
      'painting': l10n.paintingRoom,
      'plumbing': l10n.plumbingRepair,
      'electrical': l10n.electricalJob,
      'masonry': l10n.masonryWork,
    };
    final templateIcons = {
      'painting': Icons.format_paint_outlined,
      'plumbing': Icons.plumbing_outlined,
      'electrical': Icons.electrical_services_outlined,
      'masonry': Icons.construction_outlined,
    };

    return articlesAsync.when(
      data: (articles) {
        final configured = articles.where((a) => a.quickTemplate != null).toList();
        if (configured.isEmpty) return const SizedBox.shrink();

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.transparent),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.quickTemplates,
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: templateLabels.entries.map((entry) {
                    final count = configured.where((a) => a.quickTemplate == entry.key).length;
                    if (count == 0) return const SizedBox.shrink();
                    return ActionChip(
                      avatar: Icon(templateIcons[entry.key], size: 16),
                      label: Text('${entry.value} ($count)'),
                      onPressed: () => _addQuickTemplateArticles(entry.key, articles, l10n),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildMobileItem(int index, AppLocalizations l10n, AsyncValue<List<Article>> articlesAsync) {
    final item = _items[index];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildArticleAutocomplete(index, l10n, articlesAsync.value ?? []),
                ),
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: item.quantityController,
                    decoration: InputDecoration(labelText: l10n.quantity),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: item.priceController,
                    decoration: InputDecoration(labelText: l10n.price),
                    keyboardType: TextInputType.number,
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Total: ${NumberFormat.currency(symbol: '').format(item.total)}',
                style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopItemTable(AppLocalizations l10n, AsyncValue<List<Article>> articlesAsync) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.grey),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Theme.of(context).brightness == Brightness.dark 
            ? AppColors.darkSurfaceAlt 
            : AppColors.surfaceAlt),
          columnSpacing: 24,
          columns: [
            DataColumn(label: Text(l10n.description, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(l10n.quantity, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(l10n.price, style: const TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(label: Text(l10n.total, style: const TextStyle(fontWeight: FontWeight.bold))),
            const DataColumn(label: SizedBox()),
          ],
          rows: List.generate(_items.length, (index) {
            final item = _items[index];
            return DataRow(cells: [
              DataCell(
                _buildArticleAutocomplete(index, l10n, articlesAsync.value ?? [], isDense: true),
              ),
              DataCell(
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    controller: item.quantityController,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ),
              DataCell(
                SizedBox(
                  width: 100,
                  child: TextFormField(
                    controller: item.priceController,
                    textAlign: TextAlign.right,
                    decoration: const InputDecoration(border: InputBorder.none),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (v) => setState(() {}),
                  ),
                ),
              ),
              DataCell(
                Text(
                  NumberFormat.currency(symbol: '').format(item.total),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              DataCell(
                IconButton(
                  onPressed: () => _removeItem(index),
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                ),
              ),
            ]);
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Theme.of(context).dividerTheme.color ?? Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSummaryRow(l10n.subtotal, _subtotal),
            const SizedBox(height: 12),
            _buildTaxDiscountInput(l10n),
            const Divider(height: 32),
            _buildSummaryRow(l10n.total, _total, isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value, {bool isTotal = false}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: isTotal ? 20 : 14,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w500,
            color: isTotal 
              ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary) 
              : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
          ),
        ),
        Text(
          NumberFormat.currency(symbol: AppLocalizations.of(context)!.currencySymbol).format(value),
          style: GoogleFonts.inter(
            fontSize: isTotal ? 24 : 16,
            fontWeight: isTotal ? FontWeight.w900 : FontWeight.w600,
            color: isTotal 
              ? (isDark ? AppColors.darkAccent : AppColors.primary) 
              : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildTaxDiscountInput(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            initialValue: _taxRate.toString(),
            decoration: InputDecoration(
              labelText: '${l10n.tax} (%)',
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _taxRate = double.tryParse(v.replaceAll(',', '.')) ?? 0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            initialValue: _discount.toString(),
            decoration: InputDecoration(
              labelText: l10n.discount,
              isDense: true,
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) => setState(() => _discount = double.tryParse(v.replaceAll(',', '.')) ?? 0),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesCard(AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(
              l10n.notes,
              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: l10n.notes,
                border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClient == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.noClients)),
      );
      return;
    }

    setState(() => _isSaving = true);

    final invoiceItems = _items.map((data) {
      final q = double.tryParse(data.quantityController.text.replaceAll(',', '.')) ?? 1;
      final p = double.tryParse(data.priceController.text.replaceAll(',', '.')) ?? 0;
      return InvoiceItem(
        description: data.descriptionController.text,
        quantity: q,
        unitPrice: p,
        amount: q * p,
      );
    }).toList();

    final invoice = Invoice(
      id: widget.invoiceId,
      invoiceNumber: _invoiceNumberController.text,
      clientId: _selectedClient!.id!,
      projectId: _selectedProject?.id,
      issueDate: _issueDate,
      dueDate: _dueDate ?? _issueDate.add(const Duration(days: 30)),
      status: _status,
      items: invoiceItems,
      taxRate: _taxRate,
      discountAmount: _discount,
      notes: _notesController.text,
      client: _selectedClient,
    );

    try {
      if (_isEditMode) {
        await ref.read(invoiceRepositoryProvider).updateInvoice(invoice);
        ref.invalidate(invoiceByIdProvider(invoice.id!));
      } else {
        await ref.read(invoiceRepositoryProvider).createInvoice(invoice);
      }
      
      // Force refresh all relevant lists
      ref.invalidate(invoicesListProvider);
      ref.invalidate(filteredInvoicesProvider);
      if (invoice.projectId != null) {
        ref.invalidate(projectDetailsProvider(invoice.projectId!));
      }
      
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}

class _InvoiceItemData {
  final TextEditingController descriptionController;
  final TextEditingController quantityController;
  final TextEditingController priceController;

  _InvoiceItemData({
    String description = '',
    double quantity = 1,
    double price = 0,
  }) : descriptionController = TextEditingController(text: description),
       quantityController = TextEditingController(text: quantity.toString()),
       priceController = TextEditingController(text: price.toString());

  factory _InvoiceItemData.fromItem(InvoiceItem item) {
    return _InvoiceItemData(
      description: item.description,
      quantity: item.quantity,
      price: item.unitPrice,
    );
  }

  double get total {
    final q = double.tryParse(quantityController.text.replaceAll(',', '.')) ?? 0;
    final p = double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0;
    return q * p;
  }

  void dispose() {
    descriptionController.dispose();
    quantityController.dispose();
    priceController.dispose();
  }
}
