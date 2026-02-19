// screens/medicine/medicine_form_screen.dart
import 'package:flutter/material.dart';
//import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import '../../../core/models/medicine_item.dart';
import '../../../core/services/medicine_api.dart';

class MedicineFormScreen extends StatefulWidget {
  final MedicineItem? existingItem;

  const MedicineFormScreen({Key? key, this.existingItem}) : super(key: key);

  @override
  _MedicineFormScreenState createState() => _MedicineFormScreenState();
}

class _MedicineFormScreenState extends State<MedicineFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late MedicineItem _item;
  bool _isLoading = false;
  bool _isEditMode = false;
  List<MedicineItem> _knownItems = [];
  bool _isLoadingItems = true;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.existingItem != null;
    _loadKnownItems();

    if (_isEditMode) {
      _item = widget.existingItem!;
    } else {
      _item = MedicineItem(
        movementDate: DateTime.now(),
        movementType: 'وارد', // Default to Arabic for initial state
        quantity: 0,
      );
    }
  }

  Future<void> _loadKnownItems() async {
    try {
      final items = await MedicineApi.getMedicineItems();
      // Extract unique items based on ID and Name
      final uniqueItems = <int, MedicineItem>{};
      for (var item in items) {
        if (item.itemId != null && item.itemName != null) {
          if (!uniqueItems.containsKey(item.itemId)) {
            uniqueItems[item.itemId!] = item;
          }
        }
      }
      setState(() {
        _knownItems = uniqueItems.values.toList();
        _isLoadingItems = false;
      });
    } catch (e) {
      print('Error loading items: $e');
      setState(() => _isLoadingItems = false);
    }
  }

  Future<void> _saveItem() async {
    final l10n = AppLocalizations.of(context)!;
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
      });

      try {
        if (_isEditMode) {
          await MedicineApi.updateMedicineItem(_item);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.success),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          await MedicineApi.createMedicineItem(_item);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.success),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
        if (mounted) Navigator.pop(context, true);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.error}: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Widget _buildBasicInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  l10n.basicInfo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.slate900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.movementDate,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _formatDate(_item.movementDate),
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate: _item.movementDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selectedDate != null) {
                  setState(() {
                    _item = _item.copyWith(movementDate: selectedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.movementType,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              value:
                  _item.movementType == 'وارد' || _item.movementType == 'منصرف'
                  ? _item.movementType
                  : 'وارد',
              items: [
                DropdownMenuItem(value: 'وارد', child: Text(l10n.incoming)),
                DropdownMenuItem(value: 'منصرف', child: Text(l10n.outgoing)),
              ],
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(movementType: value!);
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.requiredField;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicineDetailsSection() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication_liquid, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  l10n.medicineDetails,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.slate900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Autocomplete<MedicineItem>(
                  initialValue: TextEditingValue(text: _item.itemName ?? ''),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue.text.isEmpty) {
                      return _knownItems; // Show all if empty? Or empty. Let's show all or filtered.
                    }
                    return _knownItems.where((MedicineItem option) {
                      return option.itemName != null &&
                          option.itemName!.toLowerCase().contains(
                            textEditingValue.text.toLowerCase(),
                          );
                    });
                  },
                  displayStringForOption: (MedicineItem option) =>
                      option.itemName ?? '',
                  onSelected: (MedicineItem selection) {
                    setState(() {
                      _item = _item.copyWith(
                        itemId: selection.itemId,
                        itemName: selection.itemName,
                        // Auto-fill other fields if available and unset
                        medicineType:
                            _item.medicineType ?? selection.medicineType,
                        unit: _item.unit ?? selection.unit,
                        packaging: _item.packaging ?? selection.packaging,
                        dosageForm: _item.dosageForm ?? selection.dosageForm,
                        strength: _item.strength ?? selection.strength,
                      );
                    });
                  },
                  fieldViewBuilder:
                      (
                        BuildContext context,
                        TextEditingController textEditingController,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted,
                      ) {
                        // Ensure controller has initial value if needed (Autocomplete does this via initialValue, but careful with updates)
                        return TextFormField(
                          controller: textEditingController,
                          focusNode: focusNode,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.slate900,
                          ),
                          decoration: InputDecoration(
                            labelText: l10n.itemName,
                            hintText: l10n.enterMedicineName,
                            border: const OutlineInputBorder(),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkBackground
                                : AppColors.slate50,
                            suffixIcon: _isLoadingItems
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? l10n.requiredField
                              : null,
                          onSaved: (value) {
                            // Try to match typed value to an ID if not selected via click
                            if (value != null && _item.itemId == null) {
                              try {
                                final match = _knownItems.firstWhere(
                                  (element) =>
                                      element.itemName?.toLowerCase() ==
                                      value.toLowerCase(),
                                );
                                _item = _item.copyWith(
                                  itemName: value,
                                  itemId: match.itemId,
                                );
                              } catch (e) {
                                _item = _item.copyWith(itemName: value);
                              }
                            } else {
                              _item = _item.copyWith(itemName: value);
                            }
                          },
                          onChanged: (value) {
                            if (_item.itemId != null) {
                              // If we had an ID, clear it because the user changed the name
                              // We let onSaved try to resolve it again
                              setState(() {
                                _item = _item.copyWith(itemId: null);
                              });
                            }
                          },
                        );
                      },
                  optionsViewBuilder: (context, onSelected, options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        child: Container(
                          width: constraints.maxWidth,
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final MedicineItem option = options.elementAt(
                                index,
                              );
                              return InkWell(
                                onTap: () => onSelected(option),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    option.itemName ?? '',
                                    style: TextStyle(
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.slate900,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.medicineType,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              value: _getMedicineTypes(l10n).contains(_item.medicineType)
                  ? _item.medicineType
                  : null,
              items: _getMedicineTypes(l10n).map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) =>
                  setState(() => _item = _item.copyWith(medicineType: value)),
            ),
            const SizedBox(height: 12),
            TextFormField(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: _item.movementType == 'وارد'
                    ? l10n.source
                    : l10n.recipient,
                hintText: _item.movementType == 'وارد'
                    ? l10n.supplierName
                    : l10n.recipientName,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              initialValue: _item.sourceOrRecipient,
              validator: (value) =>
                  (value == null || value.isEmpty) ? l10n.requiredField : null,
              onSaved: (value) =>
                  _item = _item.copyWith(sourceOrRecipient: value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySection() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.inventory_2, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  l10n.quantityAndPackaging,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.slate900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.quantity,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.slate50,
                    ),
                    keyboardType: TextInputType.number,
                    initialValue: _item.quantity.toString(),
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return l10n.requiredField;
                      if (double.tryParse(value) == null)
                        return l10n.invalidNumber;
                      return null;
                    },
                    onSaved: (value) =>
                        _item = _item.copyWith(quantity: double.parse(value!)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: DropdownButtonFormField<String>(
                    dropdownColor: isDark
                        ? AppColors.darkSurface
                        : Colors.white,
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.slate900,
                    ),
                    decoration: InputDecoration(
                      labelText: l10n.unit,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkBackground
                          : AppColors.slate50,
                    ),
                    value: _item.unit,
                    items: _getUnits(l10n).map((unit) {
                      return DropdownMenuItem(value: unit, child: Text(unit));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _item = _item.copyWith(unit: value);
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.packaging,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              value: _item.packaging,
              items: _getPackagingTypes(l10n).map((packaging) {
                return DropdownMenuItem(
                  value: packaging,
                  child: Text(packaging),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(packaging: value);
                });
              },
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.dosageForm,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              value: _item.dosageForm,
              items: _getDosageForms(l10n).map((form) {
                return DropdownMenuItem(value: form, child: Text(form));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _item = _item.copyWith(dosageForm: value);
                });
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.strength,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              initialValue: _item.strength,
              onSaved: (value) => _item = _item.copyWith(strength: value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.more_horiz, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  l10n.additionalInfo,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.slate900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.expiryDate,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
              ),
              readOnly: true,
              controller: TextEditingController(
                text: _formatDate(_item.expiryDate),
              ),
              onTap: () async {
                final selectedDate = await showDatePicker(
                  context: context,
                  initialDate:
                      _item.expiryDate ??
                      DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (selectedDate != null) {
                  setState(() {
                    _item = _item.copyWith(expiryDate: selectedDate);
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              style: TextStyle(
                color: isDark ? Colors.white : AppColors.slate900,
              ),
              decoration: InputDecoration(
                labelText: l10n.notes,
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: isDark
                    ? AppColors.darkBackground
                    : AppColors.slate50,
                alignLabelWithHint: true,
              ),
              initialValue: _item.notes,
              maxLines: 3,
              onSaved: (value) => _item = _item.copyWith(notes: value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              icon: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(_isEditMode ? l10n.updateRecord : l10n.saveRecord),
              onPressed: _isLoading ? null : _saveItem,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(l10n.cancel),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  List<String> _getMedicineTypes(AppLocalizations l10n) {
    return l10n.localeName == 'ar'
        ? [
            'علاج ملاريا',
            'مضاد حيوي',
            'علاج سكري',
            'مسكنات',
            'فيتامينات',
            'مضادات الالتهاب',
            'أدوية قلب',
            'أدوية ضغط',
            'مضادات حساسية',
            'أدوية هضمية',
            'مطهرات',
            'مضادات فطريات',
          ]
        : [
            'Malaria Treatment',
            'Antibiotic',
            'Diabetes Medicine',
            'Painkillers',
            'Vitamins',
            'Anti-inflammatory',
            'Heart Medicine',
            'Blood Pressure',
            'Allergy Medicine',
            'Digestive',
            'Antiseptics',
            'Antifungals',
          ];
  }

  List<String> _getPackagingTypes(AppLocalizations l10n) {
    return l10n.localeName == 'ar'
        ? [
            'كرتونة 150 جرعة',
            'فتيل',
            'حقن',
            'حبوب',
            'شراب',
            'لفة',
            'شريط',
            'كبسولة',
            'مرهم',
            'قطرة',
            'بخاخ',
          ]
        : [
            'Carton 150 doses',
            'Suppository',
            'Injection',
            'Pills',
            'Syrup',
            'Roll',
            'Strip',
            'Capsule',
            'Ointment',
            'Drop',
            'Spray',
          ];
  }

  List<String> _getDosageForms(AppLocalizations l10n) {
    return l10n.localeName == 'ar'
        ? [
            'أقراص',
            'كبسولات',
            'شراب',
            'حقن',
            'مرهم',
            'كريم',
            'قطرة',
            'بخاخ',
            'لبوس',
            'مسحوق',
            'محلول',
          ]
        : [
            'Tablets',
            'Capsules',
            'Syrup',
            'Injections',
            'Ointment',
            'Cream',
            'Drops',
            'Spray',
            'Suppositories',
            'Powder',
            'Solution',
          ];
  }

  List<String> _getUnits(AppLocalizations l10n) {
    return l10n.localeName == 'ar'
        ? ['علبة', 'عبوة', 'قطعة', 'مل', 'مج', 'لتر', 'جم']
        : ['Box', 'Pack', 'Piece', 'ml', 'mg', 'Liter', 'g'];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          _isEditMode ? l10n.editMedicineRecord : l10n.addMedicineRecord,
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildBasicInfoSection(),
              const SizedBox(height: 16),
              _buildMedicineDetailsSection(),
              const SizedBox(height: 16),
              _buildQuantitySection(),
              const SizedBox(height: 16),
              _buildAdditionalInfoSection(),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
