import 'dart:io';



import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../core/constants/asset_paths.dart';

import '../core/theme/app_colors.dart';

import '../providers/app_provider.dart';

import '../widgets/app_icon.dart';

import '../widgets/glass_surface.dart';



class ProfileNameScreen extends StatefulWidget {

  const ProfileNameScreen({super.key});



  @override

  State<ProfileNameScreen> createState() => _ProfileNameScreenState();

}



class _ProfileNameScreenState extends State<ProfileNameScreen> {

  late TextEditingController _nameController;

  late TextEditingController _greetingController;



  @override

  void initState() {

    super.initState();

    final profile = context.read<AppProvider>().profile;

    _nameController = TextEditingController(text: profile.name);

    _greetingController = TextEditingController(text: profile.greeting);

  }



  @override

  void dispose() {

    _nameController.dispose();

    _greetingController.dispose();

    super.dispose();

  }



  Future<void> _save() async {

    final provider = context.read<AppProvider>();

    await provider.updateProfile(

      name: _nameController.text.trim(),

      greeting: _greetingController.text.trim(),

    );

    if (mounted) Navigator.pop(context);

  }



  @override

  Widget build(BuildContext context) {

    final provider = context.watch<AppProvider>();



    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(

        backgroundColor: AppColors.background,

        elevation: 0,

        leading: IconButton(

          icon: const AppIcon(

            assetPath: AssetPaths.chevronLeft,

            fallback: Icons.arrow_back_ios,

            size: 20,

          ),

          onPressed: () => Navigator.pop(context),

        ),

        title: const Text(

          'Profile',

          style: TextStyle(

            fontSize: 20,

            fontWeight: FontWeight.w700,

            color: AppColors.textDark,

          ),

        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            GestureDetector(

              onTap: () => provider.pickAndCropProfileImage(),

              child: Stack(

                children: [

                  Container(

                    width: 110,

                    height: 110,

                    decoration: BoxDecoration(

                      shape: BoxShape.circle,

                      color: AppColors.inputBackground,

                      image: provider.profile.profileImagePath != null

                          ? DecorationImage(

                              image: FileImage(

                                File(provider.profile.profileImagePath!),

                              ),

                              fit: BoxFit.cover,

                            )

                          : null,

                    ),

                    child: provider.profile.profileImagePath == null

                        ? const Icon(

                            Icons.person,

                            size: 48,

                            color: AppColors.textGrey,

                          )

                        : null,

                  ),

                  Positioned(

                    right: 0,

                    bottom: 0,

                    child: Container(

                      width: 34,

                      height: 34,

                      decoration: BoxDecoration(

                        color: AppColors.primaryPurple,

                        shape: BoxShape.circle,

                        border: Border.all(color: Colors.white, width: 2),

                      ),

                      child: const Icon(

                        Icons.camera_alt,

                        size: 16,

                        color: Colors.white,

                      ),

                    ),

                  ),

                ],

              ),

            ),

            const SizedBox(height: 10),

            const Text(

              'Tap photo to select and crop',

              style: TextStyle(fontSize: 13, color: AppColors.textGrey),

            ),

            const SizedBox(height: 28),

            const Align(

              alignment: Alignment.centerLeft,

              child: Text(

                'Greeting',

                style: TextStyle(fontSize: 14, color: AppColors.textGrey),

              ),

            ),

            const SizedBox(height: 8),

            _inputField(_greetingController, 'e.g. Slam'),

            const SizedBox(height: 20),

            const Align(

              alignment: Alignment.centerLeft,

              child: Text(

                'Your Name',

                style: TextStyle(fontSize: 14, color: AppColors.textGrey),

              ),

            ),

            const SizedBox(height: 8),

            _inputField(_nameController, 'e.g. Tysen Don'),

            const Spacer(),

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

                child: const Text(

                  'Save Profile',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),

                ),

              ),

            ),

            const SizedBox(height: 24),

          ],

        ),

      ),

    );

  }



  Widget _inputField(TextEditingController controller, String hint) {

    return Container(

      height: 52,

      padding: const EdgeInsets.symmetric(horizontal: 20),

      decoration: BoxDecoration(

        color: AppColors.inputBackground,

        borderRadius: BorderRadius.circular(26),

      ),

      child: TextField(

        controller: controller,

        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),

        decoration: InputDecoration(

          hintText: hint,

          border: InputBorder.none,

          hintStyle: const TextStyle(color: AppColors.textLightGrey),

        ),

      ),

    );

  }

}



class BudgetScreen extends StatefulWidget {

  const BudgetScreen({super.key});



  @override

  State<BudgetScreen> createState() => _BudgetScreenState();

}



