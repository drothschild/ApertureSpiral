import SwiftUI

struct SettingsView: View {
    @StateObject private var settings = SpiralSettings.shared
    @StateObject private var presetManager = PresetManager.shared
    @State private var phrasesText: String = ""
    @State private var newPresetName = ""
    @State private var showingSavePreset = false
    @FocusState private var phrasesFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Preset") {
                    Picker("Load Preset", selection: $presetManager.currentPresetId) {
                        Text("Custom").tag(nil as UUID?)
                        ForEach(presetManager.builtInPresets) { preset in
                            HStack {
                                Text(preset.name)
                                Image(systemName: "star.fill")
                                    .foregroundColor(.yellow)
                                    .font(.caption2)
                            }.tag(preset.id as UUID?)
                        }
                        if !presetManager.userPresets.isEmpty {
                            ForEach(presetManager.userPresets) { preset in
                                Text(preset.name).tag(preset.id as UUID?)
                            }
                        }
                    }
                    .onChange(of: presetManager.currentPresetId) { _, newValue in
                        if let id = newValue,
                           let preset = presetManager.allPresets.first(where: { $0.id == id }) {
                            presetManager.applyPreset(preset)
                            phrasesText = settings.phrasesText
                        }
                    }

                    Button("Save Current as Preset") {
                        showingSavePreset = true
                    }
                }

                Section("Phrases") {
                    TextEditor(text: $phrasesText)
                        .focused($phrasesFocused)
                        .frame(minHeight: 100)
                        .onChange(of: phrasesText) { _, newValue in
                            settings.phrasesText = newValue
                            presetManager.currentPresetId = nil
                        }
                    Text("One phrase per line. Cycles randomly in the center.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Blades") {
                    HStack {
                        Text("\(settings.bladeCount)")
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .frame(width: 40)
                        Slider(value: Binding(
                            get: { Double(settings.bladeCount) },
                            set: {
                                settings.bladeCount = Int($0)
                                presetManager.currentPresetId = nil
                            }
                        ), in: 3...16, step: 1)
                    }
                }

                Section("Layers") {
                    HStack {
                        Text("\(settings.layerCount)")
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .frame(width: 40)
                        Slider(value: Binding(
                            get: { Double(settings.layerCount) },
                            set: {
                                settings.layerCount = Int($0)
                                presetManager.currentPresetId = nil
                            }
                        ), in: 1...8, step: 1)
                    }
                }

                Section("Speed") {
                    HStack {
                        Text(String(format: "%.1fx", settings.speed))
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .frame(width: 50)
                        Slider(value: Binding(
                            get: { settings.speed },
                            set: {
                                settings.speed = $0
                                presetManager.currentPresetId = nil
                            }
                        ), in: 0.1...3.0, step: 0.1)
                    }
                }

                Section("Aperture") {
                    HStack {
                        let fStop = 1.4 + (1 - settings.apertureSize) * 14
                        Text(String(format: "f/%.1f", fStop))
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .frame(width: 50)
                        Slider(value: Binding(
                            get: { settings.apertureSize },
                            set: {
                                settings.apertureSize = $0
                                presetManager.currentPresetId = nil
                            }
                        ), in: 0.1...1.0, step: 0.05)
                    }
                }

                Section("Color Flow") {
                    HStack {
                        Text(settings.colorFlowSpeed == 0 ? "Off" : String(format: "%.1fx", settings.colorFlowSpeed))
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .frame(width: 50)
                        Slider(value: Binding(
                            get: { settings.colorFlowSpeed },
                            set: {
                                settings.colorFlowSpeed = $0
                                presetManager.currentPresetId = nil
                            }
                        ), in: 0...2.0, step: 0.1)
                    }
                    Text("Speed of colors flowing from center outward. Set to 0 to disable.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Color Palette") {
                    ForEach(ColorPalette.allBuiltIn) { palette in
                        Button(action: {
                            settings.colorPaletteId = palette.id
                            presetManager.currentPresetId = nil
                        }) {
                            HStack {
                                HStack(spacing: 1) {
                                    ForEach(0..<8, id: \.self) { i in
                                        Rectangle()
                                            .fill(palette.swiftUIColors[i])
                                    }
                                }
                                .frame(width: 80, height: 24)
                                .clipShape(RoundedRectangle(cornerRadius: 4))

                                Text(palette.name)
                                    .foregroundColor(.primary)

                                Spacer()

                                if settings.colorPaletteId == palette.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.yellow)
                                }
                            }
                        }
                    }
                }

                Section("Mirror View") {
                    Toggle("Always On", isOn: $settings.mirrorAlwaysOn)

                    Toggle("Center on Face", isOn: $settings.eyeCenteringEnabled)
                    Text("Uses AI face detection to keep your face centered in the preview.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("Scale", isOn: Binding(
                        get: { settings.mirrorAnimationMode == 2 },
                        set: {
                            settings.mirrorAnimationMode = $0 ? 2 : 1
                            presetManager.currentPresetId = nil
                        }
                    ))

                    if settings.mirrorAlwaysOn {
                        Text("Camera preview stays visible.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        HStack {
                            Text(settings.captureTimerMinutes == 0 ? "Off" : "\(settings.captureTimerMinutes) min")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(width: 60)
                            Slider(value: Binding(
                                get: { Double(settings.captureTimerMinutes) },
                                set: { settings.captureTimerMinutes = Int($0) }
                            ), in: 0...30, step: 1)
                        }

                        if settings.captureTimerMinutes > 0 {
                            Toggle("Save Picture", isOn: Binding(
                                get: { !settings.previewOnly },
                                set: { settings.previewOnly = !$0 }
                            ))
                            Text(settings.previewOnly
                                ? "Camera preview will appear but no photo will be taken."
                                : "Automatically capture a photo after the specified time.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        } else {
                            Text("Set a timer to enable camera preview or auto-capture.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

            }
            .onTapGesture {
                phrasesFocused = false
            }
            .navigationTitle("Settings")
            .onAppear {
                phrasesText = settings.phrasesText
            }
            .alert("Save Preset", isPresented: $showingSavePreset) {
                TextField("Preset name", text: $newPresetName)
                Button("Cancel", role: .cancel) {
                    newPresetName = ""
                }
                Button("Save") {
                    let name = newPresetName.trimmingCharacters(in: .whitespaces)
                    if !name.isEmpty {
                        presetManager.saveCurrentAsPreset(name: name)
                    }
                    newPresetName = ""
                }
            } message: {
                Text("Enter a name for this preset")
            }
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
