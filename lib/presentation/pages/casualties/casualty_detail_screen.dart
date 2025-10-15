import 'package:flutter/material.dart';
import '../../../core/models/casualty.dart';
import '../../../core/models/martyr_compensation.dart';
import '../../../core/services/casualty_api.dart';

class CasualtyDetailScreen extends StatefulWidget {
  final Casualty casualty;

  CasualtyDetailScreen({required this.casualty});

  @override
  _CasualtyDetailScreenState createState() => _CasualtyDetailScreenState();
}

class _CasualtyDetailScreenState extends State<CasualtyDetailScreen> {
  MartyrCompensation? _compensation;
  Map<String, dynamic>? _personnelData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAdditionalData();
  }

  Future<void> _loadAdditionalData() async {
    try {
      if (widget.casualty.isMartyr) {
        final compensation = await CasualtyApi.getCompensationByCasualtyId(widget.casualty.id!);
        setState(() {
          _compensation = compensation;
        });
      }
      
      if (widget.casualty.personnelId != null) {
        final personnel = await CasualtyApi.getPersonnelById(widget.casualty.personnelId!);
        setState(() {
          _personnelData = personnel;
        });
      }
    } catch (e) {
      print('Error loading additional data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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

  Widget _buildPersonnelInfoSection() {
    if (_personnelData == null) return SizedBox();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'البيانات الأساسية للمستنفر',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 12),
            _buildDetailItem('الاسم الكامل', 
                '${_personnelData!['first_name']} ${_personnelData!['second_name']} ${_personnelData!['third_name']} ${_personnelData!['fourth_name']}'),
            _buildDetailItem('الرقم العسكري', _personnelData!['military_id']?.toString()),
            _buildDetailItem('الرتبة', _personnelData!['rank']),
            _buildDetailItem('الوحدة', _personnelData!['unit']),
          ],
        ),
      ),
    );
  }

  Widget _buildNextOfKinSection() {
    if (_personnelData == null) return SizedBox();

    final nextOfKinName = _personnelData!['next_of_kin_name'];
    final nextOfKinPhone = _personnelData!['next_of_kin_phone'];
    final nextOfKinAddress = _personnelData!['next_of_kin_address'];

    if (nextOfKinName == null && nextOfKinPhone == null && nextOfKinAddress == null) {
      return SizedBox();
    }

    return Card(
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
            _buildDetailItem('الاسم', nextOfKinName),
            _buildDetailItem('رقم التلفون', nextOfKinPhone),
            _buildDetailItem('العنوان', nextOfKinAddress),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الحادث',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 12),
            _buildDetailItem('نوع الاستمارة', widget.casualty.formType),
            _buildDetailItem('تاريخ الحادث', widget.casualty.incidentDateFormatted, isImportant: true),
            _buildDetailItem('موقع الحادث', widget.casualty.incidentLocation),
            _buildDetailItem('رقم إشارة الحالة', widget.casualty.caseSignalNumber),
            if (widget.casualty.isInjured) ...[
              _buildDetailItem('حالة الإصابة', widget.casualty.injurySeverity),
              _buildDetailItem('المستشفيات', widget.casualty.hospitals),
              _buildDetailItem('تاريخ العلاج', widget.casualty.treatmentHistory),
            ],
            if (widget.casualty.isMartyr) ...[
              _buildDetailItem('مكان الدفن', widget.casualty.burialLocation),
              _buildDetailItem('إحداثيات القبر', widget.casualty.graveCoordinates),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompensationSection() {
    if (!widget.casualty.isMartyr || _compensation == null) return SizedBox();

    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تعويضات الشهيد',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
            SizedBox(height: 12),
            if (_compensation!.compensationDate != null)
              _buildDetailItem('تاريخ التعويض', 
                  '${_compensation!.compensationDate!.year}-${_compensation!.compensationDate!.month.toString().padLeft(2, '0')}-${_compensation!.compensationDate!.day.toString().padLeft(2, '0')}'),
            if (_compensation!.amount != null)
              _buildDetailItem('المبلغ', '${_compensation!.amount} جنيه'),
            if (_compensation!.paymentMethod != null)
              _buildDetailItem('طريقة الدفع', _compensation!.paymentMethod),
            if (_compensation!.recipientName != null)
              _buildDetailItem('المستلم', _compensation!.recipientName),
            if (_compensation!.payingEntity != null)
              _buildDetailItem('الجهة الدافعة', _compensation!.payingEntity),
            if (_compensation!.compensationType != null)
              _buildDetailItem('نوع التعويض', _compensation!.compensationType),
            if (_compensation!.paymentReceiptNumber != null)
              _buildDetailItem('رقم إيصال الدفع', _compensation!.paymentReceiptNumber),
            if (_compensation!.materialItems != null)
              _buildDetailItem('المواد العينية', _compensation!.materialItems),
            if (_compensation!.estimatedValue != null)
              _buildDetailItem('القيمة المقدرة', '${_compensation!.estimatedValue} جنيه'),
            if (_compensation!.notes != null)
              _buildDetailItem('ملاحظات', _compensation!.notes),
          ],
        ),
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                backgroundColor: widget.casualty.typeColor,
                                child: Icon(
                                  widget.casualty.isMartyr ? Icons.flag : Icons.medical_services,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.casualty.fullName ?? 'غير محدد',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      widget.casualty.formType,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: widget.casualty.typeColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16),
                  _buildPersonnelInfoSection(),
                  SizedBox(height: 16),
                  _buildNextOfKinSection(),
                  SizedBox(height: 16),
                  _buildIncidentInfoSection(),
                  SizedBox(height: 16),
                  _buildCompensationSection(),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}