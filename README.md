# ApertureSpiral

An iOS app featuring an animated camera aperture spiral with integrated mirror view and AI-powered face tracking.

## Features

### Spiral Visualization
- Animated spiral mimicking a camera iris with breathing expansion/contraction
- Customizable blade count (3-16) and layer depth (1-8)
- Adjustable speed (0.1x-3.0x) and aperture size (f/1.4 to f/15.4)
- Color flow animation from center outward with adjustable speed
- Color by blade or by layer modes
- 8 built-in color palettes: Warm, Cool, Ocean, Sunset, Rainbow, Pastel, Monochrome, Neon
- Optional lens flare effect (toggleable in Settings > Effects)
- Tap to reverse rotation direction

### Spiral Center Photo
- Select any photo from your device's photo library
- Interactive center point selection with draggable circle tool
- Photo displays in the spiral center aperture area
- Photo gets progressively covered by fill color as aperture closes
- Cannot be used simultaneously with mirror view

### Mirror View
- Front-facing camera preview in the aperture center
- AI face detection keeps your face centered using Vision framework
- Two animation modes: Zoom only or Zoom + Scale
- Always-on mirror option
- Cannot be used simultaneously with photo mode

### Face Detection
- Freeze spiral when no face detected (after 5 seconds)
- Freeze spiral when not looking at screen (eye tracking)
- "LOOK AT THE SPIRAL" message displays when frozen

### Text Overlays
- Custom phrases displayed in the spiral center
- Random phrase cycling with fade animations
- One phrase per line in settings

### Auto-Capture Photography
- Timer-based photo capture (1-30 minute intervals)
- Flash effect feedback
- Photos saved to in-app gallery

### Photo Gallery
- 3-column grid gallery
- Detail view with sharing and deletion

### Presets
- 4 built-in presets: Birthday, Calm, Intense, Trippy
- Save and load custom presets
- Import/export presets as XML files
- Randomize all settings with one tap

### Keyboard Shortcuts
When using with an external keyboard:
- `R` - Randomize settings
- `M` - Toggle mirror view
- `P` - Capture photo
- `→` - Speed up
- `←` - Slow down

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Camera permission

## Installation

1. Clone the repository
2. Open `ApertureSpiral.xcodeproj` in Xcode
3. Build and run (Cmd+R)

## Usage

### Gestures
- **Tap** spiral to reverse rotation
- **Swipe right** to speed up
- **Swipe left** to slow down
- **Tap** when tab bar is hidden to reveal it

### Navigation
- **Spiral** - Main visualization
- **Settings** - Customize parameters
- **Photos** - View captured images

## Architecture

```
ApertureSpiral/
├── ApertureSpiralApp.swift        # App entry, keyboard command handling
├── Camera/
│   ├── CameraManager.swift        # Camera session, face detection, eye tracking
│   ├── CameraPreviewView.swift    # Camera preview with face centering
│   └── GazeTracker.swift          # Eye gaze tracking
├── Storage/
│   ├── ColorPalette.swift         # Color palette definitions
│   ├── PhotoStorageManager.swift  # Photo persistence
│   ├── SpiralSettings.swift       # Settings with UserDefaults persistence
│   └── TrancePhoto.swift          # Photo data model
└── Views/
    ├── CenterSelectorView.swift   # Photo center point selection with draggable circle
    ├── GalleryView.swift          # Photo gallery grid
    ├── LoadingOverlay.swift       # Loading screen
    ├── MainView.swift             # Tab navigation
    ├── NativeSpiralCanvas.swift   # SwiftUI Canvas spiral rendering
    ├── PhotoDetailView.swift      # Photo viewer with sharing
    ├── PhotoPickerView.swift      # Device photo library picker
    ├── PresetsView.swift          # Preset model and manager
    ├── SettingsView.swift         # Settings UI
    └── SpiralView.swift           # Main spiral view with camera overlay
```

## Technologies

- **SwiftUI** - UI and Canvas-based spiral rendering
- **AVFoundation** - Camera capture
- **Vision** - Face detection and eye tracking
- **Combine** - Reactive state management

## Testing

```bash
xcodebuild test -scheme ApertureSpiral -destination 'platform=iOS Simulator,name=iPhone 16'
```

## License

All rights reserved.
