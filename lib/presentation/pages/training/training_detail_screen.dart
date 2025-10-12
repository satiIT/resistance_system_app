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

  Widget _buildTrainingCampCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.military_tech, color: Colors.blue),
                SizedBox(width: 8),
                Text('معسكر عهد الرجال',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (record.trainingCampCourseName != null)
              _buildDetailRow('الدورة التدريبية', record.trainingCampCourseName!),
            if (record.trainingCampWeaponName != null)
              _buildDetailRow('السلاح', record.trainingCampWeaponName!),
            if (record.trainingCampDuration != null)
              _buildDetailRow('مدة الدورة', '${record.trainingCampDuration} يوم'),
            if (record.trainingCampFiringRange != null)
              _buildDetailRow('موقع ضرب النار', record.trainingCampFiringRange!),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecializedCourseCard() {
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
                Text('الدورات المتخصصة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (record.specializedCourseType != null)
              _buildDetailRow('نوع الدورة', record.specializedCourseType!),
            if (record.specializedCourseDetails != null)
              _buildDetailRow('تفاصيل الدورة', record.specializedCourseDetails!),
          ],
        ),
      ),
    );
  }

  Widget _buildWeaponCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.security, color: Colors.red),
                SizedBox(width: 8),
                Text('بيانات التسليح',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            if (record.weaponTypeReceived != null)
              _buildDetailRow('نوع السلاح المستلم', record.weaponTypeReceived!),
            if (record.weaponNumber != null)
              _buildDetailRow('رقم السلاح', record.weaponNumber!),
            if (record.weaponAccessories != null && record.weaponAccessories!.isNotEmpty)
              _buildDetailRow('ملحقات السلاح', record.weaponAccessories!.join(', ')),
          ],
        ),
      ),
    );
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
            _buildInfoCard('المستنفر', '${record.personnelName ?? "غير محدد"} - ${record.militaryNumber ?? "غير محدد"}'),
            SizedBox(height: 12),
            _buildInfoCard('نوع التدريب السابق', record.previousTrainingType ?? 'غير محدد'),
            SizedBox(height: 16),
            
            if (record.trainingCampCourseName != null) ...[
              _buildTrainingCampCard(),
              SizedBox(height: 16),
            ],
            
            if (record.specializedCourseType != null) ...[
              _buildSpecializedCourseCard(),
              SizedBox(height: 16),
            ],
            
            if (record.weaponTypeReceived != null) ...[
              _buildWeaponCard(),
              SizedBox(height: 16),
            ],
            
            if (record.createdAt != null) 
              _buildInfoCard('تاريخ الإنشاء', 
                '${record.createdAt!.toLocal().toString().split(' ')[0]} '
                '${record.createdAt!.toLocal().toString().split(' ')[1].substring(0, 5)}'
              ),
          ],
        ),
      ),
    );
  }
}