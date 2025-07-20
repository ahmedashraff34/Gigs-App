import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/theme.dart';
import '../services/user_service.dart';
import '../screens/admin_disputes_table.dart';

class DisputeStatistics {
  final int totalDisputes;
  final int pendingDisputes;
  final int resolvedDisputes;
  final int closedDisputes;

  DisputeStatistics({
    required this.totalDisputes,
    required this.pendingDisputes,
    required this.resolvedDisputes,
    required this.closedDisputes,
  });

  factory DisputeStatistics.fromJson(Map<String, dynamic> json) {
    return DisputeStatistics(
      totalDisputes: json['totalDisputes'] ?? 0,
      pendingDisputes: json['pendingDisputes'] ?? 0,
      resolvedDisputes: json['resolvedDisputes'] ?? 0,
      closedDisputes: json['closedDisputes'] ?? 0,
    );
  }
}

class DisputeInfoCard extends StatefulWidget {
  const DisputeInfoCard({Key? key}) : super(key: key);

  @override
  State<DisputeInfoCard> createState() => _DisputeInfoCardState();
}

class _DisputeInfoCardState extends State<DisputeInfoCard> {
  DisputeStatistics? _statistics;
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _fetchDisputeStatistics();
  }

  Future<void> _fetchDisputeStatistics() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Get authentication token
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('❌ No token found - User needs to login again');
        await _userService.handleInvalidToken();
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication required';
          _isLoading = false;
        });
        return;
      }

      // Validate token before making request
      final isTokenValid = await _userService.isTokenValid();
      if (!isTokenValid) {
        print('❌ Token is invalid or expired');
        await _userService.handleInvalidToken();
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication failed';
          _isLoading = false;
        });
        return;
      }

      print('🔑 Token found: ${token.substring(0, 20)}...');
      print('📡 Fetching dispute statistics...');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8090/api/admin/disputes/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _statistics = DisputeStatistics.fromJson(data);
          _isLoading = false;
        });
        print('✅ Dispute statistics loaded successfully');
      } else if (response.statusCode == 401) {
        print('❌ Authentication failed - Token may be expired or invalid');
        await _userService.handleInvalidToken();
        setState(() {
          _hasError = true;
          _errorMessage = 'Authentication failed';
          _isLoading = false;
        });
      } else {
        print('❌ Failed to load dispute statistics: ${response.statusCode}');
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load dispute statistics (${response.statusCode})';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('❌ Error fetching dispute statistics: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  Widget _buildStatItem({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: AppTheme.borderRadius,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              count.toString(),
              style: AppTheme.textStyle0.copyWith(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: AppTheme.paddingSmall),
            Text(
              title,
              style: AppTheme.textStyle2.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppTheme.borderRadiusLarge,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingLarge),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Wrap(
                spacing: 4,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.gavel,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppTheme.paddingMedium),
                  Text(
                    'Dispute Statistics',
                    style: AppTheme.textStyle0.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _fetchDisputeStatistics,
                    icon: Icon(
                      Icons.refresh,
                      color: AppTheme.textColor1,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AdminDisputesTable()),
                      );
                    },
                    icon: Icon(
                      Icons.list,
                      color: AppTheme.textColor1,
                      size: 20,
                    ),
                    tooltip: 'View All Disputes',
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.paddingLarge),

              // Content
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppTheme.paddingLarge),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_hasError)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppTheme.paddingLarge),
                    child: Column(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppTheme.urgentColor,
                          size: 48,
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        Text(
                          _errorMessage,
                          style: AppTheme.textStyle2.copyWith(
                            color: AppTheme.urgentColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppTheme.paddingMedium),
                        ElevatedButton(
                          onPressed: _fetchDisputeStatistics,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: AppTheme.borderRadius,
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_statistics != null)
                Column(
                  children: [
                    // Statistics Grid
                    Row(
                      children: [
                        _buildStatItem(
                          title: 'Total',
                          count: _statistics!.totalDisputes,
                          color: AppTheme.primaryColor,
                          icon: Icons.assessment,
                        ),
                        const SizedBox(width: AppTheme.paddingMedium),
                        _buildStatItem(
                          title: 'Pending',
                          count: _statistics!.pendingDisputes,
                          color: AppTheme.warningColor,
                          icon: Icons.pending,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingMedium),
                    Row(
                      children: [
                        _buildStatItem(
                          title: 'Resolved',
                          count: _statistics!.resolvedDisputes,
                          color: AppTheme.successColor,
                          icon: Icons.check_circle,
                        ),
                        const SizedBox(width: AppTheme.paddingMedium),
                        _buildStatItem(
                          title: 'Closed',
                          count: _statistics!.closedDisputes,
                          color: AppTheme.textColor1,
                          icon: Icons.close,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.paddingLarge),

                    // Summary
                    Container(
                      padding: const EdgeInsets.all(AppTheme.paddingMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.lightAccentColor.withOpacity(0.3),
                        borderRadius: AppTheme.borderRadius,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.paddingSmall),
                          Expanded(
                            child: Text(
                              '${_statistics!.pendingDisputes} disputes require attention',
                              style: AppTheme.textStyle2.copyWith(
                                color: AppTheme.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
} 