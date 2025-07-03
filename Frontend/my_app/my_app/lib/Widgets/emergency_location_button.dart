import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyLocationButton extends StatefulWidget {
  final String telegramNumber;
  final String? customMessage;
  final VoidCallback? onLocationSent;
  final bool showConfirmation;

  const EmergencyLocationButton({
    Key? key,
    required this.telegramNumber,
    this.customMessage,
    this.onLocationSent,
    this.showConfirmation = true,
  }) : super(key: key);

  @override
  State<EmergencyLocationButton> createState() => _EmergencyLocationButtonState();
}

class _EmergencyLocationButtonState extends State<EmergencyLocationButton> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _handleEmergencyPress,
            icon: _isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.emergency, size: 24),
            label: Text(
              _isLoading ? 'Sending SOS...' : 'SOS - Send Location',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 8,
              shadowColor: Colors.red.withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Debug button for testing location only
        TextButton.icon(
          onPressed: _isLoading ? null : _testLocationOnly,
          icon: const Icon(Icons.location_searching, size: 16),
          label: const Text('Test Location Only'),
          style: TextButton.styleFrom(
            foregroundColor: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _handleEmergencyPress() {
    if (widget.showConfirmation) {
      _showEmergencyConfirmation();
    } else {
      _sendEmergencyLocation();
    }
  }

  void _showEmergencyConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.red.shade50,
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Emergency Alert',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to send an emergency location alert?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(
              'This will send your current location to: ${widget.telegramNumber}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendEmergencyLocation();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Send SOS'),
          ),
        ],
      ),
    );
  }

  Future<void> _sendEmergencyLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Debug: Starting emergency location process...');
      
      // Get current location with high priority
      Position? position = await _locationService.getCurrentLocation();
      
      if (position == null) {
        print('Debug: Current location failed, trying last known location...');
        // Try to get last known location as fallback
        position = await _locationService.getLastKnownLocation();
        
        if (position == null) {
          print('Debug: Both current and last known location failed');
          _showError('Unable to get your location. Please check your location settings.');
          return;
        } else {
          print('Debug: Using last known location: ${position.latitude}, ${position.longitude}');
        }
      } else {
        print('Debug: Using current location: ${position.latitude}, ${position.longitude}');
      }

      // Send emergency location to Telegram
      await _sendEmergencyTelegram(position);

      // Call callback if provided
      widget.onLocationSent?.call();

    } catch (e) {
      print('Debug: Error in _sendEmergencyLocation: $e');
      _showError('Error sending emergency location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendEmergencyTelegram(Position position) async {
    try {
      final emergencyMsg = widget.customMessage ?? '🚨 EMERGENCY: I need immediate help! 🚨';
      final locationText = _locationService.formatLocationForMessage(position);
      final timestamp = DateTime.now().toString().split('.')[0];
      
      final fullMessage = '''
$emergencyMsg

📍 My current location:
${locationText}

⏰ Time: $timestamp

Please respond immediately!''';
      
      // Handle different Telegram number formats
      String telegramNumber = widget.telegramNumber;
      
      print('Debug: Original telegram number: $telegramNumber');
      print('Debug: Full message length: ${fullMessage.length}');
      
      // Try different URL formats for Telegram
      List<Uri> telegramUrls = [];
      
      // Format 1: Direct phone number (remove + and format)
      if (telegramNumber.startsWith('+')) {
        String cleanNumber = telegramNumber.substring(1).replaceAll(RegExp(r'[^\d]'), '');
        telegramUrls.add(Uri.parse('https://t.me/$cleanNumber?text=${Uri.encodeComponent(fullMessage)}'));
        print('Debug: Format 1 URL: ${telegramUrls.last}');
      }
      
      // Format 2: With + prefix
      telegramUrls.add(Uri.parse('https://t.me/+${telegramNumber.replaceAll(RegExp(r'[^\d]'), '')}?text=${Uri.encodeComponent(fullMessage)}'));
      print('Debug: Format 2 URL: ${telegramUrls.last}');
      
      // Format 3: Direct username format (if it's not a phone number)
      if (!telegramNumber.startsWith('+') && !telegramNumber.contains(RegExp(r'\d'))) {
        telegramUrls.add(Uri.parse('https://t.me/${telegramNumber}?text=${Uri.encodeComponent(fullMessage)}'));
        print('Debug: Format 3 URL: ${telegramUrls.last}');
      }

      bool urlLaunched = false;
      
      for (Uri url in telegramUrls) {
        print('Debug: Trying URL: $url');
        
        if (await canLaunchUrl(url)) {
          print('Debug: URL can be launched: $url');
          try {
            await launchUrl(url, mode: LaunchMode.externalApplication);
            _showSuccess('Emergency location sent to ${widget.telegramNumber}');
            urlLaunched = true;
            break;
          } catch (e) {
            print('Debug: Failed to launch URL: $e');
            continue;
          }
        } else {
          print('Debug: URL cannot be launched: $url');
        }
      }
      
      if (!urlLaunched) {
        // Fallback: Try to open Telegram app directly
        final telegramAppUrl = Uri.parse('tg://msg?to=${widget.telegramNumber}&text=${Uri.encodeComponent(fullMessage)}');
        
        if (await canLaunchUrl(telegramAppUrl)) {
          await launchUrl(telegramAppUrl);
          _showSuccess('Emergency location sent to ${widget.telegramNumber}');
        } else {
          _showError('Could not open Telegram. Please check if Telegram is installed and the number is correct. Try opening Telegram manually and sending the location.');
          
          // Show the message content so user can copy it
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Emergency Message'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Please copy this message and send it manually to your emergency contact:'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SelectableText(fullMessage),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      print('Debug: Error in _sendEmergencyTelegram: $e');
      _showError('Error sending to Telegram: $e');
    }
  }

  Future<void> _testLocationOnly() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('Debug: Testing location retrieval only...');
      
      Position? position = await _locationService.getCurrentLocation();
      
      if (position == null) {
        position = await _locationService.getLastKnownLocation();
      }
      
      if (position != null) {
        final locationText = _locationService.formatLocationForMessage(position);
        print('Debug: Location test successful: $locationText');
        
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Location Test'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Location retrieved successfully!'),
                const SizedBox(height: 8),
                Text('Latitude: ${position?.latitude ?? 'N/A'}'),
                Text('Longitude: ${position?.longitude ?? 'N/A'}'),
                const SizedBox(height: 8),
                Text('Formatted: $locationText'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else {
        _showError('Location test failed. Check permissions and GPS.');
      }
    } catch (e) {
      print('Debug: Location test error: $e');
      _showError('Location test error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
} 