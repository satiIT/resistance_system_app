// screens/finance/finance_detail_screen.dart
import 'package:flutter/material.dart';
import '../../../core/models/financial_item.dart';

class FinanceDetailScreen extends StatelessWidget {
  final FinancialItem item;

  FinanceDetailScreen({required this.item});

  Widget _buildDetailItem(String label, String value, {bool isImportant = false, Color? valueColor}) {
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
              value,
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل السجل المالي'),
        backgroundColor: Colors.indigo,
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
                                item.source,
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
                        _buildStatusIndicator('${item.amount} جنيه', Colors.blue),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // معلومات السجل
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'معلومات السجل',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailItem('نوع السجل', item.description),
                    _buildDetailItem(
                      item.type == 'incoming' ? 'الجهة الموردة' : 'بند الصرف', 
                      item.source
                    ),
                    _buildDetailItem(
                      item.type == 'incoming' ? 'طريقة التوريد' : 'الشخص المستلم', 
                      item.method
                    ),
                    _buildDetailItem('المبلغ', '${item.amount} جنيه'),
                    _buildDetailItem('التاريخ', _formatDate(item.entryDate)),
                  ],
                ),
              ),
            ),

            // معلومات إضافية
            if (item.notes != null) ...[
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
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 12),
                      _buildDetailItem('ملاحظات', item.notes!),
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
}