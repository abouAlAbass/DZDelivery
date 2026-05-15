// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Invoice Pro';

  @override
  String get dashboard => 'Tableau de bord';

  @override
  String get invoices => 'Factures';

  @override
  String get invoiceLabel => 'Facture';

  @override
  String get quoteLabel => 'Devis';

  @override
  String get clients => 'Clients';

  @override
  String get settings => 'Paramètres';

  @override
  String get logout => 'Déconnexion';

  @override
  String get login => 'Connexion';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mot de passe';

  @override
  String get createInvoice => 'Nouvelle facture';

  @override
  String get draft => 'Brouillon';

  @override
  String get sent => 'Envoyée';

  @override
  String get paid => 'Payée';

  @override
  String get overdue => 'En retard';

  @override
  String get unpaid => 'Impayée';

  @override
  String get accepted => 'Accepté';

  @override
  String get converted => 'Converti';

  @override
  String get cancelled => 'Annulée';

  @override
  String get expired => 'Expiré';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get darkTheme => 'Thème sombre';

  @override
  String get lightTheme => 'Thème clair';

  @override
  String get systemTheme => 'Système par défaut';

  @override
  String get selectTheme => 'Choisir le thème';

  @override
  String get selectLanguage => 'Choisir la langue';

  @override
  String get total => 'Total';

  @override
  String get status => 'Statut';

  @override
  String get date => 'Date';

  @override
  String get dueDate => 'Date d\'échéance';

  @override
  String get issueDate => 'Date d\'émission';

  @override
  String get clientName => 'Nom du client';

  @override
  String get amount => 'Montant';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get noInvoices => 'Aucune facture trouvée';

  @override
  String get noClients => 'Aucun client trouvé';

  @override
  String get addClient => 'Ajouter un client';

  @override
  String get editClient => 'Modifier le client';

  @override
  String get editInvoice => 'Modifier la facture';

  @override
  String get clientDetails => 'Détails du client';

  @override
  String get save => 'Enregistrer';

  @override
  String get cancel => 'Annuler';

  @override
  String get name => 'Nom complet';

  @override
  String get address => 'Adresse';

  @override
  String get phone => 'Téléphone';

  @override
  String get website => 'Site web';

  @override
  String get companyName => 'Nom de l\'entreprise';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get confirmDelete => 'Voulez-vous vraiment supprimer ceci ?';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get downloadPdf => 'Télécharger le PDF';

  @override
  String get pdfSaved => 'PDF enregistré dans Documents';

  @override
  String get viewPdf => 'Voir le PDF';

  @override
  String get share => 'Partager';

  @override
  String get exportPdf => 'Exporter en PDF';

  @override
  String get companyInfo => 'Profil de l\'entreprise';

  @override
  String get businessProfileSubtitle => 'Utilisé sur les factures PDF générées';

  @override
  String get currency => 'Devise';

  @override
  String get items => 'Articles';

  @override
  String get addItem => 'Ajouter un article';

  @override
  String get description => 'Description';

  @override
  String get quantity => 'Quantité';

  @override
  String get price => 'Prix';

  @override
  String get unitPrice => 'Prix unitaire';

  @override
  String get tax => 'Taxe (%)';

  @override
  String get discount => 'Remise';

  @override
  String get subtotal => 'Sous-total';

  @override
  String get totalTax => 'Montant de la taxe';

  @override
  String get notes => 'Notes';

  @override
  String get invoiceNumber => 'N° Facture';

  @override
  String get selectClient => 'Sélectionner un client';

  @override
  String get selectArticle => 'Sélectionner un article';

  @override
  String get recordPayment => 'Enregistrer un paiement';

  @override
  String get paymentAmount => 'Montant du paiement';

  @override
  String get paymentRecorded => 'Paiement enregistré';

  @override
  String get invoiceMarkedPaid => 'Facture marquée comme PAYÉE';

  @override
  String get updateStatus => 'Mettre à jour le statut';

  @override
  String get statusUpdated => 'Statut mis à jour';

  @override
  String get billTo => 'Facturer à';

  @override
  String get summary => 'Résumé';

  @override
  String get newInvoice => 'Nouvelle facture';

  @override
  String get invoiceDetails => 'Détails de la facture';

  @override
  String get attachment => 'Pièce jointe';

  @override
  String get addAttachment => 'Ajouter une pièce jointe';

  @override
  String get changeAttachment => 'Changer la pièce jointe';

  @override
  String get saveSettings => 'Enregistrer les paramètres';

  @override
  String get settingsSaved => 'Paramètres enregistrés avec succès';

  @override
  String get appSettings => 'Paramètres de l\'application';

  @override
  String get totalRevenue => 'Chiffre d\'affaires';

  @override
  String get outstanding => 'En attente';

  @override
  String get totalClients => 'Total clients';

  @override
  String get thisMonth => 'Ce mois';

  @override
  String get thisWeek => 'Cette semaine';

  @override
  String get lastMonth => 'Le mois dernier';

  @override
  String get issued => 'Emises';

  @override
  String get recentInvoices => 'Factures récentes';

  @override
  String get overdueInvoices => 'Factures en retard';

  @override
  String overdueAlert(int count) {
    return '$count Facture(s) en retard';
  }

  @override
  String get immediateAction => 'Action immédiate requise';

  @override
  String get noRecentInvoices => 'Aucune facture récente';

  @override
  String get thankyou => 'Merci pour votre confiance !';

  @override
  String get paymentTerms => 'Conditions de paiement : 30 jours net.';

  @override
  String get pdfDownloadedAndOpened => 'PDF téléchargé et ouvert :';

  @override
  String get error => 'Erreur';

  @override
  String get errorGeneratingPdf => 'Erreur lors de la génération du PDF';

  @override
  String get notesOptional => 'Notes (facultatif)';

  @override
  String get paymentNotesHint => 'ex. virement bancaire, espèces';

  @override
  String get record => 'Enregistrer';

  @override
  String get changeStatus => 'Changer le statut';

  @override
  String get unknownClient => 'Client inconnu';

  @override
  String get invoiceSavedSuccessfully => 'Facture enregistrée avec succès';

  @override
  String get addAtLeastOnePricedItem =>
      'Veuillez ajouter au moins un article avec un prix';

  @override
  String get errorSavingInvoice =>
      'Erreur lors de l\'enregistrement de la facture';

  @override
  String get searchClients => 'Rechercher des clients...';

  @override
  String get searchInvoices => 'Rechercher des factures...';

  @override
  String get errorLoadingClients => 'Erreur lors du chargement des clients';

  @override
  String get addFirstClient => 'Ajouter votre premier client';

  @override
  String get english => 'Anglais';

  @override
  String get french => 'Français';

  @override
  String get arabic => 'Arabe';

  @override
  String get currencySymbol => 'DZD';

  @override
  String get payments => 'Paiements';

  @override
  String get payment => 'Paiement';

  @override
  String get noPayments => 'Aucun paiement trouvé';

  @override
  String get addPayment => 'Ajouter un paiement';

  @override
  String get balance => 'Solde';

  @override
  String get paidAmount => 'Montant payé';

  @override
  String get remaining => 'Restant';

  @override
  String get paymentMethod => 'Mode de paiement';

  @override
  String get paymentDate => 'Date de paiement';

  @override
  String get history => 'Historique';

  @override
  String get relatedPayments => 'Paiements associés';

  @override
  String get articles => 'Articles';

  @override
  String get article => 'Article';

  @override
  String get noArticles => 'Aucun article trouvé';

  @override
  String get addArticle => 'Ajouter un article';

  @override
  String get editArticle => 'Modifier l\'article';

  @override
  String get code => 'Code';

  @override
  String get unit => 'Unité';

  @override
  String get measure => 'Mesure';

  @override
  String get searchArticles => 'Rechercher des articles...';

  @override
  String get pricePerUnit => 'Prix unitaire';

  @override
  String get kg => 'kg';

  @override
  String get m2 => 'm²';

  @override
  String get m3 => 'm³';

  @override
  String get pieces => 'Pièces';

  @override
  String get physical => 'Physique';

  @override
  String get service => 'Service';

  @override
  String get projects => 'Projets';

  @override
  String get project => 'Projet';

  @override
  String get projectDetails => 'Détails du projet';

  @override
  String get addProject => 'Ajouter un projet';

  @override
  String get noProjects => 'Aucun projet trouvé';

  @override
  String get projectName => 'Nom du projet';

  @override
  String get optionalProject => 'Projet (facultatif)';

  @override
  String get noProject => 'Aucun projet';

  @override
  String get expenses => 'Dépenses';

  @override
  String get expense => 'Dépense';

  @override
  String get addExpense => 'Ajouter une dépense';

  @override
  String get noExpenses => 'Aucune dépense trouvée';

  @override
  String get expenseType => 'Type de dépense';

  @override
  String get expenseTypes => 'Types de dépenses';

  @override
  String get expenseTypesSubtitle =>
      'Gérez les catégories réutilisables de dépenses de projet.';

  @override
  String get relatedInvoices => 'Factures associées';

  @override
  String get notProvided => 'Non renseigné';

  @override
  String get requiredField => 'Obligatoire';

  @override
  String get updateClient => 'Mettre à jour le client';

  @override
  String get emailAddress => 'Adresse email';

  @override
  String get phoneNumber => 'Numéro de téléphone';

  @override
  String get companyLogo => 'Logo de l\'entreprise';

  @override
  String get companyLogoSubtitle =>
      'Apparaît sur toutes les factures PDF générées';

  @override
  String get noLogo => 'Aucun logo';

  @override
  String get changeLogo => 'Changer le logo';

  @override
  String get uploadLogo => 'Importer un logo';

  @override
  String get removeLogo => 'Supprimer le logo';

  @override
  String get logoHelp => 'PNG ou JPG, utilisé sur les factures PDF.';

  @override
  String get invoiceNotFound => 'Facture introuvable';

  @override
  String get invoiceNumberShort => 'Facture n°';

  @override
  String get addClientFirst => 'Ajoutez d\'abord un client';

  @override
  String get quotes => 'Devis';

  @override
  String get quote => 'Devis';

  @override
  String get createQuote => 'Nouveau devis';

  @override
  String get editQuote => 'Modifier le devis';

  @override
  String get quoteDetails => 'Détails du devis';

  @override
  String get quoteNumber => 'Devis n°';

  @override
  String get validUntil => 'Valable jusqu\'au';

  @override
  String get noQuotes => 'Aucun devis trouvé';

  @override
  String get convertToInvoice => 'Convertir en facture';

  @override
  String get quoteConverted => 'Devis converti en facture';

  @override
  String get approvalSignature => 'Signature d\'accord client';

  @override
  String get goodForApproval => 'Bon pour accord';

  @override
  String get rejected => 'Refusé';

  @override
  String get quickTemplates => 'Modèles rapides';

  @override
  String get paintingRoom => 'Peinture chambre';

  @override
  String get plumbingRepair => 'Réparation plomberie';

  @override
  String get electricalJob => 'Travaux électriques';

  @override
  String get masonryWork => 'Travaux maçonnerie';

  @override
  String get quickTemplateTrade => 'Modèle rapide devis';

  @override
  String get noQuickTemplate => 'Aucun modèle rapide';

  @override
  String get defaultQuantity => 'Quantité par défaut';

  @override
  String get quickTemplateOrder => 'Ordre d\'affichage';

  @override
  String get configureQuickArticles => 'Configurer les articles rapides';

  @override
  String get chooseFromArticles => 'Choisir article';

  @override
  String get addQuickTemplateArticles => 'Ajouter modèle rapide';

  @override
  String get noQuickTemplateArticles => 'Aucun article rapide configuré';

  @override
  String get articleCategory => 'Catégorie';

  @override
  String get laborCategory => 'Main d\'œuvre';

  @override
  String get materialsCategory => 'Matériaux';

  @override
  String get travelCategory => 'Déplacement';

  @override
  String get rentalCategory => 'Location matériel';

  @override
  String get supplyCategory => 'Fourniture';

  @override
  String get margin => 'Marge (%)';

  @override
  String get defaultTax => 'TVA par défaut (%)';

  @override
  String get surfacePreparation => 'Préparation support';

  @override
  String get plasterAndSanding => 'Enduit et ponçage';

  @override
  String get paintingLabor => 'Peinture main d\'œuvre';

  @override
  String get leakDiagnosis => 'Diagnostic fuite';

  @override
  String get plumbingInstallation => 'Pose et réparation';

  @override
  String get wiringProtection => 'Câblage et protection';

  @override
  String get electricalLabor => 'Main d\'œuvre électricité';

  @override
  String get masonryPreparation => 'Préparation chantier';

  @override
  String get blockWork => 'Maçonnerie blocs';

  @override
  String get masonryLabor => 'Main d\'œuvre maçonnerie';

  @override
  String get siteAddress => 'Adresse du chantier';

  @override
  String get projectStatus => 'Statut du chantier';

  @override
  String get planned => 'Prévu';

  @override
  String get inProgress => 'En cours';

  @override
  String get completed => 'Terminé';

  @override
  String get awaitingPayment => 'En attente paiement';

  @override
  String get estimatedProfit => 'Bénéfice estimé';

  @override
  String get unpaidInvoices => 'Factures impayées';

  @override
  String get partialPayment => 'Paiement partiel';

  @override
  String get remainingToPay => 'Reste à payer';

  @override
  String get sendReminder => 'Relancer';

  @override
  String get lastReminder => 'Dernière relance';

  @override
  String get reminderLogged => 'Date de relance enregistrée';

  @override
  String get contactClient => 'Contacter le client';

  @override
  String get globalSearch => 'Recherche globale';

  @override
  String get searchEverything =>
      'Rechercher clients, factures, projets, articles, paiements...';

  @override
  String get globalSearchHint =>
      'Recherchez par client, numéro de facture, projet, article, méthode de paiement ou note.';

  @override
  String get noSearchResults => 'Aucun résultat correspondant';

  @override
  String get addToProject => 'Ajouter au projet';

  @override
  String get supplier => 'Fournisseur';

  @override
  String get attachReceipt => 'Joindre un reçu photo';

  @override
  String get changeReceipt => 'Changer le reçu';

  @override
  String get quickClient => 'Client rapide';

  @override
  String get quickArticle => 'Article rapide';

  @override
  String get mobileQuickActions => 'Actions rapides';

  @override
  String get draftAutoSaved => 'Brouillon sauvegardé automatiquement';

  @override
  String get collectedThisMonth => 'Total encaissé ce mois';

  @override
  String get monthlyExpenses => 'Dépenses du mois';

  @override
  String get ongoingProjects => 'Chantiers en cours';

  @override
  String get deleteClientErrorHasInvoices =>
      'Impossible de supprimer : ce client a des factures.';

  @override
  String get deleteClientErrorHasPayments =>
      'Impossible de supprimer : ce client a des paiements.';

  @override
  String get deleteClientConfirm =>
      'Supprimer ce client ? Ses devis seront également supprimés.';

  @override
  String get clientDeleted => 'Client supprimé avec succès.';

  @override
  String get deleteInvoiceConfirm =>
      'Supprimer cette facture ? Cette action est irréversible.';

  @override
  String get deleteInvoiceErrorHasPayments =>
      'Impossible de supprimer : cette facture a déjà des paiements enregistrés.';

  @override
  String get invoiceDeleted => 'Facture supprimée avec succès.';

  @override
  String get deleteQuoteConfirm => 'Supprimer ce devis ?';

  @override
  String get quoteDeleted => 'Devis supprimé avec succès.';

  @override
  String get createRefund => 'Créer un avoir';

  @override
  String get refund => 'Avoir';

  @override
  String get refunds => 'Avoirs';

  @override
  String get refundDetails => 'Détails de l\'avoir';

  @override
  String get refundNumber => 'Avoir n°';

  @override
  String get refundDate => 'Date de l\'avoir';

  @override
  String get refundReason => 'Raison de l\'avoir';

  @override
  String get refundAmount => 'Montant remboursé';

  @override
  String get netAmount => 'Montant net';

  @override
  String get refundedQuantity => 'Qté remboursée';

  @override
  String get availableToRefund => 'Disponible à rembourser';

  @override
  String get refundSuccess => 'Avoir créé avec succès';

  @override
  String get refundErrorExceedsQuantity =>
      'La quantité dépasse la quantité facturée restante.';

  @override
  String get refundErrorCancelledInvoice =>
      'Impossible de créer un avoir sur une facture annulée.';

  @override
  String get profitability => 'Rentabilité';

  @override
  String get projectProfitability => 'Rentabilité du projet';

  @override
  String get noRefundsYet => 'Aucun avoir trouvé';

  @override
  String get validated => 'Validé';

  @override
  String get includePayments => 'Inclure les paiements';

  @override
  String get paymentHistoryAndBalance => 'Historique des paiements et solde';

  @override
  String get confirm => 'Confirmer';

  @override
  String get cash => 'Cash';

  @override
  String get transfer => 'Versement';

  @override
  String get errorPaymentExceedsBalance =>
      'Le montant du paiement ne peut pas dépasser le solde restant';

  @override
  String get before => 'Avant';

  @override
  String get during => 'En cours';

  @override
  String get after => 'Après';

  @override
  String get addPhoto => 'Ajouter une photo';

  @override
  String get camera => 'Appareil photo';

  @override
  String get gallery => 'Galerie';

  @override
  String get projectPhotos => 'Photos du projet';

  @override
  String get photoCategory => 'Catégorie';

  @override
  String get comment => 'Commentaire';
}
