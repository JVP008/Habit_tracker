import 'package:flutter/material.dart';

/// A color picker dialog with predefined vibrant colors and custom color option
class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const ColorPickerDialog({super.key, required this.initialColor});

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;

  // Vibrant, visible color palette
  static const List<Color> _predefinedColors = [
    // Reds & Pinks
    Color(0xFFF44336), // Red
    Color(0xFFE91E63), // Pink
    Color(0xFF9C27B0), // Purple
    // Blues & Cyans
    Color(0xFF3F51B5), // Indigo
    Color(0xFF2196F3), // Blue
    Color(0xFF00BCD4), // Cyan
    // Greens
    Color(0xFF4CAF50), // Green
    Color(0xFF8BC34A), // Light Green
    Color(0xFF009688), // Teal
    // Yellows & Oranges
    Color(0xFFFFEB3B), // Yellow
    Color(0xFFFF9800), // Orange
    Color(0xFFFF5722), // Deep Orange
    // Browns & Grays
    Color(0xFF795548), // Brown
    Color(0xFF607D8B), // Blue Grey
    Color(0xFF9E9E9E), // Grey
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFFFAFAFA),
      title: const Text(
        'Pick a color',
        style: TextStyle(
          color: Color(0xFF2C2C2C),
          fontWeight: FontWeight.w500,
          letterSpacing: 1.2,
        ),
      ),
      content: SizedBox(
        width: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Preview of selected color
              Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: _selectedColor,
                  border: Border.all(color: Colors.black, width: 3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Selected Color',
                    style: TextStyle(
                      color: _selectedColor.computeLuminance() > 0.5
                          ? Colors.black
                          : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Color grid
              const Text(
                'Choose from preset colors:',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A6A6A),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: _predefinedColors.length,
                itemBuilder: (context, index) {
                  final color = _predefinedColors[index];
                  final isSelected = _selectedColor.value == color.value;

                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        border: Border.all(
                          color: Colors.black,
                          width: isSelected ? 3 : 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: isSelected
                            ? [
                                const BoxShadow(
                                  color: Colors.black,
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                ),
                              ]
                            : null,
                      ),
                      child: isSelected
                          ? Icon(
                              Icons.check,
                              color: color.computeLuminance() > 0.5
                                  ? Colors.black
                                  : Colors.white,
                              size: 24,
                            )
                          : null,
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Custom color sliders
              const Text(
                'Or create your own color:',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6A6A6A),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 12),

              _buildColorSlider('Red', Color(_selectedColor.value).red, (
                value,
              ) {
                setState(() {
                  _selectedColor = Color.fromARGB(
                    255,
                    value.toInt(),
                    Color(_selectedColor.value).green,
                    Color(_selectedColor.value).blue,
                  );
                });
              }),

              _buildColorSlider('Green', Color(_selectedColor.value).green, (
                value,
              ) {
                setState(() {
                  _selectedColor = Color.fromARGB(
                    255,
                    Color(_selectedColor.value).red,
                    value.toInt(),
                    Color(_selectedColor.value).blue,
                  );
                });
              }),

              _buildColorSlider('Blue', Color(_selectedColor.value).blue, (
                value,
              ) {
                setState(() {
                  _selectedColor = Color.fromARGB(
                    255,
                    Color(_selectedColor.value).red,
                    Color(_selectedColor.value).green,
                    value.toInt(),
                  );
                });
              }),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }

  Widget _buildColorSlider(
    String label,
    int value,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF2C2C2C),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Slider(
              value: value.toDouble(),
              min: 0,
              max: 255,
              divisions: 255,
              activeColor: const Color(0xFF2C2C2C),
              inactiveColor: const Color(0xFFBDBDBD),
              onChanged: onChanged,
            ),
          ),
          SizedBox(
            width: 35,
            child: Text(
              value.toString(),
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 12, color: Color(0xFF6A6A6A)),
            ),
          ),
        ],
      ),
    );
  }
}
