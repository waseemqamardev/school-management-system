import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/school_constants.dart';
import '../models/student_model.dart';
import '../providers/auth_provider.dart';
import '../providers/parent_provider.dart';

class LinkChildDialog extends StatefulWidget {
  const LinkChildDialog({super.key});

  @override
  State<LinkChildDialog> createState() => _LinkChildDialogState();
}

class _LinkChildDialogState extends State<LinkChildDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _uniqueCodeController = TextEditingController();
  final _rollNumberController = TextEditingController();
  String? _selectedClassId;
  Student? _verifiedStudent;
  bool _isSearching = false;
  String? _searchError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    final parentProvider = context.read<ParentProvider>();
    if (parentProvider.availableClasses.isNotEmpty) {
      _selectedClassId = parentProvider.availableClasses.first.classId;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _uniqueCodeController.dispose();
    _rollNumberController.dispose();
    super.dispose();
  }

  // 1. Search by Unique ID (Primary & Versatile Mode)
  void _searchByUniqueCode([String? codeToUse]) async {
    final code = (codeToUse ?? _uniqueCodeController.text).trim();
    if (code.isEmpty) {
      setState(() => _searchError = 'Please enter a Student Unique Link ID.');
      return;
    }

    if (codeToUse != null) {
      _uniqueCodeController.text = codeToUse;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _verifiedStudent = null;
    });

    final parentProvider = context.read<ParentProvider>();
    final student = await parentProvider.verifyStudentByUniqueCode(code);

    if (mounted) {
      setState(() {
        _isSearching = false;
        if (student != null) {
          _verifiedStudent = student;
          _searchError = null;
        } else {
          _searchError = 'No active student found with Link ID "$code". Please check the admission card or code issued by school.';
        }
      });
    }
  }

  // 2. Search by Class & Roll Number (Fallback Alternative Mode)
  void _searchByClassAndRoll() async {
    final roll = _rollNumberController.text.trim();
    if (roll.isEmpty || _selectedClassId == null) {
      setState(() => _searchError = 'Please select a class and enter roll number.');
      return;
    }

    setState(() {
      _isSearching = true;
      _searchError = null;
      _verifiedStudent = null;
    });

    final parentProvider = context.read<ParentProvider>();
    final student = await parentProvider.verifyStudent(
      rollNumber: roll,
      classId: _selectedClassId!,
    );

    if (mounted) {
      setState(() {
        _isSearching = false;
        if (student != null) {
          _verifiedStudent = student;
          _searchError = null;
        } else {
          _searchError = 'No student found with Roll #$roll in the selected class.';
        }
      });
    }
  }

  void _confirmLink() async {
    if (_verifiedStudent == null) return;
    final auth = context.read<AuthProvider>();
    final parentProvider = context.read<ParentProvider>();
    final userId = auth.currentUser?.userId;

    if (userId == null) return;

    final success = await parentProvider.linkChildByUniqueCode(
      parentUserId: userId,
      code: _verifiedStudent!.linkCode,
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${_verifiedStudent!.name} (ID: ${_verifiedStudent!.linkCode}) connected to your portal!',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.present,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else {
        setState(() {
          _searchError = parentProvider.errorMessage ?? 'Failed to connect student.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentProvider = context.watch<ParentProvider>();
    final classes = parentProvider.availableClasses;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.vpn_key_rounded, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Connect Student',
                          style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          'Link via unique school access code or class lookup',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Segmented Tab Selector (Unique ID vs Class & Roll)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 12),
                  unselectedLabelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 12),
                  tabs: const [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.qr_code_rounded, size: 16),
                          SizedBox(width: 6),
                          Text('Unique Link ID'),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.badge_outlined, size: 16),
                          SizedBox(width: 6),
                          Text('Class & Roll #'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Tab 1: Unique Student ID Mode
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) {
                  if (_tabController.index == 0) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Enter Student Unique ID / Link Key',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _uniqueCodeController,
                                textCapitalization: TextCapitalization.characters,
                                style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w700, letterSpacing: 1.2),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. ARQ-8A-01, ARQ-8A-05',
                                  prefixIcon: Icon(Icons.key_rounded, color: AppColors.primary),
                                ),
                                onFieldSubmitted: (_) => _searchByUniqueCode(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _isSearching ? null : () => _searchByUniqueCode(),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                backgroundColor: AppColors.primary,
                              ),
                              child: _isSearching
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                    )
                                  : Text('Verify', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),

                        // Quick Test Demo Chips
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildQuickChip('ARQ-8A-01', 'Ali Khan'),
                            _buildQuickChip('ARQ-8A-02', 'Sana Ahmed'),
                            _buildQuickChip('ARQ-8A-05', 'Hamza Ali'),
                            _buildQuickChip('ARQ-8A-06', 'Fatima Khan'),
                          ],
                        ),
                      ],
                    );
                  } else {
                    // Tab 2: Class & Roll Number Mode
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Class & Section',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          initialValue: _selectedClassId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                          ),
                          items: classes.map((c) {
                            return DropdownMenuItem(
                              value: c.classId,
                              child: Text(
                                c.displayName,
                                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 13.5),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedClassId = val;
                                _verifiedStudent = null;
                                _searchError = null;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Student Roll Number',
                          style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _rollNumberController,
                                keyboardType: TextInputType.text,
                                style: GoogleFonts.plusJakartaSans(fontSize: 14),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. 01, 05, 08',
                                  prefixIcon: Icon(Icons.badge_outlined),
                                ),
                                onFieldSubmitted: (_) => _searchByClassAndRoll(),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _isSearching ? null : _searchByClassAndRoll,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                backgroundColor: AppColors.primary,
                              ),
                              child: _isSearching
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation(Colors.white)),
                                    )
                                  : Text('Verify', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5)),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),
              const SizedBox(height: 14),

              // Search Error Message
              if (_searchError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade300),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded, color: Colors.red.shade700, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _searchError!,
                          style: GoogleFonts.plusJakartaSans(fontSize: 12, color: Colors.red.shade900, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 250.ms).shake(duration: 250.ms),
                const SizedBox(height: 14),
              ],

              // Verified Student Card Preview
              if (_verifiedStudent != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.presentLight,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.present.withAlpha(140), width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.goldAccent, width: 2),
                            ),
                            child: CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.white,
                              backgroundImage: AssetImage(SchoolConstants.getStudentAvatar(_verifiedStudent!.name)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        _verifiedStudent!.name,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16.5,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.verified_rounded, color: AppColors.present, size: 20),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'ID: ${_verifiedStudent!.linkCode}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10.5,
                                          color: Colors.white,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Roll #${_verifiedStudent!.rollNumber} • Class 8-A',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 11.5,
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: parentProvider.isLoading ? null : _confirmLink,
                          icon: const Icon(Icons.link_rounded, size: 18),
                          label: Text(
                            'Connect ${_verifiedStudent!.name.split(' ').first} to My Portal',
                            style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickChip(String code, String name) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _searchByUniqueCode(code),
        borderRadius: BorderRadius.circular(8),
        splashColor: AppColors.rippleBlue,
        highlightColor: AppColors.rippleYellow.withAlpha(35),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary.withAlpha(40)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.touch_app_rounded, size: 12, color: AppColors.primary),
              const SizedBox(width: 4),
              Text(
                '$code ($name)',
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
