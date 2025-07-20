import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hugeicons/hugeicons.dart';
import '../constants/theme.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AppTheme.paddingHuge,
                horizontal: AppTheme.paddingLarge,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // SvgPicture.asset(
                  //   "assets/svg/logo.svg",
                  //   height: 120,
                  //   width: 120,
                  // ),
                  const SizedBox(height: 8),
                  Text(
                    "GIGS",
                    style: AppTheme.textStyle0.copyWith(fontSize: 32),
                  ),
                  Spacer(),
                  Image.asset(
                    'assets/images/get_started1.png',
                    height: constraints.maxHeight * 0.3,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Get Things Done\nNear You',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Find help or offer your skills easily,\nright from your neighborhood.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Spacer(),
                  // Bottom buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(color: AppTheme.lightAccentColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppTheme.primaryColor),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/register');
                      },
                      child: Text(
                        'Register',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
