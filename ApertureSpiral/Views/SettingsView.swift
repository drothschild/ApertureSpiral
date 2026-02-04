import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    @ObservedObject private var settings = SpiralSettings.shared
    @ObservedObject private var presetManager = PresetManager.shared
    @State private var phrasesText: String = ""
    @State private var newPresetName = ""
    @State private var showingSavePreset = false
    @State private var showingPhotoPickerSheet = false
    @FocusState private var phrasesFocused: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Preset") {
                    NavigationLink {
                        PresetSelectionView(phrasesText: $phrasesText)
                    } label: {
                        HStack {
                            Text("Load Preset")
                            Spacer()
                            Text(presetManager.allPresets.first { $0.id == presetManager.currentPresetId }?.name ?? "None")
                                .foregroundColor(.secondary)
                        }
                    }

                    Button("Save Current as Preset") {
                        showingSavePreset = true
                    }

                    Button("Randomize") {
                        settings.randomize()
                        presetManager.currentPresetId = nil
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
                        .onChange(of: phrasesFocused) { _, isFocused in
                            if !isFocused {
                                let lines = phrasesText
                                    .components(separatedBy: .newlines)
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                    .filter { !$0.isEmpty }
                                let uniqueSorted = Array(Set(lines)).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                                let newText = uniqueSorted.joined(separator: "\n")
                                if newText != phrasesText {
                                    phrasesText = newText
                                }
                            }
                        }
                    Text("One phrase per line. Cycles randomly in the center.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Text Display Duration") {
                    HStack {
                        Text(String(format: "%.1fs", settings.phraseDisplayDuration))
                            .font(.headline)
                            .foregroundColor(.yellow)
                            .frame(width: 50)
                        Slider(value: Binding(
                            get: { settings.phraseDisplayDuration },
                            set: {
                                settings.phraseDisplayDuration = $0
                                presetManager.currentPresetId = nil
                            }
                        ), in: 0.5...5.0, step: 0.5)
                    }
                    Text("How long each phrase appears on screen.")
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

                    Toggle("Color by Blade", isOn: Binding(
                        get: { settings.colorByBlade },
                        set: {
                            settings.colorByBlade = $0
                            presetManager.currentPresetId = nil
                        }
                    ))
                    Text(settings.colorByBlade ? "Each blade has its own color." : "Each layer has its own color.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Effects") {
                    Toggle("Lens Flare", isOn: Binding(
                        get: { settings.lensFlareEnabled },
                        set: {
                            settings.lensFlareEnabled = $0
                            presetManager.currentPresetId = nil
                        }
                    ))
                    Text("Adds a subtle orbiting light flare effect.")
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
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                    }
                }

                Section("Face Detection") {
                    Toggle("Freeze spiral when no face detected", isOn: $settings.freezeWhenNoFace)
                    Text("Freeze the spiral without a detected face.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("Freeze spiral when not looking", isOn: $settings.freezeWhenNotLooking)
                    Text("Uses eye tracking to freeze when you look away from the screen.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Spiral Center Photo") {
                    Button {
                        // Turn off mirror view when selecting a photo
                        if settings.mirrorAlwaysOn {
                            settings.mirrorAlwaysOn = false
                        }
                        showingPhotoPickerSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.circle.fill")
                                .foregroundColor(.yellow)
                            Text(settings.selectedPhotoData == nil ? "Select Photo" : "Change Photo")
                                .foregroundColor(.primary)
                            Spacer()
                            if settings.selectedPhotoData != nil {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .buttonStyle(.plain)

                    if settings.selectedPhotoData != nil {
                        Button(role: .destructive) {
                            settings.selectedPhotoData = nil
                            settings.photoCenterX = 0.5
                            settings.photoCenterY = 0.5
                        } label: {
                            HStack {
                                Image(systemName: "trash")
                                Text("Remove Photo")
                            }
                        }
                    }

                    Text("Choose a photo to display in the spiral center aperture. The photo will be covered by the filled color as the aperture closes. Cannot be used with mirror view.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Mirror View") {
                    Toggle("On", isOn: Binding(
                        get: { settings.mirrorAlwaysOn },
                        set: { isOn in
                            settings.mirrorAlwaysOn = isOn
                            // Turn off photo when mirror is turned on
                            if isOn && settings.selectedPhotoData != nil {
                                settings.selectedPhotoData = nil
                                settings.photoCenterX = 0.5
                                settings.photoCenterY = 0.5
                            }
                        }
                    ))
                    .disabled(settings.selectedPhotoData != nil)
                    Text("Show camera preview at center of spiral. Cannot be used with photo.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("Center on Face", isOn: $settings.eyeCenteringEnabled)
                        .disabled(settings.selectedPhotoData != nil)
                    Text("Uses AI face detection to keep your face centered in the spiral.")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Toggle("Scale", isOn: Binding(
                        get: { settings.mirrorAnimationMode == 2 },
                        set: {
                            settings.mirrorAnimationMode = $0 ? 2 : 1
                            presetManager.currentPresetId = nil
                        }
                    ))
                    .disabled(settings.selectedPhotoData != nil)
                }

                Section("Photo Capture") {
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
                    Text(settings.captureTimerMinutes > 0
                        ? "A photo will be captured every \(settings.captureTimerMinutes) minute\(settings.captureTimerMinutes == 1 ? "" : "s")."
                        : "Set a timer to periodically capture photos.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Keyboard Shortcuts") {
                    KeyboardShortcutRow(key: "R", description: "Randomize settings")
                    KeyboardShortcutRow(key: "M", description: "Toggle mirror")
                    KeyboardShortcutRow(key: "P", description: "Capture photo")
                    KeyboardShortcutRow(key: "→", description: "Speed up")
                    KeyboardShortcutRow(key: "←", description: "Slow down")
                }

            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("Settings")
            .onAppear {
                phrasesText = settings.phrasesText
            }
            .onDisappear {
                let lines = phrasesText
                    .components(separatedBy: .newlines)
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                let uniqueSorted = Array(Set(lines)).sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending }
                phrasesText = uniqueSorted.joined(separator: "\n")
                settings.phrasesText = phrasesText
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
            .sheet(isPresented: $showingPhotoPickerSheet) {
                PhotoPickerView(settings: settings)
            }
        }
    }
}

struct PresetSelectionView: View {
    @ObservedObject private var settings = SpiralSettings.shared
    @ObservedObject private var presetManager = PresetManager.shared
    @Binding var phrasesText: String
    @Environment(\.dismiss) private var dismiss
    @State private var showingImporter = false
    @State private var showingExporter = false
    @State private var presetToExport: Preset?
    @State private var importError: String?
    @State private var showingImportError = false

    var body: some View {
        List {
            Section {
                Button {
                    showingImporter = true
                } label: {
                    Label("Import Preset", systemImage: "square.and.arrow.down")
                }
            }

            Section("Built-in Presets") {
                ForEach(presetManager.builtInPresets) { preset in
                    presetRow(preset: preset, isBuiltIn: true)
                }
            }

            if !presetManager.userPresets.isEmpty {
                Section("Your Presets") {
                    ForEach(presetManager.userPresets) { preset in
                        presetRow(preset: preset, isBuiltIn: false)
                    }
                }
            }
        }
        .navigationTitle("Select Preset")
        .navigationBarTitleDisplayMode(.inline)
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.xml],
            allowsMultipleSelection: false
        ) { result in
            handleImport(result)
        }
        .fileExporter(
            isPresented: $showingExporter,
            document: presetToExport.map { PresetDocument(preset: $0) },
            contentType: .xml,
            defaultFilename: presetToExport.map { "\($0.name).xml" }
        ) { result in
            if case .failure(let error) = result {
                importError = error.localizedDescription
                showingImportError = true
            }
        }
        .alert("Import Error", isPresented: $showingImportError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(importError ?? "Failed to import preset")
        }
    }

    @ViewBuilder
    private func presetRow(preset: Preset, isBuiltIn: Bool) -> some View {
        Button {
            presetManager.applyPreset(preset)
            phrasesText = settings.phrasesText
            dismiss()
        } label: {
            HStack {
                Label(preset.name, systemImage: isBuiltIn ? "star.fill" : "person")
                    .foregroundColor(.primary)
                Spacer()
                if presetManager.currentPresetId == preset.id {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                presetToExport = preset
                showingExporter = true
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            .tint(.blue)
        }
        .swipeActions(edge: .trailing) {
            if !isBuiltIn {
                Button(role: .destructive) {
                    presetManager.deletePreset(preset)
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }

    private func handleImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            guard url.startAccessingSecurityScopedResource() else {
                importError = "Unable to access file"
                showingImportError = true
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }

            do {
                let xmlString = try String(contentsOf: url, encoding: .utf8)
                if let preset = presetManager.importPreset(from: xmlString) {
                    presetManager.applyPreset(preset)
                    phrasesText = settings.phrasesText
                    dismiss()
                } else {
                    importError = "Invalid preset file format"
                    showingImportError = true
                }
            } catch {
                importError = error.localizedDescription
                showingImportError = true
            }
        case .failure(let error):
            importError = error.localizedDescription
            showingImportError = true
        }
    }
}

struct KeyboardShortcutRow: View {
    let key: String
    let description: String

    var body: some View {
        HStack {
            Text(key)
                .font(.system(.body, design: .monospaced))
                .fontWeight(.semibold)
                .foregroundColor(.yellow)
                .frame(width: 36, height: 28)
                .background(Color.secondary.opacity(0.2))
                .cornerRadius(6)
            Text(description)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
