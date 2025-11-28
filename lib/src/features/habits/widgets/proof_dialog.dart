import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:habit_tracker/src/core/widgets/neo_brutalist_button.dart';

class ProofDialog extends StatefulWidget {
  final Function(String proofPath) onProofSubmitted;

  const ProofDialog({super.key, required this.onProofSubmitted});

  @override
  State<ProofDialog> createState() => _ProofDialogState();
}

class _ProofDialogState extends State<ProofDialog> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _image = picked);
      }
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(8, 8), blurRadius: 0),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PROOF REQUIRED',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Money is on the line. Prove you did it.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Image Preview area
            GestureDetector(
              onTap: () => _pickImage(ImageSource.camera),
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.file(
                          File(_image!.path),
                          fit: BoxFit.cover,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.camera_alt_outlined,
                            size: 48,
                            color: Colors.black,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'TAP TO TAKE PHOTO',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: NeoBrutalistButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.white,
                    child: const Text('LATER'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoBrutalistButton(
                    onPressed: _image == null || _isUploading
                        ? null
                        : () async {
                            setState(() => _isUploading = true);
                            // Simulate upload delay
                            await Future.delayed(const Duration(seconds: 1));
                            widget.onProofSubmitted(_image!.path);
                            if (!mounted) return;
                            Navigator.pop(context);
                          },
                    backgroundColor: _image == null
                        ? Colors.grey
                        : Colors.black,
                    child: _isUploading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'SUBMIT',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
