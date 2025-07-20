import 'package:ali_grad/services/user_service.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:ali_grad/widgets/submit_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/theme.dart';
import '../../widgets/my_box.dart';
import '../../widgets/inputBox.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  UserService userService = UserService();
  final firstnameController = TextEditingController();
  final lastnameController = TextEditingController();
  final phoneController = TextEditingController();

  void updateUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final success = await userService.updateUserById(
      userId: userId!,
      firstName: firstnameController.text.trim(),
      lastName: lastnameController.text.trim(),
      phoneNumber: phoneController.text.trim(),
    );

    if (success) {
      Navigator.pushNamed(context, "/profile");
    }
  }

  @override
  void dispose() {
    super.dispose();
    firstnameController.dispose();
    lastnameController.dispose();
    phoneController.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUserData();
  }

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId != null) {
      final user = await userService.getUserById(userId);
      if (user != null) {
        setState(() {
          firstnameController.text = user.firstName;
          lastnameController.text = user.lastName;
          phoneController.text = user.phoneNumber;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Manage Profile",
        showBackButton: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(50),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MyBox(
              boxPadding: AppTheme.paddingMedium,
              boxChild: Column(
                children: [
                  InputBox(
                    obscure: false,
                    label: "First name",
                    hintText: "Mohamed",
                    controller: firstnameController,
                  ),
                  SizedBox(
                    height: AppTheme.paddingLarge,
                  ),
                  InputBox(
                    obscure: false,
                    label: "Last name",
                    hintText: "Mohamed",
                    controller: lastnameController,
                  ),
                  SizedBox(
                    height: AppTheme.paddingLarge,
                  ),
                  InputBox(
                    obscure: false,
                    label: "Phone",
                    hintText: "Enter your Phone",
                    controller: phoneController,
                  ),
                  SizedBox(
                    height: AppTheme.paddingLarge,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppTheme.paddingLarge,
            ),
            SubmitButton(
              text: "Save",
              onPressed: updateUser,
            ),
          ],
        ),
      ),
    );
  }
}
