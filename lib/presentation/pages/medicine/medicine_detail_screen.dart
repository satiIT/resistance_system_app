// lib/presentation/pages/medicine/medicine_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/l10n/app_localizations.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import '../../../core/models/medicine_item.dart';

class MedicineDetailScreen extends StatelessWidget {
  final MedicineItem item;

  const MedicineDetailScreen({Key? key, required this.item}) : super(key: key);

  Widget _buildDetailItem(
    BuildContext context,
    String label,
    String? value, {
    bool isImportant = false,
    Color? valueColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isImportant
                  ? AppColors.error
                  : (isDark ? AppColors.slate300 : AppColors.slate700),
            ),
          ),
          Expanded(
            child: Text(
              value ?? AppLocalizations.of(context)!.noDataFound,
              style: TextStyle(
                color:
                    valueColor ?? (isDark ? Colors.white : AppColors.slate900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) return AppLocalizations.of(context)!.noDataFound;
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      appBar: AppBar(title: Text(l10n.viewDetails), elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة المعلومات الأساسية
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: item.typeColor,
                          child: Icon(item.typeIcon, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemName ?? l10n.noDataFound,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : AppColors.slate900,
                                ),
                              ),
                              Text(
                                item.movementType == 'وارد'
                                    ? l10n.incoming
                                    : (item.movementType == 'منصرف'
                                          ? l10n.outgoing
                                          : item.movementType),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: item.typeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildStatusIndicator(
                          item.movementType == 'وارد'
                              ? l10n.incoming
                              : (item.movementType == 'منصرف'
                                    ? l10n.outgoing
                                    : item.movementType),
                          item.typeColor,
                        ),
                        if (item.isExpired)
                          _buildStatusIndicator(l10n.expired, Colors.red),
                        if (!item.isExpired && item.expiryDate != null)
                          _buildStatusIndicator(
                            item.expiryStatus,
                            item.expiryColor,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // معلومات الدواء
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.medicineDetails,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(context, l10n.itemName, item.itemName),
                    _buildDetailItem(
                      context,
                      l10n.medicineType,
                      item.medicineType,
                    ),
                    _buildDetailItem(context, l10n.dosageForm, item.dosageForm),
                    _buildDetailItem(context, l10n.strength, item.strength),
                    _buildDetailItem(
                      context,
                      l10n.movementType,
                      item.movementType == 'وارد'
                          ? l10n.incoming
                          : (item.movementType == 'منصرف'
                                ? l10n.outgoing
                                : item.movementType),
                    ),
                    _buildDetailItem(
                      context,
                      l10n.quantity,
                      '${item.quantity} ${item.unit ?? ""}',
                    ),
                    _buildDetailItem(
                      context,
                      l10n.date,
                      _formatDate(context, item.movementDate),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // معلومات التعبئة والجهة
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.quantityAndPackaging,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailItem(context, l10n.packaging, item.packaging),
                    _buildDetailItem(context, l10n.unit, item.unit),
                    if (item.movementType == 'وارد')
                      _buildDetailItem(
                        context,
                        l10n.source,
                        item.sourceOrRecipient,
                      ),
                    if (item.movementType == 'منصرف')
                      _buildDetailItem(
                        context,
                        l10n.recipient,
                        item.sourceOrRecipient,
                      ),
                    if (item.storeName != null)
                      _buildDetailItem(context, l10n.store, item.storeName),
                  ],
                ),
              ),
            ),

            // معلومات الصلاحية
            if (item.expiryDate != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.expiryDate,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetailItem(
                        context,
                        l10n.expiryDate,
                        _formatDate(context, item.expiryDate),
                        valueColor: item.expiryColor,
                      ),
                      _buildDetailItem(
                        context,
                        l10n.expiryStatus,
                        item.expiryStatus,
                        valueColor: item.expiryColor,
                      ),
                      _buildDetailItem(
                        context,
                        l10n.daysRemaining,
                        item.expiryDate != null
                            ? '${item.expiryDate!.difference(DateTime.now()).inDays} ${l10n.daysRemaining}'
                            : l10n.noDataFound,
                        valueColor: item.expiryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // معلومات إضافية
            if (item.notes != null ||
                item.medicineCategory != null ||
                item.itemCode != null) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: isDark ? AppColors.darkSurface : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.additionalInfo,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (item.itemCode != null)
                        _buildDetailItem(context, l10n.itemCode, item.itemCode),
                      if (item.medicineCategory != null)
                        _buildDetailItem(
                          context,
                          l10n.medicineCategory,
                          item.medicineCategory,
                        ),
                      if (item.unitOfMeasure != null)
                        _buildDetailItem(
                          context,
                          l10n.unitOfMeasure,
                          item.unitOfMeasure,
                        ),
                      if (item.notes != null)
                        _buildDetailItem(context, l10n.notes, item.notes),
                    ],
                  ),
                ),
              ),
            ],

            // حالة الدواء
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: isDark ? AppColors.darkSurface : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.status,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          item.isExpired ? Icons.error : Icons.check_circle,
                          color: item.isExpired ? Colors.red : Colors.green,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.isExpired
                                ? l10n.expiredWarning
                                : l10n.validWarning,
                            style: TextStyle(
                              fontSize: 16,
                              color: item.isExpired ? Colors.red : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.expiryDate != null && !item.isExpired) ...[
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: _calculateExpiryProgress(item.expiryDate!),
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _calculateExpiryProgress(item.expiryDate!) > 0.7
                              ? Colors.green
                              : _calculateExpiryProgress(item.expiryDate!) > 0.3
                              ? Colors.orange
                              : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          '${l10n.daysRemaining}: ${item.expiryDate!.difference(DateTime.now()).inDays}',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.slate400
                                : AppColors.slate600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // أزرار الإجراءات
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.edit),
                    onPressed: () {
                      // Handled by parent or Navigator
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.share),
                    label: Text(l10n.share),
                    onPressed: () => _shareMedicineInfo(context, item),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  double _calculateExpiryProgress(DateTime expiryDate) {
    final now = DateTime.now();
    final totalDays = expiryDate
        .difference(
          DateTime(expiryDate.year - 1, expiryDate.month, expiryDate.day),
        )
        .inDays
        .toDouble();
    final remainingDays = expiryDate.difference(now).inDays.toDouble();

    if (remainingDays <= 0) return 0.0;
    if (remainingDays >= totalDays) return 1.0;

    return remainingDays / totalDays;
  }

  void _shareMedicineInfo(BuildContext context, MedicineItem item) {
    final l10n = AppLocalizations.of(context)!;
    final String shareText =
        '''
${l10n.shareTextHeader}:
• ${l10n.itemName}: ${item.itemName ?? l10n.noDataFound}
• ${l10n.medicineType}: ${item.medicineType ?? l10n.noDataFound}
• ${l10n.quantity}: ${item.quantity} ${item.unit ?? ''}
• ${l10n.movementType}: ${item.movementType}
• ${l10n.expiryDate}: ${_formatDate(context, item.expiryDate)}
• ${l10n.expiryStatus}: ${item.expiryStatus}
${item.notes != null ? '• ${l10n.notes}: ${item.notes}' : ''}
    ''';

    debugPrint('Sharing medicine info: $shareText');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.copiedToClipboard),
        backgroundColor: Colors.green,
      ),
    );
  }
}
