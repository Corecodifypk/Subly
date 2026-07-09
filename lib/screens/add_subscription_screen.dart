import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/asset_paths.dart';
import '../core/theme/app_colors.dart';
import '../models/subscription.dart';
import '../providers/app_provider.dart';
import '../services/brand_icon_service.dart';
import '../widgets/app_icon.dart';
import '../widgets/brand_icon.dart';
import '../widgets/bottom_nav_bar.dart';
import '../services/unity_ads_instances.dart';
import '../services/ad_loading_overlay.dart';
import '../utils/feedback_utils.dart';

class AddSubscriptionScreen extends StatefulWidget {
  const AddSubscriptionScreen({super.key, this.subscription});

  final Subscription? subscription;

  bool get isEditing => subscription != null;

  @override
  State<AddSubscriptionScreen> createState() => _AddSubscriptionScreenState();
}

class _AddSubscriptionScreenState extends State<AddSubscriptionScreen> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController(text: '0.00');
  String _billingCycle = 'Monthly';
  late DateTime _nextPaymentDate;

  @override
  void initState() {
    super.initState();
    final sub = widget.subscription;
    if (sub != null) {
      _nameController.text = sub.name;
      _amountController.text = sub.amount.toStringAsFixed(2);
      _billingCycle = sub.billingCycle;
      _nextPaymentDate = sub.nextPaymentDate;
    } else {
      _nextPaymentDate = DateTime.now().add(const Duration(days: 30));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextPaymentDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryPurple,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _nextPaymentDate = picked);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text);
    if (name.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    final category = _guessCategory(name);
    final provider = context.read<AppProvider>();
    final navigator = Navigator.of(context);

    await AdLoadingOverlay.runBeforeShow(
      context: context,
      showAd: () => actionInterstitial.showAndWait(onClosed: () {}),
    );

    if (widget.isEditing) {
      final updated = widget.subscription!.copyWith(
        name: name,
        planName: _billingCycle == 'Monthly'
            ? 'Premium Subscription'
            : 'Annual Subscription',
        amount: amount,
        billingCycle: _billingCycle,
        nextPaymentDate: _nextPaymentDate,
        category: category,
      );
      await provider.updateSubscription(updated);
      if (mounted) {
        showTopSnackBar(context, 'Subscription updated successfully');
      }
    } else {
      final sub = Subscription(
        id: const Uuid().v4(),
        name: name,
        planName: _billingCycle == 'Monthly'
            ? 'Premium Subscription'
            : 'Annual Subscription',
        amount: amount,
        billingCycle: _billingCycle,
        nextPaymentDate: _nextPaymentDate,
        category: category,
      );
      await provider.addSubscription(sub);
      if (provider.subscriptions.length >= 2 && !provider.hasRatedApp) {
        provider.triggerReviewPrompt();
      }
      if (mounted) {
        showTopSnackBar(context, 'Subscription added successfully');
      }
    }
    navigator.pop();
  }

  String _guessCategory(String name) {
    final lower = name.toLowerCase();
    if (['spotify', 'apple music', 'music'].any(lower.contains)) {
      return 'Music';
    }
    if ([
      'netflix',
      'hulu',
      'disney',
      'hbo',
      'youtube',
      'prime',
    ].any(lower.contains)) {
      return 'Entertainment';
    }
    return 'All';
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final maxWidth = isTablet ? 600.0 : double.infinity;
    final serviceName = _nameController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.isEditing ? 'Edit Subscription' : 'Add Subscription',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        titleSpacing: 0,
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: -1,
        activeLabel: null,
        onTap: (index) {
          Navigator.pop(context);
          context.read<AppProvider>().setTabIndex(index);
        },
        onFabTap: _save,
        showAddSubsFab: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (serviceName.isNotEmpty) ...[
                  Center(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.8, end: 1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutBack,
                      builder: (context, value, child) {
                        return Transform.scale(scale: value, child: child);
                      },
                      child: BrandIcon(name: serviceName, size: 64),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                _buildLabel('Service Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. Netflix, YouTube',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: BrandIconService.suggestions.map((s) {
                    return GestureDetector(
                      onTap: () {
                        _nameController.text = s;
                        setState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.inputBackground,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          s,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                _buildLabel('Amount'),
                _buildTextField(
                  controller: _amountController,
                  hint: '0.00',
                  prefix: '\$',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                  ],
                ),
                const SizedBox(height: 24),
                _buildLabel('Billing Cycle'),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    children: [
                      _cycleButton('Monthly'),
                      _cycleButton('Yearly'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildLabel('Next Payment Date'),
                GestureDetector(
                  onTap: _pickDate,
                  child: Container(
                    height: 52,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(26),
                    ),
                    child: Row(
                      children: [
                        const AppIcon(
                          assetPath: AssetPaths.calendarDate,
                          fallback: Icons.calendar_today_outlined,
                          size: 20,
                          color: AppColors.textBlack,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          DateFormat('d MMM yyyy').format(_nextPaymentDate),
                          style: const TextStyle(
                            fontSize: 15,
                            color: AppColors.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      widget.isEditing ? 'Update Subscription' : 'Save Subscription',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _cycleButton(String cycle) {
    final isActive = _billingCycle == cycle;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _billingCycle = cycle),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryPurpleLight : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              cycle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? AppColors.primaryPurpleDark
                    : AppColors.textGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textGrey,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          if (prefix != null)
            Text(
              prefix,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textDark,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textLightGrey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
