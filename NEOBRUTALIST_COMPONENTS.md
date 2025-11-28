# NeoBrutalist 3D Button Implementation

## Overview
This implementation adds a retro neobrutalism-style 3D button and text field components to your Flutter app with smooth push-down animations.

## Components Created

### 1. NeoBrutalistButton (`neo_brutalist_button.dart`)
A custom button widget featuring:
- **Thick black borders** (4-6px, customizable)
- **3D shadow effect** with configurable offset
- **Smooth push-down animation** (100ms) when pressed
- **Retro aesthetic** with sharp, geometric shapes

#### Properties:
- `onPressed`: Callback function when button is tapped
- `child`: The widget to display inside the button (usually Text)
- `borderWidth`: Thickness of the border (default: 4.0)
- `borderRadius`: Corner radius (default: 12.0)
- `shadowOffset`: Shadow depth when unpressed (default: 6.0)
- `backgroundColor`: Button background color (default: white)
- `borderColor`: Border color (default: black)
- `shadowColor`: Shadow color (default: black)
- `padding`: Internal padding
- `width`: Optional width constraint

#### How it works:
1. Uses `GestureDetector` to detect tap down/up/cancel events
2. Manages `_isPressed` state to toggle between pressed and unpressed
3. `AnimatedContainer` smoothly transitions the shadow offset and vertical position
4. When pressed:
   - Shadow reduces from 6px to 2px
   - Button translates down by 4px
   - Creates realistic "push-down" effect

### 2. NeoBrutalistTextField (`neo_brutalist_text_field.dart`)
A text input field with matching neobrutalist style:
- **Thick black borders** matching the button
- **Static 3D shadow** (4px offset for subtle depth)
- **Clean, minimal design** with no Flutter default decorations

#### Properties:
- `controller`: TextEditingController for managing input
- `labelText`: Label text displayed above input
- `hintText`: Placeholder text
- `keyboardType`: Type of keyboard to display
- `borderWidth`: Border thickness (default: 4.0)
- `borderRadius`: Corner radius (default: 12.0)
- `shadowOffset`: Static shadow depth (default: 4.0)
- `backgroundColor`: Field background (default: white)
- `borderColor`: Border color (default: black)
- `shadowColor`: Shadow color (default: black)

## Integration in Your App

The components are already integrated into your registration screen (`main.dart`):

```dart
// Text fields with 3D effect
NeoBrutalistTextField(
  controller: _nameCtrl,
  labelText: 'name',
  hintText: 'Enter your name',
),

NeoBrutalistTextField(
  controller: _emailCtrl,
  labelText: 'email',
  hintText: 'Enter your email',
  keyboardType: TextInputType.emailAddress,
),

// Button with 3D push-down animation
NeoBrutalistButton(
  width: double.infinity,
  onPressed: () async {
    // Your registration logic here
  },
  child: const Text('enter zenflow'),
),
```

## Visual Effect Details

### Default State:
- White background
- 4-6px thick black border
- 6-8px black shadow offset downward
- Button appears "raised" above the surface

### Pressed State (100ms transition):
- Shadow reduces to 2px
- Button moves down 4-6px
- Creates smooth "push into surface" effect
- Maintains all other styling

## Color Scheme
- **Background**: White (#FFFFFF) or light grey (#FAFAFA)
- **Borders**: Pure black (#000000)
- **Shadow**: Pure black with no blur for sharp, retro effect
- **Text**: Black (#000000)

## Customization Example

```dart
// Custom colored button
NeoBrutalistButton(
  backgroundColor: Colors.yellow,
  borderColor: Colors.black,
  shadowColor: Colors.black,
  borderWidth: 6.0,
  shadowOffset: 8.0,
  onPressed: () => print('Pressed!'),
  child: const Text('CUSTOM BUTTON'),
)
```

## Demo Screen

A demo screen is available at `lib/src/core/widgets/neo_brutalist_demo.dart` showcasing all components with feature descriptions.

## Animation Specifications
- **Duration**: 100-150ms for snappy feel
- **Curve**: `Curves.easeInOut` for smooth transitions
- **Shadow reduction**: From 6-8px to 2px
- **Vertical movement**: 4-6px downward

## Files Modified
1. `lib/src/core/widgets/neo_brutalist_button.dart` - New button component
2. `lib/src/core/widgets/neo_brutalist_text_field.dart` - New text field component
3. `lib/main.dart` - Updated registration screen to use new components
4. `lib/src/core/widgets/neo_brutalist_demo.dart` - Demo screen

## Best Practices
1. Use `width: double.infinity` for full-width buttons
2. Add spacing between fields (16-24px recommended)
3. Keep shadow offsets proportional to border width
4. Use consistent border radius across all components
5. Maintain high contrast (black/white) for best neobrutalist effect

Enjoy your new retro-style 3D buttons! 🎨✨
