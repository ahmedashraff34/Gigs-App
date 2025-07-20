import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';
import '../services/admin_user_service.dart';
import '../constants/theme.dart';

class AdminUsersScreen extends StatefulWidget {
  @override
  _AdminUsersScreenState createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminUserService _userService = AdminUserService();
  List<AdminUser> _users = [];
  List<AdminUser> _filteredUsers = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });
    try {
      final users = await _userService.fetchAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      _filteredUsers = _users.where((user) {
        final name = (user.firstName + ' ' + user.lastName).toLowerCase();
        final email = user.email.toLowerCase();
        return name.contains(query.toLowerCase()) || email.contains(query.toLowerCase());
      }).toList();
    });
  }

  Widget _buildUserCard(AdminUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Text(user.firstName.isNotEmpty ? user.firstName[0] : '?'),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  foregroundColor: AppTheme.primaryColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.firstName + ' ' + user.lastName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        user.email,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Icon(
                  user.verified ? Icons.verified : Icons.verified_outlined,
                  color: user.verified ? Colors.green : Colors.grey,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(user.phoneNumber, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(user.username, style: const TextStyle(fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Balance: ', style: const TextStyle(fontSize: 13)),
                Text(user.balance.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            if (user.keycloakId != null && user.keycloakId!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.vpn_key, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Keycloak ID: ${user.keycloakId}', style: const TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by name or email...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _filterUsers,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 48, color: Colors.red),
                            const SizedBox(height: 12),
                            Text('Failed to load users', style: const TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _fetchUsers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : _filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
                                const SizedBox(height: 12),
                                const Text('No users found', style: TextStyle(fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _fetchUsers,
                            child: ListView.builder(
                              itemCount: _filteredUsers.length,
                              itemBuilder: (context, index) {
                                return _buildUserCard(_filteredUsers[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }
} 