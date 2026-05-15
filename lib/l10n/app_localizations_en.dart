// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Invoice Pro';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get invoices => 'Invoices';

  @override
  String get invoiceLabel => 'Invoice';

  @override
  String get quoteLabel => 'Quote';

  @override
  String get clients => 'Clients';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get login => 'Login';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get createInvoice => 'New Invoice';

  @override
  String get draft => 'Draft';

  @override
  String get sent => 'Sent';

  @override
  String get paid => 'Paid';

  @override
  String get overdue => 'Overdue';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get accepted => 'Accepted';

  @override
  String get converted => 'Converted';

  @override
  String get cancelled => 'Cancelled';

  @override
  String get expired => 'Expired';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get systemTheme => 'System Default';

  @override
  String get selectTheme => 'Select Theme';

  @override
  String get selectLanguage => 'Select Language';

  @override
  String get total => 'Total';

  @override
  String get status => 'Status';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Due Date';

  @override
  String get issueDate => 'Issue Date';

  @override
  String get clientName => 'Client Name';

  @override
  String get amount => 'Amount';

  @override
  String get noData => 'No data available';

  @override
  String get noInvoices => 'No invoices found';

  @override
  String get noClients => 'No clients found';

  @override
  String get addClient => 'Add Client';

  @override
  String get editClient => 'Edit Client';

  @override
  String get editInvoice => 'Edit Invoice';

  @override
  String get clientDetails => 'Client Details';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get name => 'Full Name';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get website => 'Website';

  @override
  String get companyName => 'Company Name';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get confirmDelete => 'Are you sure you want to delete this?';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get downloadPdf => 'Download PDF';

  @override
  String get pdfSaved => 'PDF saved to Documents';

  @override
  String get viewPdf => 'View PDF';

  @override
  String get share => 'Share';

  @override
  String get exportPdf => 'Export PDF';

  @override
  String get companyInfo => 'Business Profile';

  @override
  String get businessProfileSubtitle => 'Used on generated PDF invoices';

  @override
  String get currency => 'Currency';

  @override
  String get items => 'Items';

  @override
  String get addItem => 'Add Line Item';

  @override
  String get description => 'Description';

  @override
  String get quantity => 'Quantity';

  @override
  String get price => 'Price';

  @override
  String get unitPrice => 'Unit Price';

  @override
  String get tax => 'Tax (%)';

  @override
  String get discount => 'Discount';

  @override
  String get subtotal => 'Subtotal';

  @override
  String get totalTax => 'Tax Amount';

  @override
  String get notes => 'Notes';

  @override
  String get invoiceNumber => 'Invoice #';

  @override
  String get selectClient => 'Select Client';

  @override
  String get selectArticle => 'Select Article';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get paymentAmount => 'Payment Amount';

  @override
  String get paymentRecorded => 'Payment recorded';

  @override
  String get invoiceMarkedPaid => 'Invoice marked as PAID';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get statusUpdated => 'Status updated';

  @override
  String get billTo => 'Bill To';

  @override
  String get summary => 'Summary';

  @override
  String get newInvoice => 'New Invoice';

  @override
  String get invoiceDetails => 'Invoice Details';

  @override
  String get attachment => 'Attachment';

  @override
  String get addAttachment => 'Add Attachment';

  @override
  String get changeAttachment => 'Change Attachment';

  @override
  String get saveSettings => 'Save Settings';

  @override
  String get settingsSaved => 'Settings saved successfully';

  @override
  String get appSettings => 'App Settings';

  @override
  String get totalRevenue => 'Total Revenue';

  @override
  String get outstanding => 'Outstanding';

  @override
  String get totalClients => 'Total Clients';

  @override
  String get thisMonth => 'This Month';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastMonth => 'Last Month';

  @override
  String get issued => 'Issued';

  @override
  String get recentInvoices => 'Recent Invoices';

  @override
  String get overdueInvoices => 'Overdue Invoices';

  @override
  String overdueAlert(int count) {
    return '$count Overdue Invoice(s)';
  }

  @override
  String get immediateAction => 'Immediate action required';

  @override
  String get noRecentInvoices => 'No recent invoices';

  @override
  String get thankyou => 'Thank you for your business!';

  @override
  String get paymentTerms => 'Payment Terms: Net 30 days.';

  @override
  String get pdfDownloadedAndOpened => 'PDF downloaded and opened:';

  @override
  String get error => 'Error';

  @override
  String get errorGeneratingPdf => 'Error generating PDF';

  @override
  String get notesOptional => 'Notes (optional)';

  @override
  String get paymentNotesHint => 'e.g. Bank transfer, Cash';

  @override
  String get record => 'Record';

  @override
  String get changeStatus => 'Change status';

  @override
  String get unknownClient => 'Unknown Client';

  @override
  String get invoiceSavedSuccessfully => 'Invoice saved successfully';

  @override
  String get addAtLeastOnePricedItem =>
      'Please add at least one item with a price';

  @override
  String get errorSavingInvoice => 'Error saving invoice';

  @override
  String get searchClients => 'Search clients...';

  @override
  String get searchInvoices => 'Search invoices...';

  @override
  String get errorLoadingClients => 'Error loading clients';

  @override
  String get addFirstClient => 'Add Your First Client';

  @override
  String get english => 'English';

  @override
  String get french => 'French';

  @override
  String get arabic => 'Arabic';

  @override
  String get currencySymbol => 'DZD';

  @override
  String get payments => 'Payments';

  @override
  String get payment => 'Payment';

  @override
  String get noPayments => 'No payments found';

  @override
  String get addPayment => 'Add Payment';

  @override
  String get balance => 'Balance';

  @override
  String get paidAmount => 'Paid Amount';

  @override
  String get remaining => 'Remaining';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get paymentDate => 'Payment Date';

  @override
  String get history => 'History';

  @override
  String get relatedPayments => 'Related Payments';

  @override
  String get articles => 'Articles';

  @override
  String get article => 'Article';

  @override
  String get noArticles => 'No articles found';

  @override
  String get addArticle => 'Add Article';

  @override
  String get editArticle => 'Edit Article';

  @override
  String get code => 'Code';

  @override
  String get unit => 'Unit';

  @override
  String get measure => 'Measure';

  @override
  String get searchArticles => 'Search articles...';

  @override
  String get pricePerUnit => 'Price per unit';

  @override
  String get kg => 'kg';

  @override
  String get m2 => 'm²';

  @override
  String get m3 => 'm³';

  @override
  String get pieces => 'Pieces';

  @override
  String get physical => 'Physical';

  @override
  String get service => 'Service';

  @override
  String get projects => 'Projects';

  @override
  String get project => 'Project';

  @override
  String get projectDetails => 'Project Details';

  @override
  String get addProject => 'Add Project';

  @override
  String get noProjects => 'No projects found';

  @override
  String get projectName => 'Project Name';

  @override
  String get optionalProject => 'Project (optional)';

  @override
  String get noProject => 'No project';

  @override
  String get expenses => 'Expenses';

  @override
  String get expense => 'Expense';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get noExpenses => 'No expenses found';

  @override
  String get expenseType => 'Expense Type';

  @override
  String get expenseTypes => 'Expense Types';

  @override
  String get expenseTypesSubtitle =>
      'Manage reusable project expense categories.';

  @override
  String get relatedInvoices => 'Related Invoices';

  @override
  String get notProvided => 'Not provided';

  @override
  String get requiredField => 'Required';

  @override
  String get updateClient => 'Update Client';

  @override
  String get emailAddress => 'Email Address';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get companyLogo => 'Company Logo';

  @override
  String get companyLogoSubtitle => 'Appears on all generated PDF invoices';

  @override
  String get noLogo => 'No Logo';

  @override
  String get changeLogo => 'Change Logo';

  @override
  String get uploadLogo => 'Upload Logo';

  @override
  String get removeLogo => 'Remove Logo';

  @override
  String get logoHelp => 'PNG or JPG, used on PDF invoices.';

  @override
  String get invoiceNotFound => 'Invoice not found';

  @override
  String get invoiceNumberShort => 'Invoice #';

  @override
  String get addClientFirst => 'Add a client first';

  @override
  String get quotes => 'Quotes';

  @override
  String get quote => 'Quote';

  @override
  String get createQuote => 'New Quote';

  @override
  String get editQuote => 'Edit Quote';

  @override
  String get quoteDetails => 'Quote Details';

  @override
  String get quoteNumber => 'Quote #';

  @override
  String get validUntil => 'Valid Until';

  @override
  String get noQuotes => 'No quotes found';

  @override
  String get convertToInvoice => 'Convert to invoice';

  @override
  String get quoteConverted => 'Quote converted to invoice';

  @override
  String get approvalSignature => 'Client approval signature';

  @override
  String get goodForApproval => 'Good for approval';

  @override
  String get rejected => 'Rejected';

  @override
  String get quickTemplates => 'Quick templates';

  @override
  String get paintingRoom => 'Room painting';

  @override
  String get plumbingRepair => 'Plumbing repair';

  @override
  String get electricalJob => 'Electrical work';

  @override
  String get masonryWork => 'Masonry work';

  @override
  String get quickTemplateTrade => 'Quick quote template';

  @override
  String get noQuickTemplate => 'No quick template';

  @override
  String get defaultQuantity => 'Default quantity';

  @override
  String get quickTemplateOrder => 'Display order';

  @override
  String get configureQuickArticles => 'Configure quick articles';

  @override
  String get chooseFromArticles => 'Choose article';

  @override
  String get addQuickTemplateArticles => 'Add quick template';

  @override
  String get noQuickTemplateArticles => 'No quick template articles configured';

  @override
  String get articleCategory => 'Category';

  @override
  String get laborCategory => 'Labor';

  @override
  String get materialsCategory => 'Materials';

  @override
  String get travelCategory => 'Travel';

  @override
  String get rentalCategory => 'Equipment rental';

  @override
  String get supplyCategory => 'Supply';

  @override
  String get margin => 'Margin (%)';

  @override
  String get defaultTax => 'Default tax (%)';

  @override
  String get surfacePreparation => 'Surface preparation';

  @override
  String get plasterAndSanding => 'Plastering and sanding';

  @override
  String get paintingLabor => 'Painting labor';

  @override
  String get leakDiagnosis => 'Leak diagnosis';

  @override
  String get plumbingInstallation => 'Installation and repair';

  @override
  String get wiringProtection => 'Wiring and protection';

  @override
  String get electricalLabor => 'Electrical labor';

  @override
  String get masonryPreparation => 'Site preparation';

  @override
  String get blockWork => 'Block work';

  @override
  String get masonryLabor => 'Masonry labor';

  @override
  String get siteAddress => 'Job site address';

  @override
  String get projectStatus => 'Job status';

  @override
  String get planned => 'Planned';

  @override
  String get inProgress => 'In progress';

  @override
  String get completed => 'Completed';

  @override
  String get awaitingPayment => 'Awaiting payment';

  @override
  String get estimatedProfit => 'Estimated profit';

  @override
  String get unpaidInvoices => 'Unpaid invoices';

  @override
  String get partialPayment => 'Partial payment';

  @override
  String get remainingToPay => 'Remaining to pay';

  @override
  String get sendReminder => 'Send reminder';

  @override
  String get lastReminder => 'Last reminder';

  @override
  String get reminderLogged => 'Reminder date saved';

  @override
  String get contactClient => 'Contact client';

  @override
  String get globalSearch => 'Global search';

  @override
  String get searchEverything =>
      'Search clients, invoices, projects, articles, payments...';

  @override
  String get globalSearchHint =>
      'Search by client, invoice number, project, article, payment method or note.';

  @override
  String get noSearchResults => 'No matching results';

  @override
  String get addToProject => 'Add to project';

  @override
  String get supplier => 'Supplier';

  @override
  String get attachReceipt => 'Attach receipt photo';

  @override
  String get changeReceipt => 'Change receipt';

  @override
  String get quickClient => 'Quick client';

  @override
  String get quickArticle => 'Quick article';

  @override
  String get mobileQuickActions => 'Quick actions';

  @override
  String get draftAutoSaved => 'Draft autosaved';

  @override
  String get collectedThisMonth => 'Collected this month';

  @override
  String get monthlyExpenses => 'Expenses this month';

  @override
  String get ongoingProjects => 'Ongoing jobs';

  @override
  String get deleteClientErrorHasInvoices =>
      'Cannot delete: this client has invoices.';

  @override
  String get deleteClientErrorHasPayments =>
      'Cannot delete: this client has payments.';

  @override
  String get deleteClientConfirm =>
      'Delete this client? Associated quotes will also be deleted.';

  @override
  String get clientDeleted => 'Client deleted successfully.';

  @override
  String get deleteInvoiceConfirm =>
      'Delete this invoice? This action cannot be undone.';

  @override
  String get deleteInvoiceErrorHasPayments =>
      'Cannot delete: this invoice already has payments recorded.';

  @override
  String get invoiceDeleted => 'Invoice deleted successfully.';

  @override
  String get deleteQuoteConfirm => 'Delete this quote?';

  @override
  String get quoteDeleted => 'Quote deleted successfully.';

  @override
  String get createRefund => 'Create Refund';

  @override
  String get refund => 'Refund / Credit Note';

  @override
  String get refunds => 'Refunds';

  @override
  String get refundDetails => 'Refund Details';

  @override
  String get refundNumber => 'Refund #';

  @override
  String get refundDate => 'Refund Date';

  @override
  String get refundReason => 'Reason';

  @override
  String get refundAmount => 'Refunded Amount';

  @override
  String get netAmount => 'Net Amount';

  @override
  String get refundedQuantity => 'Refunded Qty';

  @override
  String get availableToRefund => 'Available to refund';

  @override
  String get refundSuccess => 'Refund created successfully';

  @override
  String get refundErrorExceedsQuantity =>
      'Quantity exceeds remaining invoiced quantity.';

  @override
  String get refundErrorCancelledInvoice =>
      'Cannot create refund on a cancelled invoice.';

  @override
  String get profitability => 'Profitability';

  @override
  String get projectProfitability => 'Project Profitability';

  @override
  String get noRefundsYet => 'No credit notes yet';

  @override
  String get validated => 'Validated';

  @override
  String get includePayments => 'Include Payments';

  @override
  String get paymentHistoryAndBalance => 'Payment history and balance due';

  @override
  String get confirm => 'Confirm';

  @override
  String get cash => 'Cash';

  @override
  String get transfer => 'Transfer';

  @override
  String get errorPaymentExceedsBalance =>
      'Payment amount cannot exceed the remaining balance';

  @override
  String get before => 'Before';

  @override
  String get during => 'During';

  @override
  String get after => 'After';

  @override
  String get addPhoto => 'Add Photo';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get projectPhotos => 'Project Photos';

  @override
  String get photoCategory => 'Category';

  @override
  String get comment => 'Comment';
}
