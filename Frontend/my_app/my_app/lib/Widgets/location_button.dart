import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/location_service.dart';
import 'package:geolocator/geolocator.dart';

class LocationButton extends StatefulWidget {
  final String? recipientEmail;
  final String? telegramUsername;
  final String? taskTitle;
  final VoidCallback? onLocationSent;
  final bool isEmergencyMode;
  final String? emergencyTelegramNumber;
  final String? emergencyMessage;

  const LocationButton({
    Key? key,
    this.recipientEmail,
    this.telegramUsername,
    this.taskTitle,
    this.onLocationSent,
    this.isEmergencyMode = false,
    this.emergencyTelegramNumber,
    this.emergencyMessage,
  }) : super(key: key);

  @override
  State<LocationButton> createState() => _LocationButtonState();
}

class _LocationButtonState extends State<LocationButton> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleButtonPress,
          icon: _isLoading 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(widget.isEmergencyMode ? Icons.emergency : Icons.location_on),
          label: Text(_isLoading 
            ? 'Getting Location...' 
            : widget.isEmergencyMode ? 'SOS - Send Location' : 'Share Location'),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.isEmergencyMode ? Colors.red : const Color(0xFF1DBF73),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isEmergencyMode 
            ? 'Send your current location to emergency contact'
            : 'Share your current location with the task poster',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _handleButtonPress() {
    if (widget.isEmergencyMode) {
      _sendEmergencyLocation();
    } else {
      _showSharingOptions();
    }
  }

  Future<void> _sendEmergencyLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location
      Position? position = await _locationService.getCurrentLocation();
      
      if (position == null) {
        // Try to get last known location
        position = await _locationService.getLastKnownLocation();
        
        if (position == null) {
          _showError('Unable to get your location. Please check your location settings.');
          return;
        }
      }

      // Send emergency location to Telegram
      await _sendEmergencyTelegram(position);

      // Call callback if provided
      widget.onLocationSent?.call();

    } catch (e) {
      _showError('Error sending emergency location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendEmergencyTelegram(Position position) async {
    if (widget.emergencyTelegramNumber == null) {
      _showError('No emergency contact number specified');
      return;
    }

    final emergencyMsg = widget.emergencyMessage ?? 'EMERGENCY: I need help!';
    final locationText = _locationService.formatLocationForMessage(position);
    final fullMessage = '$emergencyMsg\n\n$locationText';
    
    final telegramUrl = Uri.parse(
      'https://t.me/${widget.emergencyTelegramNumber}?text=${Uri.encodeComponent(fullMessage)}'
    );

    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
      _showSuccess('Emergency location sent to ${widget.emergencyTelegramNumber}');
    } else {
      _showError('Could not open Telegram. Please check if Telegram is installed.');
    }
  }

  void _showSharingOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Share Location Via',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.recipientEmail != null)
              ListTile(
                leading: const Icon(Icons.email, color: Colors.blue),
                title: const Text('Email'),
                subtitle: Text(widget.recipientEmail!),
                onTap: () => _shareViaEmail(),
              ),
            if (widget.telegramUsername != null)
              ListTile(
                leading: const Icon(Icons.telegram, color: Colors.blue),
                title: const Text('Telegram'),
                subtitle: Text('@${widget.telegramUsername!}'),
                onTap: () => _shareViaTelegram(),
              ),
            ListTile(
              leading: const Icon(Icons.copy, color: Colors.grey),
              title: const Text('Copy to Clipboard'),
              subtitle: const Text('Copy location coordinates'),
              onTap: () => _copyToClipboard(),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _shareViaEmail() async {
    Navigator.of(context).pop();
    await _getAndShareLocation('email');
  }

  Future<void> _shareViaTelegram() async {
    Navigator.of(context).pop();
    await _getAndShareLocation('telegram');
  }

  Future<void> _copyToClipboard() async {
    Navigator.of(context).pop();
    await _getAndShareLocation('clipboard');
  }

  Future<void> _getAndShareLocation(String method) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current location
      Position? position = await _locationService.getCurrentLocation();
      
      if (position == null) {
        // Try to get last known location
        position = await _locationService.getLastKnownLocation();
        
        if (position == null) {
          _showError('Unable to get your location. Please check your location settings.');
          return;
        }
      }

      // Share location based on method
      switch (method) {
        case 'email':
          await _sendEmail(position);
          break;
        case 'telegram':
          await _sendTelegram(position);
          break;
        case 'clipboard':
          await _copyLocationToClipboard(position);
          break;
      }

      // Call callback if provided
      widget.onLocationSent?.call();

    } catch (e) {
      _showError('Error sharing location: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendEmail(Position position) async {
    if (widget.recipientEmail == null) {
      _showError('No email recipient specified');
      return;
    }

    final subject = widget.taskTitle != null 
        ? 'Location Update - ${widget.taskTitle}'
        : 'My Current Location';
    
    final body = _locationService.formatLocationForMessage(position);
    
    final emailUrl = Uri.parse(
      'mailto:${widget.recipientEmail}?subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}'
    );

    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
      _showSuccess('Email app opened with location details');
    } else {
      _showError('Could not open email app');
    }
  }

  Future<void> _sendTelegram(Position position) async {
    if (widget.telegramUsername == null) {
      _showError('No Telegram username specified');
      return;
    }

    final message = _locationService.formatLocationForMessage(position);
    final telegramUrl = Uri.parse(
      'https://t.me/${widget.telegramUsername}?text=${Uri.encodeComponent(message)}'
    );

    if (await canLaunchUrl(telegramUrl)) {
      await launchUrl(telegramUrl, mode: LaunchMode.externalApplication);
      _showSuccess('Telegram opened with location details');
    } else {
      _showError('Could not open Telegram');
    }
  }

  Future<void> _copyLocationToClipboard(Position position) async {
    final locationText = _locationService.formatLocationForMessage(position);
    
    // Copy to clipboard
    // Note: You'll need to add clipboard package if you want to copy to clipboard
    // For now, we'll just show the location in a dialog
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Details'),
        content: SelectableText(locationText),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
