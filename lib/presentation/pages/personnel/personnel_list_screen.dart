// lib/presentation/pages/personnel/personnel_list_screen.dart
import 'package:flutter/material.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_detail_screen.dart';
import 'package:resistance_system_app/presentation/pages/personnel/personnel_form_screen.dart';
import 'package:universal_platform/universal_platform.dart';
import '../../../core/responsive/responsive_layout.dart';
import '../../../core/services/personnel_service.dart';
import '../../../core/services/debug_personnel_service.dart';

class PersonnelListScreen extends StatefulWidget {
  @override
  _PersonnelListScreenState createState() => _PersonnelListScreenState();
}

class _PersonnelListScreenState extends State<PersonnelListScreen> {
  List<dynamic> _personnelList = [];
  List<dynamic> _filteredPersonnelList = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  // بيانات التصنيف الجغرافي الحقيقية من API
  List<dynamic> _states = [];
  List<dynamic> _localities = [];

  // قيم التصفية المحددة
  String _selectedState = 'كل الولايات';
  String _selectedLocality = 'كل المحليات';
  String _selectedStatus = 'جميع';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await DebugPersonnelService.testConnection();
    await _loadGeographicalData(); // جلب البيانات الجغرافية أولاً
    await _loadPersonnel();
  }

  // جلب البيانات الجغرافية من API
  Future<void> _loadGeographicalData() async {
    try {
      print('🗺️ جاري جلب البيانات الجغرافية...');

      // جلب الولايات من API
      final statesData = await PersonnelService.getStates();
      print('✅ الولايات المستلمة: ${statesData.length} ولاية');

      // جلب المحليات من API
      final localitiesData = await PersonnelService.getLocalities();
      print('✅ المحليات المستلمة: ${localitiesData.length} محلية');

      setState(() {
        _states = statesData;
        _localities = localitiesData;
      });
    } catch (e) {
      print('❌ خطأ في جلب البيانات الجغرافية: $e');
      // نستخدم بيانات افتراضية في حالة الخطأ
      setState(() {
        _states = [
          {'state_name': 'ولاية الخرطوم', 'state_code': 'KH'},
          {'state_name': 'ولاية الجزيرة', 'state_code': 'GZ'},
          {'state_name': 'ولاية البحر الأحمر', 'state_code': 'RS'},
        ];
        _localities = [
          {'locality_name': 'محلية الخرطوم', 'state_code': 'KH'},
          {'locality_name': 'محلية شرق النيل', 'state_code': 'KH'},
          {'locality_name': 'محلية أم درمان', 'state_code': 'KH'},
        ];
      });
    }
  }

  Future<void> _loadPersonnel() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      print('🔄 جاري جلب البيانات من API...');
      final data = await PersonnelService.getAllPersonnel();

      print('✅ البيانات المستلمة: ${data.length} عنصر');

      setState(() {
        _personnelList = data;
        _filteredPersonnelList = data; // في البداية نعرض كل البيانات
        _isLoading = false;
      });
    } catch (e) {
      print('❌ خطأ في جلب البيانات: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // تطبيق التصفية على البيانات
  void _applyFilters() {
    List<dynamic> filteredList = _personnelList;

    // التصفية حسب الولاية
    if (_selectedState != 'كل الولايات') {
      filteredList = filteredList.where((personnel) {
        final state = _getField(personnel, 'state');
        return state == _selectedState;
      }).toList();
    }

    // التصفية حسب المحلية
    if (_selectedLocality != 'كل المحليات') {
      filteredList = filteredList.where((personnel) {
        final locality = _getField(personnel, 'locality');
        return locality == _selectedLocality;
      }).toList();
    }

    // التصفية حسب الحالة
    if (_selectedStatus != 'جميع') {
      filteredList = filteredList.where((personnel) {
        final status = _getField(personnel, 'status');
        return status == _selectedStatus;
      }).toList();
    }

    setState(() {
      _filteredPersonnelList = filteredList;
    });
  }

  Future<void> _searchPersonnel(String query) async {
    if (query.isEmpty) {
      setState(() {
        _filteredPersonnelList = _personnelList;
      });
      _applyFilters(); // نطبق التصفية الحالية
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final results = await PersonnelService.searchPersonnel(query);
      setState(() {
        _personnelList = results;
        _filteredPersonnelList = results;
        _isLoading = false;
      });
      _applyFilters(); // نطبق التصفية على نتائج البحث
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _navigateToDetail(dynamic personnelIdValue) {
    // PersonnelDetailScreen expects an int id. Accept dynamic values from API
    // (some endpoints return strings) and parse safely.
    try {
      final idInt = personnelIdValue is int
          ? personnelIdValue
          : int.parse(personnelIdValue?.toString() ?? '');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PersonnelDetailScreen(personnelId: idInt),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('معرّف المستنفر غير صالح')));
    }
  }

  void _navigateToForm() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PersonnelFormScreen()),
    ).then((_) {
      _loadPersonnel();
    });
  }

  // دالة للحصول على قيمة الحقل من البيانات
  String _getField(dynamic personnel, String fieldName) {
    if (personnel is Map) {
      return personnel[fieldName]?.toString() ?? 'غير محدد';
    }
    return 'غير محدد';
  }

  // بناء واجهة الويب
  Widget _buildWebLayout(BuildContext context) {
    return Row(
      children: [
        // الشريط الجانبي للتصفية
        _buildFilterSidebar(context),
        // القائمة الرئيسية
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(context),
                SizedBox(height: 16),
                Expanded(child: _buildPersonnelGrid(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // بناء واجهة الموبايل
  Widget _buildMobileLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSearchBar(context),
          SizedBox(height: 16),
          Expanded(child: _buildPersonnelList(context)),
        ],
      ),
    );
  }

  // الشريط الجانبي للتصفية (للويب) - تم تحديثه
  Widget _buildFilterSidebar(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Container(
      width: isMobile ? 200 : 280,
      color: Colors.grey[50],
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.filter_list, size: 18),
                SizedBox(width: 8),
                Text(
                  'التصنيف الجغرافي',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),

            // تصفية الولايات - بيانات حقيقية من API
            _buildFilterDropdown(
              'الولاية',
              _selectedState,
              ['كل الولايات'] +
                  _states.map((state) {
                    if (state is Map)
                      return state['state_name']?.toString() ??
                          state.toString();
                    return state?.toString() ?? 'غير معروف';
                  }).toList(),
              (value) {
                setState(() {
                  _selectedState = value!;
                });
                _applyFilters();
              },
            ),

            SizedBox(height: 16),

            // تصفية المحليات - بيانات حقيقية من API
            _buildFilterDropdown(
              'المحلية',
              _selectedLocality,
              ['كل المحليات'] +
                  _localities.map((locality) {
                    if (locality is Map)
                      return locality['locality_name']?.toString() ??
                          locality.toString();
                    return locality?.toString() ?? 'غير معروف';
                  }).toList(),
              (value) {
                setState(() {
                  _selectedLocality = value!;
                });
                _applyFilters();
              },
            ),

            SizedBox(height: 16),

            // تصفية الحالة
            _buildFilterDropdown(
              'الحالة',
              _selectedStatus,
              ['جميع', 'نشط', 'غير نشط', 'شهيد', 'جريح'],
              (value) {
                setState(() {
                  _selectedStatus = value!;
                });
                _applyFilters();
              },
            ),

            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),

            // إحصائيات سريعة
            _buildQuickStats(),
          ],
        ),
      ),
    );
  }

  // عنصر التصفية المحدث
  Widget _buildFilterDropdown(
    String title,
    String selectedValue,
    List<String> options,
    ValueChanged<String?> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue,
              isExpanded: true,
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      value,
                      style: TextStyle(fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  // إحصائيات سريعة
  Widget _buildQuickStats() {
    final total = _personnelList.length;
    final filtered = _filteredPersonnelList.length;
    final activeCount = _personnelList
        .where((p) => _getField(p, 'status') == 'نشط')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'إحصائيات سريعة',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        _buildStatItem('إجمالي المستنفرين', total.toString()),
        _buildStatItem('المعروض حالياً', filtered.toString()),
        _buildStatItem('النشطين', activeCount.toString()),
        if (total > 0)
          _buildStatItem(
            'نسبة العرض',
            '${((filtered / total) * 100).toStringAsFixed(1)}%',
          ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  // شريط البحث
  Widget _buildSearchBar(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);

    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12 : 16),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'ابحث بالاسم، الرقم العسكري، أو الرقم القومي...',
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 8),
                ),
                onChanged: _searchPersonnel,
              ),
            ),
            if (isMobile)
              IconButton(
                icon: Icon(Icons.filter_list),
                onPressed: () => _showFilterDialog(context),
                tooltip: 'التصفية',
              ),
          ],
        ),
      ),
    );
  }

  // شبكة العرض (للويب) - محدثة لتعمل مع البيانات المصفاة
  Widget _buildPersonnelGrid(BuildContext context) {
    final bool isMobile = ResponsiveLayout.isMobile(context);

    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_filteredPersonnelList.isEmpty) {
      return _buildEmptyWidget();
    }

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isMobile ? 1 : 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: isMobile ? 1.3 : 1.7,
      ),
      itemCount: _filteredPersonnelList.length,
      itemBuilder: (context, index) {
        return _buildPersonnelCard(_filteredPersonnelList[index], context);
      },
    );
  }

  // قائمة العرض (للموبايل) - محدثة لتعمل مع البيانات المصفاة
  Widget _buildPersonnelList(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorWidget();
    }

    if (_filteredPersonnelList.isEmpty) {
      return _buildEmptyWidget();
    }

    return ListView.builder(
      itemCount: _filteredPersonnelList.length,
      itemBuilder: (context, index) {
        return _buildPersonnelListItem(_filteredPersonnelList[index], context);
      },
    );
  }

  // بطاقة المستنفر (للويب) - محسنة لمنع overflow
  Widget _buildPersonnelCard(dynamic personnel, BuildContext context) {
    String fullName =
        '${_getField(personnel, 'first_name')} ${_getField(personnel, 'second_name')} ${_getField(personnel, 'third_name')} ${_getField(personnel, 'fourth_name')}'
            .trim();
    if (fullName.isEmpty || fullName == 'غير محدد غير محدد غير محدد غير محدد') {
      fullName = 'مستنفر';
    }

    return Card(
      elevation: 3,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _navigateToDetail(_getField(personnel, 'id')),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          constraints: BoxConstraints(minHeight: 200),
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // الجزء العلوي: المعلومات
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // العنوان والحالة
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  height: 1.3,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 4),
                              Text(
                                'الرقم العسكري: ${_getField(personnel, 'military_id')}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(
                              _getField(personnel, 'status'),
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getField(personnel, 'status'),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12),

                    // المعلومات الجغرافية
                    _buildInfoChip(
                      '📍',
                      'الولاية',
                      _getField(personnel, 'state'),
                    ),
                    _buildInfoChip(
                      '🏘️',
                      'المحلية',
                      _getField(personnel, 'locality'),
                    ),
                    _buildInfoChip('⭐', 'الرتبة', _getField(personnel, 'rank')),
                    _buildInfoChip(
                      '🔰',
                      'الوحدة',
                      _getField(personnel, 'unit'),
                    ),

                    SizedBox(height: 8),

                    // معلومات إضافية
                    if (_getField(personnel, 'national_id') != 'غير محدد')
                      Text(
                        'الرقم القومي: ${_getField(personnel, 'national_id')}',
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                  ],
                ),
              ),

              // زر التفاصيل
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _navigateToDetail(_getField(personnel, 'id')),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    backgroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: Text(
                    'عرض التفاصيل',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // دالة مساعدة للحصول على لون الحالة
  Color _getStatusColor(String status) {
    switch (status) {
      case 'نشط':
        return Colors.green;
      case 'غير نشط':
        return Colors.orange;
      case 'شهيد':
        return Colors.red;
      case 'جريح':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  // شريط المعلومات المضغوط
  Widget _buildInfoChip(String emoji, String label, String value) {
    if (value.isEmpty || value == 'غير محدد') return SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$emoji ', style: TextStyle(fontSize: 12)),
          Expanded(
            child: Text(
              '$label: $value',
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // عنصر قائمة المستنفر (للموبايل)
  Widget _buildPersonnelListItem(dynamic personnel, BuildContext context) {
    String fullName =
        '${_getField(personnel, 'first_name')} ${_getField(personnel, 'second_name')} ${_getField(personnel, 'third_name')} ${_getField(personnel, 'fourth_name')}'
            .trim();
    if (fullName.isEmpty || fullName == 'غير محدد غير محدد غير محدد غير محدد') {
      fullName = 'مستنفر';
    }

    return Card(
      margin: EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(
            _getField(personnel, 'status'),
          ).withOpacity(0.2),
          foregroundColor: _getStatusColor(_getField(personnel, 'status')),
          child: Text(
            _getField(personnel, 'military_id').isNotEmpty
                ? _getField(personnel, 'military_id').substring(0, 1)
                : '?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(fullName, style: TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getField(personnel, 'state')} - ${_getField(personnel, 'locality')}',
            ),
            Text(
              'الرقم العسكري: ${_getField(personnel, 'military_id')}',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _navigateToDetail(_getField(personnel, 'id')),
      ),
    );
  }

  // واجهة الخطأ
  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              'حدث خطأ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPersonnel,
              icon: Icon(Icons.refresh),
              label: Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  // واجهة لا توجد بيانات
  Widget _buildEmptyWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'لا توجد بيانات',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              _selectedState != 'كل الولايات' ||
                      _selectedLocality != 'كل المحليات' ||
                      _selectedStatus != 'جميع'
                  ? 'لا توجد نتائج تطابق معايير التصفية المحددة'
                  : 'انقر على زر + لإضافة مستنفر جديد',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500]),
            ),
            SizedBox(height: 16),
            if (_selectedState != 'كل الولايات' ||
                _selectedLocality != 'كل المحليات' ||
                _selectedStatus != 'جميع')
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedState = 'كل الولايات';
                    _selectedLocality = 'كل المحليات';
                    _selectedStatus = 'جميع';
                  });
                  _applyFilters();
                },
                child: Text('إعادة تعيين التصفية'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isWeb = UniversalPlatform.isWeb;

    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة المستنفرين'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _navigateToForm,
            tooltip: 'إضافة مستنفر جديد',
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _showSearchDialog(context),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadPersonnel,
            tooltip: 'تحديث البيانات',
          ),
        ],
      ),
      body: isWeb ? _buildWebLayout(context) : _buildMobileLayout(context),
      floatingActionButton: !isWeb
          ? FloatingActionButton(
              onPressed: _navigateToForm,
              child: Icon(Icons.add),
              tooltip: 'إضافة مستنفر جديد',
            )
          : null,
    );
  }

  void _showSearchDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('بحث متقدم'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'البحث بالاسم أو الرقم العسكري',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _searchPersonnel(_searchController.text);
              Navigator.pop(context);
            },
            child: Text('بحث'),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تصفية النتائج'),
        content: Container(
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFilterDropdown(
                'الولاية',
                _selectedState,
                ['كل الولايات'] +
                    _states.map((state) {
                      if (state is Map)
                        return state['state_name']?.toString() ??
                            state.toString();
                      return state?.toString() ?? 'غير معروف';
                    }).toList(),
                (value) {
                  setState(() {
                    _selectedState = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildFilterDropdown(
                'المحلية',
                _selectedLocality,
                ['كل المحليات'] +
                    _localities.map((locality) {
                      if (locality is Map)
                        return locality['locality_name']?.toString() ??
                            locality.toString();
                      return locality?.toString() ?? 'غير معروف';
                    }).toList(),
                (value) {
                  setState(() {
                    _selectedLocality = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              _buildFilterDropdown(
                'الحالة',
                _selectedStatus,
                ['جميع', 'نشط', 'غير نشط', 'شهيد', 'جريح'],
                (value) {
                  setState(() {
                    _selectedStatus = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              _applyFilters();
              Navigator.pop(context);
            },
            child: Text('تطبيق التصفية'),
          ),
        ],
      ),
    );
  }
}
