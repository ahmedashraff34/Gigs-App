import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/theme.dart';
import '../widgets/inputBox.dart';

class OffersScreen extends StatefulWidget {
  const OffersScreen({super.key});

  @override
  State<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends State<OffersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class RaiseOfferBottomSheet extends StatefulWidget {
  final void Function({double amount, String comment, String resumeLink})
      onSubmit;
  final String category;

  const RaiseOfferBottomSheet(
      {super.key, required this.onSubmit, required this.category});

  @override
  State<RaiseOfferBottomSheet> createState() => _RaiseOfferBottomSheetState();
}

class _RaiseOfferBottomSheetState extends State<RaiseOfferBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _resumeLinkController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final isEvent = widget.category == 'EVENT_STAFFING';
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          left: AppTheme.paddingLarge,
          right: AppTheme.paddingLarge,
          top: AppTheme.paddingLarge,
          bottom:
              MediaQuery.of(context).viewInsets.bottom + AppTheme.paddingLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            Text(
              isEvent ? "Apply to Event" : "Raise an Offer",
              style: AppTheme.headerTextStyle.copyWith(fontSize: 22),
            ),
            const SizedBox(height: AppTheme.paddingLarge),
            if (!isEvent) ...[
              Text("Amount (EGP)", style: AppTheme.textStyle1),
              const SizedBox(height: AppTheme.paddingSmall),
              InputBox(
                label: null,
                hintText: "Enter your offer amount",
                obscure: false,
                controller: _amountController,
              ),
              const SizedBox(height: AppTheme.paddingLarge),
            ],
            Text(isEvent ? "Comment" : "Comment", style: AppTheme.textStyle1),
            const SizedBox(height: AppTheme.paddingSmall),
            InputBox(
              label: null,
              hintText:
                  isEvent ? "Enter a comment" : "Add a comment (optional)",
              obscure: false,
              controller: _commentController,
            ),
            if (isEvent) ...[
              const SizedBox(height: AppTheme.paddingLarge),
              Text("Resume Link", style: AppTheme.textStyle1),
              const SizedBox(height: AppTheme.paddingSmall),
              InputBox(
                label: null,
                hintText: "Paste your resume/profile link",
                obscure: false,
                controller: _resumeLinkController,
              ),
            ],
            const SizedBox(height: AppTheme.paddingLarge),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSubmitting
                    ? null
                    : () {
                        if (!isEvent) {
                          final amount =
                              double.tryParse(_amountController.text.trim());
                          final comment = _commentController.text.trim();
                          if (amount == null || amount <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text("Please enter a valid amount.")),
                            );
                            return;
                          }
                          setState(() => _isSubmitting = true);
                          widget.onSubmit(amount: amount, comment: comment);
                          setState(() => _isSubmitting = false);
                          Navigator.of(context).pop();
                        } else {
                          final comment = _commentController.text.trim();
                          final resumeLink = _resumeLinkController.text.trim();
                          if (comment.isEmpty || resumeLink.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text("Please fill all fields.")),
                            );
                            return;
                          }
                          setState(() => _isSubmitting = true);
                          // For event, pass 0 as amount, and combine comment and resumeLink
                          widget.onSubmit(
                              comment: comment, resumeLink: resumeLink);
                          setState(() => _isSubmitting = false);
                          Navigator.of(context).pop();
                        }
                      },
                child: _isSubmitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(isEvent ? "Submit Application" : "Submit Offer",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
