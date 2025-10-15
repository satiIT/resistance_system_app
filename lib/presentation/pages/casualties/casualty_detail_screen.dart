import 'package:flutter/material.dart';
import '../../../core/models/casualty.dart';

class CasualtyDetailScreen extends StatelessWidget {
  final Casualty casualty;

  CasualtyDetailScreen({required this.casualty});

  Widget _buildDetailItem(String label, String? value, {bool isImportant = false}) {
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
                color: isImportant ? Colors.red : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل السجل'),
        backgroundColor: Colors.red,
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
                          backgroundColor: casualty.typeColor,
                          child: Icon(
                            casualty.isMartyr ? Icons.flag : Icons.medical_services,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                casualty.fullName,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                casualty.formType,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: casualty.typeColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 24),
                    _buildDetailItem('الرقم العسكري', casualty.militaryNumber),
                    _buildDetailItem('رقم إشارة الحالة', casualty.caseSignalNumber),
                    _buildDetailItem('تاريخ الحادث', casualty.incidentDateFormatted, isImportant: true),
                    _buildDetailItem('موقع الحادث', casualty.incidentLocation),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // معلومات الإصابة/الاستشهاد
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل ${casualty.isMartyr ? 'الاستشهاد' : 'الإصابة'}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(height: 12),
                    if (casualty.isInjured) ...[
                      _buildDetailItem('حالة الإصابة', casualty.injurySeverity),
                      _buildDetailItem('المستشفيات', casualty.hospitals),
                    ],
                    if (casualty.isMartyr) ...[
                      _buildDetailItem('مكان الدفن', casualty.burialLocation),
                      _buildDetailItem('إحداثيات القبر', casualty.graveCoordinates),
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // معلومات أقرب الأقربين
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'أقرب الأقربين',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildDetailItem('الاسم', casualty.nextOfKinName),
                    _buildDetailItem('رقم التلفون', casualty.nextOfKinPhone),
                    _buildDetailItem('العنوان', casualty.nextOfKinAddress),
                  ],
                ),
              ),
            ),

            // خلافة الشهيد (إذا كان شهيداً)
            if (casualty.isMartyr && 
                (casualty.compensationDate != null || 
                 casualty.compensationAmount != null ||
                 casualty.paymentMethod != null)) ...[
              SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'خلافة الشهيد',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      SizedBox(height: 12),
                      if (casualty.compensationDate != null)
                        _buildDetailItem('تاريخ الخلافة', 
                          '${casualty.compensationDate!.year}-${casualty.compensationDate!.month.toString().padLeft(2, '0')}-${casualty.compensationDate!.day.toString().padLeft(2, '0')}'),
                      if (casualty.compensationAmount != null)
                        _buildDetailItem('المبلغ', '${casualty.compensationAmount} جنيه'),
                      if (casualty.paymentMethod != null)
                        _buildDetailItem('طريقة الدفع', casualty.paymentMethod),
                      if (casualty.compensationRecipient != null)
                        _buildDetailItem('المستلم', casualty.compensationRecipient),
                      if (casualty.payingEntity != null)
                        _buildDetailItem('الجهة الدافعة', casualty.payingEntity),
                      if (casualty.materialItems != null)
                        _buildDetailItem('المواد العينية', casualty.materialItems),
                      if (casualty.materialValue != null)
                        _buildDetailItem('قيمة المواد', '${casualty.materialValue} جنيه'),
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