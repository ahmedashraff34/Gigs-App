import 'package:ali_grad/constants/theme.dart';
import 'package:ali_grad/services/user_service.dart';
import 'package:ali_grad/services/task_service.dart';
import 'package:ali_grad/widgets/app_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../utils/cloudinary.dart';

import '../../widgets/my_box.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserService userService = UserService();
  TaskService taskService = TaskService();
  String firstName = "";
  String lastName = "";
  String role = "";
  String userInitials = "";
  double balance = 0.0;
  int completedTasksCount = 0;
  String? profileUrl;

  bool isLoading = true;
  bool isLoadingTasks = true;

  final ImagePicker _picker = ImagePicker();

  bool _isCloudinaryImage(String? url) {
    return url != null && url.contains('res.cloudinary.com');
  }

  Future<void> _pickAndUploadProfileImage() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pick from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        // Delete old image if it exists and is a Cloudinary image
        if (_isCloudinaryImage(profileUrl)) {
          final oldPublicId = CloudinaryService.extractPublicId(profileUrl!);
          if (oldPublicId.isNotEmpty) {
            await CloudinaryService.deleteImageFromCloudinary(oldPublicId);
          }
        }
        File imageFile = File(pickedFile.path);
        String? uploadedUrl = await CloudinaryService.uploadImageToCloudinary(imageFile);
        if (uploadedUrl != null) {
          final prefs = await SharedPreferences.getInstance();
          final userId = prefs.getString('userId');
          if (userId != null) {
            bool success = await userService.updateProfileUrl(userId: userId, profileUrl: uploadedUrl);
            if (success) {
              setState(() {
                profileUrl = uploadedUrl;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profile image updated!')),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Failed to update profile image.')),
              );
            }
          }
        }
      }
    }
  }

  void getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    final userData = await userService.getUserById(userId!);

    if (userData != null) {
      setState(() {
        firstName = userData.firstName;
        lastName = userData.lastName;
        userInitials = "${firstName[0]} ${lastName[0]}";
        role = prefs.getString('role')!;
        balance = userData.balance;
        profileUrl = userData.profileUrl;
        isLoading = false;
      });

      // Fetch completed tasks count after user data is loaded
      getCompletedTasksCount(userId);
    } else {
      isLoading = false;
      Navigator.pop(context);
    }
  }

  void getCompletedTasksCount(String userId) async {
    try {
      final userIdInt = int.tryParse(userId);
      if (userIdInt != null) {
        final count = await taskService.countCompletedTasksForUser(userIdInt);
        if (mounted) {
          setState(() {
            completedTasksCount = count;
            isLoadingTasks = false;
          });
        }
      }
    } catch (e) {
      print('❌ Error fetching completed tasks count: $e');
      if (mounted) {
        setState(() {
          isLoadingTasks = false;
        });
      }
    }
  }

  void changeRole() async {
    String selectedRole = role == "runner" ? "poster" : "runner";

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('role', selectedRole);
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/$selectedRole-home", // route name
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void logout() async {
    await userService.logoutUser();
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/login', // route name
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Profile",
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(AppTheme.paddingHuge),
              child: Column(
                children: [
                  Expanded(
                    flex: 4,
                    child: MyBox(
                      backgroundColor: AppTheme.primaryColor,
                      boxPadding: 0,
                      boxChild: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _pickAndUploadProfileImage,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                profileUrl != null && profileUrl!.isNotEmpty
                                    ? CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.white,
                                        backgroundImage: NetworkImage(profileUrl!),
                                      )
                                    : CircleAvatar(
                                        radius: 48,
                                        backgroundColor: Colors.white,
                                        child: Text(
                                          userInitials,
                                          style: AppTheme.textStyle0.copyWith(fontSize: 32),
                                        ),
                                      ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppTheme.paddingMedium,
                          ),
                          Text(
                            "$firstName $lastName",
                            style: AppTheme.textStyle0.copyWith(
                                color: AppTheme.textColor2, fontSize: 26),
                          ),
                          SizedBox(
                            height: AppTheme.paddingMedium,
                          ),
                          Text(role,
                              style: AppTheme.textStyle2.copyWith(
                                color: AppTheme.disabledColor,
                              )),
                          SizedBox(
                            height: AppTheme.paddingMedium,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                children: [
                                  isLoadingTasks
                                      ? SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppTheme.textColor2,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          completedTasksCount.toString(),
                                          style: AppTheme.textStyle0.copyWith(
                                              color: AppTheme.textColor2),
                                        ),
                                  SizedBox(
                                    height: AppTheme.paddingSmall,
                                  ),
                                  Text(
                                    "Task Done",
                                    style: AppTheme.textStyle2.copyWith(
                                        color: AppTheme.disabledColor),
                                  )
                                ],
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Container(
                                width: 1,
                                height: 48,
                                color: AppTheme.dividerColor,
                              ),
                              SizedBox(
                                width: 40,
                              ),
                              Column(
                                children: [
                                  Text(
                                    balance.toStringAsFixed(2),
                                    style: AppTheme.textStyle0
                                        .copyWith(color: AppTheme.textColor2),
                                  ),
                                  SizedBox(
                                    height: AppTheme.paddingSmall,
                                  ),
                                  Text(
                                    role == "poster" ? "Balance" : "Earnings",
                                    style: AppTheme.textStyle2.copyWith(
                                        color: AppTheme.disabledColor),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppTheme.paddingLarge,
                  ),
                  Expanded(
                    flex: 4,
                    child: MyBox(
                      boxPadding: AppTheme.paddingHuge,
                      boxChild: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: changeRole,
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppTheme.borderRadius,
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: .3),
                                  ),
                                  child:
                                      Icon(HugeIcons.strokeRoundedWorkoutRun),
                                ),
                                SizedBox(
                                  width: AppTheme.paddingSmall,
                                ),
                                Text(
                                  "Become a ${role == "runner" ? "poster" : "runner"}",
                                  style: AppTheme.textStyle0
                                      .copyWith(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(HugeIcons.strokeRoundedArrowRight01)
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppTheme.borderRadius,
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: .3),
                                  ),
                                  child:
                                      Icon(HugeIcons.strokeRoundedFingerAccess),
                                ),
                                SizedBox(
                                  width: AppTheme.paddingSmall,
                                ),
                                Text(
                                  "Change password",
                                  style: AppTheme.textStyle0
                                      .copyWith(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(HugeIcons.strokeRoundedArrowRight01)
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                {Navigator.pushNamed(context, "/edit-profile")},
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppTheme.borderRadius,
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: .3),
                                  ),
                                  child: Icon(HugeIcons.strokeRoundedEdit03),
                                ),
                                SizedBox(
                                  width: AppTheme.paddingSmall,
                                ),
                                Text(
                                  "Edit profile",
                                  style: AppTheme.textStyle0
                                      .copyWith(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(HugeIcons.strokeRoundedArrowRight01)
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: logout,
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: AppTheme.borderRadius,
                                    color: Colors.red.withValues(alpha: .2),
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(
                                  width: AppTheme.paddingSmall,
                                ),
                                Text(
                                  "Logout",
                                  style: AppTheme.textStyle0
                                      .copyWith(fontSize: 16),
                                ),
                                Spacer(),
                                Icon(
                                  HugeIcons.strokeRoundedArrowRight01,
                                  color: AppTheme.primaryColor,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
