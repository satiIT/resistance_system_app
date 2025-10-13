import 'package:flutter/material.dart';
import '../../../core/models/training_record.dart';
import 'training_form_screen.dart';

class TrainingDetailScreen extends StatelessWidget {
  final TrainingRecord record;

  TrainingDetailScreen({required this.record});

  Widget _buildInfoCard(String title, String value) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            SizedBox(height: 4),
            Text(value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text('$label:',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text('المعلومات الأساسية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildDetailRow('اسم المستنفر', record.personnelName ?? 'غير محدد'),
            _buildDetailRow('الرقم العسكري', record.militaryNumber ?? 'غير محدد'),
            _buildDetailRow('الدورة التدريبية', record.courseName ?? 'غير محدد'),
            _buildDetailRow('نوع الدورة', record.courseType ?? 'غير محدد'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainingInfoCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: Colors.green),
                SizedBox(width: 8),
                Text('معلومات التدريب',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (record.priorTrainingType != null)
              _buildDetailRow('نوع التدريب السابق', record.priorTrainingType!),
            if (record.trainingCampName != null)
              _buildDetailRow('معسكر التدريب', record.trainingCampName!),
            if (record.firingLocation != null)
              _buildDetailRow('موقع ضرب النار', record.firingLocation!),
            if (record.weaponType != null)
              _buildDetailRow('نوع السلاح', record.weaponType!),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializedTrainingCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.engineering, color: Colors.orange),
                SizedBox(width: 8),
                Text('التدريب المتخصص',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (record.specializedCourseType != null)
              _buildDetailRow('نوع الدورة المتخصصة', record.specializedCourseType!),
            if (record.weaponTrainingType != null)
              _buildDetailRow('نوع تدريب السلاح', record.weaponTrainingType!),
          ],
        ),
      ),
    );
  }

  Widget _buildEvaluationCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assessment, color: Colors.purple),
                SizedBox(width: 8),
                Text('التقييم والنتائج',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildDetailRow('حالة الحضور', record.attendanceStatus ?? 'غير محدد'),
            if (record.evaluationScore != null)
              _buildDetailRow('نتيجة التقييم', '${record.evaluationScore!} / 100'),
            _buildDetailRow('استلام الشهادة', record.certificateReceived == true ? 'نعم' : 'لا'),
            if (record.notes != null && record.notes!.isNotEmpty)
              _buildDetailRow('ملاحظات', record.notes!),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseDetailsCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.red),
                SizedBox(width: 8),
                Text('تفاصيل الدورة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (record.courseLocation != null)
              _buildDetailRow('موقع الدورة', record.courseLocation!),
            if (record.courseStartDate != null)
              _buildDetailRow('تاريخ البدء', _formatDate(record.courseStartDate!)),
            if (record.courseEndDate != null)
              _buildDetailRow('تاريخ الانتهاء', _formatDate(record.courseEndDate!)),
            if (record.courseDurationDays != null)
              _buildDetailRow('مدة الدورة', '${record.courseDurationDays!} يوم'),
            if (record.joinedAt != null)
              _buildDetailRow('تاريخ الانضمام', _formatDateTime(record.joinedAt!)),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل سجل التدريب'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrainingFormScreen(existingRecord: record),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoCard(),
            SizedBox(height: 16),
            _buildTrainingInfoCard(),
            SizedBox(height: 16),
            
            if (record.specializedCourseType != null || record.weaponTrainingType != null) ...[
              _buildSpecializedTrainingCard(),
              SizedBox(height: 16),
            ],
            
            _buildEvaluationCard(),
            SizedBox(height: 16),
            
            if (record.courseLocation != null || record.courseStartDate != null) ...[
              _buildCourseDetailsCard(),
              SizedBox(height: 16),
            ],
            
            if (record.joinedAt != null) 
              _buildInfoCard('تاريخ التسجيل', _formatDateTime(record.joinedAt!)),
          ],
        ),
      ),
    );
  }
}