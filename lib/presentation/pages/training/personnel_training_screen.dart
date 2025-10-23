import 'package:flutter/material.dart';
import 'package:resistance_system_app/presentation/pages/training/instructors_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/training_courses_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/training_course_form_screen.dart';
import 'package:resistance_system_app/presentation/pages/training/instructor_form_screen.dart';
import './../../../core/models/training_record.dart';
import './../../../core/services/training_api.dart';
import 'training_form_screen.dart';
import 'training_detail_screen.dart';

class PersonnelTrainingScreen extends StatefulWidget {
  @override
  _PersonnelTrainingScreenState createState() => _PersonnelTrainingScreenState();
}

class _PersonnelTrainingScreenState extends State<PersonnelTrainingScreen> {
  List<TrainingRecord> trainingRecords = [];
  bool isLoading = true;
  String searchQuery = '';
  int _selectedFilter = 0; // 0: جميع السجلات, 1: حاضر فقط, 2: غائب فقط
  bool _isSearching = false;
  bool _isGridView = false; // تبديل بين العرض الشبكي والجدولي
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTrainingData();
  }

  void _refreshData() {
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });
    _loadTrainingData();
  }

  Future<void> _loadTrainingData() async {
  try {
    print('🔄 Loading training data with safe API...');
    setState(() {
      isLoading = true;
      _errorMessage = null;
    });

    final response = await SafeTrainingApi.getTrainingRecordsSafe();
    
    print('📊 Loaded ${response.length} records successfully');
    
    setState(() {
      trainingRecords = response;
      isLoading = false;
      _errorMessage = null;
    });
    
  } catch (e, stackTrace) {
    print('💥 Error in _loadTrainingData: $e');
    print('📝 Stack trace: $stackTrace');
    
    setState(() {
      isLoading = false;
      _errorMessage = _getUserFriendlyError(e);
    });
    
    _showErrorSnackBar(_getUserFriendlyError(e));
  }
}

String _getUserFriendlyError(dynamic error) {
  final errorString = error.toString();
  
  if (errorString.contains('Failed host lookup')) {
    return 'تعذر الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت.';
  } else if (errorString.contains('Connection refused')) {
    return 'الخادم غير متاح حالياً. يرجى المحاولة لاحقاً.';
  } else if (errorString.contains('لا توجد سجلات صالحة')) {
    return 'لا توجد سجلات تدريب صالحة للعرض';
  } else if (errorString.contains('خطأ في تحميل البيانات')) {
    return 'حدث خطأ في تحميل البيانات من الخادم';
  } else {
    return 'حدث خطأ غير متوقع: $errorString';
  }
}
void _emergencyRecovery() {
  setState(() {
    trainingRecords = [];
    _errorMessage = null;
    isLoading = false;
  });
  
  _showErrorSnackBar('تم تفريغ السجلات المؤقتة. يرجى إعادة تحميل البيانات.');
}

