// screens/medicine/medicine_detail_screen.dart - الجزء المكمل
import 'package:flutter/material.dart';
import '../../../core/models/medicine_item.dart';

class MedicineDetailScreen extends StatelessWidget {
  final MedicineItem item;

  MedicineDetailScreen({required this.item});

  Widget _buildDetailItem(String label, String? value, {bool isImportant = false, Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isImportant ? Colors.red : Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'غير محدد',
              style: TextStyle(
                color: valueColor ?? (isImportant ? Colors.red : Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String status, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل سجل الدواء'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة المعلومات الأساسية
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: item.typeColor,
                          child: Icon(item.typeIcon, color: Colors.white),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.itemName ?? 'غير محدد',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                item.movementType,
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
                    SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStatusIndicator(item.movementType, item.typeColor),
                        SizedBox(width: 8),
                        if (item.isExpired)
                          _buildStatusIndicator('منتهي الصلاحية', Colors.red),
                        if (!item.isExpired && item.expiryDate != null)
                          _buildStatusIndicator(item.expiryStatus, item.expiryColor),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // معلومات الدواء
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الدواء',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailItem('اسم الدواء', item.itemName),
                    _buildDetailItem('نوع الدواء', item.medicineType),
                    _buildDetailItem('شكل الجرعة', item.dosageForm),
                    _buildDetailItem('التركيز', item.strength),
                    _buildDetailItem('نوع الحركة', item.movementType),
                    _buildDetailItem('الكمية', '${item.quantity} ${item.unit ?? ""}'),
                    _buildDetailItem('التاريخ', _formatDate(item.movementDate)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // معلومات التعبئة والجهة
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات التعبئة والجهة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailItem('نوع العبوة', item.packaging),
                    _buildDetailItem('الوحدة', item.unit),
                    if (item.movementType == 'وارد') 
                      _buildDetailItem('المصدر', item.sourceOrRecipient),
                    if (item.movementType == 'منصرف') 
                      _buildDetailItem('المستلم', item.sourceOrRecipient),
                    if (item.storeName != null)
                      _buildDetailItem('المخزن', item.storeName),
                  ],
                ),
              ),
            ),

            // معلومات الصلاحية
            if (item.expiryDate != null) ...[
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات الصلاحية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDetailItem(
                        'تاريخ انتهاء الصلاحية', 
                        _formatDate(item.expiryDate),
                        valueColor: item.expiryColor,
                      ),
                      _buildDetailItem(
                        'حالة الصلاحية',
                        item.expiryStatus,
                        valueColor: item.expiryColor,
                      ),
                      _buildDetailItem(
                        'الأيام المتبقية',
                        item.expiryDate != null 
                            ? '${item.expiryDate!.difference(DateTime.now()).inDays} يوم'
                            : 'غير محدد',
                        valueColor: item.expiryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // معلومات إضافية
            if (item.notes != null || item.medicineCategory != null || item.itemCode != null) ...[
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات إضافية',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple,
                        ),
                      ),
                      SizedBox(height: 12),
                      if (item.itemCode != null)
                        _buildDetailItem('كود الصنف', item.itemCode),
                      if (item.medicineCategory != null)
                        _buildDetailItem('فئة الدواء', item.medicineCategory),
                      if (item.unitOfMeasure != null)
                        _buildDetailItem('وحدة القياس', item.unitOfMeasure),
                      if (item.notes != null)
                        _buildDetailItem('ملاحظات', item.notes),
                    ],
                  ),
                ),
              ),
            ],

            // معلومات المخزون والتحذيرات
            SizedBox(height: 16),
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة الدواء',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          item.isExpired ? Icons.error : Icons.check_circle,
                          color: item.isExpired ? Colors.red : Colors.green,
                          size: 24,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.isExpired 
                                ? '⚠️ هذا الدواء منتهي الصلاحية'
                                : '✅ هذا الدواء ساري الصلاحية',
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
                      SizedBox(height: 8),
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
                      SizedBox(height: 4),
                      Text(
                        'متبقي ${item.expiryDate!.difference(DateTime.now()).inDays} يوم من الصلاحية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 20),

            // أزرار الإجراءات
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: Icon(Icons.edit),
                      label: Text('تعديل السجل'),
                      onPressed: () {
                        // سيتم إضافة التنقل لشاشة التعديل لاحقاً
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.share),
                      label: Text('مشاركة'),
                      onPressed: () {
                        _shareMedicineInfo(context, item);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double _calculateExpiryProgress(DateTime expiryDate) {
    final now = DateTime.now();
    final totalDays = expiryDate.difference(DateTime(expiryDate.year - 1, expiryDate.month, expiryDate.day)).inDays.toDouble();
    final remainingDays = expiryDate.difference(now).inDays.toDouble();
    
    if (remainingDays <= 0) return 0.0;
    if (remainingDays >= totalDays) return 1.0;
    
    return remainingDays / totalDays;
  }

  void _shareMedicineInfo(BuildContext context, MedicineItem item) {
    // محاكاة وظيفة المشاركة
    final String shareText = '''
💊 معلومات الدواء:
• اسم الدواء: ${item.itemName ?? 'غير محدد'}
• نوع الدواء: ${item.medicineType ?? 'غير محدد'}
• الكمية: ${item.quantity} ${item.unit ?? ''}
• نوع الحركة: ${item.movementType}
• تاريخ الانتهاء: ${_formatDate(item.expiryDate)}
• حالة الصلاحية: ${item.expiryStatus}
${item.notes != null ? '• ملاحظات: ${item.notes}' : ''}
    ''';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم نسخ معلومات الدواء للمشاركة'),
        backgroundColor: Colors.green,
      ),
    );
    
    // في التطبيق الحقيقي، نستخدم حزمة المشاركة مثل: share_plus
    // Share.share(shareText);
  }
}