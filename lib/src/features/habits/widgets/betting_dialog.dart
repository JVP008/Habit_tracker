import 'package:flutter/material.dart';
import 'package:habit_tracker/src/core/widgets/neo_brutalist_button.dart';

class BettingDialog extends StatefulWidget {
  final Function(double amount, String supervisor, String phone) onPlaceBet;

  const BettingDialog({super.key, required this.onPlaceBet});

  @override
  State<BettingDialog> createState() => _BettingDialogState();
}

class _BettingDialogState extends State<BettingDialog> {
  double _amount = 100.0;
  final TextEditingController _supervisorController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

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
              'STREAK OR PAY',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Bet real money on your habit. If you miss a day, you pay.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4A4A4A),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),

            // Amount Slider
            Text(
              'BET AMOUNT: ₹${_amount.toInt()}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.black,
                inactiveTrackColor: Colors.grey[300],
                thumbColor: Colors.black,
                overlayColor: Colors.black.withValues(alpha: 0.1),
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _amount,
                min: 100,
                max: 10000,
                divisions: 99,
                onChanged: (value) => setState(() => _amount = value),
              ),
            ),

            const SizedBox(height: 16),

            // Supervisor Name
            _buildNeoTextField(
              controller: _supervisorController,
              label: 'SUPERVISOR NAME',
              hint: 'Who will judge you?',
            ),
            const SizedBox(height: 12),

            // Supervisor Phone
            _buildNeoTextField(
              controller: _phoneController,
              label: 'WHATSAPP NUMBER',
              hint: '+91 98765...',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: NeoBrutalistButton(
                    onPressed: () => Navigator.pop(context),
                    backgroundColor: Colors.white,
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeoBrutalistButton(
                    onPressed: () {
                      if (_supervisorController.text.isNotEmpty &&
                          _phoneController.text.isNotEmpty) {
                        widget.onPlaceBet(
                          _amount,
                          _supervisorController.text,
                          _phoneController.text,
                        );
                        Navigator.pop(context);
                      }
                    },
                    backgroundColor: Colors.black,
                    child: const Text(
                      'BET NOW',
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

  Widget _buildNeoTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black, width: 2),
            borderRadius: BorderRadius.circular(8),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                offset: Offset(2, 2),
                blurRadius: 0,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[500]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
