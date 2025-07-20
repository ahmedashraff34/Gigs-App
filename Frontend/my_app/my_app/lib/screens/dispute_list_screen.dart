import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DisputeListScreen extends StatefulWidget {
  @override
  _DisputeListScreenState createState() => _DisputeListScreenState();
}

class _DisputeListScreenState extends State<DisputeListScreen> {
  late Future<List<dynamic>> _disputesFuture;
  Set<int> _loadingDisputes = {};

  @override
  void initState() {
    super.initState();
    _disputesFuture = fetchDisputes();
  }

  Future<List<dynamic>> fetchDisputes() async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8888/api/disputes'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as List;
    } else {
      throw Exception('Failed to load disputes');
    }
  }

  Future<String> fetchUsername(int userId) async {
    final response = await http.get(Uri.parse('http://10.0.2.2:8888/api/users/$userId'));
    if (response.statusCode == 200) {
      final user = jsonDecode(response.body);
      return user['username'] ?? userId.toString();
    } else {
      return userId.toString();
    }
  }

  Future<void> resolveDispute(int disputeId) async {
    final resolution = await showDialog<String>(
      context: context,
      builder: (context) {
        String text = '';
        return AlertDialog(
          title: Text('Enter Resolution'),
          content: TextField(
            autofocus: true,
            decoration: InputDecoration(hintText: 'Resolution details'),
            onChanged: (val) => text = val,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(text),
              child: Text('Resolve'),
            ),
          ],
        );
      },
    );
    if (resolution == null || resolution.trim().isEmpty) return;
    setState(() => _loadingDisputes.add(disputeId));
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8888/api/disputes/$disputeId/resolve'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'resolution': resolution.trim()}),
    );
    setState(() => _loadingDisputes.remove(disputeId));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dispute $disputeId resolved.')),
      );
      setState(() {
        _disputesFuture = fetchDisputes();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to resolve dispute $disputeId.')),
      );
    }
  }

  Future<void> closeDispute(int disputeId) async {
    setState(() => _loadingDisputes.add(disputeId));
    final response = await http.put(
      Uri.parse('http://10.0.2.2:8888/api/disputes/$disputeId/close'),
      headers: {'Content-Type': 'application/json'},
    );
    setState(() => _loadingDisputes.remove(disputeId));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Dispute $disputeId closed.')),
      );
      setState(() {
        _disputesFuture = fetchDisputes();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to close dispute $disputeId.')),
      );
    }
  }

  String formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final date = DateTime.parse(isoString);
      return DateFormat('yyyy-MM-dd HH:mm').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Disputes'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _disputesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \\${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No disputes found.'));
          }
          final disputes = snapshot.data!;
          return ListView.builder(
            itemCount: disputes.length,
            itemBuilder: (context, index) {
              final dispute = disputes[index];
              return FutureBuilder<List<String>>(
                future: Future.wait([
                  fetchUsername(dispute['raisedBy']),
                  fetchUsername(dispute['defendantId']),
                ]),
                builder: (context, userSnapshot) {
                  final complainant = userSnapshot.hasData ? userSnapshot.data![0] : dispute['raisedBy'].toString();
                  final defendant = userSnapshot.hasData ? userSnapshot.data![1] : dispute['defendantId'].toString();
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dispute #${dispute['disputeId']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          SizedBox(height: 8),
                          Text('Task ID: ${dispute['taskId']}'),
                          Text('Complainant: $complainant'),
                          Text('Defendant: $defendant'),
                          Text('Status: ${dispute['status']}'),
                          if (dispute['createdAt'] != null)
                            Text('Created: ${formatDate(dispute['createdAt'])}'),
                          SizedBox(height: 8),
                          Text('Reason: ${dispute['reason']}'),
                          if (dispute['images'] != null && dispute['images'].toString().isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text('Evidence: ${dispute['images']}'),
                            ),
                          SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: _loadingDisputes.contains(dispute['disputeId'])
                                    ? null
                                    : () => resolveDispute(dispute['disputeId']),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                child: _loadingDisputes.contains(dispute['disputeId'])
                                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text('Resolve'),
                              ),
                              SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: _loadingDisputes.contains(dispute['disputeId'])
                                    ? null
                                    : () => closeDispute(dispute['disputeId']),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: _loadingDisputes.contains(dispute['disputeId'])
                                    ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text('Close'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
} 