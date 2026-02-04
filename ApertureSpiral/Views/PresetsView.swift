import SwiftUI
import Combine
import UniformTypeIdentifiers

struct Preset: Codable, Identifiable {
    let id: UUID
    var name: String
    var bladeCount: Int
    var layerCount: Int
    var speed: Double
    var apertureSize: Double
    var phrases: [String]
    var phraseDisplayDuration: Double
    var previewOnly: Bool
    var colorFlowSpeed: Double
    var mirrorAlwaysOn: Bool
    var mirrorAnimationMode: Int
    var eyeCenteringEnabled: Bool
    var freezeWhenNoFace: Bool
    var freezeWhenNotLooking: Bool
    var colorPaletteId: String
    var colorByBlade: Bool
    var lensFlareEnabled: Bool

    init(id: UUID = UUID(), name: String, bladeCount: Int, layerCount: Int, speed: Double, apertureSize: Double, phrases: [String], phraseDisplayDuration: Double = 2.0, previewOnly: Bool = false, colorFlowSpeed: Double = 0.5, mirrorAlwaysOn: Bool = false, mirrorAnimationMode: Int = 2, eyeCenteringEnabled: Bool = true, freezeWhenNoFace: Bool = false, freezeWhenNotLooking: Bool = false, colorPaletteId: String = "warm", colorByBlade: Bool = false, lensFlareEnabled: Bool = true) {
        self.id = id
        self.name = name
        self.bladeCount = bladeCount
        self.layerCount = layerCount
        self.speed = speed
        self.apertureSize = apertureSize
        self.phrases = phrases
        self.phraseDisplayDuration = phraseDisplayDuration
        self.previewOnly = previewOnly
        self.colorFlowSpeed = colorFlowSpeed
        self.mirrorAlwaysOn = mirrorAlwaysOn
        self.mirrorAnimationMode = mirrorAnimationMode
        self.eyeCenteringEnabled = eyeCenteringEnabled
        self.freezeWhenNoFace = freezeWhenNoFace
        self.freezeWhenNotLooking = freezeWhenNotLooking
        self.colorPaletteId = colorPaletteId
        self.colorByBlade = colorByBlade
        self.lensFlareEnabled = lensFlareEnabled
    }

    /// Checks if this preset's settings match the given values
    func matchesSettings(bladeCount: Int, layerCount: Int, speed: Double, apertureSize: Double, phrases: [String], phraseDisplayDuration: Double, previewOnly: Bool, colorFlowSpeed: Double, mirrorAlwaysOn: Bool, mirrorAnimationMode: Int, eyeCenteringEnabled: Bool, freezeWhenNoFace: Bool, freezeWhenNotLooking: Bool, colorPaletteId: String, colorByBlade: Bool, lensFlareEnabled: Bool) -> Bool {
        return self.bladeCount == bladeCount &&
               self.layerCount == layerCount &&
               abs(self.speed - speed) < 0.01 &&
               abs(self.apertureSize - apertureSize) < 0.01 &&
               self.phrases == phrases &&
               abs(self.phraseDisplayDuration - phraseDisplayDuration) < 0.01 &&
               self.previewOnly == previewOnly &&
               abs(self.colorFlowSpeed - colorFlowSpeed) < 0.01 &&
               self.mirrorAlwaysOn == mirrorAlwaysOn &&
               self.mirrorAnimationMode == mirrorAnimationMode &&
               self.eyeCenteringEnabled == eyeCenteringEnabled &&
               self.freezeWhenNoFace == freezeWhenNoFace &&
               self.freezeWhenNotLooking == freezeWhenNotLooking &&
               self.colorPaletteId == colorPaletteId &&
               self.colorByBlade == colorByBlade &&
               self.lensFlareEnabled == lensFlareEnabled
    }

