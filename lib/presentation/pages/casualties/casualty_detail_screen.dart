import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:resistance_system_app/core/theme/app_theme.dart';
import 'package:resistance_system_app/presentation/widgets/modern_widgets.dart';
import '../../../core/models/casualty.dart';
import '../../../core/models/martyr_compensation.dart';
import '../../../core/services/casualty_api.dart';
import '../../../core/models/training_record.dart';
import '../../../core/services/training_api.dart';
import '../training/training_detail_screen.dart';
import 'casualty_form_screen.dart';

class CasualtyDetailScreen extends StatefulWidget {
  final Casualty casualty;

  CasualtyDetailScreen({required this.casualty});

  @override
  _CasualtyDetailScreenState createState() => _CasualtyDetailScreenState();
}

class _CasualtyDetailScreenState extends State<CasualtyDetailScreen> {
  MartyrCompensation? _compensation;
  Map<String, dynamic>? _personnelData;
  List<TrainingRecord> _trainingRecords = [];
  bool _isLoading = true;
  bool _compensationLoading = false;
  bool _trainingLoading = false;

  @override
  void initState() {
    super.initState();
    _loadAdditionalData();
  }

  Future<void> _loadAdditionalData() async {
    try {
      if (widget.casualty.isMartyr) {
        setState(() {
          _compensationLoading = true;
        });
        final compensation = await CasualtyApi.getCompensationByCasualtyId(
          widget.casualty.id!,
        );
        setState(() {
          _compensation = compensation;
          _compensationLoading = false;
        });
      }

      if (widget.casualty.personnelId != null) {
        final personnel = await CasualtyApi.getPersonnelById(
          widget.casualty.personnelId!,
        );
        setState(() {
          _personnelData = personnel;
        });

        // Fetch training records
        setState(() => _trainingLoading = true);
        final allTraining = await TrainingApi.getTrainingRecords();
        setState(() {
          _trainingRecords = allTraining
              .where((r) => r.personnelId == widget.casualty.personnelId)
              .toList();
          _trainingLoading = false;
        });
      }
    } catch (e) {
      print('Error loading additional data: $e');
      setState(() {
        _compensationLoading = false;
        _trainingLoading = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                color: (statusColor ?? AppColors.primary).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value ?? 'غير محدد',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: statusColor ?? Colors.white,
                ),
              ),
            )
          else
            Expanded(
              child: Text(
                value ?? 'غير محدد',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Colors.white,
                ),
                textAlign: TextAlign.end,
              ),
            ),
        ],
      ),
    );
  }

  Color _getTypeColor(Casualty casualty) {
    return casualty.isMartyr ? Colors.red : Colors.orange;
  }

  String _getIncidentDateFormatted(Casualty casualty) {
    if (casualty.incidentDate == null) return 'غير محدد';
    return '${casualty.incidentDate!.year}-${casualty.incidentDate!.month.toString().padLeft(2, '0')}-${casualty.incidentDate!.day.toString().padLeft(2, '0')}';
  }

  Widget _buildPersonnelInfoSection() {
    if (_personnelData == null) return const SizedBox();

    return ModernSectionCard(
      title: 'البيانات الأساسية للمستنفر',
      icon: Icons.person_search_rounded,
      child: Column(
        children: [
          _buildDetailRow(
            'الاسم الكامل',
            '${_personnelData!['first_name'] ?? ''} ${_personnelData!['second_name'] ?? ''} ${_personnelData!['third_name'] ?? ''} ${_personnelData!['fourth_name'] ?? ''}',
          ),
          _buildDetailRow(
            'الرقم العسكري',
            _personnelData!['military_id']?.toString(),
          ),
          _buildDetailRow('الرتبة', _personnelData!['rank']),
          _buildDetailRow('الوحدة', _personnelData!['unit']),
        ],
      ),
    );
  }

  Widget _buildNextOfKinSection() {
    if (_personnelData == null) return const SizedBox();

    final nextOfKinName = _personnelData!['next_of_kin_name'];
    final nextOfKinPhone = _personnelData!['next_of_kin_phone'];
    final nextOfKinAddress = _personnelData!['next_of_kin_address'];

    if (nextOfKinName == null &&
        nextOfKinPhone == null &&
        nextOfKinAddress == null) {
      return const SizedBox();
    }

    return ModernSectionCard(
      title: 'أقرب الأقربين',
      icon: Icons.family_restroom_rounded,
      child: Column(
        children: [
          _buildDetailRow('الاسم', nextOfKinName),
          _buildDetailRow('رقم التلفون', nextOfKinPhone),
          _buildDetailRow('العنوان', nextOfKinAddress),
        ],
      ),
    );
  }

  Widget _buildIncidentInfoSection() {
    final color = _getTypeColor(widget.casualty);
    return ModernSectionCard(
      title: 'معلومات الحادث',
      icon: Icons.event_note_rounded,
      child: Column(
        children: [
          _buildDetailRow('نوع الاستمارة', widget.casualty.caseType),
          _buildDetailRow(
            'تاريخ الحادث',
            _getIncidentDateFormatted(widget.casualty),
            isStatus: true,
            statusColor: color,
          ),
          _buildDetailRow('موقع الحادث', widget.casualty.incidentLocation),
          _buildDetailRow('رقم إشارة الحالة', widget.casualty.signalNumber),
          if (widget.casualty.isInjured) ...[
            _buildDetailRow('حالة الإصابة', widget.casualty.injurySeverity),
            _buildDetailRow('المستشفيات', widget.casualty.hospitals),
            _buildDetailRow('تاريخ العلاج', widget.casualty.treatmentHistory),
          ],
          if (widget.casualty.isMartyr) ...[
            _buildDetailRow('مكان الدفن', widget.casualty.burialLocation),
            _buildDetailRow('إحداثيات القبر', widget.casualty.graveCoordinates),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    if (widget.casualty.notes == null || widget.casualty.notes!.isEmpty) {
      return const SizedBox();
    }
    return ModernSectionCard(
      title: 'ملاحظات إضافية',
      icon: Icons.description_rounded,
      child: Text(
        widget.casualty.notes!,
        style: GoogleFonts.tajawal(
          height: 1.6,
          color: AppColors.slate700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildInjuryDescriptionSection() {
    if (!widget.casualty.isInjured ||
        widget.casualty.injuryDescription == null) {
      return const SizedBox();
    }
    return ModernSectionCard(
      title: 'وصف الإصابة',
      icon: Icons.medical_services_rounded,
      child: Text(
        widget.casualty.injuryDescription!,
        style: GoogleFonts.tajawal(
          height: 1.6,
          color: AppColors.slate700,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCompensationSection() {
    if (!widget.casualty.isMartyr) return const SizedBox();

    return ModernSectionCard(
      title: 'تعويضات الشهيد',
      icon: Icons.payments_rounded,
      child: Column(
        children: [
          if (_compensationLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_compensation == null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'لا توجد بيانات تعويض',
                  style: GoogleFonts.tajawal(color: AppColors.slate400),
                ),
              ),
            )
          else ...[
            if (_compensation!.compensationDate != null)
              _buildDetailRow(
                'تاريخ التعويض',
                '${_compensation!.compensationDate!.year}-${_compensation!.compensationDate!.month.toString().padLeft(2, '0')}-${_compensation!.compensationDate!.day.toString().padLeft(2, '0')}',
              ),
            _buildDetailRow(
              'المبلغ',
              _compensation!.amount != null
                  ? '${_compensation!.amount} جنيه'
                  : null,
            ),
            _buildDetailRow('طريقة الدفع', _compensation!.paymentMethod),
            _buildDetailRow('المستلم', _compensation!.recipientName),
            _buildDetailRow('الجهة الدافعة', _compensation!.payingEntity),
            _buildDetailRow('نوع التعويض', _compensation!.compensationType),
            _buildDetailRow(
              'رقم إيصال الدفع',
              _compensation!.paymentReceiptNumber,
            ),
            _buildDetailRow('المواد العينية', _compensation!.materialItems),
            _buildDetailRow(
              'القيمة المقدرة',
              _compensation!.estimatedValue != null
                  ? '${_compensation!.estimatedValue} جنيه'
                  : null,
            ),
            if (_compensation!.notes != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _compensation!.notes!,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: AppColors.slate600,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrainingSection() {
    return ModernSectionCard(
      title: 'السجل التدريبي',
      icon: Icons.school_rounded,
      child: Column(
        children: [
          if (_trainingLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_trainingRecords.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'لا توجد سجلات تدريبية لهذا الشخص',
                  style: GoogleFonts.tajawal(color: AppColors.slate400),
                ),
              ),
            )
          else
            ..._trainingRecords
                .map(
                  (record) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      record.courseName ?? 'دورة غير محددة',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      record.attendanceStatus ?? 'حالة غير محددة',
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: AppColors.slate500,
                      ),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.slate400,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (c) => TrainingDetailScreen(record: record),
                      ),
                    ),
                  ),
                )
                .toList(),
        ],
      ),
    );
  }

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
              builder: (c) =>
                  CasualtyFormScreen(existingCasualty: widget.casualty),
            ),
          ).then((_) => _loadAdditionalData()),
        ),
      ],
      children: [
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: CircularProgressIndicator(),
            ),
          )
        else ...[
          _buildHeroHeader(),
          const SizedBox(height: 32),
          _buildIncidentInfoSection(),
          _buildInjuryDescriptionSection(),
          _buildPersonnelInfoSection(),
          _buildNextOfKinSection(),
          _buildTrainingSection(),
          _buildCompensationSection(),
          _buildNotesSection(),
          const SizedBox(height: 48),
        ],
      ],
    );
  }

  Widget _buildHeroHeader() {
    final color = _getTypeColor(widget.casualty);
    return GlassContainer(
      padding: const EdgeInsets.all(24),
      borderRadius: 24,
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: color.withOpacity(0.05), blurRadius: 15),
              ],
            ),
            child: Icon(
              widget.casualty.isMartyr
                  ? Icons.flag_rounded
                  : Icons.medical_services_rounded,
              color: color,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.casualty.fullName ?? 'غير موثق',
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
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.casualty.isMartyr ? 'شهيد' : 'جروح وإصابات العمل',
                    style: GoogleFonts.tajawal(
                      color: color,
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
}
