import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/theme.dart';

class GreetingBanner extends StatefulWidget {
  final String? location;
  final double? customHeight;

  const GreetingBanner({
    Key? key,
    this.location,
    this.customHeight,
  }) : super(key: key);

  @override
  State<GreetingBanner> createState() => _GreetingBannerState();
}

class _GreetingBannerState extends State<GreetingBanner> {
  String username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final fetchedUsername = prefs.getString('username') ?? 'User';
    setState(() {
      username = fetchedUsername;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Hi, $username",
          style: AppTheme.textStyle0,
        ),
        Text(
          "${_getGreeting()}",
          style: AppTheme.textStyle2,
        )
        // const SizedBox(height: 4),
        // Container(
        //   height: 60,
        //   width: 40,
        //   padding: const EdgeInsets.all(AppTheme.paddingSmall),
        //   decoration: BoxDecoration(
        //     borderRadius: BorderRadius.circular(AppTheme.paddingLarge),
        //     color: AppTheme.primaryColor.withOpacity(0.3),
        //   ),
        //   child: const Icon(
        //     FontAwesomeIcons.solidBell,
        //     color: AppTheme.primaryColor,
        //   ),
        // )
      ],
    );
  }
}