    /// Converts the preset to XML format
    func toXML() -> String {
        var xml = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        xml += "<preset>\n"
        xml += "  <id>\(id.uuidString)</id>\n"
        xml += "  <name>\(escapeXML(name))</name>\n"
        xml += "  <bladeCount>\(bladeCount)</bladeCount>\n"
        xml += "  <layerCount>\(layerCount)</layerCount>\n"
        xml += "  <speed>\(speed)</speed>\n"
        xml += "  <apertureSize>\(apertureSize)</apertureSize>\n"
        xml += "  <phrases>\n"
        for phrase in phrases {
            xml += "    <phrase>\(escapeXML(phrase))</phrase>\n"
        }
        xml += "  </phrases>\n"
        xml += "  <phraseDisplayDuration>\(phraseDisplayDuration)</phraseDisplayDuration>\n"
        xml += "  <previewOnly>\(previewOnly)</previewOnly>\n"
        xml += "  <colorFlowSpeed>\(colorFlowSpeed)</colorFlowSpeed>\n"
        xml += "  <mirrorAlwaysOn>\(mirrorAlwaysOn)</mirrorAlwaysOn>\n"
        xml += "  <mirrorAnimationMode>\(mirrorAnimationMode)</mirrorAnimationMode>\n"
        xml += "  <eyeCenteringEnabled>\(eyeCenteringEnabled)</eyeCenteringEnabled>\n"
        xml += "  <freezeWhenNoFace>\(freezeWhenNoFace)</freezeWhenNoFace>\n"
        xml += "  <freezeWhenNotLooking>\(freezeWhenNotLooking)</freezeWhenNotLooking>\n"
        xml += "  <colorPaletteId>\(escapeXML(colorPaletteId))</colorPaletteId>\n"
        xml += "  <colorByBlade>\(colorByBlade)</colorByBlade>\n"
        xml += "  <lensFlareEnabled>\(lensFlareEnabled)</lensFlareEnabled>\n"
        xml += "</preset>"
        return xml
    }

    private func escapeXML(_ string: String) -> String {
        string
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }

    /// Creates a preset from XML data
    static func fromXML(_ xmlString: String) -> Preset? {
        let parser = PresetXMLParser(xmlString: xmlString)
        return parser.parse()
    }
}

/// XML Parser for Preset data
private class PresetXMLParser: NSObject, XMLParserDelegate {
    private let xmlString: String
    private var currentElement = ""
    private var currentValue = ""

    private var id: UUID?
    private var name: String?
    private var bladeCount: Int?
    private var layerCount: Int?
    private var speed: Double?
    private var apertureSize: Double?
    private var phrases: [String] = []
    private var phraseDisplayDuration: Double = 2.0
    private var previewOnly: Bool = false
    private var colorFlowSpeed: Double = 0.5
    private var mirrorAlwaysOn: Bool = false
    private var mirrorAnimationMode: Int = 2
    private var eyeCenteringEnabled: Bool = true
    private var freezeWhenNoFace: Bool = false
    private var freezeWhenNotLooking: Bool = false
    private var colorPaletteId: String = "warm"
    private var colorByBlade: Bool = false
    private var lensFlareEnabled: Bool = true

    private var inPhrases = false

    init(xmlString: String) {
        self.xmlString = xmlString
    }

