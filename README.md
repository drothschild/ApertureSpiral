# ApertureSpiral

An immersive, meditative iOS app featuring an animated spiral aperture visualization with integrated front-facing camera preview and AI-powered face centering. Created to test developing iOS apps in Claude.

## Features

### Spiral Visualization
- Dynamic animated spiral mimicking a camera iris opening/closing
- Customizable blade count (3-16) and layer depth (1-8)
- Breathing animation creating natural expansion/contraction
- Warm amber-to-magenta gradient color palette with outward flow
- Lens flare effects for visual richness
- Adjustable speed (0.1x-3.0x) and aperture depth (f/1.4 to f/15.4)

### Camera Mirror
- Front-facing camera preview in the aperture center
- AI face detection using Vision framework for automatic eye centering
- Three animation modes: Scale, Zoom, or Both
- Always-on mirror option for continuous viewing

### Auto-Capture Photography
- Configurable capture timer (0-30 minutes)
- Flash effect feedback during capture
- Preset association for tracking capture settings

### Text Overlays
- Customizable phrases displayed in the spiral center
- Smooth fade animations with phrase cycling

### Photo Gallery
- 3-column grid gallery of captured photos
- Detail view with metadata, sharing, and deletion

### Presets
- Built-in presets: Birthday, Calm, Intense
- Create and save custom presets

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+
- Camera access permission

## Installation

1. Clone the repository
2. Open `ApertureSpiral.xcodeproj` in Xcode
3. Select your target device or simulator
4. Build and run (Cmd+R)

## Usage

### Gestures
- **Tap** the spiral to reverse rotation direction
- **Swipe right** to increase speed
- **Swipe left** to decrease speed
- **Tap** when tab bar is hidden to reveal it

### Navigation
- **Spiral tab**: Main visualization experience
- **Settings tab**: Customize all parameters
- **Photos tab**: View captured images

## Architecture

```
ApertureSpiral/
├── ApertureSpiralApp.swift          # App entry point
├── Camera/
│   ├── CameraManager.swift          # Camera & face detection
│   └── CameraPreviewView.swift      # Camera preview component
├── Storage/
│   ├── TrancePhoto.swift            # Photo data model
│   ├── SpiralSettings.swift         # Settings persistence
│   └── PhotoStorageManager.swift    # Photo storage
└── Views/
    ├── MainView.swift               # Tab navigation
    ├── SpiralView.swift             # Main visualization
    ├── SettingsView.swift           # Configuration
    ├── GalleryView.swift            # Photo gallery
    ├── PhotoDetailView.swift        # Photo viewer
    ├── NativeSpiralCanvas.swift     # Spiral rendering
    └── PresetsView.swift            # Preset management
```

## Technologies

- **SwiftUI** - UI components and layouts
- **AVFoundation** - Camera capture and preview
- **Vision** - AI face detection
- **Core Data** - Data management
- **Combine** - Reactive state management

## License

All rights reserved.