class _BudgetScreenState extends State<BudgetScreen> {

  late TextEditingController _controller;



  @override

  void initState() {

    super.initState();

    _controller = TextEditingController(

      text: context.read<AppProvider>().profile.monthlyBudget.toStringAsFixed(0),

    );

  }



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    final provider = context.watch<AppProvider>();

    final spending = provider.totalMonthlySpending;

    final budget = provider.profile.monthlyBudget;

    final remaining = budget - spending;

    final progress = budget > 0 ? (spending / budget).clamp(0.0, 1.0) : 0.0;



    return Scaffold(

      backgroundColor: AppColors.background,

      appBar: AppBar(

        backgroundColor: AppColors.background,

        elevation: 0,

        leading: IconButton(

          icon: const AppIcon(

            assetPath: AssetPaths.chevronLeft,

            fallback: Icons.arrow_back_ios,

            size: 20,

          ),

          onPressed: () => Navigator.pop(context),

        ),

        title: const Text(

          'Monthly Budget',

          style: TextStyle(

            fontSize: 20,

            fontWeight: FontWeight.w700,

            color: AppColors.textDark,

          ),

        ),

      ),

      body: Padding(

        padding: const EdgeInsets.all(20),

        child: Column(

          children: [

            SoftCard(

              borderRadius: 24,

              padding: const EdgeInsets.all(24),

              child: Column(

                children: [

                  Text(

                    '\$${budget.toStringAsFixed(0)}',

                    style: const TextStyle(

                      fontSize: 42,

                      fontWeight: FontWeight.w800,

                      color: AppColors.textDark,

                      letterSpacing: -1,

                    ),

                  ),

                  const Text(

                    'Monthly budget',

                    style: TextStyle(fontSize: 14, color: AppColors.textGrey),

                  ),

                  const SizedBox(height: 24),

                  ClipRRect(

                    borderRadius: BorderRadius.circular(8),

                    child: LinearProgressIndicator(

                      value: progress,

                      minHeight: 8,

                      backgroundColor: AppColors.inputBackground,

                      color: progress > 0.9

                          ? AppColors.trendRed

                          : AppColors.primaryPurple,

                    ),

                  ),

                  const SizedBox(height: 12),

                  Row(

                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [

                      Text(

                        'Spent: \$${spending.toStringAsFixed(2)}',

                        style: const TextStyle(

                          fontSize: 13,

                          color: AppColors.textGrey,

                        ),

                      ),

                      Text(

                        'Left: \$${remaining.toStringAsFixed(2)}',

                        style: TextStyle(

                          fontSize: 13,

                          fontWeight: FontWeight.w600,

                          color: remaining >= 0

                              ? AppColors.activeGreen

                              : AppColors.trendRed,

                        ),

                      ),

                    ],

                  ),

                ],

              ),

            ),

            const SizedBox(height: 24),

            const Align(

              alignment: Alignment.centerLeft,

              child: Text(

                'Set new budget',

                style: TextStyle(fontSize: 14, color: AppColors.textGrey),

              ),

            ),

            const SizedBox(height: 8),

            Container(

              height: 52,

              padding: const EdgeInsets.symmetric(horizontal: 20),

              decoration: BoxDecoration(

                color: AppColors.inputBackground,

                borderRadius: BorderRadius.circular(26),

              ),

              child: Row(

                children: [

                  const Text(

                    '\$',

                    style: TextStyle(

                      fontSize: 18,

                      fontWeight: FontWeight.w700,

                    ),

                  ),

                  Expanded(

                    child: TextField(

                      controller: _controller,

                      keyboardType:

                          const TextInputType.numberWithOptions(decimal: true),

                      style: const TextStyle(fontSize: 16),

                      decoration: const InputDecoration(

                        border: InputBorder.none,

                        hintText: '500',

                      ),

                    ),

                  ),

                ],

              ),

            ),

            const Spacer(),

            SizedBox(

              width: double.infinity,

              height: 52,

              child: ElevatedButton(

                onPressed: () async {

                  final value = double.tryParse(_controller.text);

                  if (value != null) {

                    await provider.updateBudget(value);

                    if (!context.mounted) return;

                    Navigator.pop(context);

                  }

                },

                style: ElevatedButton.styleFrom(

                  backgroundColor: AppColors.primaryPurple,

                  foregroundColor: Colors.white,

                  shape: RoundedRectangleBorder(

                    borderRadius: BorderRadius.circular(26),

                  ),

                  elevation: 0,

                ),

                child: const Text(

                  'Save Budget',

                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),

                ),

              ),

            ),

            const SizedBox(height: 24),

          ],

        ),

      ),

    );

  }

}