    func parse() -> Preset? {
        guard let data = xmlString.data(using: .utf8) else { return nil }
        let parser = XMLParser(data: data)
        parser.delegate = self
        guard parser.parse(),
              let name = name,
              let bladeCount = bladeCount,
              let layerCount = layerCount,
              let speed = speed,
              let apertureSize = apertureSize else {
            return nil
        }
        return Preset(
            id: id ?? UUID(),
            name: name,
            bladeCount: bladeCount,
            layerCount: layerCount,
            speed: speed,
            apertureSize: apertureSize,
            phrases: phrases.isEmpty ? [""] : phrases,
            phraseDisplayDuration: phraseDisplayDuration,
            previewOnly: previewOnly,
            colorFlowSpeed: colorFlowSpeed,
            mirrorAlwaysOn: mirrorAlwaysOn,
            mirrorAnimationMode: mirrorAnimationMode == 0 ? 1 : mirrorAnimationMode,
            eyeCenteringEnabled: eyeCenteringEnabled,
            freezeWhenNoFace: freezeWhenNoFace,
            freezeWhenNotLooking: freezeWhenNotLooking,
            colorPaletteId: colorPaletteId,
            colorByBlade: colorByBlade,
            lensFlareEnabled: lensFlareEnabled
        )
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
        currentValue = ""
        if elementName == "phrases" {
            inPhrases = true
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentValue += string
    }

    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        let value = currentValue.trimmingCharacters(in: .whitespacesAndNewlines)

        switch elementName {
        case "id":
            id = UUID(uuidString: value)
        case "name":
            name = value
        case "bladeCount":
            bladeCount = Int(value)
        case "layerCount":
            layerCount = Int(value)
        case "speed":
            speed = Double(value)
        case "apertureSize":
            apertureSize = Double(value)
        case "phrase":
            if inPhrases && !value.isEmpty {
                phrases.append(value)
            }
        case "phrases":
            inPhrases = false
        case "phraseDisplayDuration":
            phraseDisplayDuration = Double(value) ?? 2.0
        case "captureTimerMinutes":
            // Ignore for backwards compatibility with old preset files
            break
        case "previewOnly":
            previewOnly = value.lowercased() == "true"
        case "colorFlowSpeed":
            colorFlowSpeed = Double(value) ?? 0.5
        case "mirrorAlwaysOn":
            mirrorAlwaysOn = value.lowercased() == "true"
        case "mirrorAnimationMode":
            mirrorAnimationMode = Int(value) ?? 2
        case "eyeCenteringEnabled":
            eyeCenteringEnabled = value.lowercased() == "true"
        case "freezeWhenNoFace":
            freezeWhenNoFace = value.lowercased() == "true"
        case "freezeWhenNotLooking":
            freezeWhenNotLooking = value.lowercased() == "true"
        case "colorPaletteId":
            colorPaletteId = value.isEmpty ? "warm" : value
        case "colorByBlade":
            colorByBlade = value.lowercased() == "true"
        case "lensFlareEnabled":
            lensFlareEnabled = value.lowercased() == "true"
        default:
            break
        }
    }
}

/// Document type for preset XML files
struct PresetDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.xml] }

    var preset: Preset

    init(preset: Preset) {
        self.preset = preset
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let xmlString = String(data: data, encoding: .utf8),
              let preset = Preset.fromXML(xmlString) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.preset = preset
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let xml = preset.toXML()
        guard let data = xml.data(using: .utf8) else {
            throw CocoaError(.fileWriteUnknown)
        }
        return FileWrapper(regularFileWithContents: data)
    }
}

class PresetManager: ObservableObject {
    static let shared = PresetManager()

    @Published var userPresets: [Preset] = []
    @Published var currentPresetId: UUID?

