import 'package:flutter/material.dart';
import '../models/dispute_model.dart';
import '../services/admin_dispute_service.dart';
import '../services/user_service.dart';
import '../constants/theme.dart';

class AdminDisputesTable extends StatefulWidget {
  @override
  _AdminDisputesTableState createState() => _AdminDisputesTableState();
}

class _AdminDisputesTableState extends State<AdminDisputesTable>
    with SingleTickerProviderStateMixin {
  final AdminDisputeService _disputeService = AdminDisputeService();
  final UserService _userService = UserService();
  
  List<Dispute> _disputes = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  String _selectedFilter = 'all';
  
  late TabController _tabController;

  final List<String> _filters = [
    'all',
    'pending',
    'resolved',
    'closed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _filters.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _selectedFilter = _filters[_tabController.index];
        _fetchDisputes();
      }
    });
    _fetchDisputes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchDisputes() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      String? statusFilter;
      if (_selectedFilter != 'all') {
        statusFilter = _selectedFilter;
      }

      final disputes = await _disputeService.getDisputes(status: statusFilter);
      
      setState(() {
        _disputes = disputes;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error fetching disputes: $e');
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveDispute(Dispute dispute) async {
    final TextEditingController notesController = TextEditingController();
    final TextEditingController recipientController = TextEditingController(text: dispute.runnerId);
    String resolutionType = 'REFUND';
    bool isLoading = false;
    String? errorMessage;

    await showDialog(
      context: context,
      barrierDismissible: !isLoading,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Row(
                children: [
                  Icon(
                    Icons.gavel,
                    color: AppTheme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Resolve Dispute',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                    maxWidth: 350,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispute: ${dispute.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Between: ${dispute.posterName != 'Unknown' ? dispute.posterName : 'ID: ' + dispute.posterId} & ${dispute.runnerName != 'Unknown' ? dispute.runnerName : 'ID: ' + dispute.runnerId}'),
                      const SizedBox(height: 16),
                      const Text('Resolution Type:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'REFUND',
                                groupValue: resolutionType,
                                onChanged: isLoading ? null : (value) => setState(() => resolutionType = value!),
                              ),
                              const Text('Refund to Poster'),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<String>(
                                value: 'RELEASE',
                                groupValue: resolutionType,
                                onChanged: isLoading ? null : (value) => setState(() => resolutionType = value!),
                              ),
                              const Text('Release to Runner'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text('Admin Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: notesController,
                        maxLines: 3,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'Enter resolution details...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      if (resolutionType == 'RELEASE') ...[
                        const SizedBox(height: 12),
                        const Text('Recipient ID:', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: recipientController,
                          keyboardType: TextInputType.number,
                          enabled: !isLoading,
                          decoration: InputDecoration(
                            hintText: 'Enter recipient user ID',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                      if (resolutionType == 'REFUND') ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.orange, size: 20),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Refund Information',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Payment will be refunded to the task poster.',
                                style: TextStyle(color: Colors.orange.shade700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Recipient ID (Runner): ${dispute.runnerId}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          try {
                            // Validate recipient ID for RELEASE resolution
                            if (resolutionType == 'RELEASE') {
                              final recipientId = int.tryParse(recipientController.text.trim());
                              if (recipientId == null || recipientId <= 0) {
                                throw Exception('Please enter a valid recipient ID for release payment');
                              }
                            }

                            // Get recipient ID based on resolution type
                            final recipientId = resolutionType == 'RELEASE' 
                                ? int.tryParse(recipientController.text.trim()) ?? 0
                                : int.tryParse(dispute.runnerId) ?? 0;

                            if (recipientId <= 0) {
                              throw Exception('Invalid recipient ID: ${dispute.runnerId}');
                            }

                            print('🔧 Resolving dispute with payment:');
                            print('   Dispute ID: ${dispute.id}');
                            print('   Resolution Type: $resolutionType');
                            print('   Admin Notes: ${notesController.text.trim()}');
                            print('   Recipient ID: $recipientId');

                            await _disputeService.resolveDisputeWithPayment(
                              disputeId: dispute.id,
                              resolutionType: resolutionType,
                              adminNotes: notesController.text.trim(),
                              recipientId: recipientId,
                            );
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Dispute resolved successfully'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            _fetchDisputes();
                          } catch (e) {
                            setState(() {
                              isLoading = false;
                              errorMessage = _getFriendlyErrorMessage(e);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(_getFriendlyErrorMessage(e)),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Resolve', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  String _getFriendlyErrorMessage(Object e) {
    final msg = e.toString();
    if (msg.contains('Network error')) {
      return 'Network error: Please check your internet connection.';
    } else if (msg.contains('404')) {
      return 'Dispute not found (404). Please refresh and try again.';
    } else if (msg.contains('401')) {
      return 'Authentication failed. Please log in again.';
    } else if (msg.contains('500')) {
      return 'Server error (500). Please try again later.';
    } else if (msg.contains('Failed to resolve dispute')) {
      return 'Failed to resolve dispute. Please check your input and try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  void _viewDisputeDetails(Dispute dispute) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primaryColor,
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                'Dispute Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('ID', dispute.id),
                _buildDetailRow('Title', dispute.title),
                _buildDetailRow('Description', dispute.description),
                _buildDetailRow('Status', dispute.statusDisplay),
                _buildDetailRow('Created', '${dispute.formattedDate} at ${dispute.formattedTime}'),
                _buildDetailRow('Complainant', dispute.posterName != 'Unknown' ? dispute.posterName : 'ID: ' + dispute.posterId),
                _buildDetailRow('Defendant', dispute.runnerName != 'Unknown' ? dispute.runnerName : 'ID: ' + dispute.runnerId),
                if (dispute.resolution != null) _buildDetailRow('Resolution', dispute.resolution!),
                if (dispute.resolvedAt != null) _buildDetailRow('Resolved', '${dispute.resolvedAt!.day}/${dispute.resolvedAt!.month}/${dispute.resolvedAt!.year}'),
                
                // Evidence Images Section
                if (dispute.evidenceUris.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Evidence Images:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: dispute.evidenceUris.length,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              dispute.evidenceUris[index],
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.error_outline,
                                    color: Colors.grey,
                                    size: 40,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 200,
                                  height: 200,
                                  color: Colors.grey.shade100,
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            if (dispute.status.toLowerCase() == 'pending')
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _resolveDispute(dispute);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                ),
                child: const Text(
                  'Resolve',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisputeCard(Dispute dispute) {
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dispute.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${dispute.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: dispute.statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: dispute.statusColor.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    dispute.statusDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: dispute.statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  '${dispute.formattedDate} at ${dispute.formattedTime}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${dispute.posterName != 'Unknown' ? dispute.posterName : 'ID: ' + dispute.posterId} vs ${dispute.runnerName != 'Unknown' ? dispute.runnerName : 'ID: ' + dispute.runnerId}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _viewDisputeDetails(dispute),
                  child: const Text('View'),
                ),
                if (dispute.status.toLowerCase() == 'pending') ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _resolveDispute(dispute),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Resolve',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Disputes Management'),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Resolved'),
            Tab(text: 'Closed'),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchDisputes,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: _filters.map((filter) {
          return _buildDisputesList();
        }).toList(),
      ),
    );
  }

  Widget _buildDisputesList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Failed to load disputes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchDisputes,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_disputes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No disputes found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no disputes in the selected category',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchDisputes,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _disputes.length,
        itemBuilder: (context, index) {
          return _buildDisputeCard(_disputes[index]);
        },
      ),
    );
  }
} 