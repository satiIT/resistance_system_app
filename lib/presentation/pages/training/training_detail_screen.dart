import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/models/training_record.dart';
import 'training_form_screen.dart';

class TrainingDetailScreen extends StatelessWidget {
  final TrainingRecord record;

  TrainingDetailScreen({required this.record});

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: 'تفاصيل السجل',
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => TrainingFormScreen(existingRecord: record),
            ),
          ),
        ),
      ],
      children: [
        _buildHeroHeader(),
        const SizedBox(height: 32),

        ModernSectionCard(
          title: 'معلومات الدورة',
          icon: Icons.school_rounded,
          child: Column(
            children: [
              _buildDetailRow('اسم الدورة', record.courseName),
              _buildDetailRow('نوع الدورة', record.courseType),
              _buildDetailRow('معسكر التدريب', record.trainingCampName),
              _buildDetailRow('موقع الرماية', record.firingLocation),
            ],
          ),
        ),

        ModernSectionCard(
          title: 'التدريب المتخصص',
          icon: Icons.engineering_rounded,
          child: Column(
            children: [
              _buildDetailRow('الدورة المتخصصة', record.specializedCourseType),
              _buildDetailRow('نوع السلاح', record.weaponType),
              _buildDetailRow('تدريب السلاح الخاص', record.weaponTrainingType),
              _buildDetailRow('التدريب السابق', record.priorTrainingType),
            ],
          ),
        ),

        ModernSectionCard(
          title: 'النتائج والتقييم',
          icon: Icons.assessment_rounded,
          child: Column(
            children: [
              _buildDetailRow('حالة الحضور', record.attendanceStatus),
              _buildDetailRow(
                'درجة التقييم',
                record.evaluationScore?.toString(),
              ),
              _buildDetailRow(
                'استلام الشهادة',
                record.certificateReceived == true
                    ? 'تم الاستلام'
                    : 'لم يتم الاستلام',
                isStatus: true,
                statusColor: record.certificateReceived == true
                    ? Colors.green
                    : Colors.redAccent,
              ),
            ],
          ),
        ),

        if (record.notes != null && record.notes!.isNotEmpty)
          ModernSectionCard(
            title: 'ملاحظات إضافية',
            icon: Icons.description_rounded,
            child: Text(
              record.notes!,
              style: GoogleFonts.tajawal(
                height: 1.6,
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ),
        const SizedBox(height: 48),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 15,
                ),
              ],
            ),
            child: const Icon(
              Icons.person_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.personnelName ?? 'غير موثق',
                  style: GoogleFonts.tajawal(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.slate100.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'الرقم العسكري: ${record.militaryNumber ?? '---'}',
                    style: GoogleFonts.tajawal(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    String label,
    String? value, {
    bool isStatus = false,
    Color? statusColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(color: Colors.white70, fontSize: 14),
          ),
          if (isStatus)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (statusColor ?? AppColors.primary).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value ?? '---',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: statusColor ?? Colors.white,
                ),
              ),
            )
          else
            Text(
              value ?? '---',
              style: GoogleFonts.tajawal(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
