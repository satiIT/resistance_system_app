import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

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
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Sabiqat Platform'**
  String get appTitle;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Sabiqat Platform Dashboard'**
  String get dashboardTitle;

  /// No description provided for @personnel.
  ///
  /// In en, this message translates to:
  /// **'Personnel'**
  String get personnel;

  /// No description provided for @training.
  ///
  /// In en, this message translates to:
  /// **'Training'**
  String get training;

  /// No description provided for @movements.
  ///
  /// In en, this message translates to:
  /// **'Movements'**
  String get movements;

  /// No description provided for @casualties.
  ///
  /// In en, this message translates to:
  /// **'Casualties & Martyrs'**
  String get casualties;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @pharmacy.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy'**
  String get pharmacy;

  /// No description provided for @finance.
  ///
  /// In en, this message translates to:
  /// **'Finance'**
  String get finance;

  /// No description provided for @reports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports;

  /// No description provided for @intelligence.
  ///
  /// In en, this message translates to:
  /// **'Intelligence'**
  String get intelligence;

  /// No description provided for @welcomeAdmin.
  ///
  /// In en, this message translates to:
  /// **'Welcome, Administrator'**
  String get welcomeAdmin;

  /// No description provided for @trainingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage training programs and monitor individual progress.'**
  String get trainingSubtitle;

  /// No description provided for @movementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track strategic movements and regional assignments.'**
  String get movementsSubtitle;

  /// No description provided for @casualtiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Document martyrs and wounded records and support cases.'**
  String get casualtiesSubtitle;

  /// No description provided for @inventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor supply levels and manage logistics storage.'**
  String get inventorySubtitle;

  /// No description provided for @pharmacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Control medical supplies and tracking movement (Form 7).'**
  String get pharmacySubtitle;

  /// No description provided for @financeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage budget, expenses, and financial tracking (Form 9).'**
  String get financeSubtitle;

  /// No description provided for @reportsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Generate comprehensive data analytics and summary reports.'**
  String get reportsSubtitle;

  /// No description provided for @intelligenceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Secure monitoring and situational awareness reports.'**
  String get intelligenceSubtitle;

  /// No description provided for @systemSummary.
  ///
  /// In en, this message translates to:
  /// **'Here is a general summary of the system status and available resources today.'**
  String get systemSummary;

  /// No description provided for @quickManagementTools.
  ///
  /// In en, this message translates to:
  /// **'Quick Management Tools'**
  String get quickManagementTools;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @totalPersonnel.
  ///
  /// In en, this message translates to:
  /// **'Total Personnel'**
  String get totalPersonnel;

  /// No description provided for @currentTasks.
  ///
  /// In en, this message translates to:
  /// **'Current Tasks'**
  String get currentTasks;

  /// No description provided for @pharmacyRequests.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Requests'**
  String get pharmacyRequests;

  /// No description provided for @emergencyCases.
  ///
  /// In en, this message translates to:
  /// **'Emergency Cases'**
  String get emergencyCases;

  /// No description provided for @personnelManagement.
  ///
  /// In en, this message translates to:
  /// **'Personnel Management'**
  String get personnelManagement;

  /// No description provided for @personnelSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View and manage the database of volunteers and recruits in the system.'**
  String get personnelSubtitle;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name, military ID, or national ID...'**
  String get searchHint;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @martyr.
  ///
  /// In en, this message translates to:
  /// **'Martyr'**
  String get martyr;

  /// No description provided for @wounded.
  ///
  /// In en, this message translates to:
  /// **'Wounded'**
  String get wounded;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @locality.
  ///
  /// In en, this message translates to:
  /// **'Locality'**
  String get locality;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @allStates.
  ///
  /// In en, this message translates to:
  /// **'All States'**
  String get allStates;

  /// No description provided for @allLocalities.
  ///
  /// In en, this message translates to:
  /// **'All Localities'**
  String get allLocalities;

  /// No description provided for @allStatus.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allStatus;

  /// No description provided for @militaryId.
  ///
  /// In en, this message translates to:
  /// **'Military ID'**
  String get militaryId;

  /// No description provided for @nationalId.
  ///
  /// In en, this message translates to:
  /// **'National ID'**
  String get nationalId;

  /// No description provided for @rank.
  ///
  /// In en, this message translates to:
  /// **'Rank'**
  String get rank;

  /// No description provided for @unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'An error occurred'**
  String get errorOccurred;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @quickStats.
  ///
  /// In en, this message translates to:
  /// **'Quick Statistics'**
  String get quickStats;

  /// No description provided for @totalDisplay.
  ///
  /// In en, this message translates to:
  /// **'Currently Displayed'**
  String get totalDisplay;

  /// No description provided for @pharmacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pharmacy Movement Form (7)'**
  String get pharmacyTitle;

  /// No description provided for @financeTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Management Form (9)'**
  String get financeTitle;

  /// No description provided for @searchMedicine.
  ///
  /// In en, this message translates to:
  /// **'Search in medicines...'**
  String get searchMedicine;

  /// No description provided for @searchFinance.
  ///
  /// In en, this message translates to:
  /// **'Search in financial records...'**
  String get searchFinance;

  /// No description provided for @incoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incoming;

  /// No description provided for @outgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoing;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @medicineType.
  ///
  /// In en, this message translates to:
  /// **'Medicine Type'**
  String get medicineType;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @basicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get basicInfo;

  /// No description provided for @medicineDetails.
  ///
  /// In en, this message translates to:
  /// **'Medicine Details'**
  String get medicineDetails;

  /// No description provided for @packaging.
  ///
  /// In en, this message translates to:
  /// **'Packaging'**
  String get packaging;

  /// No description provided for @dosageForm.
  ///
  /// In en, this message translates to:
  /// **'Dosage Form'**
  String get dosageForm;

  /// No description provided for @strength.
  ///
  /// In en, this message translates to:
  /// **'Strength / Concentration'**
  String get strength;

  /// No description provided for @quantityAndPackaging.
  ///
  /// In en, this message translates to:
  /// **'Quantity and Packaging'**
  String get quantityAndPackaging;

  /// No description provided for @additionalInfo.
  ///
  /// In en, this message translates to:
  /// **'Additional Information'**
  String get additionalInfo;

  /// No description provided for @movementDate.
  ///
  /// In en, this message translates to:
  /// **'Movement Date'**
  String get movementDate;

  /// No description provided for @movementType.
  ///
  /// In en, this message translates to:
  /// **'Movement Type'**
  String get movementType;

  /// No description provided for @source.
  ///
  /// In en, this message translates to:
  /// **'Source'**
  String get source;

  /// No description provided for @recipient.
  ///
  /// In en, this message translates to:
  /// **'Recipient'**
  String get recipient;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Medicine Name'**
  String get itemName;

  /// No description provided for @sourceOrRecipient.
  ///
  /// In en, this message translates to:
  /// **'Source/Recipient'**
  String get sourceOrRecipient;

  /// No description provided for @saveRecord.
  ///
  /// In en, this message translates to:
  /// **'Save Record'**
  String get saveRecord;

  /// No description provided for @updateRecord.
  ///
  /// In en, this message translates to:
  /// **'Update Record'**
  String get updateRecord;

  /// No description provided for @editMedicineRecord.
  ///
  /// In en, this message translates to:
  /// **'Edit Medicine Record'**
  String get editMedicineRecord;

  /// No description provided for @addMedicineRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Medicine Record'**
  String get addMedicineRecord;

  /// No description provided for @itemCode.
  ///
  /// In en, this message translates to:
  /// **'Item Code'**
  String get itemCode;

  /// No description provided for @medicineCategory.
  ///
  /// In en, this message translates to:
  /// **'Medicine Category'**
  String get medicineCategory;

  /// No description provided for @unitOfMeasure.
  ///
  /// In en, this message translates to:
  /// **'Unit of Measure'**
  String get unitOfMeasure;

  /// No description provided for @store.
  ///
  /// In en, this message translates to:
  /// **'Store'**
  String get store;

  /// No description provided for @expiryStatus.
  ///
  /// In en, this message translates to:
  /// **'Expiry Status'**
  String get expiryStatus;

  /// No description provided for @daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get daysRemaining;

  /// No description provided for @expiredWarning.
  ///
  /// In en, this message translates to:
  /// **'This medicine is expired'**
  String get expiredWarning;

  /// No description provided for @validWarning.
  ///
  /// In en, this message translates to:
  /// **'This medicine is valid'**
  String get validWarning;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareTextHeader.
  ///
  /// In en, this message translates to:
  /// **'Medicine Information'**
  String get shareTextHeader;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Information copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @expired.
  ///
  /// In en, this message translates to:
  /// **'Expired'**
  String get expired;

  /// No description provided for @expiryDate.
  ///
  /// In en, this message translates to:
  /// **'Expiry Date'**
  String get expiryDate;

  /// No description provided for @nearExpiry.
  ///
  /// In en, this message translates to:
  /// **'Near Expiry'**
  String get nearExpiry;

  /// No description provided for @stats.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get stats;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @currency.
  ///
  /// In en, this message translates to:
  /// **'SDG'**
  String get currency;

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net Balance'**
  String get netBalance;

  /// No description provided for @budgetStatus.
  ///
  /// In en, this message translates to:
  /// **'Budget Status'**
  String get budgetStatus;

  /// No description provided for @addIncoming.
  ///
  /// In en, this message translates to:
  /// **'Add Incoming'**
  String get addIncoming;

  /// No description provided for @addOutgoing.
  ///
  /// In en, this message translates to:
  /// **'Add Outgoing'**
  String get addOutgoing;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get confirmDelete;

  /// No description provided for @deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this record?'**
  String get deleteMessage;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading data...'**
  String get loading;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get requiredField;

  /// No description provided for @enterMedicineName.
  ///
  /// In en, this message translates to:
  /// **'Please enter medicine name'**
  String get enterMedicineName;

  /// No description provided for @supplierName.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get supplierName;

  /// No description provided for @recipientName.
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get recipientName;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get invalidNumber;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @birthDate.
  ///
  /// In en, this message translates to:
  /// **'Birth Date'**
  String get birthDate;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @maritalStatus.
  ///
  /// In en, this message translates to:
  /// **'Marital Status'**
  String get maritalStatus;

  /// No description provided for @educationLevel.
  ///
  /// In en, this message translates to:
  /// **'Education Level'**
  String get educationLevel;

  /// No description provided for @occupation.
  ///
  /// In en, this message translates to:
  /// **'Occupation'**
  String get occupation;

  /// No description provided for @skills.
  ///
  /// In en, this message translates to:
  /// **'Skills'**
  String get skills;

  /// No description provided for @geographicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Geographical Information'**
  String get geographicalInfo;

  /// No description provided for @administrativeUnit.
  ///
  /// In en, this message translates to:
  /// **'Administrative Unit'**
  String get administrativeUnit;

  /// No description provided for @cityVillage.
  ///
  /// In en, this message translates to:
  /// **'City/Village'**
  String get cityVillage;

  /// No description provided for @currentResidence.
  ///
  /// In en, this message translates to:
  /// **'Current Residence'**
  String get currentResidence;

  /// No description provided for @prewarResidence.
  ///
  /// In en, this message translates to:
  /// **'Pre-war Residence'**
  String get prewarResidence;

  /// No description provided for @placeOfOrigin.
  ///
  /// In en, this message translates to:
  /// **'Place of Origin'**
  String get placeOfOrigin;

  /// No description provided for @militaryInfo.
  ///
  /// In en, this message translates to:
  /// **'Military Information'**
  String get militaryInfo;

  /// No description provided for @enlistmentDate.
  ///
  /// In en, this message translates to:
  /// **'Enlistment Date'**
  String get enlistmentDate;

  /// No description provided for @militaryBackground.
  ///
  /// In en, this message translates to:
  /// **'Military Background'**
  String get militaryBackground;

  /// No description provided for @basicTraining.
  ///
  /// In en, this message translates to:
  /// **'Basic Training'**
  String get basicTraining;

  /// No description provided for @weaponType.
  ///
  /// In en, this message translates to:
  /// **'Weapon Type'**
  String get weaponType;

  /// No description provided for @lastTrainingDate.
  ///
  /// In en, this message translates to:
  /// **'Last Training Date'**
  String get lastTrainingDate;

  /// No description provided for @familyInfo.
  ///
  /// In en, this message translates to:
  /// **'Family Information'**
  String get familyInfo;

  /// No description provided for @wivesCount.
  ///
  /// In en, this message translates to:
  /// **'Wives Count'**
  String get wivesCount;

  /// No description provided for @childrenCount.
  ///
  /// In en, this message translates to:
  /// **'Children Count'**
  String get childrenCount;

  /// No description provided for @dependentsCount.
  ///
  /// In en, this message translates to:
  /// **'Dependents Count'**
  String get dependentsCount;

  /// No description provided for @motherName.
  ///
  /// In en, this message translates to:
  /// **'Mother Full Name'**
  String get motherName;

  /// No description provided for @motherPhone.
  ///
  /// In en, this message translates to:
  /// **'Mother Phone'**
  String get motherPhone;

  /// No description provided for @nextOfKin.
  ///
  /// In en, this message translates to:
  /// **'Next of Kin'**
  String get nextOfKin;

  /// No description provided for @nextOfKinPhone.
  ///
  /// In en, this message translates to:
  /// **'Next of Kin Phone'**
  String get nextOfKinPhone;

  /// No description provided for @medicalInfo.
  ///
  /// In en, this message translates to:
  /// **'Medical Information'**
  String get medicalInfo;

  /// No description provided for @healthStatus.
  ///
  /// In en, this message translates to:
  /// **'Health Status'**
  String get healthStatus;

  /// No description provided for @chronicConditions.
  ///
  /// In en, this message translates to:
  /// **'Chronic Conditions'**
  String get chronicConditions;

  /// No description provided for @allergies.
  ///
  /// In en, this message translates to:
  /// **'Allergies'**
  String get allergies;

  /// No description provided for @medicalNotes.
  ///
  /// In en, this message translates to:
  /// **'Medical Notes'**
  String get medicalNotes;

  /// No description provided for @bloodType.
  ///
  /// In en, this message translates to:
  /// **'Blood Type'**
  String get bloodType;

  /// No description provided for @emergencyContactPhone.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact Phone'**
  String get emergencyContactPhone;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @updateData.
  ///
  /// In en, this message translates to:
  /// **'Update Data'**
  String get updateData;

  /// No description provided for @trainingHistory.
  ///
  /// In en, this message translates to:
  /// **'Training History'**
  String get trainingHistory;

  /// No description provided for @entitlements.
  ///
  /// In en, this message translates to:
  /// **'Entitlements'**
  String get entitlements;

  /// No description provided for @equipment.
  ///
  /// In en, this message translates to:
  /// **'Equipment'**
  String get equipment;

  /// No description provided for @quickInfo.
  ///
  /// In en, this message translates to:
  /// **'Quick Information'**
  String get quickInfo;

  /// No description provided for @lastUpdate.
  ///
  /// In en, this message translates to:
  /// **'Last Update'**
  String get lastUpdate;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @inDevelopment.
  ///
  /// In en, this message translates to:
  /// **'In development'**
  String get inDevelopment;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @addPersonnelRecord.
  ///
  /// In en, this message translates to:
  /// **'Add Personnel Record'**
  String get addPersonnelRecord;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @secondName.
  ///
  /// In en, this message translates to:
  /// **'Second Name'**
  String get secondName;

  /// No description provided for @thirdName.
  ///
  /// In en, this message translates to:
  /// **'Third Name'**
  String get thirdName;

  /// No description provided for @fourthName.
  ///
  /// In en, this message translates to:
  /// **'Fourth Name'**
  String get fourthName;

  /// No description provided for @contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// No description provided for @educationAndSkills.
  ///
  /// In en, this message translates to:
  /// **'Education & Skills'**
  String get educationAndSkills;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @savePersonnel.
  ///
  /// In en, this message translates to:
  /// **'Save Personnel'**
  String get savePersonnel;

  /// No description provided for @updatePersonnel.
  ///
  /// In en, this message translates to:
  /// **'Update Personnel'**
  String get updatePersonnel;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @single.
  ///
  /// In en, this message translates to:
  /// **'Single'**
  String get single;

  /// No description provided for @married.
  ///
  /// In en, this message translates to:
  /// **'Married'**
  String get married;

  /// No description provided for @divorced.
  ///
  /// In en, this message translates to:
  /// **'Divorced'**
  String get divorced;

  /// No description provided for @widowed.
  ///
  /// In en, this message translates to:
  /// **'Widowed'**
  String get widowed;

  /// No description provided for @retired.
  ///
  /// In en, this message translates to:
  /// **'Retired'**
  String get retired;
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
      <String>['ar', 'en'].contains(locale.languageCode);

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
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