    let builtInPresets: [Preset] = [
        Preset(name: "Birthday", bladeCount: 9, layerCount: 5, speed: 1.0, apertureSize: 0.5, phrases: ["Happy", "Birthday", "We Love You"], phraseDisplayDuration: 2.0, previewOnly: false, colorFlowSpeed: 1.0, mirrorAlwaysOn: true, mirrorAnimationMode: 2, eyeCenteringEnabled: true, freezeWhenNoFace: false, freezeWhenNotLooking: false, colorPaletteId: "warm", colorByBlade: false, lensFlareEnabled: true),
        Preset(name: "Calm", bladeCount: 6, layerCount: 3, speed: 0.5, apertureSize: 0.7, phrases: ["Breathe", "Relax", "Peace"], phraseDisplayDuration: 3.0, previewOnly: false, colorFlowSpeed: 0.3, mirrorAlwaysOn: false, mirrorAnimationMode: 2, eyeCenteringEnabled: true, freezeWhenNoFace: true, freezeWhenNotLooking: true, colorPaletteId: "cool", colorByBlade: false, lensFlareEnabled: false),
        Preset(name: "Intense", bladeCount: 16, layerCount: 8, speed: 2.5, apertureSize: 0.3, phrases: ["WOW", "AMAZING", "YES"], phraseDisplayDuration: 1.0, previewOnly: false, colorFlowSpeed: 2.0, mirrorAlwaysOn: true, mirrorAnimationMode: 2, eyeCenteringEnabled: true, freezeWhenNoFace: false, freezeWhenNotLooking: false, colorPaletteId: "neon", colorByBlade: true, lensFlareEnabled: true),
        Preset(name: "Trippy", bladeCount: 12, layerCount: 6, speed: 1.5, apertureSize: 0.4, phrases: ["Whoa", "Dude", "Vibrate", "What's Happening?", "Drift"], phraseDisplayDuration: 2.5, previewOnly: false, colorFlowSpeed: 0.8, mirrorAlwaysOn: true, mirrorAnimationMode: 1, eyeCenteringEnabled: true, freezeWhenNoFace: false, freezeWhenNotLooking: false, colorPaletteId: "earth", colorByBlade: true, lensFlareEnabled: true),
    ]

    var allPresets: [Preset] {
        builtInPresets + userPresets
    }

    private let userPresetsKey = "userPresets"
    private let userDefaults: UserDefaults
    private let settings: SpiralSettings

    private init() {
        self.userDefaults = .standard
        self.settings = SpiralSettings.shared
        loadUserPresets()
        detectCurrentPreset()
    }

    /// Creates an instance for testing purposes with custom UserDefaults and settings
    init(forTesting userDefaults: UserDefaults, settings: SpiralSettings) {
        self.userDefaults = userDefaults
        self.settings = settings
        loadUserPresets()
        detectCurrentPreset()
    }

    /// Backwards-compatible testing initializer that only accepts UserDefaults
    convenience init(forTesting userDefaults: UserDefaults) {
        self.init(forTesting: userDefaults, settings: SpiralSettings(forTesting: userDefaults))
    }

    /// Resets user presets (for testing)
    func reset() {
        userPresets = []
        currentPresetId = nil
        userDefaults.removeObject(forKey: userPresetsKey)
    }

    func saveCurrentAsPreset(name: String) {
        let s = self.settings
        let preset = Preset(
            name: name,
            bladeCount: s.bladeCount,
            layerCount: s.layerCount,
            speed: s.speed,
            apertureSize: s.apertureSize,
            phrases: s.phrases,
            phraseDisplayDuration: s.phraseDisplayDuration,
            previewOnly: s.previewOnly,
            colorFlowSpeed: s.colorFlowSpeed,
            mirrorAlwaysOn: s.mirrorAlwaysOn,
            mirrorAnimationMode: (s.mirrorAnimationMode == 0 ? 1 : s.mirrorAnimationMode),
            eyeCenteringEnabled: s.eyeCenteringEnabled,
            freezeWhenNoFace: s.freezeWhenNoFace,
            freezeWhenNotLooking: s.freezeWhenNotLooking,
            colorPaletteId: s.colorPaletteId,
            colorByBlade: s.colorByBlade,
            lensFlareEnabled: s.lensFlareEnabled
        )
        // Snapshot the new preset list so encoding/saving can occur off the main thread.
        let snapshot = userPresets + [preset]

        // Update published state on main thread immediately so UI shows change.
        DispatchQueue.main.async {
            self.userPresets.append(preset)
            self.currentPresetId = preset.id
        }

        // Encode and persist on a background queue to avoid blocking UI taps.
        DispatchQueue.global(qos: .userInitiated).async {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            self.userDefaults.set(data, forKey: self.userPresetsKey)
        }
    }