// Update your error widget to include emergency recovery
Widget _buildErrorWidget() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.error_outline, size: 80, color: Colors.red),
        SizedBox(height: 16),
        Text(
          'حدث خطأ في تحميل البيانات',
          style: TextStyle(fontSize: 18, color: Colors.red, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            _errorMessage!,
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _refreshData,
          icon: Icon(Icons.refresh),
          label: Text('إعادة المحاولة'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _emergencyRecovery,
          icon: Icon(Icons.cleaning_services),
          label: Text('تفريغ السجلات المؤقتة'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.orange,
          ),
        ),
      ],
    ),
  );
}
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), 
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  List<TrainingRecord> get filteredRecords {
    var filtered = trainingRecords;

    // تطبيق البحث
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((record) {
        return record.personnelName?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ==
                true ||
            record.militaryNumber?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ==
                true ||
            record.courseName?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ==
                true ||
            record.priorTrainingType?.toLowerCase().contains(
                  searchQuery.toLowerCase(),
                ) ==
                true;
      }).toList();
    }

    // تطبيق الفلتر حسب الحالة
    if (_selectedFilter == 1) {
      filtered = filtered.where((record) => record.attendanceStatus == 'حاضر').toList();
    } else if (_selectedFilter == 2) {
      filtered = filtered.where((record) => record.attendanceStatus == 'غائب').toList();
    }

    return filtered;
  }

  // دالة لمعالجة القيم الفارغة والغير محددة
  String _handleNullValue(String? value, {String defaultValue = 'غير محدد'}) {
    if (value == null || value.isEmpty || value == 'null' || value == 'NULL') {
      return defaultValue;
    }
    return value;
  }

  // دالة لمعالجة القيم الرقمية الفارغة
  String _handleNullNumber(int? value, {String defaultValue = '--'}) {
    if (value == null) {
      return defaultValue;
    }
    return value.toString();
  }

  // دالة لمعالجة التواريخ الفارغة
  String _handleNullDate(String? date, {String defaultValue = 'غير محدد'}) {
    if (date == null || date.isEmpty || date == 'null') {
      return defaultValue;
    }
    try {
      // محاولة تنسيق التاريخ إذا كان صالحاً
      return date.substring(0, 10); // عرض أول 10 خانات فقط (YYYY-MM-DD)
    } catch (e) {
      return defaultValue;
    }
  }

  Widget _buildTrainingCard(TrainingRecord record) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: _getStatusColor(record.attendanceStatus),
              width: 6,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _handleNullValue(record.personnelName, defaultValue: 'لا يوجد اسم'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          _handleNullValue(record.militaryNumber, defaultValue: 'لا يوجد رقم'),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(record.attendanceStatus),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Course Info
              _buildInfoRow(
                Icons.school,
                'الدورة التدريبية',
                _handleNullValue(record.courseName, defaultValue: 'لا توجد دورة'),
              ),
              
              SizedBox(height: 8),
              
              // Training Type
              _buildInfoRow(
                Icons.category,
                'نوع التدريب',
                _handleNullValue(record.priorTrainingType, defaultValue: 'غير محدد'),
              ),
              
              SizedBox(height: 8),
              
              // Evaluation
              Row(
                children: [
                  Icon(Icons.star, size: 18, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'التقييم: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 4),
                  _buildEvaluationWidget(record.evaluationScore),
                ],
              ),
              
              SizedBox(height: 16),
              
              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'سجل التدريب',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.visibility, size: 20),
                        onPressed: () => _viewTrainingDetails(record),
                        color: Colors.blue,
                        tooltip: 'عرض التفاصيل',
                      ),
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: () => _editTrainingRecord(record),
                        color: Colors.orange,
                        tooltip: 'تعديل',
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, size: 20),
                        onPressed: () => _showDeleteDialog(record),
                        color: Colors.red,
                        tooltip: 'حذف',
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(TrainingRecord record) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: () => _viewTrainingDetails(record),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _getStatusColor(record.attendanceStatus).withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Align(
                  alignment: Alignment.topLeft,
                  child: _buildStatusChip(record.attendanceStatus),
                ),
                
                SizedBox(height: 12),
                
                // Name and Military Number
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue,
                        radius: 24,
                        child: Text(
                          _handleNullValue(record.personnelName)?.substring(0, 1) ?? '?',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _handleNullValue(record.personnelName, defaultValue: 'لا يوجد اسم'),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        _handleNullValue(record.militaryNumber, defaultValue: 'لا يوجد رقم'),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Course Info
                _buildGridInfoRow(
                  Icons.school, 
                  _handleNullValue(record.courseName, defaultValue: 'لا توجد دورة')
                ),
                
                SizedBox(height: 8),
                
                // Training Type
                _buildGridInfoRow(
                  Icons.category, 
                  _handleNullValue(record.priorTrainingType, defaultValue: 'غير محدد')
                ),
                
                SizedBox(height: 8),
                
                // Evaluation
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildEvaluationWidget(record.evaluationScore),
                  ],
                ),
                
                SizedBox(height: 12),
                
                // Quick Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildActionButton(Icons.visibility, Colors.blue, 
                        () => _viewTrainingDetails(record)),
                    _buildActionButton(Icons.edit, Colors.orange, 
                        () => _editTrainingRecord(record)),
                    _buildActionButton(Icons.delete, Colors.red, 
                        () => _showDeleteDialog(record)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, Color color, VoidCallback onPressed) {
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.1),
      radius: 16,
      child: IconButton(
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        color: color,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildGridInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String? status) {
    // استخدام الدالة المساعدة للتعامل مع الحالة الفارغة
    final statusValue = _handleNullValue(status, defaultValue: 'غير محدد');
    final statusInfo = _getStatusInfo(statusValue);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusInfo['color'],
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: statusInfo['color'].withOpacity(0.3),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(statusValue),
            color: Colors.white,
            size: 14,
          ),
          SizedBox(width: 4),
          Text(
            statusInfo['text'],
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final statusValue = _handleNullValue(status, defaultValue: 'غير محدد');
    final statusInfo = _getStatusInfo(statusValue);
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: statusInfo['color'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusInfo['text'],
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEvaluationWidget(int? score) {
    // استخدام الدالة المساعدة للتعامل مع القيم الفارغة
    final scoreValue = _handleNullNumber(score, defaultValue: '--');

    if (scoreValue == '--') {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          scoreValue,
          style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    }

    // تحويل النص إلى رقم للتقييم
    final numericScore = int.tryParse(scoreValue) ?? 0;
    
    Color scoreColor = Colors.red;
    String evaluationText = 'ضعيف';
    
    if (numericScore >= 90) {
      scoreColor = Colors.green;
      evaluationText = 'ممتاز';
    } else if (numericScore >= 80) {
      scoreColor = Colors.green;
      evaluationText = 'جيد جداً';
    } else if (numericScore >= 70) {
      scoreColor = Colors.blue;
      evaluationText = 'جيد';
    } else if (numericScore >= 60) {
      scoreColor = Colors.orange;
      evaluationText = 'مقبول';
    }

    return Tooltip(
      message: '$evaluationText ($numericScore)',
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: scoreColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scoreColor, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              color: scoreColor,
              size: 14,
            ),
            SizedBox(width: 4),
            Text(
              numericScore.toString(),
              style: TextStyle(
                color: scoreColor, 
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'حاضر':
        return Colors.green;
      case 'غائب':
        return Colors.red;
      case 'متأخر':
        return Colors.orange;
      case 'منقطع':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'حاضر':
        return Icons.check_circle;
      case 'غائب':
        return Icons.cancel;
      case 'متأخر':
        return Icons.access_time;
      case 'منقطع':
        return Icons.do_not_disturb;
      default:
        return Icons.help;
    }
  }

  Map<String, dynamic> _getStatusInfo(String? status) {
    switch (status) {
      case 'حاضر':
        return {'text': 'حاضر', 'color': Colors.green};
      case 'غائب':
        return {'text': 'غائب', 'color': Colors.red};
      case 'متأخر':
        return {'text': 'متأخر', 'color': Colors.orange};
      case 'منقطع':
        return {'text': 'منقطع', 'color': Colors.purple};
      default:
        return {'text': status ?? 'غير محدد', 'color': Colors.grey};
    }
  }

  Widget _buildContent() {
  if (isLoading) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.blue),
          SizedBox(height: 16),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  if (_errorMessage != null) {
    return _buildErrorWidget();
  }

  if (filteredRecords.isEmpty) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school, size: 80, color: Colors.grey[400]!),
          SizedBox(height: 16),
          Text(
            searchQuery.isEmpty && _selectedFilter == 0
                ? 'لا توجد سجلات تدريب'
                : 'لا توجد نتائج للبحث',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            searchQuery.isEmpty && _selectedFilter == 0
                ? 'انقر على زر (+) لإضافة سجل تدريب جديد'
                : 'حاول البحث بكلمات أخرى',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 20),
          if (searchQuery.isEmpty && _selectedFilter == 0)
            ElevatedButton.icon(
              onPressed: _addNewTrainingRecord,
              icon: Icon(Icons.add),
              label: Text('إضافة سجل تدريب جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
        ],
      ),
    );
  }

  if (_isGridView) {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) => _buildGridItem(filteredRecords[index]),
    );
  } else {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 8),
      itemCount: filteredRecords.length,
      itemBuilder: (context, index) => _buildTrainingCard(filteredRecords[index]),
    );
  }
}
  void _showDeleteDialog(TrainingRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.white),
                SizedBox(width: 8),
                Text('تأكيد الحذف', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          content: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete_forever, size: 48, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'هل تريد حذف سجل التدريب',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  record.personnelName ?? 'غير معروف',
                  style: TextStyle(fontSize: 18, color: Colors.blue, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'هذا الإجراء لا يمكن التراجع عنه',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteTrainingRecord(record);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('حذف', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTrainingRecord(TrainingRecord record) async {
    try {
      await TrainingApi.deleteTrainingRecord(record.id!);
      setState(() {
        trainingRecords.removeWhere((r) => r.id == record.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف سجل التدريب بنجاح'),
          backgroundColor: Colors.green,
        )
      );
    } catch (e) {
      _showErrorSnackBar('خطأ في حذف السجل: $e');
    }
  }

  void _viewTrainingDetails(TrainingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingDetailScreen(record: record),
      ),
    );
  }

  void _editTrainingRecord(TrainingRecord record) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TrainingFormScreen(existingRecord: record),
      ),
    ).then((_) => _loadTrainingData());
  }

  void _addNewTrainingRecord() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TrainingFormScreen()),
    ).then((_) => _loadTrainingData());
  }

  Widget _buildFilterChips() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50]!,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'تصفية حسب الحضور:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]!, fontSize: 12),
              ),
              Spacer(),
              IconButton(
                icon: Icon(
                  _isGridView ? Icons.view_list : Icons.grid_view,
                  color: Colors.blue,
                ),
                onPressed: () {
                  setState(() {
                    _isGridView = !_isGridView;
                  });
                },
                tooltip: _isGridView ? 'عرض جدولي' : 'عرض شبكي',
              ),
            ],
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: Text('الكل (${trainingRecords.length})'),
                selected: _selectedFilter == 0,
                selectedColor: Colors.blue[100]!,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? 0 : _selectedFilter;
                  });
                },
                checkmarkColor: Colors.blue,
              ),
              FilterChip(
                label: Text('حاضر فقط'),
                selected: _selectedFilter == 1,
                selectedColor: Colors.green[100]!,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? 1 : 0;
                  });
                },
                checkmarkColor: Colors.green,
              ),
              FilterChip(
                label: Text('غائب فقط'),
                selected: _selectedFilter == 2,
                selectedColor: Colors.red[100]!,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = selected ? 2 : 0;
                  });
                },
                checkmarkColor: Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('استمارة التدريب والتسليح - استمارة رقم (2)'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) searchQuery = '';
              });
            },
            tooltip: 'بحث',
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addNewTrainingRecord,
            tooltip: 'إضافة سجل تدريب جديد',
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'courses',
                child: Row(
                  children: [
                    Icon(Icons.school, color: Colors.green),
                    SizedBox(width: 8),
                    Text('إدارة الدورات'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_course',
                child: Row(
                  children: [
                    Icon(Icons.add_circle, color: Colors.green),
                    SizedBox(width: 8),
                    Text('إضافة دورة جديدة'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'instructors',
                child: Row(
                  children: [
                    Icon(Icons.person, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('إدارة المدربين'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_instructor',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('إضافة مدرب جديد'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('تحديث البيانات'),
                  ],
                ),
              ),
            ],
            onSelected: (String value) {
              switch (value) {
                case 'refresh':
                  _refreshData();
                  break;
                case 'courses':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrainingCoursesScreen()),
                  );
                  break;
                case 'add_course':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TrainingCourseFormScreen()),
                  );
                  break;
                case 'instructors':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstructorsScreen()),
                  );
                  break;
                case 'add_instructor':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InstructorFormScreen()),
                  );
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Section
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            height: _isSearching ? 80 : 0,
            child: _isSearching
                ? Padding(
                    padding: EdgeInsets.all(16),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'بحث في سجلات التدريب',
                        hintText: 'ابحث بالاسم، الرقم العسكري، أو اسم الدورة...',
                        prefixIcon: Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[50]!,
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                  )
                : SizedBox.shrink(),
          ),

          // Header Info
          if (!isLoading && _errorMessage == null)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50]!,
                border: Border(bottom: BorderSide(color: Colors.blue[100]!)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.school, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'إجمالي السجلات: ${filteredRecords.length}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Chip(
                    label: Text(
                      _isGridView ? 'عرض شبكي' : 'عرض جدولي',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
            ),

          // Filter Chips
          if (!isLoading && _errorMessage == null)
            _buildFilterChips(),

          // Content
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: _errorMessage == null 
          ? FloatingActionButton(
              onPressed: _addNewTrainingRecord,
              child: Icon(Icons.add),
              tooltip: 'إضافة سجل تدريب جديد',
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              elevation: 4,
            )
          : null,
    );
  }
}