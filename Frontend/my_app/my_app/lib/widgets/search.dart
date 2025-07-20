import 'package:ali_grad/constants/theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TaskSearchSection extends StatefulWidget {
  @override
  _TaskSearchSectionState createState() => _TaskSearchSectionState();
}

class _TaskSearchSectionState extends State<TaskSearchSection> {
  final List<String> categories = [
    'All',
    'Moving',
    'Cleaning',
    'Grocery',
    'Delivery',
    'Other',
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  boxShadow: AppTheme.cardShadow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.primaryColor,
                    ),
                    hintText: 'Search tasks near you...',
                    hintStyle: AppTheme.textStyle2,
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        // const SizedBox(height: AppTheme.paddingMedium),
        // SizedBox(
        //   height: 40,
        //   child: ListView.separated(
        //     scrollDirection: Axis.horizontal,
        //     itemCount: categories.length,
        //     separatorBuilder: (_, __) =>
        //         const SizedBox(width: AppTheme.paddingSmall),
        //     itemBuilder: (context, i) {
        //       final isSelected = i == selectedIndex;
        //       return GestureDetector(
        //         onTap: () => setState(() => selectedIndex = i),
        //         child: Container(
        //           padding: const EdgeInsets.symmetric(
        //               horizontal: AppTheme.paddingMedium),
        //           alignment: Alignment.center,
        //           decoration: BoxDecoration(
        //             boxShadow: AppTheme.cardShadow,
        //             color: isSelected
        //                 ? Theme.of(context).primaryColor
        //                 : AppTheme.cardColor,
        //             borderRadius: BorderRadius.circular(64),
        //           ),
        //           child: Text(
        //             categories[i],
        //             style: TextStyle(
        //               color: isSelected
        //                   ? AppTheme.textLightColor
        //                   : AppTheme.textColor,
        //               fontWeight:
        //                   isSelected ? FontWeight.w900 : FontWeight.w400,
        //             ),
        //           ),
        //         ),
        //       );
        //     },
        //   ),
        // ),
      ],
    );
  }
}