    func applyPreset(_ preset: Preset) {
        // Use the batched apply on the settings instance to avoid multiple UserDefaults writes
        settings.applyPreset(preset)
        currentPresetId = preset.id
    }

    func deletePreset(_ preset: Preset) {
        userPresets.removeAll { $0.id == preset.id }
        saveUserPresets()
        if currentPresetId == preset.id {
            currentPresetId = nil
        }
    }

    /// Imports a preset from XML data and adds it to user presets
    func importPreset(from xmlString: String) -> Preset? {
        guard var preset = Preset.fromXML(xmlString) else { return nil }
        // Generate new ID to avoid conflicts with existing presets
        preset = Preset(
            id: UUID(),
            name: preset.name,
            bladeCount: preset.bladeCount,
            layerCount: preset.layerCount,
            speed: preset.speed,
            apertureSize: preset.apertureSize,
            phrases: preset.phrases,
            phraseDisplayDuration: preset.phraseDisplayDuration,
            previewOnly: preset.previewOnly,
            colorFlowSpeed: preset.colorFlowSpeed,
            mirrorAlwaysOn: preset.mirrorAlwaysOn,
            mirrorAnimationMode: preset.mirrorAnimationMode,
            eyeCenteringEnabled: preset.eyeCenteringEnabled,
            freezeWhenNoFace: preset.freezeWhenNoFace,
            freezeWhenNotLooking: preset.freezeWhenNotLooking,
            colorPaletteId: preset.colorPaletteId,
            colorByBlade: preset.colorByBlade,
            lensFlareEnabled: preset.lensFlareEnabled
        )
        userPresets.append(preset)
        saveUserPresets()
        return preset
    }

    /// Creates a temporary file URL for exporting a preset
    func exportPresetURL(_ preset: Preset) -> URL? {
        let xml = preset.toXML()
        let fileName = "\(preset.name.replacingOccurrences(of: " ", with: "_")).xml"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        do {
            try xml.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            return nil
        }
    }

    private func loadUserPresets() {
        guard let data = userDefaults.data(forKey: userPresetsKey),
              let presets = try? JSONDecoder().decode([Preset].self, from: data) else {
            return
        }
        // Normalize any legacy mirrorAnimationMode == 0 values to 1 (zoom-only)
        let sanitized = presets.map { (p: Preset) -> Preset in
            var p = p
            if p.mirrorAnimationMode == 0 { p.mirrorAnimationMode = 1 }
            return p
        }
        userPresets = sanitized
        // Persist sanitized presets back to storage
        saveUserPresets()
    }

    private func saveUserPresets() {
        // Persist using a background queue to avoid UI jank during encodes.
        let snapshot = userPresets
        DispatchQueue.global(qos: .utility).async {
            guard let data = try? JSONEncoder().encode(snapshot) else { return }
            self.userDefaults.set(data, forKey: self.userPresetsKey)
        }
    }

    /// Detects if current settings match any preset and sets currentPresetId accordingly
    func detectCurrentPreset() {
        let s = settings
        for preset in allPresets {
            if preset.matchesSettings(
                bladeCount: s.bladeCount,
                layerCount: s.layerCount,
                speed: s.speed,
                apertureSize: s.apertureSize,
                phrases: s.phrases,
                phraseDisplayDuration: s.phraseDisplayDuration,
                previewOnly: s.previewOnly,
                colorFlowSpeed: s.colorFlowSpeed,
                mirrorAlwaysOn: s.mirrorAlwaysOn,
                mirrorAnimationMode: s.mirrorAnimationMode,
                eyeCenteringEnabled: s.eyeCenteringEnabled,
                freezeWhenNoFace: s.freezeWhenNoFace,
                freezeWhenNotLooking: s.freezeWhenNotLooking,
                colorPaletteId: s.colorPaletteId,
                colorByBlade: s.colorByBlade,
                lensFlareEnabled: s.lensFlareEnabled
            ) {
                currentPresetId = preset.id
                return
            }
        }
        currentPresetId = nil
    }
}
