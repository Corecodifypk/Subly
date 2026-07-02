import 'package:flutter/material.dart';

import 'package:provider/provider.dart';



import '../core/constants/asset_paths.dart';

import '../core/theme/app_colors.dart';

import '../providers/app_provider.dart';

import '../widgets/app_icon.dart';

import '../widgets/empty_subscriptions_state.dart';

import '../widgets/subscription_list_with_ads.dart';

import 'subscription_detail_screen.dart';



class AllSubscriptionsScreen extends StatefulWidget {

  const AllSubscriptionsScreen({super.key, this.initialFilter = 'All'});



  final String initialFilter;



  @override

  State<AllSubscriptionsScreen> createState() => _AllSubscriptionsScreenState();

}



class _AllSubscriptionsScreenState extends State<AllSubscriptionsScreen> {

  late String _selectedFilter;

  final _filters = ['All', 'Upcoming', 'Entertainment', 'Music'];



  @override

  void initState() {

    super.initState();

    _selectedFilter = widget.initialFilter;

  }



  @override

  Widget build(BuildContext context) {

    final provider = context.watch<AppProvider>();

    final filtered = provider.getByCategory(_selectedFilter);

    final isTablet = MediaQuery.of(context).size.width > 600;



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

          'All Subscription',

          style: TextStyle(

            fontSize: 24,

            fontWeight: FontWeight.w700,

            color: AppColors.textDark,

          ),

        ),

        titleSpacing: 0,

      ),

      body: Column(

        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

          const SizedBox(height: 8),

          SizedBox(

            height: 40,

            child: ListView.builder(

              scrollDirection: Axis.horizontal,

              padding: EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),

              itemCount: _filters.length,

              itemBuilder: (context, index) {

                final filter = _filters[index];

                final isActive = filter == _selectedFilter;

                return GestureDetector(

                  onTap: () => setState(() => _selectedFilter = filter),

                  child: AnimatedContainer(

                    duration: const Duration(milliseconds: 200),

                    margin: const EdgeInsets.only(right: 10),

                    padding: const EdgeInsets.symmetric(

                      horizontal: 20,

                      vertical: 8,

                    ),

                    decoration: BoxDecoration(

                      color: isActive

                          ? AppColors.filterActiveBg

                          : AppColors.filterInactive,

                      borderRadius: BorderRadius.circular(20),

                    ),

                    child: Text(

                      filter,

                      style: TextStyle(

                        fontSize: 14,

                        fontWeight: FontWeight.w500,

                        color: isActive

                            ? AppColors.filterActiveText

                            : AppColors.textGrey,

                      ),

                    ),

                  ),

                );

              },

            ),

          ),

          const SizedBox(height: 20),

          Expanded(

            child: filtered.isEmpty && _selectedFilter != 'All'

                ? const EmptySubscriptionsState(

                    title: 'No subscriptions found',

                    subtitle: 'Try a different filter or add a new one',

                  )

                : ListView(

                    padding:

                        EdgeInsets.symmetric(horizontal: isTablet ? 32 : 20),

                    children: [

                      SubscriptionListWithAds(

                        subscriptions: filtered,

                        onTap: (sub) =>

                            openSubscriptionDetail(context, sub),

                      ),

                    ],

                  ),

          ),

        ],

      ),

    );

  }

}


