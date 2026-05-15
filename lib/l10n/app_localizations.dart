import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Invoice Pro'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @invoiceLabel.
  ///
  /// In en, this message translates to:
  /// **'Invoice'**
  String get invoiceLabel;

  /// No description provided for @quoteLabel.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quoteLabel;

  /// No description provided for @clients.
  ///
  /// In en, this message translates to:
  /// **'Clients'**
  String get clients;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @createInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get createInvoice;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @overdue.
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get overdue;

  /// No description provided for @unpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get unpaid;

  /// No description provided for @accepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get accepted;

  /// No description provided for @converted.
  ///
  /// In en, this message translates to:
  /// **'Converted'**
  String get converted;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @systemTheme.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get systemTheme;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dueDate.
  ///
  /// In en, this message translates to:
  /// **'Due Date'**
  String get dueDate;

  /// No description provided for @issueDate.
  ///
  /// In en, this message translates to:
  /// **'Issue Date'**
  String get issueDate;

  /// No description provided for @clientName.
  ///
  /// In en, this message translates to:
  /// **'Client Name'**
  String get clientName;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices found'**
  String get noInvoices;

  /// No description provided for @noClients.
  ///
  /// In en, this message translates to:
  /// **'No clients found'**
  String get noClients;

  /// No description provided for @addClient.
  ///
  /// In en, this message translates to:
  /// **'Add Client'**
  String get addClient;

  /// No description provided for @editClient.
  ///
  /// In en, this message translates to:
  /// **'Edit Client'**
  String get editClient;

  /// No description provided for @editInvoice.
  ///
  /// In en, this message translates to:
  /// **'Edit Invoice'**
  String get editInvoice;

  /// No description provided for @clientDetails.
  ///
  /// In en, this message translates to:
  /// **'Client Details'**
  String get clientDetails;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get name;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @website.
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirmDelete;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get downloadPdf;

  /// No description provided for @pdfSaved.
  ///
  /// In en, this message translates to:
  /// **'PDF saved to Documents'**
  String get pdfSaved;

  /// No description provided for @viewPdf.
  ///
  /// In en, this message translates to:
  /// **'View PDF'**
  String get viewPdf;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @exportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get exportPdf;

  /// No description provided for @companyInfo.
  ///
  /// In en, this message translates to:
  /// **'Business Profile'**
  String get companyInfo;

  /// No description provided for @businessProfileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Used on generated PDF invoices'**
  String get businessProfileSubtitle;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currency;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Line Item'**
  String get addItem;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unitPrice;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax (%)'**
  String get tax;

  /// No description provided for @discount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get discount;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @totalTax.
  ///
  /// In en, this message translates to:
  /// **'Tax Amount'**
  String get totalTax;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @invoiceNumber.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get invoiceNumber;

  /// No description provided for @selectClient.
  ///
  /// In en, this message translates to:
  /// **'Select Client'**
  String get selectClient;

  /// No description provided for @selectArticle.
  ///
  /// In en, this message translates to:
  /// **'Select Article'**
  String get selectArticle;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @paymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Payment Amount'**
  String get paymentAmount;

  /// No description provided for @paymentRecorded.
  ///
  /// In en, this message translates to:
  /// **'Payment recorded'**
  String get paymentRecorded;

  /// No description provided for @invoiceMarkedPaid.
  ///
  /// In en, this message translates to:
  /// **'Invoice marked as PAID'**
  String get invoiceMarkedPaid;

  /// No description provided for @updateStatus.
  ///
  /// In en, this message translates to:
  /// **'Update Status'**
  String get updateStatus;

  /// No description provided for @statusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get statusUpdated;

  /// No description provided for @billTo.
  ///
  /// In en, this message translates to:
  /// **'Bill To'**
  String get billTo;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @newInvoice.
  ///
  /// In en, this message translates to:
  /// **'New Invoice'**
  String get newInvoice;

  /// No description provided for @invoiceDetails.
  ///
  /// In en, this message translates to:
  /// **'Invoice Details'**
  String get invoiceDetails;

  /// No description provided for @attachment.
  ///
  /// In en, this message translates to:
  /// **'Attachment'**
  String get attachment;

  /// No description provided for @addAttachment.
  ///
  /// In en, this message translates to:
  /// **'Add Attachment'**
  String get addAttachment;

  /// No description provided for @changeAttachment.
  ///
  /// In en, this message translates to:
  /// **'Change Attachment'**
  String get changeAttachment;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSaved.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSaved;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @outstanding.
  ///
  /// In en, this message translates to:
  /// **'Outstanding'**
  String get outstanding;

  /// No description provided for @totalClients.
  ///
  /// In en, this message translates to:
  /// **'Total Clients'**
  String get totalClients;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastMonth.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get lastMonth;

  /// No description provided for @issued.
  ///
  /// In en, this message translates to:
  /// **'Issued'**
  String get issued;

  /// No description provided for @recentInvoices.
  ///
  /// In en, this message translates to:
  /// **'Recent Invoices'**
  String get recentInvoices;

  /// No description provided for @overdueInvoices.
  ///
  /// In en, this message translates to:
  /// **'Overdue Invoices'**
  String get overdueInvoices;

  /// No description provided for @overdueAlert.
  ///
  /// In en, this message translates to:
  /// **'{count} Overdue Invoice(s)'**
  String overdueAlert(int count);

  /// No description provided for @immediateAction.
  ///
  /// In en, this message translates to:
  /// **'Immediate action required'**
  String get immediateAction;

  /// No description provided for @noRecentInvoices.
  ///
  /// In en, this message translates to:
  /// **'No recent invoices'**
  String get noRecentInvoices;

  /// No description provided for @thankyou.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your business!'**
  String get thankyou;

  /// No description provided for @paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms: Net 30 days.'**
  String get paymentTerms;

  /// No description provided for @pdfDownloadedAndOpened.
  ///
  /// In en, this message translates to:
  /// **'PDF downloaded and opened:'**
  String get pdfDownloadedAndOpened;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @errorGeneratingPdf.
  ///
  /// In en, this message translates to:
  /// **'Error generating PDF'**
  String get errorGeneratingPdf;

  /// No description provided for @notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get notesOptional;

  /// No description provided for @paymentNotesHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bank transfer, Cash'**
  String get paymentNotesHint;

  /// No description provided for @record.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get record;

  /// No description provided for @changeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get changeStatus;

  /// No description provided for @unknownClient.
  ///
  /// In en, this message translates to:
  /// **'Unknown Client'**
  String get unknownClient;

  /// No description provided for @invoiceSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Invoice saved successfully'**
  String get invoiceSavedSuccessfully;

  /// No description provided for @addAtLeastOnePricedItem.
  ///
  /// In en, this message translates to:
  /// **'Please add at least one item with a price'**
  String get addAtLeastOnePricedItem;

  /// No description provided for @errorSavingInvoice.
  ///
  /// In en, this message translates to:
  /// **'Error saving invoice'**
  String get errorSavingInvoice;

  /// No description provided for @searchClients.
  ///
  /// In en, this message translates to:
  /// **'Search clients...'**
  String get searchClients;

  /// No description provided for @searchInvoices.
  ///
  /// In en, this message translates to:
  /// **'Search invoices...'**
  String get searchInvoices;

  /// No description provided for @errorLoadingClients.
  ///
  /// In en, this message translates to:
  /// **'Error loading clients'**
  String get errorLoadingClients;

  /// No description provided for @addFirstClient.
  ///
  /// In en, this message translates to:
  /// **'Add Your First Client'**
  String get addFirstClient;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @french.
  ///
  /// In en, this message translates to:
  /// **'French'**
  String get french;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @currencySymbol.
  ///
  /// In en, this message translates to:
  /// **'DZD'**
  String get currencySymbol;

  /// No description provided for @payments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get payments;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @noPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments found'**
  String get noPayments;

  /// No description provided for @addPayment.
  ///
  /// In en, this message translates to:
  /// **'Add Payment'**
  String get addPayment;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// No description provided for @paidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get paidAmount;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @paymentDate.
  ///
  /// In en, this message translates to:
  /// **'Payment Date'**
  String get paymentDate;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @relatedPayments.
  ///
  /// In en, this message translates to:
  /// **'Related Payments'**
  String get relatedPayments;

  /// No description provided for @articles.
  ///
  /// In en, this message translates to:
  /// **'Articles'**
  String get articles;

  /// No description provided for @article.
  ///
  /// In en, this message translates to:
  /// **'Article'**
  String get article;

  /// No description provided for @noArticles.
  ///
  /// In en, this message translates to:
  /// **'No articles found'**
  String get noArticles;

  /// No description provided for @addArticle.
  ///
  /// In en, this message translates to:
  /// **'Add Article'**
  String get addArticle;

  /// No description provided for @editArticle.
  ///
  /// In en, this message translates to:
  /// **'Edit Article'**
  String get editArticle;

  /// No description provided for @code.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @measure.
  ///
  /// In en, this message translates to:
  /// **'Measure'**
  String get measure;

  /// No description provided for @searchArticles.
  ///
  /// In en, this message translates to:
  /// **'Search articles...'**
  String get searchArticles;

  /// No description provided for @pricePerUnit.
  ///
  /// In en, this message translates to:
  /// **'Price per unit'**
  String get pricePerUnit;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @m2.
  ///
  /// In en, this message translates to:
  /// **'m²'**
  String get m2;

  /// No description provided for @m3.
  ///
  /// In en, this message translates to:
  /// **'m³'**
  String get m3;

  /// No description provided for @pieces.
  ///
  /// In en, this message translates to:
  /// **'Pieces'**
  String get pieces;

  /// No description provided for @physical.
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// No description provided for @service.
  ///
  /// In en, this message translates to:
  /// **'Service'**
  String get service;

  /// No description provided for @projects.
  ///
  /// In en, this message translates to:
  /// **'Projects'**
  String get projects;

  /// No description provided for @project.
  ///
  /// In en, this message translates to:
  /// **'Project'**
  String get project;

  /// No description provided for @projectDetails.
  ///
  /// In en, this message translates to:
  /// **'Project Details'**
  String get projectDetails;

  /// No description provided for @addProject.
  ///
  /// In en, this message translates to:
  /// **'Add Project'**
  String get addProject;

  /// No description provided for @noProjects.
  ///
  /// In en, this message translates to:
  /// **'No projects found'**
  String get noProjects;

  /// No description provided for @projectName.
  ///
  /// In en, this message translates to:
  /// **'Project Name'**
  String get projectName;

  /// No description provided for @optionalProject.
  ///
  /// In en, this message translates to:
  /// **'Project (optional)'**
  String get optionalProject;

  /// No description provided for @noProject.
  ///
  /// In en, this message translates to:
  /// **'No project'**
  String get noProject;

  /// No description provided for @expenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// No description provided for @expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get expense;

  /// No description provided for @addExpense.
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// No description provided for @noExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses found'**
  String get noExpenses;

  /// No description provided for @expenseType.
  ///
  /// In en, this message translates to:
  /// **'Expense Type'**
  String get expenseType;

  /// No description provided for @expenseTypes.
  ///
  /// In en, this message translates to:
  /// **'Expense Types'**
  String get expenseTypes;

  /// No description provided for @expenseTypesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage reusable project expense categories.'**
  String get expenseTypesSubtitle;

  /// No description provided for @relatedInvoices.
  ///
  /// In en, this message translates to:
  /// **'Related Invoices'**
  String get relatedInvoices;

  /// No description provided for @notProvided.
  ///
  /// In en, this message translates to:
  /// **'Not provided'**
  String get notProvided;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @updateClient.
  ///
  /// In en, this message translates to:
  /// **'Update Client'**
  String get updateClient;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @companyLogo.
  ///
  /// In en, this message translates to:
  /// **'Company Logo'**
  String get companyLogo;

  /// No description provided for @companyLogoSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Appears on all generated PDF invoices'**
  String get companyLogoSubtitle;

  /// No description provided for @noLogo.
  ///
  /// In en, this message translates to:
  /// **'No Logo'**
  String get noLogo;

  /// No description provided for @changeLogo.
  ///
  /// In en, this message translates to:
  /// **'Change Logo'**
  String get changeLogo;

  /// No description provided for @uploadLogo.
  ///
  /// In en, this message translates to:
  /// **'Upload Logo'**
  String get uploadLogo;

  /// No description provided for @removeLogo.
  ///
  /// In en, this message translates to:
  /// **'Remove Logo'**
  String get removeLogo;

  /// No description provided for @logoHelp.
  ///
  /// In en, this message translates to:
  /// **'PNG or JPG, used on PDF invoices.'**
  String get logoHelp;

  /// No description provided for @invoiceNotFound.
  ///
  /// In en, this message translates to:
  /// **'Invoice not found'**
  String get invoiceNotFound;

  /// No description provided for @invoiceNumberShort.
  ///
  /// In en, this message translates to:
  /// **'Invoice #'**
  String get invoiceNumberShort;

  /// No description provided for @addClientFirst.
  ///
  /// In en, this message translates to:
  /// **'Add a client first'**
  String get addClientFirst;

  /// No description provided for @quotes.
  ///
  /// In en, this message translates to:
  /// **'Quotes'**
  String get quotes;

  /// No description provided for @quote.
  ///
  /// In en, this message translates to:
  /// **'Quote'**
  String get quote;

  /// No description provided for @createQuote.
  ///
  /// In en, this message translates to:
  /// **'New Quote'**
  String get createQuote;

  /// No description provided for @editQuote.
  ///
  /// In en, this message translates to:
  /// **'Edit Quote'**
  String get editQuote;

  /// No description provided for @quoteDetails.
  ///
  /// In en, this message translates to:
  /// **'Quote Details'**
  String get quoteDetails;

  /// No description provided for @quoteNumber.
  ///
  /// In en, this message translates to:
  /// **'Quote #'**
  String get quoteNumber;

  /// No description provided for @validUntil.
  ///
  /// In en, this message translates to:
  /// **'Valid Until'**
  String get validUntil;

  /// No description provided for @noQuotes.
  ///
  /// In en, this message translates to:
  /// **'No quotes found'**
  String get noQuotes;

  /// No description provided for @convertToInvoice.
  ///
  /// In en, this message translates to:
  /// **'Convert to invoice'**
  String get convertToInvoice;

  /// No description provided for @quoteConverted.
  ///
  /// In en, this message translates to:
  /// **'Quote converted to invoice'**
  String get quoteConverted;

  /// No description provided for @approvalSignature.
  ///
  /// In en, this message translates to:
  /// **'Client approval signature'**
  String get approvalSignature;

  /// No description provided for @goodForApproval.
  ///
  /// In en, this message translates to:
  /// **'Good for approval'**
  String get goodForApproval;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @quickTemplates.
  ///
  /// In en, this message translates to:
  /// **'Quick templates'**
  String get quickTemplates;

  /// No description provided for @paintingRoom.
  ///
  /// In en, this message translates to:
  /// **'Room painting'**
  String get paintingRoom;

  /// No description provided for @plumbingRepair.
  ///
  /// In en, this message translates to:
  /// **'Plumbing repair'**
  String get plumbingRepair;

  /// No description provided for @electricalJob.
  ///
  /// In en, this message translates to:
  /// **'Electrical work'**
  String get electricalJob;

  /// No description provided for @masonryWork.
  ///
  /// In en, this message translates to:
  /// **'Masonry work'**
  String get masonryWork;

  /// No description provided for @quickTemplateTrade.
  ///
  /// In en, this message translates to:
  /// **'Quick quote template'**
  String get quickTemplateTrade;

  /// No description provided for @noQuickTemplate.
  ///
  /// In en, this message translates to:
  /// **'No quick template'**
  String get noQuickTemplate;

  /// No description provided for @defaultQuantity.
  ///
  /// In en, this message translates to:
  /// **'Default quantity'**
  String get defaultQuantity;

  /// No description provided for @quickTemplateOrder.
  ///
  /// In en, this message translates to:
  /// **'Display order'**
  String get quickTemplateOrder;

  /// No description provided for @configureQuickArticles.
  ///
  /// In en, this message translates to:
  /// **'Configure quick articles'**
  String get configureQuickArticles;

  /// No description provided for @chooseFromArticles.
  ///
  /// In en, this message translates to:
  /// **'Choose article'**
  String get chooseFromArticles;

  /// No description provided for @addQuickTemplateArticles.
  ///
  /// In en, this message translates to:
  /// **'Add quick template'**
  String get addQuickTemplateArticles;

  /// No description provided for @noQuickTemplateArticles.
  ///
  /// In en, this message translates to:
  /// **'No quick template articles configured'**
  String get noQuickTemplateArticles;

  /// No description provided for @articleCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get articleCategory;

  /// No description provided for @laborCategory.
  ///
  /// In en, this message translates to:
  /// **'Labor'**
  String get laborCategory;

  /// No description provided for @materialsCategory.
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materialsCategory;

  /// No description provided for @travelCategory.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get travelCategory;

  /// No description provided for @rentalCategory.
  ///
  /// In en, this message translates to:
  /// **'Equipment rental'**
  String get rentalCategory;

  /// No description provided for @supplyCategory.
  ///
  /// In en, this message translates to:
  /// **'Supply'**
  String get supplyCategory;

  /// No description provided for @margin.
  ///
  /// In en, this message translates to:
  /// **'Margin (%)'**
  String get margin;

  /// No description provided for @defaultTax.
  ///
  /// In en, this message translates to:
  /// **'Default tax (%)'**
  String get defaultTax;

  /// No description provided for @surfacePreparation.
  ///
  /// In en, this message translates to:
  /// **'Surface preparation'**
  String get surfacePreparation;

  /// No description provided for @plasterAndSanding.
  ///
  /// In en, this message translates to:
  /// **'Plastering and sanding'**
  String get plasterAndSanding;

  /// No description provided for @paintingLabor.
  ///
  /// In en, this message translates to:
  /// **'Painting labor'**
  String get paintingLabor;

  /// No description provided for @leakDiagnosis.
  ///
  /// In en, this message translates to:
  /// **'Leak diagnosis'**
  String get leakDiagnosis;

  /// No description provided for @plumbingInstallation.
  ///
  /// In en, this message translates to:
  /// **'Installation and repair'**
  String get plumbingInstallation;

  /// No description provided for @wiringProtection.
  ///
  /// In en, this message translates to:
  /// **'Wiring and protection'**
  String get wiringProtection;

  /// No description provided for @electricalLabor.
  ///
  /// In en, this message translates to:
  /// **'Electrical labor'**
  String get electricalLabor;

  /// No description provided for @masonryPreparation.
  ///
  /// In en, this message translates to:
  /// **'Site preparation'**
  String get masonryPreparation;

  /// No description provided for @blockWork.
  ///
  /// In en, this message translates to:
  /// **'Block work'**
  String get blockWork;

  /// No description provided for @masonryLabor.
  ///
  /// In en, this message translates to:
  /// **'Masonry labor'**
  String get masonryLabor;

  /// No description provided for @siteAddress.
  ///
  /// In en, this message translates to:
  /// **'Job site address'**
  String get siteAddress;

  /// No description provided for @projectStatus.
  ///
  /// In en, this message translates to:
  /// **'Job status'**
  String get projectStatus;

  /// No description provided for @planned.
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get planned;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get inProgress;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @awaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting payment'**
  String get awaitingPayment;

  /// No description provided for @estimatedProfit.
  ///
  /// In en, this message translates to:
  /// **'Estimated profit'**
  String get estimatedProfit;

  /// No description provided for @unpaidInvoices.
  ///
  /// In en, this message translates to:
  /// **'Unpaid invoices'**
  String get unpaidInvoices;

  /// No description provided for @partialPayment.
  ///
  /// In en, this message translates to:
  /// **'Partial payment'**
  String get partialPayment;

  /// No description provided for @remainingToPay.
  ///
  /// In en, this message translates to:
  /// **'Remaining to pay'**
  String get remainingToPay;

  /// No description provided for @sendReminder.
  ///
  /// In en, this message translates to:
  /// **'Send reminder'**
  String get sendReminder;

  /// No description provided for @lastReminder.
  ///
  /// In en, this message translates to:
  /// **'Last reminder'**
  String get lastReminder;

  /// No description provided for @reminderLogged.
  ///
  /// In en, this message translates to:
  /// **'Reminder date saved'**
  String get reminderLogged;

  /// No description provided for @contactClient.
  ///
  /// In en, this message translates to:
  /// **'Contact client'**
  String get contactClient;

  /// No description provided for @globalSearch.
  ///
  /// In en, this message translates to:
  /// **'Global search'**
  String get globalSearch;

  /// No description provided for @searchEverything.
  ///
  /// In en, this message translates to:
  /// **'Search clients, invoices, projects, articles, payments...'**
  String get searchEverything;

  /// No description provided for @globalSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by client, invoice number, project, article, payment method or note.'**
  String get globalSearchHint;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No matching results'**
  String get noSearchResults;

  /// No description provided for @addToProject.
  ///
  /// In en, this message translates to:
  /// **'Add to project'**
  String get addToProject;

  /// No description provided for @supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get supplier;

  /// No description provided for @attachReceipt.
  ///
  /// In en, this message translates to:
  /// **'Attach receipt photo'**
  String get attachReceipt;

  /// No description provided for @changeReceipt.
  ///
  /// In en, this message translates to:
  /// **'Change receipt'**
  String get changeReceipt;

  /// No description provided for @quickClient.
  ///
  /// In en, this message translates to:
  /// **'Quick client'**
  String get quickClient;

  /// No description provided for @quickArticle.
  ///
  /// In en, this message translates to:
  /// **'Quick article'**
  String get quickArticle;

  /// No description provided for @mobileQuickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get mobileQuickActions;

  /// No description provided for @draftAutoSaved.
  ///
  /// In en, this message translates to:
  /// **'Draft autosaved'**
  String get draftAutoSaved;

  /// No description provided for @collectedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Collected this month'**
  String get collectedThisMonth;

  /// No description provided for @monthlyExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses this month'**
  String get monthlyExpenses;

  /// No description provided for @ongoingProjects.
  ///
  /// In en, this message translates to:
  /// **'Ongoing jobs'**
  String get ongoingProjects;

  /// No description provided for @deleteClientErrorHasInvoices.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete: this client has invoices.'**
  String get deleteClientErrorHasInvoices;

  /// No description provided for @deleteClientErrorHasPayments.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete: this client has payments.'**
  String get deleteClientErrorHasPayments;

  /// No description provided for @deleteClientConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this client? Associated quotes will also be deleted.'**
  String get deleteClientConfirm;

  /// No description provided for @clientDeleted.
  ///
  /// In en, this message translates to:
  /// **'Client deleted successfully.'**
  String get clientDeleted;

  /// No description provided for @deleteInvoiceConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this invoice? This action cannot be undone.'**
  String get deleteInvoiceConfirm;

  /// No description provided for @deleteInvoiceErrorHasPayments.
  ///
  /// In en, this message translates to:
  /// **'Cannot delete: this invoice already has payments recorded.'**
  String get deleteInvoiceErrorHasPayments;

  /// No description provided for @invoiceDeleted.
  ///
  /// In en, this message translates to:
  /// **'Invoice deleted successfully.'**
  String get invoiceDeleted;

  /// No description provided for @deleteQuoteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this quote?'**
  String get deleteQuoteConfirm;

  /// No description provided for @quoteDeleted.
  ///
  /// In en, this message translates to:
  /// **'Quote deleted successfully.'**
  String get quoteDeleted;

  /// No description provided for @createRefund.
  ///
  /// In en, this message translates to:
  /// **'Create Refund'**
  String get createRefund;

  /// No description provided for @refund.
  ///
  /// In en, this message translates to:
  /// **'Refund / Credit Note'**
  String get refund;

  /// No description provided for @refunds.
  ///
  /// In en, this message translates to:
  /// **'Refunds'**
  String get refunds;

  /// No description provided for @refundDetails.
  ///
  /// In en, this message translates to:
  /// **'Refund Details'**
  String get refundDetails;

  /// No description provided for @refundNumber.
  ///
  /// In en, this message translates to:
  /// **'Refund #'**
  String get refundNumber;

  /// No description provided for @refundDate.
  ///
  /// In en, this message translates to:
  /// **'Refund Date'**
  String get refundDate;

  /// No description provided for @refundReason.
  ///
  /// In en, this message translates to:
  /// **'Reason'**
  String get refundReason;

  /// No description provided for @refundAmount.
  ///
  /// In en, this message translates to:
  /// **'Refunded Amount'**
  String get refundAmount;

  /// No description provided for @netAmount.
  ///
  /// In en, this message translates to:
  /// **'Net Amount'**
  String get netAmount;

  /// No description provided for @refundedQuantity.
  ///
  /// In en, this message translates to:
  /// **'Refunded Qty'**
  String get refundedQuantity;

  /// No description provided for @availableToRefund.
  ///
  /// In en, this message translates to:
  /// **'Available to refund'**
  String get availableToRefund;

  /// No description provided for @refundSuccess.
  ///
  /// In en, this message translates to:
  /// **'Refund created successfully'**
  String get refundSuccess;

  /// No description provided for @refundErrorExceedsQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity exceeds remaining invoiced quantity.'**
  String get refundErrorExceedsQuantity;

  /// No description provided for @refundErrorCancelledInvoice.
  ///
  /// In en, this message translates to:
  /// **'Cannot create refund on a cancelled invoice.'**
  String get refundErrorCancelledInvoice;

  /// No description provided for @profitability.
  ///
  /// In en, this message translates to:
  /// **'Profitability'**
  String get profitability;

  /// No description provided for @projectProfitability.
  ///
  /// In en, this message translates to:
  /// **'Project Profitability'**
  String get projectProfitability;

  /// No description provided for @noRefundsYet.
  ///
  /// In en, this message translates to:
  /// **'No credit notes yet'**
  String get noRefundsYet;

  /// No description provided for @validated.
  ///
  /// In en, this message translates to:
  /// **'Validated'**
  String get validated;

  /// No description provided for @includePayments.
  ///
  /// In en, this message translates to:
  /// **'Include Payments'**
  String get includePayments;

  /// No description provided for @paymentHistoryAndBalance.
  ///
  /// In en, this message translates to:
  /// **'Payment history and balance due'**
  String get paymentHistoryAndBalance;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @transfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transfer;

  /// No description provided for @errorPaymentExceedsBalance.
  ///
  /// In en, this message translates to:
  /// **'Payment amount cannot exceed the remaining balance'**
  String get errorPaymentExceedsBalance;

  /// No description provided for @before.
  ///
  /// In en, this message translates to:
  /// **'Before'**
  String get before;

  /// No description provided for @during.
  ///
  /// In en, this message translates to:
  /// **'During'**
  String get during;

  /// No description provided for @after.
  ///
  /// In en, this message translates to:
  /// **'After'**
  String get after;

  /// No description provided for @addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get addPhoto;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @projectPhotos.
  ///
  /// In en, this message translates to:
  /// **'Project Photos'**
  String get projectPhotos;

  /// No description provided for @photoCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get photoCategory;

  /// No description provided for @comment.
  ///
  /// In en, this message translates to:
  /// **'Comment'**
  String get comment;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
