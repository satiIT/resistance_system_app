import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/inventory_item.dart';
import '../../widgets/modern_widgets.dart';

class InventoryDetailScreen extends StatelessWidget {
  final InventoryItem item;

  InventoryDetailScreen({required this.item});

  @override
  Widget build(BuildContext context) {
    return ModernPageScaffold(
      title: 'تفاصيل الحركة',
      children: [
        ModernScreenHeader(
          title: item.itemName ?? 'غير معروف',
          subtitle: 'تفاصيل حركة المخزون رقم #${item.id ?? '---'}',
        ),
        const SizedBox(height: 24),

        _buildMainCard(),

        ModernSectionCard(
          title: 'معلومات الحركة',
          icon: Icons.swap_vert_rounded,
          child: Column(
            children: [
              _buildDetailRow(
                'نوع الحركة',
                item.movementType,
                color: item.typeColor,
              ),
              _buildDetailRow(
                'الكمية',
                '${item.quantity} ${item.packaging ?? ""}',
              ),
              _buildDetailRow('التاريخ', _formatDate(item.movementDate)),
              if (item.approvedBy != null)
                _buildDetailRow('المعتمد', item.approvedBy!),
            ],
          ),
        ),

        ModernSectionCard(
          title: 'الأطراف والمخازن',
          icon: Icons.door_back_door_rounded,
          child: Column(
            children: [
              if (item.movementType == 'وارد') ...[
                _buildDetailRow(
                  'الجهة الموردة',
                  item.supplierEntity ?? 'غير معروف',
                ),
                if (item.toStoreName != null)
                  _buildDetailRow('المخزن المستلم', item.toStoreName!),
              ] else if (item.movementType == 'منصرف') ...[
                _buildDetailRow(
                  'الجهة المستلمة',
                  item.receiverEntity ?? 'غير معروف',
                ),
                if (item.fromStoreName != null)
                  _buildDetailRow('المخزن المصدر', item.fromStoreName!),
              ] else if (item.movementType == 'نقل') ...[
                if (item.fromStoreName != null)
                  _buildDetailRow('من مخزن', item.fromStoreName!),
                if (item.toStoreName != null)
                  _buildDetailRow('إلى مخزن', item.toStoreName!),
              ],
            ],
          ),
        ),

        if (item.expiryDate != null || item.batchNumber != null)
          ModernSectionCard(
            title: 'بيانات الصلاحية والتشغيلة',
            icon: Icons.timer_rounded,
            child: Column(
              children: [
                if (item.expiryDate != null)
                  _buildDetailRow(
                    'تاريخ الانتهاء',
                    _formatDate(item.expiryDate!),
                    color: item.expiryColor,
                  ),
                if (item.batchNumber != null)
                  _buildDetailRow('رقم الدفعة', item.batchNumber!),
                _buildDetailRow(
                  'الحالة',
                  item.expiryStatus,
                  color: item.expiryColor,
                ),
              ],
            ),
          ),

        if (item.notes != null && item.notes!.isNotEmpty)
          ModernSectionCard(
            title: 'ملاحظات إضافية',
            icon: Icons.notes_rounded,
            child: Text(
              item.notes!,
              style: GoogleFonts.tajawal(color: Colors.white70, height: 1.5),
            ),
          ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [item.typeColor.withOpacity(0.2), Colors.black12],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: item.typeColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: item.typeColor.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(item.typeIcon, color: item.typeColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.movementType,
                  style: GoogleFonts.tajawal(
                    color: item.typeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '${item.quantity} وحدة في ${item.packaging ?? "عبوة"}',
                  style: GoogleFonts.tajawal(color: Colors.white70),
                ),
              ],
            ),
          ),
          ModernStatusBadge(
            text: item.movementType == 'وارد' ? 'دخول' : 'خروج',
            color: item.typeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(color: Colors.white54, fontSize: 14),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.tajawal(
                color: color ?? Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
