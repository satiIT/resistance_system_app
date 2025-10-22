import 'package:flutter/material.dart';
import '../../../core/models/inventory_item.dart';

class InventoryDetailScreen extends StatelessWidget {
  final InventoryItem item;

  InventoryDetailScreen({required this.item});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل حركة المخزون'),
        backgroundColor: Colors.teal,
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
                                item.description,
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
                        _buildStatusIndicator(item.description, item.typeColor),
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

            // معلومات الحركة
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الحركة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailItem('نوع الحركة', item.movementType),
                    _buildDetailItem('الصنف', item.itemName),
                    _buildDetailItem('الكمية', '${item.quantity} ${item.packaging ?? ""}'),
                    _buildDetailItem('التاريخ', _formatDate(item.movementDate)),
                    _buildDetailItem('العبوة', item.packaging),
                    if (item.approvedBy != null)
                      _buildDetailItem('تمت الموافقة بواسطة', item.approvedBy),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // معلومات الجهات
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات الجهات',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (item.movementType == 'وارد') ...[
                      _buildDetailItem('الجهة الموردة', item.supplierEntity),
                      if (item.toStoreName != null)
                        _buildDetailItem('المخزن المستلم', item.toStoreName),
                    ] else if (item.movementType == 'منصرف') ...[
                      _buildDetailItem('الجهة المستلمة', item.receiverEntity),
                      if (item.fromStoreName != null)
                        _buildDetailItem('المخزن المصدر', item.fromStoreName),
                    ] else if (item.movementType == 'نقل') ...[
                      if (item.fromStoreName != null)
                        _buildDetailItem('من المخزن', item.fromStoreName),
                      if (item.toStoreName != null)
                        _buildDetailItem('إلى المخزن', item.toStoreName),
                    ],
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
                        _formatDate(item.expiryDate!),
                        valueColor: item.expiryColor,
                      ),
                      _buildDetailItem(
                        'حالة الصلاحية',
                        item.expiryStatus,
                        valueColor: item.expiryColor,
                      ),
                      if (item.batchNumber != null)
                        _buildDetailItem('رقم الدفعة', item.batchNumber),
                    ],
                  ),
                ),
              ),
            ],

            // معلومات إضافية
            if (item.notes != null || item.packagingDetails != null) ...[
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
                      if (item.packagingDetails != null)
                        _buildDetailItem('تفاصيل العبوة', item.packagingDetails),
                      if (item.notes != null)
                        _buildDetailItem('ملاحظات', item.notes),
                    ],
                  ),
                ),
              ),
            ],

            // معلومات التصنيف
            if (item.category != null || item.itemCode != null) ...[
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'معلومات التصنيف',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.brown,
                        ),
                      ),
                      SizedBox(height: 12),
                      if (item.itemCode != null)
                        _buildDetailItem('كود الصنف', item.itemCode),
                      if (item.category != null)
                        _buildDetailItem('الفئة', item.category),
                      if (item.unitOfMeasure != null)
                        _buildDetailItem('وحدة القياس', item.unitOfMeasure),
                    ],
                  ),
                ),
              ),
            ],

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}